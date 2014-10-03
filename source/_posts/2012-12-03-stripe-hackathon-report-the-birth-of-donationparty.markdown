---
layout: post
title: "Stripe hackathon report: the birth of Donation Party"
date: 2012-12-03 23:45
comments: true
categories: 
---
Last Saturday was the Stripe [Hack to the Future](https://stripe.com/blog/hack-to-the-future) hackathon.
I've been working on attending more tech talks and other events lately, and since Stripe is pretty well known and I only live a block away, this one was a no-brainer.
Naturally, they encouraged people to utilize Stripe, so I spent a few minutes the night before thinking about what to build.
I quickly decided it should be something involving small transactions, and that it should be relatively silly: not something that would look like a "real" business idea.

## The idea

Near the front entrance of [Hacker Dojo](http://hackerdojo.com) is a credit card reader, used to accept donations.
Unlike normal credit card readers, this one donates a random amount up to $20 on your behalf when you swipe your card.

While neat on its own, the real fun starts when you can get a bunch of people to all swipe one after another.
Often we can arrange to have a little prize like a t-shirt or coffee mug for the "winner" who ends up donating the most.
The money goes to a good cause, isn't large enough to really care about, and the whole experience has a fun air competition: there's a prize at stake, and suspense is high, but the outcome is not under anyones control.

With a little tweaking, I figured building a small web app basically simulating that same experience could be a lot of fun.

## The Hackathon

I went over to Stripe HQ the next day and after having a quick bite to eat thanks to Stripe's amazing culinary team, I set about recruiting people to get building.
Normally, even at an event like a hackathon where you know you have _something_ in common with almost everyone there, it's a little hard to just start talking to people.
But with the goal of starting work ASAP, and most people's desire to get working on something too, it was easy to get things started.

Within about 30 minutes we had a team of four (the perfect size!) ready to get going.
Most amazingly, we not only quickly came up with a great name, but a name with an available .com domain name!
By the end of the night, we actually had made great progress.
There's a lot more to be done, but there happens to be another hackathon this Saturday at [RISE](https://www.facebook.com/events/512718438746224/) where we plan to finish everything up.


## Lessons Learned

While what we built was really cool, the actual experience of building it was one of the most valuable experiences I've had in the last few months.
I've been reading and thinking about all sorts of startup and software development related topics lately, and this was a great chance to reflect upon them.

A few times during the hackathon particularly interesting thoughts crossed my mind.
They might not be completely unique, but they're still powerful.


### Stay flexible

Since I was basing my hackathon idea off of a real world experience, I was lucky to have an extremely clear idea of what I wanted to build.
I had specific interactions, pricing, and even wording in mind from the very start.

By the end of the night, none of the details of what we had built were similar, although the overall premise was preserved.

Initially, I was a little concerned when people started suggesting things directly in conflict with details that were, in my mind, already decided.
I realized I had to let go of any specific vision I had, and just let our project evolve with input from the entire team.

Partially, this was because I knew I had to ensure everyone on the team *wanted* to keep working, and if I was too firm on any particular detail, they might decide they weren't interested in helping anymore.
Of course, there was absolutely no reason for me to believe that any preference I had for the direction of our project was automatically correct, and I have no doubt that the combined input of four people made it far better than I ever could have hoped to achieve on my own.


### Urgency helps with decision making

Within about 10 minutes of gathering a small team, we had firmly made an incredible number of major decisions.

What language should we use? What hosting provider? Should we build a mobile app?

Those decisions alone could have taken weeks to decide at even a small company.
Initial versions of user flows and interactions took us about 15 minutes, but could have taken even a fast moving startup a while.

The single hardest choice for any company, what to name your product, was decided in 30 seconds.

There's nothing special about anyone on the team that caused us to make decisions so quickly, we simply didn't have a lot of time, and therefore had a strong sense of urgency.

No doubt there are thousands of smaller decisions we could have worried about, but more important than any of them was our need to just _build stuff_.

We didn't spend any time talking about coding styles, indentation, or any of the other classic programming debates.
All software developers, of course, have extremely strong opinions on each of these topics, so not having to debate them was extremely refreshing.

Going forward, I'm going to focus on keeping the same sense of urgency for each and every project I work on, and hopefully all of them will be more successful.


### Focus on the core of your project, outsource everything else

Another key to moving fast was to only spend time on the part of your project that makes it interesting, and let someone else take care of everything else you can.
No one cares about the efficiency of our web servers, even if we all would have enjoyed tweaking them, so we used Heroku and were live in minutes.
When we realized we needed a pub/sub system, we didn't want to have to deal with setting up our own, so we let [Pusher](http://pusherapp.com) take care of it, and went back to working on something else.

For us, and for any team starting out, focusing only on what the user sees is the only way to go.
Leave everything else to someone else.


### Keep your team productive

I came to this hackathon mostly expecting to gather a team, come up with a basic design, and then more or less and sit down and code.
In fact, for about two thirds of the night, I spent all my time just making sure everyone else could work.

At first, it might seem like this is silly.
If I too had just gotten to work, there would be four people working instead of three.

But look at it another way: which is better, to have three people working in a productive, uninterrupted state, or four people constantly having to get sidetracked.
I spent all night setting up dev apps, SSL certs, celery queues, and whatever [else](http://www.inc.com/magazine/20081201/how-hard-could-it-be-my-style-of-servant-leadership.html) needed to be done.

Quite frankly, all the other team members worked on the hard, exciting stuff, and did a great job.
But they wouldn't have done as awesome of a job without my unglamorous help from the sidelines, and thats a great feeling.


## Advice for Stripe

I really want to thank Stripe for hosting this hackathon and letting everyone eat their tasty food, but I also want to give some feedback that might make future events better.
As a quick disclaimer I want to mention that I was fairly heads down for much of the night, so if I missed something, my apologies.


### Do some sort of judging

While the event was ostensibly a hackathon, and indeed much hacking was done by several teams, it would be more correct to call it an office hours session.
Guests were in attendance, even working on their own projects, but there wasn't much structure imposed by Stripe, and at the end of the day the event fizzled out with no strong conclusion from Stripe.

There's something to be said for a low key gathering, but Stripe, next time you host a hackathon, go all in on actually making it a hackathon.
Have people register teams, do some sort of judging, give out a prize, the usual.
Just helping people organize into teams probably would have tripled the number of people seriously working.

On the other hand, a more structured hackathon might have made it harder for me to pick up new team members, so maybe I should be careful what I wish for.


### Make your employees more active

As a small team using Stripe for the first time, I can't think of a better place to have been working than _in the Stripe offices_.
Stripe employees were available to answer any questions we had, and they were overall really eager to help.
That said, it seemed like we were always having to seek them out.

Maybe I just missed it, but I would have loved to have been bugged by Stripe employees dropping by every couple minutes, just to chat with us about our project.
They could have quickly checked out how we were using Stripe, warned us before we ran into known problems, and helped us make things better than we could have on our own.
