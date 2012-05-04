---
layout: post
title: "Debugging Amarok Transcoding to iPod"
date: 2012-04-27 10:34
comments: true
categories: amarok
---
Thanks to Matěj Laitl, Amarok now supports transcoding music when copying to iPods and iPhones.

However, while attempting to copy some FLAC encoded music to my iPod while transcoding to ALAC, I discovered it did not work, with only an unhelpful error message displayed.

{% img /images/transferFailed.png 'Transfer Failed' 'A screenshot of an unhelpful Amarok dialog' %}

Launching amarok with the --debug flag, I was able to see a little more detail:

	amarok: Transcoding from KUrl("file:///home/spectre256/music/Trouble Maker/Trouble Maker/Trouble Maker - Trouble Maker-%20 01 - Trouble Maker.flac") to KUrl("file:///media/IPOD/iPod_Control/Music/F45/libgpod869044.m4a")
	amarok: BEGIN: Transcoding::Job::Job(const KUrl&, const KUrl&, const Transcoding::Configuration&, QObject*)
	amarok:   BEGIN: void Transcoding::Job::init()
	amarok:     foo
	amarok:     ("-acodec", "alac")
	amarok:     "FFMPEG call is " ("ffmpeg", "-i", "/home/spectre256/music/Trouble Maker/Trouble Maker/Trouble Maker - Trouble Maker-  01 - Trouble Maker.flac", "-acodec", "alac", "-map_meta_data", "/media/IPOD/iPod_Control/Music/F45/libgpod869044.m4a:/home/spectre256/music/Trouble Maker/Trouble Maker/Trouble Maker - Trouble Maker-  01 - Trouble Maker.flac", "/media/IPOD/iPod_Control/Music/F45/libgpod869044.m4a")
	amarok:   END__: void Transcoding::Job::init() [Took: 0s]
	amarok: END__: Transcoding::Job::Job(const KUrl&, const KUrl&, const Transcoding::Configuration&, QObject*) [Took: 0s]
	amarok: BEGIN: virtual void Transcoding::Job::start()
	amarok:   starting ffmpeg
	amarok:   call is  ("ffmpeg", "-i", "/home/spectre256/music/Trouble Maker/Trouble Maker/Trouble Maker - Trouble Maker-  01 - Trouble Maker.flac", "-acodec", "alac", "-map_meta_data", "/media/IPOD/iPod_Control/Music/F45/libgpod869044.m4a:/home/spectre256/music/Trouble Maker/Trouble Maker/Trouble Maker - Trouble Maker-  01 - Trouble Maker.flac", "/media/IPOD/iPod_Control/Music/F45/libgpod869044.m4a")
	amarok:   ""
	amarok:   ffmpeg started
	amarok: END__: virtual void Transcoding::Job::start() [Took: 0.002s]
	amarok: BEGIN: void Transcoding::Job::transcoderDone(int, QProcess::ExitStatus)
	amarok:   ""
	amarok:   NAY, transcoding fail!
	amarok: END__: void Transcoding::Job::transcoderDone(int, QProcess::ExitStatus) [Took: 0s]

So the transcoding appears to be failing. Fortunately we have a big help to figure out why: we have the exact command parameters used for the transcoding.
On the surface of course, the command and parameters look completely legitimate.
To see what was broken, I just had to run the transcode command myself. The following output was the result:

	fmpeg version 0.10.2 Copyright (c) 2000-2012 the FFmpeg developers
	  built on Apr 14 2012 00:48:59 with gcc 4.5.3
	  configuration: --prefix=/usr --libdir=/usr/lib64 --shlibdir=/usr/lib64 --mandir=/usr/share/man --enable-shared --cc=x86_64-pc-linux-gnu-gcc --cxx=x86_64-pc-linux-gnu-g++ --ar=x86_64-pc-linux-gnu-ar --optflags='-O2 -pipe -march=native -fomit-frame-pointer' --extra-cflags='-O2 -pipe -march=native -fomit-frame-pointer' --extra-cxxflags='-O2 -pipe -march=native -fomit-frame-pointer' --disable-static --enable-gpl --enable-version3 --enable-postproc --enable-avfilter --disable-stripping --disable-debug --disable-network --disable-vaapi --disable-vdpau --enable-libmp3lame --enable-libvo-aacenc --enable-libvorbis --enable-libx264 --enable-libxvid --disable-indev=v4l --disable-indev=oss --disable-indev=jack --enable-x11grab --disable-outdev=oss --enable-libfreetype --disable-amd3dnow --disable-amd3dnowext --disable-altivec --disable-avx --disable-vis --disable-neon --cpu=host --enable-hardcoded-tables
	  libavutil      51. 35.100 / 51. 35.100
	  libavcodec     53. 61.100 / 53. 61.100
	  libavformat    53. 32.100 / 53. 32.100
	  libavdevice    53.  4.100 / 53.  4.100
	  libavfilter     2. 61.100 /  2. 61.100
	  libswscale      2.  1.100 /  2.  1.100
	  libswresample   0.  6.100 /  0.  6.100
	  libpostproc    52.  0.100 / 52.  0.100
	[flac @ 0x864320] max_analyze_duration 5000000 reached at 5015510
	Input #0, flac, from '/home/spectre256/music/Trouble Maker/Trouble Maker/Trouble Maker - Trouble Maker-  01 - Trouble Maker.flac':
	  Metadata:
	    ARTIST          : Trouble Maker
	    TITLE           : Trouble Maker
	    ALBUM           : Trouble Maker
	    DATE            : 2011
	    GENRE           : K-Pop
	    album_artist    : 트러블 메이커
	    STYLE           : Trouble Maker
	    track           : 1
	    TOTALTRACKS     : 4
	    disc            : 1
	    TOTALDISCS      : 1
	  Duration: 00:03:41.37, bitrate: 1004 kb/s
	    Stream #0:0: Audio: flac, 44100 Hz, stereo, s16
	Unrecognized option 'map_meta_data'
	Failed to set value '/media/IPOD/iPod_Control/Music/F45/libgpod869044.m4a:/home/spectre256/music/Trouble Maker/Trouble Maker/Trouble Maker - Trouble Maker-  01 - Trouble Maker.flac' for option 'map_meta_data'

