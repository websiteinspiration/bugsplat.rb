---
title: "Using Let's Encrypt Without certbot"
id: cdn3
tags: Programming
topic: Software
description: "Certbot is a wonderful tool but it doesn't work for my CDN project."
---

In [my last post](/why-a-cdn-anyway) I talked about what a CDN is and why you might want one.
To recap, my goal is automatic, magical DNS/SSL/caching management.
Today we're going to talk about one aspect of this project: HTTPS and SSL.

SSL, or *Secure Sockets Layer*, is the mechanism web browsers use to secure and encrypt the connection between your computer and the server that is serving up the content you're looking for.

A few years ago browser vendors started getting very serious about wanting every website to be encrypted.
At the time, SSL was expensive to implement because you needed to buy or pay to renew certificates at least once a year.

Almost simultaneously with this increased need for encryption, organizations including the Electronic Frontier Foundation and the Mozilla Foundation started a new certificate authority (organization that issues certificates) named Let's Encrypt.
Let's Encrypt is different because it issues certificates for free with an API.

Most people use a tool named `certbot` that automates the process of acquiring certificates for a given website.
However, `certbot` doesn't really work for my purposes.
I want to centrally manage my certificates and copy them out to my CDN nodes on a regular basis, which means I need to use the DNS challenge type.
`certbot`'s support for the DNS challenge isn't really adequate for my needs.

## Challenge Types

Let's Encrypt uses *challenges* to verify that you own the domain that you're trying to acquire a certificate for.
Currently there are two different challenge types, `http-01` and `dns-01`.

For `http-01`, you simply create a file within a well-known directory structure within your website containing a challenge string that the API gives you.
Then you tell Let`s Encrypt to go look for it.
If the file is there and contains the correct challenge string, Let's Encrypt will give you a certificate.

`dns-01` works much the same way, except instead of creating a file you create a `TXT` record for your domain.
Let's Encrypt will ask your domain's DNS servers for the value of the `TXT` record, and if it matches what it expects, you get a certificate.

`http-01` has the advantage of being really simple and easy to use with the `certbot` tool and whatever web server you happen to have.
However, with multiple servers in the mix it can get tricky to make sure that every server has a certificate without hitting Let's Encrypt's rate limits.

That's why I'm using `dns-01`.
I can easily drive the API from the central management node and copy the certificates out to all of the CDN nodes simultaneously.

## How ACME Works

I use a gem called [`acme-client`](https://github.com/unixcharles/acme-client) to drive Let's Encrypt `ACMEv2` API.
Once you know ACME's terminology it's easy to use.

1. An `order` is the initial request to generate a certificate for one or more domain names
2. An `authorization` is LetsEncrypt's response to the `order`. It contains one or more `challenges` for each domain name in the `order`.
3. After setting up the challenges with either `http-01` or `dns-01`, you then `request_validation`. LetsEncrypt tries to verify that you were able to successfully install the challenges.
4. Finally, after LetsEncrypt has seen the validations in the wild, you send a `Certificate Request` (`csr`). LetsEncrypt responds with a properly signed certificate, valid for all of the domain names that you verified and sent with your `csr`.

## Getting a Certificate, End to End

### Step 1: Sign up for an account

The first thing we need to do is sign up for a LetsEncrypt account.
Accounts are identified with a private key and an email address.

```ruby
require 'acme-client'
require 'openssl'

key = OpenSSL::PKey::RSA.new(4096)
client = Acme::Client.new(
  private_key: key, 
  directory: 'https://acme-staging-v02.api.letsencrypt.org/directory'
)

