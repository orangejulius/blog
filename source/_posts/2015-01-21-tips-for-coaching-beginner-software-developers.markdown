---
layout: post
title: "Tips For Coaching Beginner Software Developers"
date: 2015-01-21 18:13:04 +0100
comments: true
categories: mentoring
---
For most of my time as a programmer, I've thought about learning in exactly one
context: teaching myself more stuff. In the past few years though, I've made an
explicit effort to focus on the opposite problem: teaching others, especially
complete beginners.

And I'm so glad I've made this effort, because it's been _extremely_ fun and
rewarding. It's not easy, and I'm certain I come home from a day of teaching at
least as exhausted as I have ever come home from a day of coding, but it's been
worth it. I don't just help others into the field of software, but I myself
become a better software developer: so much of what we do involves working with
each other rather than computers themselves.

My goal here is to share as much of what I've learned so that anyone looking
to start coaching can benefit from my experience. I hope experienced mentors
will share their own thoughts too.

## Praise Often, and Remind Learners that Getting Stuck is Normal
This is the most basic and core concept I've learned about teaching.

Remember that almost every student comes into the classroom worried, if not
convinced, that they simply don't have whatever mental faculties or background
it takes to program. The world is full of voices that have told them this.
Unfortunately, many of these voices come from within the software community.

Moreover, however much we programmers debate between ourselves if coding is more
like math or writing, most students are terrified of anything that possibly has
a mathematical foundation.

Women, kids, older people (according to Silicon Valley logic, anyone past 25 is
probably considered "old"), and minorities are usually especially worried[1],
but you'd also be surprised how much fear a few lines of Ruby can impart on
young, well educated white guys.

Programming is hard and the fear of failing and looking dumb is something
everyone struggles with.  As a teacher our job is to combat that.

So far, my go-to tactics are:

1. strongly asserting that every programmer, no matter how experienced,
   struggles when learning. There aren't certain people born with an ability to
   pick up programming without making any mistakes.
2. reminding students that they are capable of learning to code, and that the
   satisfaction that comes after struggling through something and finally
   prevailing is really enjoyable.

It's not enough to simply state these things, they have to be proven through
actual actions in the classroom. The first is easier: don't be afraid to admit
what you, even as a teacher, don't know. Anyone who has taught knows that
there's no better way to secure a solid understanding of something than to teach
it to someone else. As your understanding grows, be sure to share it with your
students.

