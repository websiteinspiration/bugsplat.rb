---
title: Building a Private Backhaul Network for your VPSs with ZeroTier
id: zt
tags: Networking
topic: Networking
description: See how I built a private network that ties together my VPSs and my laptop.
show_upsell: true
---

Almost all of my applications, both public and personal, run on a collection of virtual private servers (VPSs) hosted in various places including DigitalOcean and my own data center (i.e. the Mac mini in my basement). For a long time I've wanted to set up certain things, like centralized logging or metrics collection, but I've always been stopped by this idea that I can't run that stuff across the public network.

A few months ago I ran across a product named [ZeroTier](https://www.zerotier.com) that, among other things, allowed me to set up this network without having to invest the time in attempting to build (or purchase) a traditional VPN. This post is going to talk about why, and how, you can replicate this setup.

--fold--

## What's a Backhaul Network?

A backhaul network is a separate, private network interface that you can use to send privileged traffic between hosts within your network. Sometimes this is called dual-homing. You can use this backhaul network for anything you don't want to send over the public network. For example, monitoring or log streams, database servers, or internal admin dashboards. I personally use mine for all of the above.

Managing this kind of thing if you control your hardware and physical network is easy. You just put everything into appropriate VLANs and DMZs and make sure your router knows what to do. However, if you *don't* control your physical installation because your hosts are spread across providers, cities, or continents, it becomes a lot harder. Basically your options are to set up a VPN or try to send traffic over SSH tunnels.

ZeroTier is sort of like a VPN, in that it sets up an encrypted overlay network on top of the public network. The twist is that, instead of having a central control point like in a traditional VPN, ZT goes to great lengths to send as much as your traffic as possible point-to-point between hosts. It has extensive NAT-busting capabilities to let hosts on home networks participate.

## Setting up ZeroTier

There are two steps to setting up your network. First, you sign up for a free account on ZeroTier's website. The free account lets you create as many networks as you want with up to 10 hosts per network. You can opt to pay for your account which enables unlimited hosts per network.

Once you've signed up and logged in, you'll see a box that says `(network name)` next to a `Create Network` button. Put a name in and hit the button. This name does not have to be unique, it's strictly for your use. Make a note of the new network's Network ID.

Next, you'll need to install the ZeroTier client on your machines. Ideally it would be packaged and installed via the official distribution systems like yum and apt, but ZeroTier isn't quite there yet. Instead, there's a downloadable installer for each platform. On Linux installer is a shell script containing an embedded binary, so all you have to do is download it and run it. For OS X they provide a normal DMG containing a normal Mac application.

Once you have ZT running on a host, you can see it's automatically generated host ID like this:

```bash
$ sudo zerotier-cli info
200 info <your host id> ONLINE 0.9.2
```

Finally, each host needs to join your network. On linux and OS X you can do this via the command line, like this:

```bash
$ sudo zerotier-cli join <your network id>
```

Go back to the web interface. Within a few seconds you'll see your host ID listed, along with an unchecked checkbox in the `Authorize` column. Check the box, and soon your host will get a new IP address.

Repeat these steps for every host you want to join this network. In my personal setup I made a simple puppet module that installs the client and attempts to join my network. I just have to verify the new host's ID and check the authorize checkbox.

## Set up DNS (optional)

One last step you may want to do is set up DNS records for your backhaul network so you don't have to try to remember IP addresses. Putting private IPs in the public DNS isn't really a problem because your hosts are the only ones who will actually be able to connect to each other, but if you want to really lock things down you could run your own private DNS server for your backhaul network.

----

So far I'm just using this backhaul network for SSH and database access. Soon I plan on setting up additional services and moving more stuff over to Docker containers, and having this private network will let me be a lot more flexible with how I set things up.

That said, ZeroTier is capable of a *lot* more than just being a VPN alternative. Especially with mobile devices, it has the ability to dramatically change how peer-to-peer apps are architected.