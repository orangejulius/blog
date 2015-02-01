---
layout: post
title: "GRUB2 is coming along nicely"
date: "2012-11-18 21:01 -0800"
comments: true
categories: gentoo linux
redirect_from: /blog/2012/11/19/grub2-is-coming-along-nicely/
---
Today I decided to resurrect an old piece of hardware I've had sitting useless for a while: an Asus Eee PC [1005PE]( http://ca.asus.com/en/Eee/Eee_PC/Eee_PC_1005PE_Seashell/#specifications).

As an experiment, and to pave the way for future experimentation I decided to use GRUB2.
I'm also trying out the no-multilib profile, so grub 0.xx is not supported.

I'm pleased to report that using GRUB2 on a normal, BIOS booting system was extremely easy.
Here's some information about how I did it.

## Partition Table

I'm using a single EXT4 partition, the simplest possible setup.

    pebble ~ # cat /etc/fstab
    # /etc/fstab: static file system information.
    #
    # noatime turns off atimes for increased performance (atimes normally aren't
    # needed); notail increases performance of ReiserFS (at the expense of storage
    # efficiency).  It's safe to drop the noatime options if you want and to
    # switch between notail / tail freely.
    #
    # The root filesystem should have a pass number of either 0 or 1.
    # All other filesystems should have a pass number of 0 or greater than 1.
    #
    # See the manpage fstab(5) for more information.
    #

    # <fs>                  <mountpoint>    <type>          <opts>          <dump/pass>

    # NOTE: If your BOOT partition is ReiserFS, add the notail option to opts.
    /dev/sda1               /               ext4            noatime         0 1

## Installation

I installed Gentoo's GRUB 2.00-rc1 package.

{% codeblock lang:bash %}
    echo "~sys-boot/grub-2.00" >> /etc/portage/package.accept_keywords/grub
{% endcodeblock %}

## Setup

Since I'm using the standard ```make install``` to install kernel images to /boot, simply running ```grub2-mkconfig``` sets everything up:

{% codeblock lang:console %}
pebble ~ # grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub.cfg ...
Found linux image: /boot/vmlinuz-3.5.7-gentoo
Found linux image: /boot/vmlinuz-3.5.7-gentoo.old
done
{% endcodeblock %}

That's it!
While there's more going on behind the scenes than GRUB1's simple grub.cfg file, in the case of a BIOS driven setup, everything Just Works.
