---
layout: post
title: "Fun with 4K sectors"
date: 2012-11-28 16:49 -0800
comments: true
categories: linux
redirect_from: /blog/2012/11/28/fun-with-4k-sectors/
---
Today I received in the mail a brand new 3TB hard drive for storing my multitudes of bits.

While I was eager to get started using it, I couldn't help but dig into all the fun details of the new technology I have acquired.
There's two interesting considerations with a drive of this size and they both come down to something many people might not know much about: sectors.

A sector is basically a subdivision of usable space on a hard disk.
When your operating system wants some data from disk, it asks for data by sector.
For decades the standard size of a disk sector has remained unchanged: 512 bytes.

Recently however, two interesting things have happened.
First, with the release of hard drives with capacities larger than 2TB, more than 2^32 sectors are required to address all data on disk.
Unfortunately, the ubiquitous MBR partition table only supports up to 2^32 sectors per partition.

Second, hard drive manufacturers, in their never ending journey to give us more storage space, have realized that sectors of only 512 bytes no longer make sense.
By using 4KB sectors, it is actually possible to store more data on the same hard disk because each sector comes with some overhead used by the hard disk.

What does all this mean?
Most obviously, it requires that anyone wishing to use more than 2.2TB in a single disk use the new [GUID Partition Table](http://en.wikipedia.org/wiki/GUID_Partition_Table)
(it's possible to cleverly utilize more than 2.2TB of a single disk with multiple MBR partitions, but this often does not work with many operating systems).
Support for GPT is quite good amongst all operating systems now, and it is required for EFI, which is growing more common as well, so this is not much of an issue.

More insidiously however, it means that your hard disk is lying to you.
Since sectors have been 512 bytes literally for decades, our friendly hard drive manufacturers assumed that no operating systems would be ready to support sectors of any size other than 512 bytes (perhaps they assume programmers don't always properly use named constants for values such as sector sizes, which of course is ridiculous).
Their clever solution was to have disks store data in 4KB sectors, but continue to advertise to the operating system that sectors are 512 bytes long, and then handle the bookkeeping to translate between the two themselves.
So now there are two sector sizes worth worrying about: the logical size -- how your operating system talks to your hard disk, and the physical size -- what your disk actually does internally.
This is all well and good, except that it breaks an implicit assumption about how much work a hard disk has to do when writing data.

Consider the case of an operating system writing to two consecutive 512 byte sectors.
With 512 byte physical sectors, this is assumed to require a total of 1024 bytes be written to disk (a hard disk will generally only read and write, at minimum, a whole sector, regardless of how much or little data actually changes).
But what if those two 512 byte logical sectors were not part of the same physical sector?
Your hard drive has to write both physical sectors, a total of 8192 bytes!

If you've read any literature about SSD performance over the last few years, you'll recognize this problem: it's known as write amplification and like anything where more work than required is done, it's not good for performance.

So how much performance is lost with a misaligned partition?
Timothy Miller [investigated](http://www.osnews.com/story/22872/Linux_Not_Fully_Prepared_for_4096-Byte_Sector_Hard_Drives) by writing a small C program to force write amplification.
Curious, and always a sucker for small C programs, I ran his code myself.
Here's my version:

``` c testWriteAmplification.c
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>

char buffer[4096];

int main(int argc, char *argv[])
{
    int fd, i, off;
    long bk, byte;

    if (argc<2) {
        off = 0;
    } else {
        off = atoi(argv[1]);
    }

    srandom(off);

    fd = open("/dev/sdc", O_RDWR | O_SYNC);

    for (i=0; i<1000; i++) {
        bk = random() % 200000000;
        byte = bk * 4096 + off * 512;
        lseek64(fd, byte, SEEK_SET);
        write(fd, buffer, 4096);
    }

    close(fd);

    return 0;
}
```

The method is simple: write 4096 bytes to 1000 random locations.
By default, the program ensures that the write starts and ends at a 4KB sector boundary, but the first argument specifies an offset in 512 byte increments.
Any offset not evenly divisible by 8 will cause write amplification, and as it turns out, the performance penalty is serious:
	spectre256@ocean ~ $ sudo time ./testWriteAmplification 0
	0.00user 0.02system 0:16.17elapsed 0%CPU (0avgtext+0avgdata 1664maxresident)k
	0inputs+0outputs (0major+144minor)pagefaults 0swaps
	spectre256@ocean ~ $ sudo time ./testWriteAmplification 1
	0.00user 0.04system 0:26.45elapsed 0%CPU (0avgtext+0avgdata 1664maxresident)k
	0inputs+0outputs (0major+144minor)pagefaults 0swaps


This brings us to the dreaded A-word: alignment.
While occasional write amplification would be fine, what if your system was set up in such a way that write amplification is inevitable?
This is the danger of differing physical and logical sector sizes.
In fact, the default starting sector for many Windows partitions is 63.
This has lead many other tools to copy this default, leading to misalignment and reduced performance.
Some hard drives even internally shift all sectors by one so that such systems default to correct alignment.


# Testing different alignments

While the test above showed serious theoretical performance reduction from misaligned writes, I wanted to know what would happen in the real world, so I devised some simple testing to investigate.

Sector 34 is the first available to start a new partition, after accounting for the space needed by GPT.
Since 34 is not evenly divisible by 8, a partition starting at sector 34 will not be properly aligned, and is a good choice for testing misaligned performance.
Sector 40 is the first possible correctly aligned sector, so I used this as the starting sector for the aligned partition.

## Creating the partitions

Using sector 34 as the starting point, I created the misaligned partition using GNU Parted, and then created an ext4 filesystem:

    ocean ~ # parted /dev/sdc
    GNU Parted 3.1
    Using /dev/sdc
    Welcome to GNU Parted! Type 'help' to view a list of commands.
    (parted) mkpart ext4 0s -1s
    Warning: You requested a partition from 0.00B to 3001GB (sectors 0..5860533167).
    The closest location we can manage is 17.4kB to 3001GB (sectors 34..5860533134).
    Is this still acceptable to you?
    Yes/No? y
    Warning: The resulting partition is not properly aligned for best performance.
    Ignore/Cancel? i
    (parted) q
    Information: You may need to update /etc/fstab.

    ocean ~ # time mkfs.ext4 /dev/sdc1
    mke2fs 1.42 (29-Nov-2011)
    /dev/sdc1 alignment is offset by 3072 bytes.
    This may result in very poor performance, (re)-partitioning suggested.
    Filesystem label=
    OS type: Linux
    Block size=4096 (log=2)
    Fragment size=4096 (log=2)
    Stride=0 blocks, Stripe width=0 blocks
    183148544 inodes, 732566637 blocks
    36628331 blocks (5.00%) reserved for the super user
    First data block=0
    Maximum filesystem blocks=4294967296
    22357 block groups
    32768 blocks per group, 32768 fragments per group
    8192 inodes per group
    Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968,
        102400000, 214990848, 512000000, 550731776, 644972544

    Allocating group tables: done
    Writing inode tables: done
    Creating journal (32768 blocks): done
    Writing superblocks and filesystem accounting information: done


    real    0m29.931s
    user    0m1.671s
    sys     0m0.293s

Here's the same procedure for the aligned partition:

    ocean ~ # parted /dev/sdc
    GNU Parted 3.1
    Using /dev/sdc
    Welcome to GNU Parted! Type 'help' to view a list of commands.
    (parted) rm 1
    (parted) mkpart ext4 40s -1s
    Warning: You requested a partition from 20.5kB to 3001GB (sectors 40..5860533167).
    The closest location we can manage is 20.5kB to 3001GB (sectors 40..5860533134).
    Is this still acceptable to you?
    Yes/No? y
    Warning: The resulting partition is not properly aligned for best performance.
    Ignore/Cancel? i
    (parted) q
    Information: You may need to update /etc/fstab.

    ocean ~ # time mkfs.ext4 /dev/sdc1
    mke2fs 1.42 (29-Nov-2011)
    Filesystem label=
    OS type: Linux
    Block size=4096 (log=2)
    Fragment size=4096 (log=2)
    Stride=0 blocks, Stripe width=0 blocks
    183148544 inodes, 732566636 blocks
    36628331 blocks (5.00%) reserved for the super user
    First data block=0
    Maximum filesystem blocks=4294967296
    22357 block groups
    32768 blocks per group, 32768 fragments per group
    8192 inodes per group
    Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968,
        102400000, 214990848, 512000000, 550731776, 644972544

    Allocating group tables: done
    Writing inode tables: done
    Creating journal (32768 blocks): done
    Writing superblocks and filesystem accounting information: done


    real    0m14.333s
    user    0m1.646s
    sys     0m0.289s

There are two interesting things to note.
First, ```mkfs``` warns you when your partition alignment is incorrect.
Second, the time to initialize the ext4 filesytem was significantly faster on the aligned partition, validating both the warning from ```mkfs``` and the initial testing.
Note that parted warns about improper alignment in BOTH cases.
It [turns out](http://askubuntu.com/questions/201164/proper-alignment-of-partitions-on-an-advanced-format-hdd-using-parted) parted is only happy with 1MB alignment (for SSDs), which is too conservative in this case.

## Testing "real world" performance

To do my actual testing, I created a simple script that tested a small aspect of "real world" performance.
I wanted to test writing both small and large files, as well as some reads.
As a Gentoo user, I realized that simulating an update of the Portage ebuild tree would represent a good small file use case.
For those not familiar with Gentoo, the Portage ebuild tree is a collection of text files used to automate the compilation of system packages.
On my system, it currently consists of 137453 files in 23876 directories totaling 720MB on disk.
To simulate the action of updating the ebuild tree, I extracted an old and new [snapshot](http://distfiles.gentoo.org/snapshots/) to tmpfs,
then used rsync to copy the old, and then new snapshot to the same location on disk.

For large file performance, I tested copying a 4.4GB file from tmpfs to disk.

Here's the full script that allows me to create and mount a new filesystem, run the tests, and then unmount the filesystem in one step:

{% codeblock lang:bash %}
#!/bin/bash -ex

mkfs.ext4 /dev/sdc1 > /dev/null
mount /dev/sdc1 /mnt/test

time rsync -aH /root/tmpfs/old/ /mnt/test
time rsync -aH /root/tmpfs/latest/ /mnt/test

time cp /root/tmpfs/bigfile /mnt/test

umount /mnt/test
{% endcodeblock %}

## Results

I ran my test setup 3 times for both the aligned and misaligned partiton, recreating the partition and filesystem after each test.
Here's the average of all 3 tests results:

<table>
    <tr>
        <th></th>
        <th>Rsync old snapshot</th>
        <th>Rsync new snapshot</th>
        <th>Copy big file</th>
    </tr>
    <tr>
        <th>Misaligned Partition (sector 34)</th>
        <td>9.046s</td>
        <td>0.877s</td>
        <td>45.837s</td>
    </tr>
    <tr>
        <th>Correctly aligned partition (sector 40)</th>
        <td>7.399s</td>
        <td>0.939s</td>
        <td>33.348</td>
    </tr>
    <tr>
        <th>Speedup for correct alignment</th>
        <td>18.2%</td>
        <td>-7.0%</td>
        <td>27.2%</td>
    </tr>
</table>

### Testing Conclusion

Based on the tests, there is a significant real world performance speedup when using a correctly aligned partition, both for large and small writes.

Interestingly, there is a small performance _penalty_ shown during the second test.
I'm going to assume this test wasn't valid: I grabbed portage snapshots only a few days apart, meaning the changes to be synced are minimal.
It's doubtful that program execution times below one second are even accurate to be meaningful.
If someone else can come up with an explanation though, I'd love to hear it.

# Future work?

After doing all this testing, I started to wonder if the partitions on my SSDs are aligned correctly. SSDs are even more prone to write amplification, partially due to the fact that flash storage generally has to erase in large blocks (up to 256kb).
Hopefully in the next couple weeks I'll have time to write another blog post about it.

# Unaligned performance with 512 byte sectors

Just for fun, I wanted to see if there was a theoretical performance penalty for 4KB writes on a hard drive with 512 byte physical sectors, so I ran the write amplification script on an old 640GB drive that my new 3TB drive is replacing.

{% codeblock lang:bash %}
pismo ~ # time ./testWriteAmplification 0

real    0m16.799s
user    0m0.000s
sys     0m0.046s
pismo ~ # time ./testWriteAmplification 1

real    0m22.654s
user    0m0.000s
sys     0m0.066s
{% endcodeblock %}

Surprisingly, there was a performance penalty, although not as significant (I ran the test multiple times and the performance is consistent with the times shown above).
I imagine even hard drives with 512 byte sectors are optimized for writes aligned at 4KB.
The takeaway here is that it's important for all partitions, regardless of the underlying sector size, to be aligned correctly.

# Reference

For a full summary of the state of 4KB sector issues, the Linux ATA wiki has a comprehensive [page](https://ata.wiki.kernel.org/index.php/ATA_4_KiB_sector_issues).

##Full data from real world testing

For reference, here's all the performance data from my test script.

### Misaligned Partition
<table>
    <tr>
        <th></th>
        <th>Rsync old snapshot</th>
        <th>Rsync new snapshot</th>
        <th>Copy big file</th>
    </tr>
    <tr>
        <th>Test 1</th>
        <td>8.994s</td>
        <td>0.878s</td>
        <td>44.044s</td>
    </tr>
    <tr>
        <th>Test 2</th>
        <td>9.052s</td>
        <td>0.878s</td>
        <td>47.626s</td>
    </tr>
    <tr>
        <th>Test 3</th>
        <td>9.093s</td>
        <td>0.876s</td>
        <td>45.841s</td>
    </tr>
</table>

### Correctly aligned Partition
<table>
    <tr>
        <th></th>
        <th>Rsync old snapshot</th>
        <th>Rsync new snapshot</th>
        <th>Copy big file</th>
    </tr>
    <tr>
        <th>Test 1</th>
        <td>7.408s</td>
        <td>1.008s</td>
        <td>32.945s</td>
    </tr>
    <tr>
        <th>Test 2</th>
        <td>7.115s</td>
        <td>0.919s</td>
        <td>31.746s</td>
    </tr>
    <tr>
        <th>Test 3</th>
        <td>7.674s</td>
        <td>0.890s</td>
        <td>35.461s</td>
    </tr>
</table>
