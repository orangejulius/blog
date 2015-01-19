---
layout: post
title: "Javascript: The Good Parts, a review"
date: 2014-07-06 22:15 -0700
categories: book-reviews javascript
---

_Today I wrote up what turned out to be a somewhat lengthy [review](https://www.goodreads.com/review/show/566827873) for [Javascript: The Good Parts](http://shop.oreilly.com/product/9780596517748.do).  Since it goes a bit beyond strictly reviewing the book and talking about Javascript itself, I figured I'd post it here._

I though I had read this book before, but when I sat down to reread it this weekend I found a couple interesting things: 1.) I had never reviewed/rated this book on Goodreads, 2.) I had a bookmark halfway through the book 3.) I didn't remember any of the content for most of the chapters after my bookmark.

So here goes..

<i>Javascript: The Good Parts</i> made (or at least helped make) the Javascript language. Yes, the book was published in 2008, and yes, Javascript was created in 1995, and yes Javascript was widely used by at least the year 2000. But before <i>The Good Parts</i>, no one was allowed to view Javascript as anything but a toy. Worse, a toy with many sharp pieces that would hurt you if you tried to use it.

<i>The Good Parts</i> is still hard on Javascript, both in the main chapters of the book and in two special appendices cataloguing the Awful Parts and the Bad Parts, and there's plenty of good reasons to be hard on Javascript.

Part of this comes from Crockford's personality. While I find him likeable overall he is sometimes a bit abrasive and critical. In one of his talks, he mentions he considers colored syntax highlighting to be a feature "for children". Beyond making more than a few skilled developers angry, I'm sure comments like these do their share to keep new people out of our field. The "REAL programmers don't use X" rhetoric is strong enough without people wondering if finding value in syntax highlighting means they aren't cut out for programming.

I also notice a disconnect between Crockford's suggested pattern of Javascript usage, and that which is actually common today. Crockford was adamant that the "new" keyword never be used. He suggests we abandon what he called the "pseudoclassical" inheritance features that somewhat resemble C++ or Java, and embrace the prototypal inheritance that he considers to be the core of the Javascript language. At least in the world of Backbone.js, which is the most widely used framework I know of that isn't trying to rebuild Rails on top of Javascript, but rather work with the language, things have settled on a strange combination where prototypal inheritance handles defining objects that look eerily similar to traditional classes, and then the dreaded "new" keyword is used to intansiate individual objects.

Finally, I can not believe that Crockford isn't suffering at least a little from a case of Stockholm syndrome. I know this because I've been writing Javascript for over 10 years, and have seen my own admiration for the language grow even while I questioned whether or not my admiration was valid.

There IS an elegance in the Javascript language that this book helps unearth, but whether or not that elegant system actually makes Javascript useful is more uncertain. I see the beauty in using closures to hide access to private variables, but is it worth the cognitive load over simply declaring something private?

In any case this book is a must read for anyone doing Javascript development. I don't think this book has achieved the top status of "must reread every year", but it seems reasonable that you should read this book twice: once after you first dive into Javascript and want some semblance of clarity after the initial confusion you will no doubt encounter, and then sometime later when you are experienced with Javascript and wish to achieve Zen with the language.

