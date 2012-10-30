---
layout: post
title: "What does it take to survive an AWS outage?"
date: 2012-10-27 01:30
comments: true
published: false
categories: scalability
---
On October 22nd, EBS issues in a single availability zone brought down all sorts of websites, big and small.
EBS is an important and impressive (read: complicated) part of AWS, but this isn't the first time we've seen it underperform, and I was honestly not expecting so many well known websites with extremely talented teams to be bitten __again__.

Having worked with EC2 at scale for almost 3 years, I've seen several similar incidents and know a bit about how to weather the storm (since a hurricane has previously caused AWS issues, this is more than a figure of speech).
So, what does it take to survive an AWS outage? More specifically: how can we build a system with data stored on EBS while gracefully handling its more ugly moments?


## The Setup

EBS can help us do all sorts of things, but there's only one use case we're concerned with:
(no, not serving up [310GB of genome databases](http://aws.amazon.com/datasets/2315?_encoding=UTF8&jiveRedirect=1)) storing your web application's data!
EBS is a common solution here for a couple reasons: it's pretty cheap (storing 100GB will only [cost](http://aws.amazon.com/ebs/) you $10/month), you can make instant snapshots for backups, and if your database instance dies, you simply remount the volume on a new instance, and everything is ok again.
EBS very very rarely loses data, and furthermore it's common to use a RAID 1 (or 10) array for even more safety.
Lots of people have all their data on EBS and still sleep well at night.

But when EBS acts up, your data can go missing until Amazon fixes things.
Generally, You can relaunch instances all you want, but if one instance can't access an EBS volume, another isn't going to have better luck.

This is precisely every cloud-computing users worst nightmare: without access to your own data there is literally _nothing_ you can do to get your site running again.
So how can we prevent ourselvs from ever having to deal with this?

## Backups?

Presumably, regardless of the reliability of the storage, most people are keeping backups of their data somehow.
This is good! But don't get too comfy.
Even if you are actually in the habit of making sure your backups are valid and you can restore from them, it's often the case that when one EBS volume is having issues, many others are too.
Don't expect that you can just launch a new instance, attach a new EBS volume, restore your data and go back to browsing Reddit.
Besides, if you have any amount of data at all, restoring from backup can take a few hours.
We can do better.

## Replication?

These days, setting up repliation with almost any DBMS is dead simple.
And again, this is pretty common for an infrastructure of any significant scale.
But how many people are ready, at any time, to handle a significant number of master DBs going down without serious downtime? If you haven't already built a system to, at least, swap masters and slaves, this is going to take a long time.
Replication is, of course, a key ingredient to surviving EBS outages.
But more is needed.


## Replication across multiple Availability Zones?

Now we're getting somewhere.
Like I mentioned, it's often the case that many EBS volumes in one AZ will have issues at once.
You should keep your data in multiple physically separate locations, so using multiple availability zones is a Good Thing&trade;.
It is exactly what Amazon created them for after all.

Several people I know have cited the cost of data transfer between availability zones as a potential issue.
It is true that Amazon [charges](http://aws.amazon.com/ec2/pricing/) for data sent to another AZ in the same region, but only 1 cent per GB.
Lets say you have a fantastically active userbase, and the stream of replication data from your master DB is on the order of 100Mbps.
In that case, replication across AZs will cost you a whole $10 per day.
Now, before you object "Hey, that's $300 a month, thats more than I pay for my EC2 instance", remember one thing.
EBS is great in many ways, but lets just say I have never come across anyone who says they use it because it's fast.
Even with a fancy RAID 10 setup, which is pretty common, you're going to need multiple database instances to hit that sort of capacity, probably at least 10.
I can't imagine anyone being able to pay for the infrastructure to support this level of data usage, and not be able to pay to replicate it across availability zones.

## Automate everything

So we've established that for any chance to survive major EBS issues, you have to be replicating between AZs.
But really thats just the start.
You still would have to manually switch over your repliated slaves to become master.
If you don't have good tooling for this, it could take a while.
And how do you decide that EBS is looking questionable.
What happens when EBS breaks at 3AM? In general even with a good on-call rotation you can count on at least 20 or 30 minutes of downtime while some poor guy wakes up, drinks a coffee, figures out what is happening, and flips the right switch (I know because I've been this guy more than a few times).
You don't want to think about what happens if he hits th wrong switch (I've done this too).

Clearly, an automated solution is needed.
Fortunately, lots of recent NoSQL databases solve this problem for you.
MongoDB has [replica sets](http://www.mongodb.org/display/DOCS/Replica+Sets), CouchDB [replication](http://wiki.apache.org/couchdb/How_to_replicate_a_database) supports multi-master configuration and was specifically designed to handle sorts of downtime.
Even MySQL has good support for master-master replication and [automatic failover](http://code.google.com/p/mysql-master-ha/).
The tools are out there, and lots of people are using them.

## There's down, and then there's down

Unfortunately, things aren't quite as rosy as they might appear.
Automatic failover works when one of the databases _fails_.
But an important detail of using EBS is that, in general, an EC2 instance using EBS does not fail when EBS fails.
It simply can't read or write to the EBS volume.
This generally manifests itself as high iowait and hanging requests for data.
Importantly, connecting to a database instance with a 'stuck' EBS volume will generally _succeed_.
This sort of behavior has caused some of the more insidious bugs I've seen in large systems.

It's not impossible to work around this of course.
Most libraries for working with databases will specify both a connection timeout and a "general" tmeout.
However, the general timeout is usually set to unlimited.
This makes sense for your long-running jobs, but for any request that the user of your web service sees, it will make sense to lower this limit to a few seconds.

Since Amazon implements EBS as a block device, and the internals are (I presume), not supposed to be known to us, it can be hard to test this sort of situation.
I tested MongoDB and CouchDB behavior in this scenario by mounting a remote NFS volume, and then unplugging the ethernet cable.
This produces the behavior I mentioned above, and seems similar to my experiences with EBS failures.

## There's more to it

I've covered one particularly important aspect of handling outages, but of course there's more to it.
As Amazon mentioned in their [summary](https://aws.amazon.com/message/680342/), EBS is one of the building blocks of several other components of AWS.
Having a service completely immune to EBS-backed database issues is no good if you aren't also prepared for ELB issues.
And of course any other instance in your infrastructure can flat out fail at any time.
We can't prepare for everything, but handling single-AZ EBS outages is one thing we should all be able to handle.

## One final question

I'd love to hear from anyone who was using multi-AZ RDS instances.
How was your experience during the outage? Did you notice anything? Did you have downtime?
