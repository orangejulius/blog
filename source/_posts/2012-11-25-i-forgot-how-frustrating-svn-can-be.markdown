---
layout: post
title: "I Forgot How Frustrating SVN Can Be"
date: "2012-11-25 18:09 -0800"
comments: true
categories: git
redirect_from: /blog/2012/11/26/i-forgot-how-frustrating-svn-can-be/
---
Yesterday, I was installing the latest KDE 4.10 beta, which is built from source.
The Gentoo KDE overlay already has ebuilds, which use KDE's SVN as the source, rather than a tarball.
While installing all the packages, there was a failure to install ```kdeartwork-wallpapers```:

<pre style="font-family:Courier New;font-size:10pt;"><span style="font-weight:bold;color:#00f000;"> * </span>Package:    kde-base/kdeartwork-wallpapers-9999
<span style="font-weight:bold;color:#00f000;"> * </span>Repository: kde
<span style="font-weight:bold;color:#00f000;"> * </span>Maintainer: kde&#64;gentoo.org
<span style="font-weight:bold;color:#00f000;"> * </span>USE:        amd64 elibc_glibc kernel_linux userland_GNU
<span style="font-weight:bold;color:#00f000;"> * </span>FEATURES:   sandbox splitdebug userpriv usersandbox
&gt;&gt;&gt; Unpacking source...
 <span style="font-weight:bold;color:#00f000;">*</span> Fetching disabled since 1 hours has not passed since last update.
 <span style="font-weight:bold;color:#00f000;">*</span> Using existing repository copy at revision 1326016.
 <span style="font-weight:bold;color:#00f000;">*</span>    working copy: /usr/portage/distfiles/svn-src/kdeartwork/kdeartwork

 <span style="font-weight:bold;color:#00f000;">*</span> Exporting parts of working copy to /var/tmp/portage/kde-base/kdeartwork-wallpapers-9999/work/kdeartwork-wallpapers-9999
rsync: link_stat &quot;/usr/portage/distfiles/svn-src/kdeartwork/kdeartwork/wallpapers&quot; failed: No such file or directory (2)
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1052) [sender=3.0.9]
 <span style="font-weight:bold;color:#f00000;">*</span> ERROR: kde-base/kdeartwork-wallpapers-9999 failed (unpack phase):
 <span style="font-weight:bold;color:#f00000;">*</span>   {ESVN}: can't export subdirectory 'wallpapers' to '/var/tmp/portage/kde-base/kdeartwork-wallpapers-9999/work/kdeartwork-wallpapers-9999/'.
 <span style="font-weight:bold;color:#f00000;">*</span> 
 <span style="font-weight:bold;color:#f00000;">*</span> Call stack:
 <span style="font-weight:bold;color:#f00000;">*</span>     ebuild.sh, line   93:  Called src_unpack
 <span style="font-weight:bold;color:#f00000;">*</span>   environment, line 4224:  Called kde4-meta_src_unpack
 <span style="font-weight:bold;color:#f00000;">*</span>   environment, line 3403:  Called kde4-meta_src_extract
 <span style="font-weight:bold;color:#f00000;">*</span>   environment, line 3309:  Called die
 <span style="font-weight:bold;color:#f00000;">*</span> The specific snippet of code:
 <span style="font-weight:bold;color:#f00000;">*</span>                       rsync --recursive ${rsync_options} &quot;${wc_path}/${subdir%/}&quot; &quot;${S}/${targetdir}&quot; || die &quot;${escm}: can't export subdirectory '${subdir}' to '${S}/${targetdir}'.&quot;;
 <span style="font-weight:bold;color:#f00000;">*</span> 
 <span style="font-weight:bold;color:#f00000;">*</span> If you need support, post the output of `emerge --info '=kde-base/kdeartwork-wallpapers-9999'`,
 <span style="font-weight:bold;color:#f00000;">*</span> the complete build log and the output of `emerge -pqv '=kde-base/kdeartwork-wallpapers-9999'`.
 <span style="font-weight:bold;color:#f00000;">*</span> This ebuild used the following eclasses from overlays:
 <span style="font-weight:bold;color:#f00000;">*</span>   /var/lib/layman/kde/eclass/kde4-meta.eclass
 <span style="font-weight:bold;color:#f00000;">*</span>   /var/lib/layman/kde/eclass/kde4-base.eclass
 <span style="font-weight:bold;color:#f00000;">*</span>   /var/lib/layman/kde/eclass/kde4-functions.eclass
 <span style="font-weight:bold;color:#f00000;">*</span>   /var/lib/layman/kde/eclass/cmake-utils.eclass
 <span style="font-weight:bold;color:#f00000;">*</span> This ebuild is from an overlay named 'kde': '/var/lib/layman/kde/'
 <span style="font-weight:bold;color:#f00000;">*</span> The complete build log is located at '/var/tmp/portage/kde-base/kdeartwork-wallpapers-9999/temp/build.log'.
 <span style="font-weight:bold;color:#f00000;">*</span> The ebuild environment file is located at '/var/tmp/portage/kde-base/kdeartwork-wallpapers-9999/temp/environment'.
 <span style="font-weight:bold;color:#f00000;">*</span> Working directory: '/var/tmp/portage/kde-base/kdeartwork-wallpapers-9999/work/kdeartwork-wallpapers-9999'
 <span style="font-weight:bold;color:#f00000;">*</span> S: '/var/tmp/portage/kde-base/kdeartwork-wallpapers-9999/work/kdeartwork-wallpapers-9999'
</pre>

This is a simple package, and since it is a live ebuild, I assumed a directory had been moved and set about debugging the problem.
I spent a good amount of time looking into the KDE eclasses, trying to figure out how to figure out what was being built.
Only after a while of this, during another attempt at compiling the package, did I realize that SVN could be the culprit.

A little digging revealed that indeed SVN, for reasons unknown, had done only a partial checkout of the repository.
Indeed trying manually to checkout the entire part of the repository required was never successful in one go: it took multiple manual resumes to checkout the complete repository.
Somehow, this error was never detected by Portage.

Having not even touched SVN for 8 months, after several years of begrudingly using it, I had totally forgotten the sort of pains it allowed.
