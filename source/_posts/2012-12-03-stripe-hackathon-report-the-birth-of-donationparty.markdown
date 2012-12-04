---
layout: post
title: "Stripe hackathon report: the birth of Donation Party"
date: 2012-12-03 23:45
comments: true
categories: 
---
Last Saturday was the Stripe [Hack to the Future](https://stripe.com/blog/hack-to-the-future) hackathon.
Since I live a block away, it seemed like a reasonable choice to attend.
The night before, I spent a few minutes trying to think of ways to use Stripe to build something, anything really.
My first thought was that it should be something involving incredibly small amounts of money, and that it should be relatively silly: not something that would look like a "real" business idea.

As it happened, I thought of a fun ritual from [Hacker Dojo](http://www.hackerdojo.com/) that was a ton of fun.
At the front of Hacker Dojo is a credit card reader that donates a random amount up to $20 on your behalf when you swipe your card.
While neat on its own, the real fun starts when you can get a bunch of people to all swipe one after another.
Often we can arrange to have a little prize like a t-shirt or coffee mug for the "winner" who ends up donating the most.
The money goes to a good cause, isn't enough to really care about, and is a fun "competition" because the winner is completely out of anyones control.
It seemed like a web app in the same spirit might be fun to build, and small enough that building it in a day is not too far from impossible.
I didn't know if anyone would like my idea, but I decided to make it a goal to get some people to build it at the hackathon.

I went over to Stripe HQ the next day and after having a quick bite to eat thanks to Stripe's amazing culinary team, I set about recruiting people to get building.
Normally, even at an event like a hackathon where you know you have _something_ in common with almost everyone there, it's a little hard to just start taling to people.
But with the goal of starting work ASAP, and most people's desire to get working on something too, I ended up talking to quite a few people really quickly
Most importantly, everyone loved my idea!
Within about 30 minutes we had a team of four (the perfect size!) more or less comitted to working for the rest of the day.
Most amazingly, we not only quickly came up with a great name, but a name with an available .com domain name!

Really, it was amazing how well everyone worked together, and how quickly we moved.
We spent about 10 minutes getting to know each other, and who had the most experience in which areas.
Quickly, we settled on using Python with Django running on Heroku, and started dividing up tasks the best we could.
We all _wanted_ to use something a little more sexy, like node.js or Ruby on Rails, but we admitted that we had to stick with what we all knew well, so without any further debate we moved on.

I happen to have just read [The Passionate Programmer](http://pragprog.com/book/cfcar2/the-passionate-programmer) by Chad Fowler (book report coming soon!), and he talks about how a sense of urgency, like at a hackathon, makes tough decisions happen quickly.
Based on the example I gave above, as well as almost every other decision we had to make during the night, I have to say this is absolutely correct.
I have no doubt we all had strong, differing beliefs on everything from programming language, to indentation style, to variable naming, but with only a few hours we all set that aside.
It wasn't going to make a difference as much as just building stuff as quickly as possible.
As someone who probably spends way too much time arguing over these sorts of things, it was incredibly refreshing.
If I can figure out a way to generate the same sense of urgency, and get the same positive results, on longer lasting projects, I'm pretty sure I could take over the world.

The second really interesting thing that I learned, or really confirmed, is that if you want to move fast, you should outsource everything except the core of your product.
While our entire team consisted of people who no doubt would love to spend hours tinkering with dedicated virtual machines for hours to come up with the ideal hosting environment, we knew that wasn't what was going to help.
We pretty quickly used almost every product we could to solve problems for us.
Need web hosting and source control?
Don't waste any time setting it up yourself, just use Heroku.
Later we realized we needed a pub/sub system.
We didn't even think about building one ourselves: a quick visit to [Pusher](http://pusherapp.com) and we were on our way.

Finally, the most interesting part of the experience was what sort of work I did.
As it turns out, starting with a blank slate, there's not possibly four people's worth of code that you can start writing right away.
One guy started working just on the UI.
Two others paired to start working on the backend.
This sounds pretty standard, and was what I expected.
But what really blew me away was what I worked on.
I would have felt completely comfortable working on the backend, and would have been able to make a passable UI, but as it turns out I didn't work on either of these things.
Basically, everything I did that night was work to keep the other three team members rolling.
First, I set up Heroku to give us source control.
By the time anyone was ready to really start hacking, I had finished setting up Django, and made sure everyone's development environment was more or less working.
About the time we were ready to push to "production", our DNS was all set up.
Later, we realized we needed an SSL cert, so I got that working.
On the surface, this isn't that notable, because none of the above is hard (although acquiring SSL certs might not rightly be called _easy_).
Really, the reason this is interesting is because of what I didn't do much: code.

I thought about an [article](http://www.inc.com/magazine/20081201/how-hard-could-it-be-my-style-of-servant-leadership.html) by Joel Spolsky that I read long ago.
Here is an extremely experienced software developer, who could no doubt bill in the hundreds per hour for his time, CEO of a successful well known company, hanging window blinds.
He even admits he's not good at it.
For someone who is known for, and loves, writing code, this sounds totally crazy.

But the most interesting thing I learned that day was how this is the most effective thing he could be doing.
Any time you can proactively (or even reactively) do work to enable others to stay productive and continue making progress, you're doing something incredibly valuable.
As someone used to being productive mostly through my direct action, this was a pretty cool lesson to learn.

The Donation Party crew will be reassmbling on Saturday, December 8th at the [RISE Hackathon](https://www.facebook.com/events/512718438746224/) to finish everything up.
Stay tuned!
