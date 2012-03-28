---
layout: post
title: "Installing Gentoo on a Macbook Pro, Part 3"
date: 2012-03-27 17:33
comments: true
categories: 
---
Since last time I've made steady progress on various fronts.

## WiFi

I actually spent quite a bit of time fiddling with wifi to get it working, when in reality it was quite simple. I am now running linux 3.3, so support for the BCM4331 chip is included by default in the linux kernel. Firmware has to be downloaded and installed, but fortunately the instructions at the [b43 driver page](http://linuxwireless.org/en/users/Drivers/b43#Device_firmware_installation) work perfectly. The one catch is that in addition to the CONFIG\_B43 and CONFIG\_B43\_PHY\_HT kernel options to actually enable the drivers, CONFIG\_BCMA is required as well.

After this, wifi worked great, although 802.11n support does not yet exist. I installed wicd and everything worked fine. Initially I was running into issues with wicd asking for a password each time I logged into KDE, but adding wicd to the default runlevel fixed that, and now my computer will automatically connect to wifi networks on startup (assuming of course there is no ethernet connection and there is an unsecured or previously configured wireless network nearby).

## Annoying Startup Chime

Thusfar, every time I boot or reboot (quite often when testing kernel things!) my laptop has made the infamous startup chime. Apparently the only way to turn this off is to boot into OS X and set the volume to 0. Fortunately, I had my untouched OS X install on the original hard drive, and it is possible to boot from an external hard drive via USB. So I was able to boot into OS X once just to mute the volume. I actually went through all the initial setup steps, maybe I didn't even need to go that far, and just lower the volume immediately.

## FaceTime Camera

I didn't see much use even enabling support for the built in camera until I learned there is a google chat plugin that allows you to do video chatting over gmail. With minimal work I was able to get everything running quickly.

The [webcam](http://linuxwireless.org/en/users/Drivers/b43#Device_firmware_installation) section of the Macbook Pro Gentoo wiki page instructions were all I had to follow. A few steps there are apparently redundant for the newer models, here's what I did:

1.) Enable kernel support. The only option required is CONFIG\_USB\_VIDEO\_CLASS. I built it as a module.

2.) Unmask and install _media-video/isight-firmware-tools_. I unmasked version 1.6.

3.) Extract the firmware file. This requires the firmware file from Mac OS X itself. Fortunately I have my original OS X installation on an external hard drive. I had to build the HFS and HFS+ kernel modules, but I was able to easily grab this file. It can be found at

    System/Library/Extensions/IOUSBFamily.kext/Contents/PlugIns/AppleUSBVideoSupport.kext/Contents/MacOS/AppleUSBVideoSupport

Then it's a simple task to extract the relevant firmware

    ift-extract --apple-driver AppleUSBVideoSupport

4.) It's possible to immediately test if everything is working via mplayer. I first had to enable the v4l and v4l2 use flags and recompile, but once done the webcam should display with the following command:

    mplayer tv:// -tv driver=v4l2:width=640:height=480:device=/dev/video0 -fps 20 -vo x11

I didn't have to setup any dbus rules to create any device nodes.

5.) Finally, simply unmasking and installing _www-plugins/google-talkplugin_ allowed me to video chat via gmail in Firefox.

## Intel Graphics

I haven't made any functional modifications since last time, booting still works fine using simple patches that allow setting the number of lvms channels manually. However I spent some time digging into the actual development work being done here. First I found the [intel-gfx](http://lists.freedesktop.org/archives/intel-gfx/) mailing list while browsing the [mailing lists](http://lists.freedesktop.org/mailman/listinfo) on [freedesktop.org](http://freedesktop.org). I came across a [bug report](https://bugzilla.kernel.org/show_bug.cgi?id=42842) with a cleaner set of patches. It turns out that even with enhanced lvms channel detection, the Macbook Pro still doesn't behave, so it was added to a quirks table as a workaround. It looks like these changes will likely make it into the 3.5 kernel, which is a ways out, but at least progress is being made. Hopefully in the next couple days I will rework my branch of kernel patches to include these much nicer patches.

## Todo

So far the laptop is working quite well and I have successfully been able to use it as a laptop is meant to be used: by going out and actually using it for real work for extended periods away from home. Battery life is only ok at the moment. However I've gotten to the point where I only have a few things left to get working, even if some of them will be a major project.

* Suspend/hibernate. I've fooled with this a bit but still have to hard-reset the laptop any time it goes to sleep (which unfortunately happens whenever I close the lid currently).

* Graphics switching. I still intend to, eventually at least, be able to switch between the integrated Intel graphics and dedicated AMD graphics at will.

* Backlight adjustment. I tried a patch for this but it still stays pegged at the max. This should be a big helper for battery life.

* Tweak Intel graphics kernel parameters. There are various parameters out there that reportedely improve battery life significantly.
