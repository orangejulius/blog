---
layout: post
title: "Help requested fixing Macbook Pro related kernel regression"
date: 2012-05-08 16:00
comments: true
categories: 
---
As I mentioned in past posts, I've been working on getting my new 15" MacbookPro working completely with Linux. Good progress has been made on a lot of fronts, but there is a new [regression](https://bugs.freedesktop.org/show_bug.cgi?id=49518) in the i915 drivers that is holding me (and likely others) back. I added a [post](http://ubuntuforums.org/showthread.php?p=11916477&posted=1#post11916477) to the long MacbookPro thread on ubuntuforums. Here's what I posted for anyone who would like to help.

{% blockquote %}
	Hi all,

	Recently, the team of developers working on improvements to the i915 linux kernel drivers that are needed for many recent Macbook Pro models have been adding several enhancements to the drivers that benefit Macbook Pro users. The most notable one is that in their most recent git kernel tree, the number of LVDS channels is automatically set properly for the Macbook Pro, eliminating the need to apply a patch and pass the i915.lvds_channels=2 option as many on this thread (including myself) have done. Another change is the option to disable the intel_backlight controls, allowing the gmux_backlight control to take over which (for me at least) is the only working backlight control for a Macbook Pro.

	However recently they inadvertently introduced a regression that is also causing a similar black screen. I reported a bug and the developers are taking a look but I suspect they do not have access to any Macbooks to test with. If any readers of this post who have a modern (say, 6,x or above) Macbook pro running linux in EFI mode, and are comfortable building their own kernel from git could help out with the bug I'm sure it would be greatly appreciated and would help get these improvements into the mainline kernel faster.

	Here's what you can do:

	    1.) Read the bug report at https://bugs.freedesktop.org/show_bug.cgi?id=49518
	    2.) Get the development git sources from git://people.freedesktop.org/~danvet/drm-intel
	    3.) Confirm that commit e646d57 from the git sources introduce a black screen
	    4.) Post to the bug report the result of any patches by kernel developers. include all the information a kernel developer would need to diagnose the issue: the system name of your Macbook (eg MacbookPro8,1), the full dmesg output with drm.debug=0xe added to your kernel parameters, and the output of the intel_reg_dumper command that is part of the intel-gpu-tools package located at http://cgit.freedesktop.org/xorg/app/intel-gpu-tools/ (version 1.1 works for me).
	    5.) Otherwise help out however you can

	Thanks and happy hacking!
{% endblockquote %}
