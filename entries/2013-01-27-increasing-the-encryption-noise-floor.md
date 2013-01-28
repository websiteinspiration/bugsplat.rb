Title: Increasing the Encryption Noise Floor
Date:  2013-01-27 18:06:32
Id:    d9b85
Tags:  Programming, Meta

Inspired by Tim Bray's [recent post about encrypting his website][tbray], I decided to enable and force HTTPS for bugsplat.info. The process was straightforward and, turns out, completely free. Read on to find out how and why.

[tbray]: https://www.tbray.org/ongoing/When/201x/2012/12/02/HTTPS

--fold--

### Why?

Because I think the whole web should be encrypted and I figured I should practice what I preach. Bugsplat is primarily static html and is completely public but that doesn't mean I can't increase the encryption noise floor, so to speak. If only the websites with secret datas are encrypted then just using them is suspicious. If every site is encrypted then there's nothing to be suspicious about.

### How?

Bugsplat is deployed to my [RamNode][] VPS (notice: affiliate link) with [Capistrano::Buildpack][], a Capistrano add-on that allows you to deploy applications using [Heroku-style buildpacks][buildpacks]. Recently I added support for simply configuring HTTPS with a few options in your Capfile. Here's the relevent config from bugsplat.info's Capfile:

```ruby
set :use_ssl, true
set :force_ssl, true
set :ssl_cert_path, '/etc/nginx/certs/bugsplat.info.crt'
set :ssl_key_path, '/etc/nginx/certs/bugsplat.info.key'
```

`:use_ssl` enables listening on port 443 with SSL and the two `path` options just tell nginx where to find the keys on the server, which are deployed separately with Puppet. `:force_ssl` adds this small snippet to the exported nginx config file which redirects plain requests to SSL:

```
if ($ssl_protocol = "") {
   rewrite ^https://$server_name$request_uri? permanent;
}
```

As for the certificate, I ended up going with a free certificate from [StartSSL][]. This certificate doesn't necessarily guarantee that I am who I say I am because I just had to validate an email address, but it does guarantee that the connection is encrypted which is really all I care about. At some point I plan on going through the verification steps needed to get Class 2 certificates from StartSSL, but that's for another day.

[RamNode]: https://clientarea.ramnode.com/aff.php?aff=142
[Capistrano::Buildpack]: https://github.com/peterkeen/capistrano-buildpack
[buildpacks]: https://devcenter.heroku.com/articles/buildpacks
[StartSSL]: https://www.startssl.com