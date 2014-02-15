---
layout: post
title: "Anatomy of a simple problem and a forgettable solution"
date: 2014-02-14 22:33:33 -0800
comments: true
categories: personal-personal-goals-post
---
About once a week at work, someone hits an error while trying to deploy code. It's always the same
one: permission denied early in the Capistrano deploy process. The solution is always extremely
simple: run ```ssh-agent; ssh-add``` from the command line, and the error goes away for so long that
everyone forgets what to do to solve it. Today I solved the problem for us, hopefully once and for
all. I want to talk about why this can keep happening, and share my code for others to solve it as
well.

Capistrano uses ssh to deploy code by running commands remotely on your server. Most people are at
least familiar with the concept that ssh uses public key authentication to allow you to securely
connect to your server without entering a password. Most people are also aware that Github uses
public key authentication to allow you to pull from and push to your git repos without a password.
Very likely, both your server and Github look for the same public keys.

There are a lot of issues one can run into setting up public key authentication, but usually
everything works fine once initially set up. The error we're dealing with today however, tends to
come back. What's the difference?

The key is that when using Capistrano, there's more happening than just authenticating with either
your server or Github. You're authenticating with Github, from a command run by Capistrano ON your
server. Thus it's essentially your server authenticating with Github. Your private key, however, is
only on your local computer.

Fortunately, that's exactly the problem ssh-agent solves. It's built specifically for one thing:
securely storing your private credentials in a way such that they can be used to authenticate over
an ssh connection. Thus your server can talk to Github as if it owned your private key, but your key
is safe on your own computer. If you have an ssh agent running and configured with your private key,
of course.

To quickly spoil the mystery of the two commands needed to run to solve this issue, ```ssh-agent```
starts a background ssh agent process, but it's initially not configured to use any ssh keys. They
must be added with ```ssh-add```. By default ```ssh-add``` adds private keys in the most common
locations, so you almost never have to supply any parameters. Thus ```ssh-agent; ssh-add``` is
usually enough.

So why is this such a recurring problem then, if you just have to run ```ssh-agent; ssh-add```? I
think there's two reasons.

The first is that it's hard to distinguish from the Capistrano output that the problem is your
server failing to authenticate with Github, not your local machine failing to authenticate with your
server. Since the second possibility is what most people think of first, it's the one they try to
debug.

The second reason is a bit more insidious. Its easy to remember how to solve a problem you encounter
again and again. This problem happens infrequently, but regularly. As it turns out, unless you take
steps to prevent it, it will happen every time you restart your computer (since ssh-agent doesn't
start automatically, although it probably should). We should count ourselves lucky that we don't
generally have to restart our computers very often these days, but as it turns out there is a
downside.

Okay, so this problem is easy to solve if you know how, and easy to prevent yourself from running
into ever again (just ensure ```ssh-agent; ssh-add``` is run every time your computer starts, for
example by putting that line in your ~/.bashrc). I wanted to do a bit more though, and ensure not
just I but everyone on my team would be safe from this problem for all time.

That's why I'm happy to announce the hastily and uncreatively named
[capistrano_auto_ssh_agent](https://github.com/orangejulius/capistrano_auto_ssh_agent) gem. Simply
put it in your gemfile, add ```require 'capistrano_auto_ssh_agent'``` to your Capistrano deploy.rb
file, and Capistrano will run a task to ensure ssh-agent is running and correctly configured before
every deploy.

It's a simple gem and I don't expect to have to do much more work on it, but feedback is very
welcome. Enjoyy!
