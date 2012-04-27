---
layout: post
title: "MTP support in Amarok"
date: 2012-04-27 14:22
comments: true
categories: 
---
With iPod support(link to previous blog) working, my intercontinental flight continued to be productive. I was finally able to sit down with Amarok and get MTP support working. At current, I haven't made any code changes, but as you'll see there is plenty of room for improvement.

What is MTP?

MTP stands for Music Transfer Protocol, and was created by Microsoft. If I may say so, it would be of little consequence to the world if it weren't for the fact that some Android devices (such as my Samsung Galaxy Nexus) utilize it to allow transferring files to the built-in flash storage. Devices such as mine don't have an SD card, and somewhat understandibly it is not possible to allow the root filesystem to be mounted over USB.

As far as I can tell, MTP uses concepts just different enough that it can't easily be implemented as a normal filesytem. It's too bad, because once music is on an Android device by any means (before messing with MTP I often just downloaded them over wifi from one of my local machines), it is ready to be listend to! Contrast that with an iPod/iPhone where there is a complicated database of tracks that has to be managed as well.

Okay, so if we can't simply treat MTP devices as filesystems, what tools do we have? Basically, just one: libmtp. It offers both a set of C functions for interfacing with MTP devices, and a set of handy command line tools. By far the most useful of these is mtp\_detect. It does exactly what you'd expect: detect any connected MTP devices and tell you stuff about them. So that's where my journey began. I pluged in my phone, and ran mtp-detect. What did I get? Not much:

(show mtp detect showing nothing)

Okay, what about as root?

(show mtp detect working as root)

Alright, that's better, so how to make it work as my own user. After a little digging, (actually, looking at strace output of mtp-detect), I saw it was looking in /dev/bus/usb. Once I found out the current device id of my phone, I was able to see what permissions are required to access the device node:

    spectre256@mission ~ $ ls /dev/bus/usb/002/008 -lh
    crw-rw-r-- 1 root plugdev 189, 135 Apr 27 14:55 /dev/bus/usb/002/008

Plugdev! I added myself to that group, restarted xdm and fired up amarok. Maybe it's just my phone, but theres one very big problem with MTP that is immediately obvious: it's SLOW. Now, some might say that just transferring to an iPod or iPhone is slow enough, and this is true, especially once you are used to copying things around super fast SSDs or fast network connections. But MTP redefines slowness. Simple actions like querying the amount of free space on the device often (usually even) take 20 seconds or more. Most annoyingly, it will always take at least 30 seconds before Amarok shows the device in the UI. This would be managable except that it appears that all libmtp functions are called from within the main Qt GUI thread in Amarok. When these functions take a long time, they block, and the UI completely hangs. Separating all these calls to a worker thread would be a great help. Fortunately I'd love to do it, hopefully I'll tackle it soon.

One more hassle I ran into was really just my own impatience. In the past I've noticed that you can watch tracks as they appear in the Android music player app. Well, that seems to sometimes cause things to break, so don't do that.
