---
layout: post
title: "What does it take to survive an AWS outage?"
date: 2012-10-27 01:30
comments: true
published: false
categories: scalability
---
On October 22nd, many large and small websites suffered outages due to issues with EBS in a single availability zone.
This isn't the first time EBS has had issues, so at this point, people should have lots of experience dealing with this sort of issue. While we usually can't justify the cost of preparing for every possible level of outage, at this point being resilient to EBS issues seems wise. Having worked with EC2 quite a bit during my almost 3 years at Zynga, I happen to have experienced several incidents that were likely similar to what happened recently (I don't currently administer any EC2 instances so I have no first hand account of what happend this time, but from what I hear it sounds pretty similar to outages I did experience). So, what does it take to survive an AWS outage? More specifically, how can we build a system with data stored on EBS while gracefully handling its more ugly moments.


## the basics

EBS can be used for a lot of things, but lets consider what I imagine is the most common case: an EBS volume storing only application data from some sort of database software. This is a great setup for a couple reasons: EBS is pretty cheap (storing 100GB will only cost you $10/month), you can make snapshots for backups any time without downtime, and if the EC2 instance running your database happens to die, as they have been known to do occasionally, you simply remount the EBS volume on a new instance, and everything is ok again.

But when EBS acts up, this means your data is effectively unavailable. You can relaunch instances all you want, but generally if one instance can't access an EBS volume, another instance isn't going to have better luck.

## Backups?

Presumably, regardless of the reliability of the storage, most people are keeping backups of their data somehow. This is good! But don't get too comfy. Even if you are actually in the habit of making sure your backups are valid, and that you can actually restore from them, it's often the case that when one EBS volume is having issues, many others are too. Don't expect that you can just launch a new instance, attach a new EBS volume, restore your data and go back to browsing Reddit. Besides, if you have any amount of data at all, restoring from backup can take a few hours. We can do better.

## Replication?

These days, setting up repliation with almost any DBMS is dead simple. And again, this is pretty common for an infrastructure of any significant scale. But how many people are ready, at any time, to handle a significant number of master DBs going down without serious downtime? If you haven't already built a system to, at least, swap masters and slaves, this is going to take a long time. That said, replication is, of course, a key ingredient to surviving EBS outages. But more is needed.


## Replication across multiple Availability Zones?

Now we're getting somewhere. Like I mentioned above, it's often the case that many or most (or all?) EBS volumes in one AZ will have issues in a a major outage. And best practices dictate you should keep your data in multiple physically separate locations, so using multiple availability zones is a Good Thing&trade;. It is exactly what Amazon created them for after all.

Several people I talked to cited the cost of data transfer between availability zones as a potential issue. It is true that Amazon [charges](http://aws.amazon.com/ec2/pricing/) for data sent to another AZ in the same region, but only 1 cent per GB. Lets say you have a fantastically active userbase, and the stream of replication data from your master DB is on the order of 100Mbps. In that case, replication across AZs will cost you a whole $10 per day. Now, before you object "Hey, that's $300 a month, thats more than I pay for my EC2 instance", remember one thing. EBS is great in many ways, but lets just say I have never come across anyone who says they use it because it's fast. Even with a fancy RAID 10 setup, which is pretty common, you're going to need multiple database instances to hit that sort of capacity, probably at least 10. I can't imagine anyone being able to pay for the infrastructure to support this level of data usage, and not be able to pay to replicate it across availability zones.

## How to handle the big day

So we've established that for any chance to survive major EBS issues, you have to be replicating between AZs. But really thats just the start. You still would have to manually switch over your repliated slaves to become master. If you don't have good tooling for this, it could take a while. And how do you decide that EBS is looking questionable. What happens when EBS breaks at 3AM? In general even with a good on-call rotation you can count on at least 20 or 30 minutes of downtime while some poor guy wakes up, drinks a coffee, figures out what is happening, and flips the right switch (I know because I've been this guy more than a few times). You don't want to think about what happens if he hits th wrong switch (I've done this too).

So
