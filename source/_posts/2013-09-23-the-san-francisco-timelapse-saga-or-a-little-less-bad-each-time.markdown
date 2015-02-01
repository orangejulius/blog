---
layout: post
title: "The San Francisco timelapse saga (or: a little less bad each time)"
date: "2013-09-23 23:07 -0700"
comments: true
categories: linux tutorial photography
---
Months ago, after watching the Nth amazingly beautiful timelapse of San Francisco made by someone else, I realized I had all the tools to do the same thing.
I have a Panasonic DMC-GF1 which is, if not the world's best camera, perfectly capable of taking beautiful shots at all hours of the day.
I have a respectable ability to write shell scripts to simplify mundane tasks.
I have the perseverance and willingness to slog through man pages, google searches, and stackoverflow posts to figure out how to use one of the many video editing tools available.
I didn't have a remote shutter with repeat mode, but I bought one on Amazon.

I figured this would be everything I need to make a timelapse video, and I was right.
Making a GOOD timelapse however, takes a little trial and error.
Let's start from the beginning.

## Timelapse 1

January 17th

Armed with my camera, an 8GB memory card, a tripod, and two fully charged but aged batteries, I got started.
I pointed my camera out the window, spent 20 minutes reading the remote shutter manual (boy was it terrible), and walked away.

Shooting in RAW mode(like any good photographer of course!), at 14MP per shot, my camera ran out of memory only 4 hours later.
At 15 seconds between frames, and 25 FPS in the final video, that's just 19 seconds of video.

Not much of a timelapse.

Fortunately, I was closely watching the status of my camera as it ran out of room and promptly switched in another memory card and battery.
Unfortunately, to swap the battery and memory card I had to take my camera off the tripod, and of course you can never get it on in exactly the same way again.
So, 19 seconds into the video below you'll see the view shift, but I was able to double the length of my timelapse to 8 hours of real time and 38 seconds of video.

The next challenge was converting a bunch of RW2 files (Panasonic's raw format, which isn't well supported most places) into a video.
As it turns out, converting a bunch of RW2s to a format that can be easily encoded into a video is harder than encoding the video itself, and after a little fiddling I produced the following 38 seconds of video:
{% youtube BQ3bQcBMlic %}

Besides being short and with a big view shift in the middle, this video has a couple problems:

- You can see part of my window on the left
- You can see everything in my apartment in the window reflections
- There's a HUGE pole in the middle of my frame.

Well, we can't do anything about the third thing, but we can set out to fix the reflections and adjust our frame a bit to avoid any window panes.
I also ordered two things that night: a 64GB memory card, and an AC adapter for my camera.

## Timelapse 2

January 18th

Great news!
My 64GB memory card arrived (Amazon prime!).

Bad news!
My camera is too old to support SDXC, the SD card format variant for capacities of 64GB and up.
I'll have to make do with 32GB cards until I get a new camera, and 8GB cards until a 32GB card arrives (anyone want to buy a 64GB SDXC card?).

I decided to shoot in JPEG mode instead of RAW to at least get a little more space out of my memory card.
The video framerate is lowered to 20FPS to make it a little easier to see everything that's happening, too.

Here's the second video
{% youtube zTo-4kF49IM %}

Ouch, this one isn't level at all.
But, on the upside it's got no bad reflections, a great sunset, and it's a full minute and 46 seconds, with only a minor blip when I swapped memory cards.

## Timelapse 3

January 24th

Finally I have a larger memory card, and this time I'm determined to make use of it.
With 32GB capacity, my camera can hold almost 6000 JPG images, and at 15 seconds between frames that's right around 24 hours.

I set everything up at 12:10PM and recorded a photo every 15 seconds until 12:20PM the next day, for a total of 5995 frames!

This time I taped a big dark green bedsheet behind the camera and amazingly, it worked great: there's really no glare at all in this video.

Encoded, this makes a 3 minute, 52 second video, with over 24 hours captured.

Really, this one is quite beautiful.
The sky was overcast but the movement of the clouds is awesome, and sunset and sunrise are just fantastic.
Be sure to watch this one all the way through.

{% youtube AvZ2lPIDmiM %}

## Timelapse 4

January 25th

Now that I have the basics down, its time to just keep repeating and making some interesting videos of different weather and events.

This one is 5776 photos from 1:34PM on the 25th to 1:26PM on the 26th.

Unlike the previous video, this one is much sunnier, which made glare a bigger problem than before.
Worse, the dark sheet I was using to keep most of the glare away fell down while I was recording (you can see it disappear 12 seconds in).
So while its not what I intended to capture, you can see a great reflection of the shadow of everything in my apartment, most notably my bikes, move across my apartment as the sun shifts position.

{% youtube HX-vv9s3Pfg %}


## Timelapse 5

July 24th

I took a bit of a hiatus after the last one, but am back with a novel new technique.

Previously, my camera has been inside my apartment, ensuring that any glare, dirt, or reflections on my windows were captured in the video.
My bedroom however, has a ledge outside the window large enough to setup my tripod, so this time my camera is set up outside, and there's no reflections at all.

One little mistake though, I forgot to clear my memory card before starting so this video is only 38 seconds long, and all you get is some daytime.

{% youtube pKczmqmqtW0 %}

## Timelapse 6

July 24th

With the memory card reset after a false start earlier in the day, we're back with a full length video this time.

As I was hoping to really capture eventually, the clouds rolled in spectacularly that night, and it's really quite fantastic to watch.
However, it also presents a problem: my camera's autofocus seems to get confused.
As a result, the time between photos isn't consistent, and even worse, some frames effectively have different zoom levels due to differences in how the camera chose to focus that frame.
Next time, I'll be setting up manual focus before starting the timelapse, so this should go away.

{% youtube B7aPkTqA4mQ %}

## The script

For those that might want to encode their own timelapses, here's the script I used.

{% include_code lang:bash timelapse %}
