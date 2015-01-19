---
layout: post
date: 2014-09-04 21:17
title: Three Git commands you should never use
categories: git
---

Ahh, Git. One of the most powerful tools of our time. Also, one of the most confusing. There's no
doubt that Git has a few rough edges.

Many complain that Git is too difficult to use, and that it's easy to shoot yourself in the foot.
I'd agree to an extent, but in my experience, Git also gives you the tools to fix any problems you
cause.

In my mind the most dangerous commands in Git aren't things like `git rebase`, because any mistakes
you make with already committed data can be fixed (perhaps with a little help from `git reflog`).

Instead, the most dangerous commands in Git are those that prevent you from getting your data into
Git correctly in the first place, those that make the Git history harder to read than it had to
be, or those that behave unpredictably and hide too much information from the user.

These commands are quite popular, but I stand firm, you should never use any of them.


## git commit -a

On the surface, `git commit -a` is just a timesaver, and who doesn't like to save time? In
principle, there's nothing wrong with a command to commit everything at once. But in practice, I
find that invariably when using `git commit -a`, something not meant to be committed will be
committed. Big surprise. It might be a harmless `console.log`, or it could be massive temporary
simplification of a critical bit of code.

I like to take a second before each commit and review exactly what is going in. I've set up a
helpful `git st` [alias](https://github.com/orangejulius/dotfiles/blob/master/gitconfig#L8) that
shows me a denser version of `git status`.

Usually, I'll use one of my favorite little known Git features, `git commit -p` (`git
checkout`, `git stash`, and many other commands also accept the `-p` flag), which will go through
each section of changed code and ask whether or not you want to commit it. It comes with handy
keyboard shortcuts meaning you can go through lots of code in only a few seconds, and if anything is
there that shouldn't be committed, you can skip right over it.


## git commit -m

There are two reasons why I hate `git commit -m`.

First, it incentives short, unhelpful commit messages. On any size team (even a team of one),
commit messages are one of the most useful ways to record knowledge from that critical time when code
is actually written. `git commit -m "fixed big"` throws that opportunity right out the window.
Please everyone take a second and write awesome commit messages. Did you know Git commit messages
have a [well established
format](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html) that all editors will
help you with, and allows writing as much of a description as you want? It wasn't written for
nothing.

Second, did you know that Git will sometimes write your commit message for you? It's true! Whenever you
perform a merge that isn't simply a fast-forward, Git will generate a beautiful commit message
automatically.  It records which branch was merged into which right in the commit subject, and puts
a list of any files that had conflicts in the body. Those are the most likely places where bugs
might have sprung up, so the value of keeping track of them should be clear.

You get all this for free, unless you use `git commit -m`.


## git pull

Of the three commands, this is probably the most used. As a result, the negative effects will be
felt the strongest. And what bad thing happens with `git pull`? Nothing less than a permanently
confusing history (gasp)! While it's true that one can figure out what happened with even the most
convoluted history, why would you inflict that upon your friends, colleagues, and coworkers if you
don't have to?

So how does it happen? It takes three steps:

1. Work is done by you directly on the master branch (or whichever branch will be pulled from
eventually).
2. Someone else also works directly on the branch and pushes their changes first.
3. `git pull` is run and a merge commit is generated for even trivial and completely independent
changes.

Taken on its own, one extra merge commit is not a big deal. But if even two or three people are not
working to prevent unneeded merge commits, things get nasty real fast.[1]

The dangers of `git pull` come partially from it's bloated nature: it both fetches updates from
others, and immediately and automatically decides how to reconcile those changes with yours. This
should be two steps.

My workflow is to periodically run `git fetch`. This ONLY updates my remote branches, so I can see
what work others have done. Usually, I'll quickly inspect the changes that have been pushed using
another great [alias](https://github.com/orangejulius/dotfiles/blob/master/gitconfig#L7), `git lg`.
Finally I decide what to do. Usually I simply want to make a linear history with my changes coming
after the changes I just pulled. `git rebase` will accomplish this just fine, and then if it turns
out the resulting conflict resolution is difficult, I can abort the rebase or start over and know
exactly where thing stand.

On the other hand, even with `git pull --rebase` (which is a more sensible default than to merge),
any conflict resolution is done immediately. There wasn't a chance for you to figure out what sort
of changes were just pulled in (are they huge refactorings that will change a lot and require
careful analysis? Or were they simple changes that shouldn't be a big deal), so resolving the
conflicts is also hard. And what will the state of your working copy be after you abort the conflict
resolution? Good question.

## In summary

Everything that I believe makes for good Git usage comes from a few simple rules: understand what is
happening under the hood, use source control as a great source of information, and play nice with
others.

These are a few things that don't work with those rules, next time I'll cover some ways to follow
them.

- - -

<div class="footnotes" markdown="1">
[1] For a great example of good and bad merge commits: check out
<a href="https://gist.github.com/jbenet/ee6c9ac48068889b0912">this</a> helpful Gist.
</div>