It looks like it's the map\_meta\_data option causing issues.

After looking through the ffmpeg repository a bit, it seems map\_meta\_data was removed in version 0.10 after being depricated in version 0.7.
There is a new option called map\_metadata that replaces it, but with different syntax.
However, for simply transcoding an audio file, neither of these options are needed:
the only time they should have to be specified is when doing something such as transcoding a movie with multiple audio tracks.

This means the fix is as simple as ensuring that the map\_meta\_data option is removed. Amarok has a large codebase but it is actually very friendly to new developers, so understanding where and how to fix this turned out to be straightforward. Here, the relevant code is in src/transcoding/TranscodingJob.cpp.
This class represents a single job to do one transcode, which will be run in the background.
Different transcoders, such as the one found in src/core/transcoding/formats/TranscodingAlacFormat.cpp can set options to the transcoder (in this case it sets the "-acodec alac" option as you would expect), but there are several common options set in the Transcoding::Job::init() method; one of these is the offending map\_meta\_data option.

The relevant code is included below. It uses a KProcess object from the KDE libraries to run the transcode job in the background.
The command and parameters are set, and then the slots for progress and completion are connected to the proper signals.

{% codeblock lang:c++ %}
void
Job::init()
{
    DEBUG_BLOCK
    m_transcoder = new KProcess( this );

    m_transcoder->setOutputChannelMode( KProcess::MergedChannels );

    //First the executable...
    m_transcoder->setProgram( "ffmpeg" );
    //... then we'd have the infile configuration followed by "-i" and the infile path...
    *m_transcoder << QString( "-i" )
		  << m_src.path();
    //... and finally, outfile configuration followed by the outfile path.
    const Transcoding::Format *format = Amarok::Components::transcodingController()->format( m_configuration.encoder() );
    *m_transcoder << format->ffmpegParameters( m_configuration )
		  << QString( "-map_meta_data" )
		  << QString( m_dest.path() + ":" + m_src.path() )
		  << m_dest.path();

    //debug spam follows
    debug() << "foo";
    debug() << format->ffmpegParameters( m_configuration );
    debug() << QString( "FFMPEG call is " ) << m_transcoder->program();

    connect( m_transcoder, SIGNAL( readyRead() ),
	     this, SLOT( processOutput() ) );
    connect( m_transcoder, SIGNAL( finished( int, QProcess::ExitStatus ) ),
	     this, SLOT( transcoderDone( int, QProcess::ExitStatus ) ) );
}
{% endcodeblock %}

So the exact fix is simply to remove lines 17 and 18, so that the map\_meta\_data option is no longer passed to ffmpeg.
It does in fact work: after removing those lines and recompiling I can happily copy all my FLAC encoded music to my iPod in ALAC format!

I submitted the code for review on the Amarok [reviewboard](https://git.reviewboard.kde.org/r/104839/).
In addition to the transcoding fix, I also included a tiny fix to make debugging easier in the future: in the debug lines above where a QStringList is sent to debug output, use the .join() function to print the command exactly as it would be run, instead of a comma separated list of individual parameters.
The full set of changes can be found on [Github](https://github.com/orangejulius/amarok/tree/fixTranscode).

During this whole process, I've noticed a couple other pain points that would be great to improve. If possible I'll work on this in the near future:

* When multiple tracks are picked to be transcoded at once, each track is handled in series. Even on my Core i7 Macbook Pro, CPU is the bottleneck when transcoding a single track. I have painfully watched htop show me one core working dilligently while the others, and the iPod's disk, sit mostly idle. Ideally multiple tracks could be transcoded at once, perhaps up to the number of cores on the current sytem?
* Amarok kept telling me about stale tracks on my iPod and telling me I can do something about them. Either I can't find this option or it doesn't exist. Either way the UX at least probably has to be improved.
* When selecting a transcoding option, Amarok currently performs this transcode whether or not it makes sense or not based on the source filetypes. For example, if I ask Amarok to transcode to ALAC, any lossy filetype would be converted, which would simply waste space and time. It would be great if Amarok could detect and prevent such "upconverting".