I don't think there's any shortcut for the second: nothing but actually getting
the student to accomplish something that challenged them will do. Any coding
curriculum should focus on quickly getting a new student to successfully build
something, by themselves, to set a mood that encourages them. This is hard, but
easier than ever today: we can write [a few lines of Javascript](http://opentechschool.github.io/js-beginners-4h-workshop-1/sandbox/#drawing.js)
and have our students create pretty pictures quickly. It might have taken weeks of
painstaking work learning advanced C++ and OpenGL to do the same thing a few
years ago!

It's not completely clear to me where to draw the line when reminding students
that getting stuck and making mistakes is normal. Sometimes I've taken a rather
cynical route and said things like "our puny human brains simply aren't very
good at writing bug-free code, so we have to do what we can to keep our code
simple, and we'll still make mistakes all the time". Some students probably
appreciate brutal honesty and dark humor, others might appreciate a lighter
touch.

## Teach by Asking Lots of Questions, Carefully
No less a teacher (and learner!) than Socrates ensured that asking questions
will always be core to every teacher's tool belt, but there's some nuance here
that is extremely important to remember to keep it from backfiring.

Remember that every student is almost completely convinced they aren't cut out
for programming. If you're particularly lucky (or good!), they are having a good
time so far and have made something cool already. Still, most new students are
probably one frustrating moment of giving up forever.

The reason why asking questions works so great for teaching is that in the
process of coming up with an answer (any answer, not even a correct one!),
forces students to think hard about something, and that's how you learn. A
talented mentor can ask questions that guide a student towards understanding
without actually _telling_ them anything[2].

But being asked questions on the border of your knowledge is extremely taxing,
and sometimes students just don't come up with a good answer. Sometimes the
question is bad, sometimes the question wasn't properly matched with where they
are in the learning process, and sometimes they just need the question phrased
differently.

Not being able to answer a question can be pretty demoralizing, but there are
ways you as a coach can make it worse! There are two pitfalls: asking "obvious"
questions, and trick questions.

"Obvious questions" are useful, but dangerous. One way they often come about is
when walking through some code, mentally performing each operation in turn. As we try
to remind new coders, most math in programming is nothing more complex than
basic arithmetic. For example, a teacher and student might have this exchange
when going over a basic `for` loop:

>"OK, we set `i` to zero. Next we add one. Zero plus one is?"

>"One"

>"Then we do [whatever is in the loop]. Then we start over: what was `i`?"

>"One"

>"Good, next we add one to `i`. One plus one is?..."

>"Two"

If the student is with you, and knows what the result will be, everything is
great. But sometimes all the chaos of learning is overloading their brain for
the moment. They're trying to answer, but they just can't right now. Students
can usually tell from the tone of your voice you expect them to know the answer,
and when they can't it's really demoralizing. Be careful.

Trick questions are also something I try to avoid. It's far too easy to
demoralize your student by making them think you're showing off.

Really, avoiding the pitfalls of asking questions just comes down to doing
everything it takes to ensure to your student is sure you're there to help them
learn, rather than to make them feel bad, or to show off your skills. Create
that environment, and then use questions wisely!

## Don't be Afraid to Review the Basics
A standard first day of coding ever usually looks something like this:

1. type some extremely simple expressions into a REPL
2. type almost identical expressions into a REPL, but assign them to named
variables
3. fool around with strings and classes (maybe)
4. learn simple functions and loops
5. do Cool Things&trade; with all that knowledge

To keep students from becoming bored, there's often a big push to move through
the basics quickly. It's much more exciting to actually build something cool,
and you generally can't do that with just expressions in a REPL, so this
approach is reasonable.

But typing a few lines is not enough to learn any programming concept, and in
some ways the foundational programming concepts are the hardest to truly grok.

What I often see is students go through the quick intro to variables, or
functions, or loops, and because the examples are so simple, they feel mostly
comfortable and move on. Then, when trying to build something more complicated,
they get stuck not because of the new material, but because they are reaching
the limits of what they've learned previously.

Most coding tutorials are written assuming students know all about variables by
the time they get to for loops or functions, but that simply isn't the case.

Don't be afraid to go back a step or two when needed.  A coach is absolutely
critical for this, because experience allows the coach to figure out which core
skill is lacking, and figure out how to fix it.  Sometimes the student's current
exercise can be adapted, even if it's for something more advanced, sometimes a
simple example needs to be created on the spot.

In addition, there are some nuances to basic programming that I've discovered
students have trouble with. They aren't generally given entire chapters in a
curriculum like variables and functions might, so they don't get much coverage.
I've found it takes a decent amount of time to explain these areas.

The first is scope.  Christina Cacioppo's _Learning Online_ calls out
[variable scope](http://christinacacioppo.com/blog/learning-online)
as one of the most challenging basic concepts for students to learn, and my
experience agrees. This is understandable, because every language has different,
complicated, and sometimes
[unexpected](http://toddmotto.com/everything-you-wanted-to-know-about-javascript-scope/)
(yes I'm looking at you Javascript!) rules for it.

At least for function scope, I've found something that works reasonably well:
temporarily rearrange the students source code so that only the function they
wrote, OR the code they wrote that calls it, but not both, can be seen on the
screen at once (the low tech solution is to just insert a bunch of newlines).
Then, we can reason about each bit of code independently.

Around this time students often get confused by function arguments and local
variables passed to those functions that share the same name. I would love to
hear peoples thoughts on whether these names should be changed to be unique, or
kept the same.

In any case, when students can't see both functions on their screen, they
usually seem to be able to skirt around this area. I do know its helpful to
remind students that calling functions they themselves have written is no
different than calling other functions, which they've no doubt already done.

Another tricky concept is control flow during loops. It usually takes students
a while to be able to calculate in their head what values a variable will take
during each iteration of a loop, for example. Perhaps it's the fact that a line
like `i = i + 1;` looks much like an algebraic formula, but of course isn't
valid, or maybe it's the idea of the same line of code executing multiple times
with a variable having a different value each time that's confusing[3].

## Teach by Modifying Existing Code

Most of the time, students start with little or no code, and build up something
bigger, but this isn't the only way to learn.

I like to take some existing code, especially code the students have written,
and suggest changes to it. The key is to have the student make the changes, and
before they run the new code, ask them what they think will happen. It's OK if
they don't know, but they have to give it a good thought at least.

This works best once students are working with code with a little bit of
complexity. Loops (especially nested loops), provide lots of parameters to tweak
that can provide interesting learning opportunities.

My favorite path goes something like this:
Start with a simple for loop (a more advanced exercise nests two):

```Javascript
for (var i = 0; i < 10; i += 1) {
...
}
```

1. Ask the student to double the termination condition from 10 to 20. Students
   usually get that this will make the loop do more of whatever it was doing
   before.

2. Change the start condition to something negative, say -5. Most students are
   initially perplexed but realize why it works fairly quickly once they see the
   output

3. Change everything else back, and then change the iteration from `i += 1` to
   `i += 2`. Interestingly in my experience, students usually realize that the
   loop will now "skip" every other iteration, but don't know, or don't mention,
   that the loop will also only run half as many times. With a little more work,
   when they figure it out, it's usually a pretty big moment of understanding
   that feels good for the student.

## Do Not Enforce Your Professional Coding Standards
As an experienced developer, you've gotten to where you are by being pretty
tough on yourself. You have strict standards for the quality of your code or
your team's code, and are more than willing to call teammates out to make the
code more maintainable in the long term. On a professional team, this is a good
thing.

When working with brand new programmers, it's a great way to demoralize. The
place where this is seen the most is in indentation, whitespace, and general
code formatting. While you've probably formed strong opinions on exactly how
code should be formatted, new programmers have no such concerns. It isn't even
on their radar. When you're just figuring out how variables work, coming up with
a good variable name isn't something you can even begin to deal with.

Your job as a mentor is to ignore whatever horrors of coding style your students
produce. I'm willing to claim that there is no code a first-day student can
write that you can't read well enough to coach them just fine.

At all costs, don't express any disgust at your student's code. Even something
like "well, before I can help you, we have to fix your whitespace", is enough to
make someone feel really bad. I personally don't bother pointing out most coding
style issues to beginners.

If you really want to, you can do it, but only when your student is at a point
where they've just had success solving a problem and are feeling good. Then
very gently suggest syntax improvements. Something like "okay, now that you've
got that working, lets make a quick change so that your code is easier to work
with later".

New students aren't generally concerned with the "beauty" or "elegance" of their
code[4], so motivating them with those sorts of concerns probably won't work.
However, students generally ARE receptive to the idea of simplifying code, and
offering ways to make their job easier later is often much appreciated.

## Kids are the Ultimate Challenge

I've had the opportunity to help mentor younger kids (below age 12 or so) just a
few times, and it's been a blast: a tiring and intense blast.

In my (limited) experience, the challenges are not fundamentally different than
those for adults, but the magnitude of the challenge, and the amount of leeway
you have in solving those challenges are vastly different.

Like adults, kids are apprehensive about their abilities, and just as
worried about failing. What makes kids different when learning to code is, I
think, what primarily makes kids different from adults in anything else: kids
aren't good at managing their emotions, and kids aren't as able to delay
gratification. Let me give some examples:

* With an adult programmer, seeing a more advanced student's work isn't
  discouraging, because they understand that they will be able to build more
  impressive things over time. Kids see someone next to them doing something
  cooler than they're doing, and are often immediately unhappy. Even if they do
  get a little jealous, adults won't tell you. Kids definitely will make it
  known!

* Adults are able to push themselves all afternoon to learn something. They've
  experienced enough times when hard work paid off. Kids, when mentally
  exhausted, will make it painfully obvious. "Lets play an easier game", a kid
  once said to me after about 3 hours of working with Scratch.

* Similarly, adults are more receptive to spending time on "boring" building
  blocks, like variables and functions, before building something "cool". I
  think the only effective way to teach kids is to make the entire process as
  fun as any game, and that's just plain hard with some of the basics. This is a
  hard problem to solve. Actually, it would make it much easier to teach adults
  too, but it's more critical for teaching kids.

* In general, adults have more determination to code. Adults know their time
  spent learning to program might have huge professional or financial upside
  later. They're willing to put in a little work. Kids on the other hand, aren't
  motivated by such things: learning to code has to be a game, and if the game
  isn't fun for even a short while, it's hard to press on.

### Does _Show And Tell_ Help or Harm?

Here's something interesting I've been thinking about: a lot of events for kids
have a big demo at the end where all the kids get up on some sort of stage in
front of everyone and show off what they've built. I can see how this can be
really helpful: telling kids their work is worth showing off, and giving them an
opportunity to do so, sounds like a positive thing.

But like I said, when kids see the work of a more advanced student, it's really
easy for them to get demoralized. The problem with these demos is that they
often mix kids of vastly different ages and skills.

When a 7 year old shows off his or her extremely basic thing that he spent all
day struggling through, and then a 12 year old shows off this complex thing, is
the 7 year old really going to feel good?

I think the answer is more often than not, unfortunately, no. I can't help but
thinking that show and tell is mostly for parents to feel good, and that the
effect they can have on a young students morale can be serious. Maybe demos
should only be allowed when the age and experience level of all the students are
similar.

### Scratch

One last thought, I want to talk about [Scratch](http://scratch.mit.edu/) for a
second. Overall, I think Scratch is amazing for teaching kids. It makes it
quick and easy to add really powerful visuals to programming, and doesn't
involve typing, which is actually a big deal for younger kids. The iPad app is
flat out fantastic and easy to get started with as well.

However, I wish it came with more built in features that were higher level. For
those that aren't familiar, Scratch basically has you click and drag various
blocks that more or less map to programming primitives, like if statements,
variables, for loops, etc.

These primitives can be used to build anything, but it would be nice if it came
with more powerful blocks, even if they didn't correspond to programming
primitives, so that at least some aspects of programming could be taught while
keeping things fun for kids. It would be especially cool if, when the student is
ready, these higher level blocks could be inspected and the actual primitives
underlying them could be seen. Scratch does allow you to define your own blocks,
so maybe someone has done this, and if so I'd love to hear about it.


## Onward

For anyone looking to start coaching without a lot of experience, I can't
recommend enough that you do it! You won't be a perfect coach immediately, but
as long as you are willing to commit to genuinely wanting your student to
succeed, you'll get better.

It's a completely new set of challenges for those of us used to writing code
ourselves, but it's something every software developer should practice.

Before long, when you've mastered the art of not
[touching the keyboard](https://opentechschool.github.io/slides/presentations/coaching/?full#donts_keyboard),
you'll know you've gained a valuable skill. Better yet, you'll have helped
excite and encourage a bunch of new software developers!

_Thanks to [Charlotte Chang](https://twitter.com/pushorpull) and
[Joanne Daudier](https://twitter.com/jdaudier) for reviewing this post_

---

<div class="footnotes" markdown="1">
[1] Without a doubt, coaching events targeting specific groups like
BlackGirlsCode, RailsBridge, etc. are an enormous help and are absolutely
necessary. I'd encourage anyone to volunteer at these events: it's an eye
opening experience for those of us who got here without the explicit
discouragement many groups of people face.<br>

[2] Its probably not a good idea as a coach to only ask questions, but they're
a great start, and knowing what extra bits of clarifying information to add when
a student has figured out something on their own can really help. Adding too
much information can hurt as well, so it's a balancing act like many things.<br>

[3] A lot of people will probably say the solution is to teach functional
programming, all variables should be immutable, and all functions pure. I think
this might actually be helpful, at least in some cases. Students definitely are
comfortable with the idea of a function that takes some inputs and just does
something with them. Functions or methods that maintain their own state often
perplex them.<br>

[4] According to Charlotte Chang, who recently went through a developer bootcamp
program, many developers quickly do become very focused on code aesthetics, so
if you're coaching more experienced students, this may not be the case. And if
you are coaching very new students: enjoy it while it lasts!
</div>
