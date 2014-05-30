---
title: Start a VirtualBox VM at Boot on Mac OS X
id: vbboot
topic: Software
description: Sometimes you have a VirtualBox VM that's critical to your workflow. Start it at system boot with launchd.
---

Sometimes you have a VirtualBox VM that's critical to your workflow. For example, the Mac mini in my basement hosts a VM that does things like host all of my private Git repos and provide a staging environment for all of my wacky ideas.

When I have to reboot that Mac mini for any reason, inevitably I find myself trying to push changes to some git repo and forgetting that I have to start up the VM again by hand. And then there's the yelling and the drinking and it's no good for anyone.

It turns out you can actually run VirtualBox VMs in a few different ways, including from the command line. Assuming you have a VM named `examplevm`, this command will start it up in the background:

```bash
$ VBoxManage startvm examplevm
```

Starting up in the background isn't quite right for how this will eventually be set up, so what about running in the foreground? Turns out VirtualBox has us covered:

```bash
$ VBoxHeadless -s examplevm
```

This will start the VM up in the foreground without any visible UI. Now all we need little launchd configuration for it (in `~/Library/LaunchAgents/bugsplat.examplevm.plist`):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>KeepAlive</key>
    <true/>
    <key>Label</key>
    <string>bugsplat.examplevm</string>
    <key>ProgramArguments</key>
    <array>
      <string>VBoxHeadless</string>
      <string>-s</string>
      <string>examplevm</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>UserName</key>
    <string>peter</string>
    <key>WorkingDirectory</key>
    <string>/Users/peter</string>
    <key>StandardErrorPath</key>
    <string>/usr/local/var/log/examplevm.log</string>
    <key>StandardOutPath</key>
    <string>/usr/local/var/log/examplevm.log</string>
  </dict>
</plist>
```

There are a few important things to note about this configuration. First, notice how the ProgramArguments list is broken out. If you were to take the `VBoxHeadless` command from before, split it on spaces, and then each space gets it's own `<string>` element. *sigh* XML.

Second important thing is the `WorkingDirectory` key. It turns out VBoxHeadless is not very smart about where it looks for VMs. This has to be pointing at your home directory.

Third, the `StandardErrorPath` and `StandardOutPath` keys. The directory *has* to exist or launchd will just silently fail.

To get this thing running for the first time, just run this:

```bash
$ launchctl load -wF ~/Library/LaunchAgents/bugsplat.examplevm.plist
```

## One more thing...

The VM that I'm using this for is running Ubuntu 12.04 LTS, which has a really annoying feature. If it knows that it crashed (or the "power" was "cut", for example if I just kill the VBoxHeadless process) the GRUB boot loader has no timeout on the select screen, and the select screen is written as a tight busy loop that will consume an entire CPU core just waiting for input that will never come because it's running headless<sup><a href="#fn1" id="fn1-ref">1</a></sup>.

To fix this, you'll need to add a line to `/etc/default/grub` inside the VM:

```
GRUB_RECORDFAIL_TIMEOUT=2
```

and then run:

```bash
$ sudo update-grub
```

This gives you a two second window in which to select memtest or a recovery partition if you want, but it will still boot to the normal image eventually.

---

<p class="small" id="fn1">
<sup>1</sup> I seriously spent days banging my head against the wall thinking this was a VirtualBox bug or that something was corrupting my VMs when I killed VBoxHeadless. The thing that threw me off was the pegged CPU. It never would have occured to me that GRUB uses a tight busy loop waiting for input. <a href="#fn1-ref">&#8617;</a>
</p>
