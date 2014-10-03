---
layout: post
title: "Installing Gentoo on a Macbook Pro, Part1"
date: 2012-03-14 15:23
comments: true
categories: Gentoo
---

Today I purchased a brand new Macbook Pro from the Apple store in Palo Alto. It's a 15" model with the following specs:

* 2.5GHz Quad-core Intel Core i7 CPU
* 4GB 1333MHz DDR3 RAM
* 750GB SATA HD @ 5400RPM
* Intel HD Graphics 3000
* AMD Radeon HD 6770M with 1GB GDDR5 RAM

dmidecode identifies it as MacBookPro8,2, and the lspci output is as follows

    00:00.0 Host bridge: Intel Corporation 2nd Generation Core Processor Family DRAM Controller (rev 09)
    00:01.0 PCI bridge: Intel Corporation Xeon E3-1200/2nd Generation Core Processor Family PCI Express Root Port (rev 09)
    00:01.1 PCI bridge: Intel Corporation Xeon E3-1200/2nd Generation Core Processor Family PCI Express Root Port (rev 09)
    00:16.0 Communication controller: Intel Corporation 6 Series/C200 Series Chipset Family MEI Controller #1 (rev 04)
    00:1a.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Universal Host Controller #5 (rev 05)
    00:1a.7 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Enhanced Host Controller #2 (rev 05)
    00:1b.0 Audio device: Intel Corporation 6 Series/C200 Series Chipset Family High Definition Audio Controller (rev 05)
    00:1c.0 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 1 (rev b5)
    00:1c.1 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 2 (rev b5)
    00:1c.2 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 3 (rev b5)
    00:1d.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Universal Host Controller #1 (rev 05)
    00:1d.7 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Enhanced Host Controller #1 (rev 05)
    00:1f.0 ISA bridge: Intel Corporation HM65 Express Chipset Family LPC Controller (rev 05)
    00:1f.2 IDE interface: Intel Corporation 6 Series/C200 Series Chipset Family 4 port SATA IDE Controller (rev 05)
    00:1f.3 SMBus: Intel Corporation 6 Series/C200 Series Chipset Family SMBus Controller (rev 05)
    01:00.0 VGA compatible controller: Advanced Micro Devices [AMD] nee ATI Whistler XT [AMD Radeon HD 6700M Series]
    01:00.1 Audio device: Advanced Micro Devices [AMD] nee ATI Turks HDMI Audio [Radeon HD 6000 Series]
    02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM57765 Gigabit Ethernet PCIe (rev 10)
    02:00.1 SD Host controller: Broadcom Corporation NetXtreme BCM57765 Memory Card Reader (rev 10)
    03:00.0 Network controller: Broadcom Corporation BCM4331 802.11a/b/g/n (rev 02)
    04:00.0 FireWire (IEEE 1394): Agere Systems FW643 PCI Express 1394b Controller (PHY/Link) (rev 08)

Additionally I made the following upgrades:

