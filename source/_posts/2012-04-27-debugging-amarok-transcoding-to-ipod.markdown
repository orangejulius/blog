---
layout: post
title: "Debugging Amarok Transcoding to iPod"
date: 2012-04-27 10:34
comments: true
categories: 
---
Thanks to Matěj Laitl, Amarok now supports transcoding music when copying to ipod.

However, after testing, I discovered it did not work, with (this) unhelpful error message being displayed.

Launching amarok with the --debug flag, I was able to see (this) somewhat more helpful debug output.

It lists, in a someone inconvenient format, the exact parameters used for the transcoding. The transcoding is simply done using ffmpeg, with the output written directly to the file on the iPod. On the surface of course, the command and parameters look completely legitimate. To see what was broken, I simply copied the above output into a new shell file, removed all the commas and a few extra quotes, although I probably could have left them. The following output was the result:

Well, I am not an expert on ffmpeg, but after consulting the man page, I found there is no map\_meta\_data option, but there is a map\_metadata option. Could it really be a simple typo? I'm typing this on an airplane without access to fmpeg documentation or git, so it's possible that the name has changed over time, but that seems unlikely. Clearly the fix is simple enough, just fix the typo/mistake: (show new output)

Drat, we don't get away that easy. Again, my knowledge of ffmpeg is limited but the intent of this parameter is clearly to ensure that things like the track and artist name are properly set in the resulting transcoded file's metadata. Looking at the ffmpeg man page again, it appears this is automatically done by default. I haven't yet talked to Matěj about it yet, but perhaps there is a special case here that was specifically handled. So, what happens if we just remove the option all together?

(show transcode output)
Not surprisingy, it transcodes perfectly.
(show mplayer output)
Slightly more surprisingly, the metadata is there as well.

Okay, so the fix (for my case at least), is as simple as ensuring that the map\_meta\_data option is removed. Amarok has a large codebase but it is actually very friendly to new developers in my opinion. Things are very well (almost too well?) abstracted. The relevant code is in src/transcoding/TranscodingJob.cpp. This class represents a single job to do one transcode, which will be run in the background. Different Transcoders, such as the one found in src/core/transcoding/formats/TranscodingAlacFormat.cpp can set options to the transcoder (in this case it sets the "-acodec alac" option as you would expect), but there are several common options set in the Transcoding::Job::init() method. All that has to be done is create a KProcess object to run a process, and then set the parameters. These are the actual executable (ffmpeg), the source and destination paths, and the map\_meta\_data. (show code). Connect the KProcess signals to the slots and we're done.

So I simply commented out the lines setting the map\_meta\_data parameter, recompiled, and was good to go. Now I can happily copy all my FLAC encoded music to my iPod in ALAC format!

In addition to making this work seamlessly, I've found a couple other pain points that would be great to improve. If possible I'll work on this in the near future.

* When multiple tracks are picked to be transcoded at once, each track is handled in serial. Even on my Core i7 Macbook Pro, CPU is the bottleneck when transcoding a single track. I have painfully watched htop show me one core working dilligently while the other 7 (remember, hyperthreading), and the iPod's disk, sit mostly idle. Ideally multiple tracks could be transcoded at once, perhaps up to the number of cores on the current sytem?
* Amarok kept telling me about stale tracks on my iPod and telling me I can do something about them. Either I can't find this option or it doesn't exist. Either way the UX at least probably has to be improved.
* One item I would add as nice to have, is to improve the transcoding selection between simply copying everything or transcoding everything to a single format. Obviously, you can manually handle things fine this way. But imagine the case where you want to transfer 5 albums, some are in FLAC, others in mp3. You might want to transcode the FLAC files to ALAC to get the full quality files on your device, but of course transcoding mp3 files to ALAC is quite silly. An option to detect "upconverting" at the least would be excellent.
