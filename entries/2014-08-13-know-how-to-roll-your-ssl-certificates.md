---
title: Know How To Roll (Your SSL Certificates)
id: roll
tags: Devops
topic: Software
description: Learn how to keep your SSL certificates up to date and valid.
show_upsell: true
---

A few weeks ago [Stripe's SSL certificate became invalid](https://twitter.com/stripestatus/status/493137783595073537), along with several other major sites. *Their* certificate didn't expire, their certificate authority's root certificate did. This shouldn't happen, but as with most terrible things it crops up at rather inconvenient times.

There's not much you can do to protect yourself against a service provider's certificate expiring, but you *can* proactively protect yourself against your own certificate expiring. The biggest thing to do is have a schedule and a process.

## Schedule

This is easy. Just make a monthly recurring entry in your calendar that says "Check SSL certificates". When that calendar entry comes up, go to your website and check your certificate by clicking on the lock icon. The things you're checking for:

1. Is the lock icon still showing up how it should? If you have an EV certificate you should see your company name in the title bar. If you have a normal certificate you'll see either a green lock in Firefox or Chrome or a grey "https" in Safari.

2. Is the expiration date coming up? You should proactively roll your certificates at least a day before they're due to expire.

## Process

The process you use to roll certificates is somewhat dependent on your infrastructure, but the general ideas stay the same:

* Know how to generate a new private key
* Know how to generate a new CSR from that key
* Know how to renew your certificate with your provider using that CSR
* Know how to install your new certificate

Note that you should use a new private key every time because there may have been a private key compromise you don't know about. See [SSL Labs's SSL/TLS Deployment Best Practices](https://www.ssllabs.com/downloads/SSL_TLS_Deployment_Best_Practices_1.3.pdf) (pdf) for more details.

If you use Heroku and all of this seems like too much bother, you should check out the [ExpeditedSSL addon](https://www.expeditedssl.com). They'll automate all of these steps away and make sure you're protected.

I run all of my sites on VPSs, so I have the privilege of managing everything myself. I put together a `Rakefile` that manages the hard-to-remember steps for me. It lives in private source control along with my keys and certs, but here's what it looks like today:

```ruby
desc "Generate a new key"
task :gen_key do
  domain = get_env(:domain)
  filename = "#{domain}.key"

  `openssl genrsa -out #{filename} 2048`
end

desc "Generate a new CSR"
task :gen_csr => :gen_key do
  domain = get_env(:domain)
  csr_filename = "#{domain}.csr"
  key_filename = "#{domain}.key"

  `openssl req -new -utf8 -sha256 -key #{key_filename} -out #{csr_filename}`
  `cat #{csr_filename} | pbcopy`
end

desc "Generate a proper nginx cert file from Namecheap Comodo certificate download"
task :assemble_cert do
  cert_dir = get_env(:cert_dir)
  domain = get_env(:domain)
  pem_path = "#{domain}.crt"

  File.open(pem_path, 'w+') do |pem_file|
    add_file_to_cert pem_file, domain.gsub(/\./, '_') + '.crt'
    add_file_to_cert pem_file, 'COMODORSADomainValidationSecureServerCA.crt'
    add_file_to_cert pem_file, 'COMODORSAAddTrustCA.crt'
    add_file_to_cert pem_file, 'AddTrustExternalCARoot.crt'
  end

  puts "Wrote pem to #{pem_path}"
end

def add_file_to_cert(pem_file, filename)
  cert_dir = get_env(:cert_dir)
  full_path = File.join(cert_dir, filename)
  puts "Adding #{full_path} to pem"
  pem_file.write(File.read(full_path))
end

def get_env(name)
  val = ENV[name.to_s]
  raise "Required env variable missing: #{name}" unless val && val != ''
  val
end
```

It's really simple. All you do is feed it the fully-qualified domain name and it spits out a key and a CSR. It'll re-use an existing key if there is one to use. It's even nice enough to copy the CSR into your clipboard so you can just paste it into your provider's website.

Installing certificates is where it becomes infrastructure-dependent. Heroku has a nice guide, as does Amazon. If you're using Nginx, you'll need to generate a PEM file from your certificate and any intermediary certificates that it requires. The `Rakefile` above contains a task named `assmeble_cert` that will build a PEM file suitable for Nginx.

**Very Important Note**: Make sure to change the `assemble_cert` task to reflect the order that your certificate needs to get put together. This script generates correct files for Comodo certificates issued by Namecheap, but there's no guarantee that this is the order for any other certificate provider.

Fill out the form below to learn how to build a better Stripe integration, including a complete chapter on PCI security and SSL certificate generation.