* Replaced the stock HD with an [Intel SDD 520](http://www.anandtech.com/show/5508/intel-ssd-520-review-cherryville-brings-reliability-to-sandforce)
* Upgraded to 8GB RAM

# Setting up for installation

I of course started with the [Gentoo Wiki](http://en.gentoo-wiki.com/wiki/Macbook_Pro) page on the Macbook Pro, which appears to be lacking information on the latest models. I knew a couple things going in from my earlier research.

* I wanted to use EFI, not BIOS emulation. Besides being new and fancy, you cannot use the integrated Intel HD 3000 graphics when using BIOS emulation.
* I'm not really interested in any form of dual booting, Linux is all I need. I knew this would make things considerably easier.
* It would be hard, but eventually I wanted to get suspend, hibernate, etc working nicely

My first roadblock was almost immediate: I normally use a USB stick loaded with a recent Gentoo minimal installer. However none of the tools on this installer support the new GPT partition layout, which is requied for booting with EFI.

The Gentoo Wiki suggests using gparted, and I happened to have a somewhat old gparted CD. Unfortunately, this old version didn't work: it couldn't figure out where to mount the CD media. No problem, I can download the latest version (0.12.0-5) and try that.

I had to spend a minute to figure out how to eject the old gparted CD though. It was easy enough: reboot and hold down the mouse button.

After booting into the newer gparted CD, everything worked fine. X loaded without any issues and ethernet was working, so I was able to continue on from within the gparted environment.

Or so I thought. It turns out gparted (reasonably) was using the x86 architecture, so I couldn't chroot into the Gentoo install. Booting from my trusty USB stick also didn't work, but fortunately I had been downloading a LiveCD of Ubuntu 11.10. Unfortunately, it was a 32 bit image. I downloaded a 64 bit image, and that didn't work either. Then I checked and the new Ubuntu 12.04 [daily build LiveCDs](http://cdimage.ubuntu.com/daily-live/current/) include a Mac specific version. This didn't work. Neither did the standard 64 bit Ubuntu 12.04 daily. Neither did a [weekly snapshot](http://distfiles.gentoo.org/releases/amd64/autobuilds/20120223/) of the Gentoo minimal amd64 installer. Finally I tried the [Gentoo 2012 amd64 multilib LiveDVD](http://gentoo.mneisen.org//releases/amd64/12.0/). It didn't work when booting with the standard options (garbled X output), but when I booted using the -nofb option, KDE loaded up fine, except that the mouse didn't work. Switching to the console I was able to set a root password and start SSHD to complete the installation remotely, which is my usual method.

# Sidetrack setup
When I install Gentoo I usually diverge a bit from the instructions and install some key utilities. In this case I simply installed htop, eix, vim, dmidecode, and pciutils. None of these are huge packages, but I definitely got a feel of how fast working on this machine is going to be. I imagine it's mostly the SSD, but htop reminded me that thanks to hyperthreading, Linux sees a total of 8 cores :)

# Initial Kernel config

My first pass at the kernel config was fairly quick. I removed some things I knew I didn't need, and followed the suggestions on the [kernel config](http://en.gentoo-wiki.com/wiki/Apple_Macbook_Pro/Configuration_Files/Kernel) page from the Gentoo Wiki article. I wasn't too concerned with getting every little piece of hardware working right away. Mostly learning GRUB2, which I had never used before, and booting with EFI was my main concern.

# GRUB2 installation

Before starting, I took a long look at the [Gentoo GRUB 2 guide](http://dev.gentoo.org/~scarabeus/grub-2-guide.xml) (work in progress) and the [GRUB 2 Gentoo wiki page](http://en.gentoo-wiki.com/wiki/Grub2). I noticed a couple interesting things. I knew that GRUB 2 suggests using a small script to generate the bootloader configuration, instead of manually editing a file like with GRUB1. But I didn't know that GRUB2 seems to keep this configuration all over the place. A little annoying to be honest. Also, everything I read suggested creating a separate partition (using FAT32 as the filesystem), for bootloader related stuff. I preferred just using a single big filesystem in the past, and had done the same back when partitioning the SSD earlier. I decided to attempt to make things work with one partition, knowing I could always go back and make a new partition with gparted if I had to.

So I added a package.keywords entry for grub2, set GRUB\_PLATFORMS="efi-64" in /etc/make.conf, and installed grub2. I fooled around for a bit, rebooted once and got nowhere. So I decided to boot back into gparted and add a 200MB partition at the end. Following the Gentoo GRUB 2 guide, I set it as bootable, and then then basically folowed exactly the instructions in the EFI section. I booted, and things seemed fairly close to working: GRUB2 was detected by EFI, and loaded, but it failed saying module "normal" was not found. I fiddled around again, and this time I landed right into a GRUB menu. I fiddld around a bit, but wasn't able to get linux to boot. I realized that when I ran grub2-mkconfig I didn't have /sys properly mounted as it says right in the guide. After that, grub at least showed a menu with a correct detection of my kernel. However, attempting to boot lead to the following:

* an error message "no suitable modes found"
* a warning about booting "in blind mode"
* a garbled screen that looks like it may have been the start of a linux kernel boot (there was the teltale yellow from the tux penguin at the top), but likely resulted in a panic

After some searching, I found the [Ubuntu UEFI Booting](https://help.ubuntu.com/community/UEFIBooting#Apple_Mac_EFI_systems-1) wiki page had a section on video issues. I tried to load the efi\_gop module, but it wasn't found until I specified the full path to the module. Then I needed to load a module it depended on, again specifying the full path. This lead me to believe that something in GRUB2 wasn't configured quite right. After loading this module I can start to boot linux, however it failed fairly quickly with the following error:

    [drm:intel_dsm_pci_probe] *ERROR* failed to get supported _DSM functions

I hoped that at the very least this meant that I had finally progressed to kernel configuration issues, so I started looking at kernel patches. I knew ahead of time of quite a few patches mentioned on [Benjamin Lee's blog](http://www.b1c1l1.com/blog/2011/11/19/macbookpro82-kernel-patches-for-linux-311/), so I got to work applying those. They didn't compile, but there is apparently a [patch](https://github.com/fooblahblah/linux-mainline-efi-lvds/blob/master/i915_reverse.patch) to make them work on my current kernel (gentoo-sources-3.2.1-r2).

After making some good progress, I called it a day.
