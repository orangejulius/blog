---
layout: post
title: "I accidentally learned functional programming from ruby"
date: 2014-02-15 23:46:10 -0800
comments: true
categories: personal-personal-goals-post functional-programming ruby
---

About a year and a half ago, over ten years into my career as web developer, but with only about six
months of using web frameworks of any kind, I made the deliberate choice to switch from Python to
Ruby. My reasoning was short and simple: I had heard far too many people say good things about Ruby
on Rails, and how it was better than Django (that's a debate for another blog post).

I didn't really care for Ruby's syntax, thought Bundler, RVM, rbenv, and co were far more confusing
than pip and virtualenv[1], and especially thought the entire mantra of writing code to almost read
like English was laughable (things like ```5.times``` especially irritated me).

In short, I expected to essentially carry on programming just like before, except possibly with
better tools to help me along. That's not quite what happened.

Initially little changed. My ```for i in items:``` was replaced with ```for i in items do```, but
did exactly the same thing. But questions started coming. Why did Ruby have do/end AND curly braces?
Why were loop counter variables sometimes enclosed in vertical bars? Why did every damn thing
include Enumerable?

As I worked with Ruby more and looked around at code written by more seasoned Rubyists, I noticed
something even more strange: no one seemed to use for loops at all. It didn't even save any typing
(clearly the most important thing to Ruby programmers), yet ```items.each do |i|``` was universally
preferred.

Furthermore, Rubyists seemed to hate creating variables. Class methods were short, and seemed to
just take an input, massage it in some small way, and -- without even the courtesy of an explicit return
statement --  pass it on to the next thing. My C++ trained brain longed to see variables created
simply to iterate through arrays. Instead all I got were calls to ```map```. I found myself using
```each_with_index``` just to stay comfortable, without even needing to use an index.

As time went on though, I began to appreciate the conventions the Ruby community had adopted. There
was great clarity to be had in concentrating on what was being done -- transforming some data --,
rather than how it was done -- by iterating through every element in some sort of collection and
doing the same thing to each element. My code was shorter, but more importantly, it was more obvious
what it was doing, and why it was doing it.

Meanwhile, a movement was brewing in the programmer community at large. "Learn functional
programming" they said. "Down with side-effects." "Bow to your higher-order function gods". I took
note to read up on it some time and kept on coding.

Later, as I was also becoming better with Javascript, a language I had first learned a decade before
and dismissed as [poorly designed](http://www.oreillynet.com/pub/a/javascript/excerpts/javascript-good-parts/bad-parts.html),
I finally started getting comfortable when I discovered Underscore.js and Backbone and immediately
was comfortable with their powerful collection utilities. "Finally, someone has brought the power of
Ruby Enumerable's to Javascript", I thought.

The functional programming proponents are at least as numerous in the land of Javascript, so this
was about when I really decided to take a look and see what they had to offer. To my astonishment,
everything I read about functional programming wasn't talking about anything new, but simply giving
names to things I already did.

It was then that I realized many of the things I loved about Ruby weren't Ruby things at all. They
were functional programming things. Underscore didn't bring the power of Ruby to Javascript, it
brought the power of functional programming.

[1] I've completely reversed that decision and can't imagine leaving my Gemfiles behind for
requirements.txt. It seems silly that one would install packages, then
write the list of installed packages to a file for later, instead of just writing a list of packages
to install.