account = client.new_account(
  contact: "mailto:you@example.com}", 
  terms_of_service_agreed: true
)
```

### Step 2: Generate an Order

Next, let's start the process of getting a certificate.
The first thing we do is build an `order` from a set of domain names.

```ruby
order = client.new_order(identifiers: ['example.com']
```

The order contains one authorization per identifier per challenge type.
We only care about the `dns` challenge type.

```ruby
authorization = order.authorizations.first
label         = '_acme-challenge.example.com'
record_type   = authorization.dns.record_type
value         = authorization.dns.record_content
```

### Step 3: Set the value in Route53

I use AWS' Route53 service to host my DNS records [for a variety of reasons](/how-and-why-im-not-running-my-own-dns).
That means we now have to set a record in Route53.

First, we need to set up a client and find the zone we want to update:

```ruby
require 'aws-sdk'
route53 = Aws::Route53::Client.new(region: 'us-east-1')
zone = route53.list_hosted_zones(max_items: 100)
              .hosted_zones
              .detect { |z| z.name = 'example.com.' }
```

Next, we generate an `UPSERT` to create or update the record:

```ruby
change = {
  action: 'UPSERT',
  resource_record_set: {
    name: label,
    type: record_type,
    ttl: 1,
    resource_records: [
      { value: value }
    ]
  }
}

options = {
  hosted_zone_id: zone.id,
  change_batch: {
    changes: [change]
  }
}

route53.change_resource_record_sets(options)
```

### Step 4: Wait for DNS to populate

Route53 takes some time to push your changes out so now we have to wait.
We also have to wait for all of the DNS servers that service the zone to return with the correct value because LetsEncrypt will pick one randomly to ask for the challenge.

Let's write a loop to wait for us.
First we need to get the list of nameservers for the zone:

```ruby
nameservers = []

Resolv::DNS.open(nameserver: '8.8.8.8') do |dns|
  while nameservers.length == 0
    nameservers = dns.getresources(
      'example.com', 
      Resolv::DNS::Resource::IN::NS
    ).map(&:name).map(&:to_s)
  end
end
```

This uses Ruby's built-in DNS resolver library named `Resolv` to ask Google's public DNS server what nameservers are set up for `example.com`.

Next, we have a function that asks those nameservers for the challenge value:

```ruby
def check_dns(nameservers)
  valid = true

  nameservers.each do |nameserver|
    begin
      records = Resolv::DNS.open(nameserver: nameserver) do |dns|
        dns.getresources(
          'example.com', 
          Resolv::DNS::Resource::IN::TXT
        )
      end
      records = records.map(&:strings).flatten
      valid = value == records.first
    rescue Resolv::ResolvError
      return false
    end
    return false if !valid
  end

  valid
end

while !check_dns(nameservers)
  sleep 1
end
```

This again uses Ruby's built-in Resolv library to get a list of values.
In this case we're asking for all of the `TXT` values that we set up with the Route53 upsert earlier.

We loop over each nameserver and ask if the value is what we're looking for.
If it isn't we bail out early because we need all of the nameservers to have the correct value.

### Step 5: Request Validation

Finally, after verifying that DNS has the correct values set, we tell LetsEncrypt to validate our challenges.
If we had just asked for verification immediately after the upsert LetsEncrypt would have failed the order and there's no way to restart it or ask for them to check again.
You get one validation per order and if you fail you have to start all over.

```ruby
authorization.dns.request_validation

while true
  authorization.dns.reload
  if status == 'pending'
    sleep(2)
  else
    break
  end
end
```

### Step 6: Send a CSR and receive the certificate

Finally, after validation completes we can actually request a certificate.

```ruby
cert_key = OpenSSL::PKey::RSA.new(4096)
csr = Acme::Client::CertificateRequest.new(
  private_key: cert_key, 
  names: ['example.com']
)

order.finalize(csr: csr)

sleep(1) while order.status == 'processing'

puts cert_key.to_pem.to_s
puts order.certificate
```

The `acme-client` library comes with a handy `Acme::Client::CertificateRequest` wrapper that takes care of building a CSR exactly how LetsEncrypt wants to see them, so all we have to fill in is the list of domain names we want the certificate to apply to.
After a short wait LetsEncrypt will return the bright shiny new certificate in `order.certificate`.

## Wildcard Wrinkle

The above is great if you want to list out every domain name that you want the certificate to apply to.
LetsEncrypt recently added support for wildcard certificates, though, which are very useful but have one additional wrinkle.

Wildcard certificates apply to all of the subdomains at a single level for a given pattern.
Let's say you want your certificate to apply to these domain names:

```
example.com
www.example.com
mx.example.com
foobar.example.com
blah.foobar.example.com
```

Instead of listing all of these domains in the certificate request you can ask for a wildcard, like this:

```
example.com
*.example.com
```

The wildcard will apply to any subdomain that matches a star.
`mx.example.com` will match but `blah.mx.example.com` will not.

The wrinkle here is that LetsEncrypt will give you two challenges for the same domain name because it wants you to verify both the root and the wildcard.
You can't set easily set multiple TXT records for a given label in Route53, though, so you have to collapse them into one upsert:

```ruby
change = {
  action: 'UPSERT',
  resource_record_set: {
    name: label,
    type: record_type,
    ttl: 1,
    resource_records: [
      { value: value_for_root }
      { value: value_for_wildcard }
    ]
  }
}

options = {
  hosted_zone_id: zone.id,
  change_batch: {
    changes: [change]
  }
}

route53.change_resource_record_sets(options)
```

This seems simple because it is.
That didn't stop it from taking me about four hours to figure out, however :)
