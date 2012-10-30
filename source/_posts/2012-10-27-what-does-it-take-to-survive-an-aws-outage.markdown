---
layout: post
title: "What does it take to survive an EBS outage?"
date: 2012-10-27 01:30
comments: true
published: false
categories: scalability
---
On October 22nd, EBS issues in a single availability zone brought down all sorts of websites, big and small.
EBS is an important and impressive (read: complicated) part of AWS, but this isn't the first time we've seen it underperform, and I was honestly not expecting so many well known websites with extremely talented teams to be bitten __again__.

Having worked with EC2 at scale for almost three years, I've seen several similar incidents and know a bit about how to weather the storm (since a hurricane has previously caused AWS issues, this is more than a figure of speech).
So, what does it take to survive an AWS outage? More specifically: how can we build a system with data stored on EBS while gracefully handling its more ugly moments?

## The Setup

EBS has a lot going for it: it's pretty cheap (storing 100GB will only [cost](http://aws.amazon.com/ebs/) you $10/month), you can create snapshots at any time for backup, and when an EC2 instance fails, any EBS volumes can easily be remounted on a new instance.
EBS very rarely loses data, and it's common to use RAID 1 (or 10) for even more safety.
Lots of people have their data on EBS and still sleep well at night.

But when EBS acts up, your data can essentially go missing.
Without good preparation, there's not much to do other than wait for EBS to recover.

What can be done to prepare?
Two pieces are particularly important: replication across availability zones and quick (preferably automated) failover.

## Using Multiple Availability Zones

Due to the nature of EBS, it has been particularly vulnerable to cascading failures.
A small trigger can cause outages that affect nearly an entire availability zone.
Without having data and instances ready to go in multiple zones, there's no way to quickly recover.

Most serious deployments in EC2 will replicate data to one or more slave databases. But it seems it's less common to ensure that the master and slave are in different availability zones.

### How much will it cost?

While transfers within the same availability zone are free, Amazon [charges](http://aws.amazon.com/ec2/pricing/) charges a whopping 1 cent per GB sent to another availability zone in the same region.

What's a reasonable expected cost for replicating from one database instance?
According to Scalyr's EC2 [benchmarks](http://blog.scalyr.com/2012/10/16/a-systematic-look-at-ec2-io/), we can expect a maximum of about 2000 4KB writes per second to a single EBS volume on a small EC2 instance.
That's only to 8MB/sec, or a maximum of 675GB per day, for which Amazon whill charge you $6.75.
Meanwhile, those two small instances costs you an on-demand rate of $3.84 per day.

Keep in mind 8MB/sec is an absolute maximum. In practice, even with large EC2 instances (which Scalyr showed to have double the EBS throughput, but cost four times as much), a more sustainable throughput is at best half of that.
It's reasonable to expect that the cost of replicating to another availability zone won't exceed the cost of the database instances.

What about sending data back to non-database instances?
Scalyr found that EBS read performance is actually about an order of magnitude worse than write performance.
Even assuming maximum read AND write performance can be obtained simultaneously, it isn't significantly more expensive than just maxing out on writes.

#### A little bit extra safety

Amazon [describes](http://aws.amazon.com/ec2/#features) availability zones as "distinct locations that are engineered to be insulated from failures in other Availability Zones".
However, there has been at least one incident where an entire region was affected.

If the possibility of downtime from this scenario is unacceptable, you have to consider replicating across regions instead of availability zones.
Latency will be higher between regions, and bandwith costs will follow the public data transfer pricing, which starts at 12 cents/GB.
However, if surviving this level of catastrophy is important, the costs are surely worth it.

## How to manage failover

While it's replication across zones that allows for any chance to survive major EBS outages, quickly reacting to the outage is what will really minimize downtime.

Fortunately, in the last few years this has gotten quite a bit easier.
There are many databases supporting master-master replication, automatic leader election, and all sorts of other ways to switch over without any manual action.
MongoDB has [replica sets](http://www.mongodb.org/display/DOCS/Replica+Sets), CouchDB [replication](http://wiki.apache.org/couchdb/How_to_replicate_a_database) supports multi-master configuration and was specifically designed to handle extended downtime (there are people running CouchDB on their cell phones!).
Even MySQL has good support for master-master replication and [automatic failover](http://code.google.com/p/mysql-master-ha/) now.

If the particular database you're using doesn't support automatic failover, at the very least build a small tool that lets you manually fail over to another set of databases.
Test it heavily ahead of time and make it easy to use: there's nothing worse than scrambling to fix a problem only to mistakenly make it worse, and any time spent fiddling is time where your site is down.

### Simulating behavior during an EBS outage

Simulating EBS failures is hard.
The EBS volume doesn't disappear, it just stops responding to requests.
The instance mounting the EBS volume is generally unaffected overall.

The closet thing I can come up with to the behavior of a stuck EBS volume is to mount an NFS volume,  and then shut down the NFS daemon.
Any process reading or writing to the NFS volume will hang until the volume is reconnected.

Fortunately, there is a very important and dangerous type of issue to demonstrate how this works.

### Handling EBS issues on the client side

Most out of the box automatic failover setups work great when one of the databases _fails_.
But as mentioned above, EBS issues don't cause database to completely fail.
There will be very high iowait, and any processes using EBS-backed data may hang, but the instance in general continues running just fine.
Importantly, connecting to a database instance with a 'stuck' EBS volume will generally _succeed_.
However, remote requests for writing, (and reading, depending on the specifics of the database's caching), will generally not return any data.

Most libraries for working with databases will specify both a connection timeout and a "general" timeout, but default the general timeout to unlimited.
This is a reasonable default, since any specific timeout would limit long-running jobs, but not setting this to a relatively small value can sabotage any failover mechanisms.

To see what happens, lets use CouchDB and run a little test using the methodology described above.
CouchDB uses HTTP as an interface, so its dead simple to work with.

Here's the test procedure:

1. Set up two machines on the same network.
2. Machine A exports a directory via NFS, which will simulate our EBS volume.
3. Machine B mounts the NFS directory, and uses it to store CouchDB's data.
4. After starting CouchDB, the NFS daemon is stopped.
5. `curl` is used to simulate database traffic

And here's the result:

``` bash
#everything works initially
user@machineB ~ $ curl http://127.0.0.1:5001/sampledb/doc1
{"_id":"doc1","_rev":"1-15f65339921e497348be384867bb940f","hello":"world"}
#NFSd is stopped on machine A
#this hangs forever
user@machineB ~ $ curl http://127.0.0.1:5001/sampledb/doc1
^C
#this hangs forever too: the connection succeeded
user@machineB ~ $ curl http://127.0.0.1:5001/sampledb/doc1 --connect-timeout 5
^C
#this correctly times out
user@pismo ~ $ curl http://127.0.0.1:5001/sampledb/doc1 -m 1
curl: (28) Operation timed out after 1001 milliseconds with 0 bytes received
```

Any mechanism expecting the `--connect-timeout` option to protect against failed instances will be completely defeated when EBS starts acting up.

## Handling everything else

I've covered one particularly important aspect of handling outages, but of course there's more to it.
As Amazon mentioned in their [summary](https://aws.amazon.com/message/680342/), EBS is one of the building blocks of several other components of AWS.
Having a service completely immune to EBS-backed database issues is no good if you aren't also prepared for ELB issues.
And of course any other instance in your infrastructure can flat out fail at any time.
We can't prepare for everything, but handling single-AZ EBS outages is one thing we should all be able to handle.
