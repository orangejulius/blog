---
layout: post
title: "The power of changing history"
date: 2014-02-17 18:34:51 -0800
redirect_from: /blog/2014/02/18/the-power-of-changing-history/
comments: true
categories: git personal-personal-goals-post
---
Writing code that is easy to read and understand later is arguably the most important habit of a
good software developer. There's plenty that has been written about what the resulting code looks like,
but theres more that goes into reading your code than just, well, your code. How you share your code
with others helps too.

If you're using Git (or any other distributed version control), then you have
an incredible new power to aid in the understanding of your code, something someone using
Subversion (or any other centralized version control) simply doesn't have. I'm writing all this
because I see so few people taking advantage of it.

The advantage is simple: with Git, you can rewrite history.

As a simple example, consider the common "forgot to check in a file" commit. With Subersion, there's
no way to fix this simple mistake, no matter how soon after committing you catch it. For all time
one logical group of changes will be split into two places. With git, a simple ```git commit
--amend``` makes things right[1].

The damage done by not repairing this sort of commit is real: the history of a project is an
extremely valuable source of context and understanding. Every commit is a chance to record
why something was done, and what it is supposed to accomplish. When reading code, these are arguably
the most important questions to answer. Simply looking at code, even well written code, can mean
spending time deducing the answers. With a well managed history, the answers are out in the open.

There's a nearly endless list of ways to create a more valuable history. Most of them are, in fact,
widely talked about. Git has cheap branching; use it to keep changes that solve different problems
separate. There's no reason to have a bugfix commit in a feature branch. There's no reason not to
split work on dependencies of a large feature into separate branches.

Commits should be made frequently. Initially, there's no need for them to have any special meaning
or semantics, because commits are infinitely malleable. Take advantage of ```git rebase``` and
massage your many, disorganized commits created during development into a readable, ordered list of
semantically meaningful changes. With practice, these types of improvements can be made quickly.

Invariably, talk of these types of changes seem to devolve into an argument over the concept of an
immutable history. The idea is that as with Subversion, all project histories should record every
change ever made, in the order they were initially made, regardless of the significance of each
change. This is the most basic requirement of source control, but not the only one.

What's often missed is that with Git, you can have the best of both worlds. Develop your feature
however you want. Create dozens of messy, disorderly commits. Use commit messages that convey no
information whatsoever. Stow these changes away somewhere. Use a tag, or a branch specifically for
changes made during active development[2].

Now that you know how your code should be written, take just a couple minutes and reorganize,
reorder, and coalesce. The details of how the code came to be are no longer important. The priority
now is separating changes into logical, semantic units that, when taken in order, come together to
make the change in a readable and understandable way.

Everyone on your team will be asking questions your commits can answer. Even future you will ask
need reminders about the history of your code. Don't make anyone have to figure out your code on their
own, give them all the help you can! You're not using Git to the fullest if you don't.

[1] With the usual warning to not use ```git push --force``` if it would disrupt others.
[2] An awesome feature of git branches is that they can contain nearly any character, including
slashes. I've seen projects that use this to split branches into categories. There can be categories for bug
fixes, experiments, development, etc. The initial, unstructured writing of code done during early
development can certainly be a category.
