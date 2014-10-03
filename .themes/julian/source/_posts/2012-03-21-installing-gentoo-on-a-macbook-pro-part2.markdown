---
layout: post
title: "Installing Gentoo on a Macbook Pro, Part2"
date: 2012-03-21 17:52
comments: true
categories: 
---
It's been a couple days since I could sit down with my fancy new Macbook, but last night and today I've made some good progress. After [part 1](/blog/2012/03/14/installing-gentoo-on-a-macbook-pro/) I a nearly booting sytem, but not quite everthing was working yet. While I could get a kernel to load from grub2, it would hang almost immediately. Also grub2 was clearly misconfigured, as it was spewing many errors about missing commands, and I had to manually type in the path to my kernel image on each boot.

I didn't know enough about grub2 to hope to debug things there yet, and I was sick of the long cycle of waiting for the livecd to load, mounting filesystems required to chroot, and then making changes, so I hoped to be able to simply get a kernel to boot. As it turns out, this was not too hard.

The first main thing I did that was helpful was to set up a local git copy of the kernel code, since I knew I would be applying various patches eventually. I fiddled around with various versions from 3.1 onward, including the latest code merged as part of the newly opened 3.4 window. I actually found that the only key thing required to boot is to ensure that kernel modesetting was not enabled by default for the i195 driver (CONFIG\_DRM\_I915\_KMS): when it's enabled the kernel would hang unrecoverably (somtimes not even alt+sysrq+b worked) either a few seconds into boot if the i915 driver is conmpiled into the kernel, or after Gentoo prints the line "waiting for uevents to be processed", if built as a module.

Unfortunately I wasted a lot of time because I borrowed a kernel config used by Ubuntu. It had almost every single kernel option built as a module, including AHCI and ext2/3/4 support. Of course those had to be built into the kernel to finish booting. I wasted a lot of time disabling various modules, and eventually copied my Gentoo config from gentoo-sources-3.2.1 and modified it. One slightly confusing thing was finding the correct ethernet driver. Despire lspci listing the name as NetExtreme, it is actually the Tigon3 driver that is needed (CONFIG\_TIGON3), NOT either of the NetExtremeII drivers (CONFIG\_BNX2 or CONFIG\_BNX2X).

After this, I was able to fully boot just fine. Next I spent about 20 minutes filling /var/lib/portage/world with all the packages I wanted, ran an eix-sync, an an emerge -eav world. Despite including firefox, chromium, libreoffice, and about 800 other packages, this finished in only about 4 hours!

I fiddled around a bit with starting X, and determined it will take a lot of work. GRUB's error messages were bugging me, so I decided to fix them first, since it might help me learn a bit about EFI and GRUB2. I read a good amount of the [GRUB2 manual](http://www.gnu.org/software/grub/manual/grub.html), crafted a mail to the gentoo-user mailing list, and finally stumbled across renergy's [forum post](http://forums.gentoo.org/viewtopic-p-6988228.html) that worked perfectly.

The next task was perhaps the most daunting: get a desktop environment working. Oddly enough, for the most basic case at least, it was not that hard. Initially, I was wondering how things would work at all. Any attempts to enable modesetting by default in the i915 driver lead to hangs during boot. Yet, using the i915 module at all seems to require kernel modesetting. As it turns out, the trick is to first disable the Radeon graphics card, since presumably the two interfere if you aren't careful. [Mike Dentifrice's blog](http://dentifrice.poivron.org/laptops/macbookpro8,2/) has perfect instructions for this. The following steps are all it took:

1. Start with a Linux 3.3.1 kernel. Using my existing linux git repo, I added another remote for linux-stable pointing to git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
2. Apply the lvds\_dual\_channel and apple\_bl patches. Few others seem to have shared their work, so I pushed a branch with the patches to my [linux github repo](https://github.com/orangejulius/linux/tree/v3.1.1-patches).
3. Build and install the kernel. Make sure the i915 driver is compiled into the kernel and kernel modesetting is enabled by default. In other words, set the following config options:
        CONFIG_DRM_I915=y
        CONFIG_DRM_I915_KMS=y
4. Update your grub.cfg to disable the Radeon card and pass required parameters to the kernel. The menuentry for my kernel ended up looking like this:
       menuentry 'Gentoo GNU/Linux, with Linux 3.1.1-00002-g77b9830' --class gentoo --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-3.1.1-00002-g77b9830-advanced-1f2dc33c-2639-42f9-8502-9c7d3f24e7ec' {
           load_video
           set gfxpayload=keep
           insmod gzio
           insmod part_gpt
           insmod ext2
           set root='hd0,gpt1'
           # switch gmux to IGD
           outb 0x728 1
           outb 0x710 2
           outb 0x740 2
           #powers down ATI
           outb 0x750 0
           if [ x$feature_platform_search_hint = xy ]; then
               search --no-floppy --fs-uuid --set=root --hint-bios=hd0,gpt1 --hint-efi=hd0,gpt1 --hint-baremetal=ahci0,gpt1  1f2dc33c-2639-42f9-8502-9c7d3f24e7ec
           else
               search --no-floppy --fs-uuid --set=root 1f2dc33c-2639-42f9-8502-9c7d3f24e7ec
           fi
           echo    'Loading Linux 3.1.1-00002-g77b9830 ...'
           linux   /boot/vmlinuz-3.1.1-00002-g77b9830 root=/dev/sda1 ro i915.lvds_channels=2 reboot=pci acpi_backlight=vendor
       }

Pretty easy, right? Well there's some problems. Linux 3.1.1 isn't exactly the newest. Among other things, it doesn't support the Macbook Pro's wireless card. Fortunately there's a [patch](http://dentifrice.poivron.org/laptops/macbookpro8,2/files/3.1.0-bcm4331.patch) for that. But it would be nice to be able to use a newer kernel with all the latest updates, right? Plus, all that power in the Radeon graphics card is going to waste all the time. I'll have to conquer those hurdles another day.

Since I had a working desktop environment now, I decided quickly to see how things were working. Firefox and Amarok worked just fine, but when I tried to watch a few minutes of Firefly, I realized there was no sound! I fiddled with model=mb5 and other settings in /etc/modprobe.d/alsa.conf but it turns out all I had to do was enable SND\_HDA\_CODEC\_CIRRUS. It's the only Intel HDA coded that's required actually.

Stay tuned as there clearly will be a part 3 (at least) in the near future.
