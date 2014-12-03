---
layout: post
title: "Deconstructing Fizz Buzz with Flip-Flops in Ruby"
date: 2014-12-03 15:53:52 +0100
comments: true
categories: 
---
Ruby is small. If it's not your first programming language, picking up all the basic syntax in a
weekend isn't out of the question. I've been writing and reading Ruby code for several years now,
and figured I was closing in on at least familiarity with all the core concepts.

Of course, there's always more to learn, and there were more than a few very experienced Ruby
programmers that learned about a new operator last week: the
[flip-flop](http://nithinbekal.com/posts/ruby-flip-flop/).

Nithin's blog post gives a great overview of the syntax, so lets look at a more complicated example
from [Reddit](http://www.reddit.com/r/ruby/comments/2n987g/the_flip_flop_operator_in_ruby/cmbiwt8?context=1):
```Ruby
a=b=c=(1..100).each do |num|
  print num, ?\r,
    ("Fizz" unless (a = !a) .. (a = !a)),
    ("Buzz" unless (b = !b) ... !((c = !c) .. (c = !c))),
    ?\n
end
```

This code clearly came from an obfuscation contest[1], and I'm not even going to attempt to suggest
that I understood how this code worked after first reading it. But I was intrigued.  Never mind the
flip-flop operator, most of this code looks unfamiliar to someone used to reading idiomatic Ruby,
and I wanted to know how it all worked. So lets break it down piece by piece, and see if some sense
can be made.

## Starting out with some assignment

The first line is perhaps the most normal. Chaining assignment is used frequently in many languages.
And while many of the methods we use in
[Enumerable](http://ruby-doc.org/core-2.1.5/Enumerable.html), like `map`, return something useful,
the `each` method is actually defined on the `Range` class, and just 
[returns the range](http://www.ruby-doc.org/core-2.1.5/Range.html#method-i-each).

But the code above uses the `a`, `b`, and `c` variables _before_ the `each` iterator finishes, what is
their value then? Let's run a simple test script to find out:

```Ruby
# a no-op each
a = (1..2).each do |num|
  puts a.inspect # => nil
end
puts a.inspect # => (1..10)
```

Aha, it just is set to nil. Of course a variable that isn't first initialized will throw an error,
so this first line is really just a short way of initializing the `a`, `b` and `c` variables to
_something_, before the start of the iterator. Let's do out first refactor of the code then, to make
it more readable:

```Ruby
a = b = c = nil
(1..100).each do |num|
  print num, ?\r,
    ("Fizz" unless (a = !a) .. (a = !a)),
    ("Buzz" unless (b = !b) ... !((c = !c) .. (c = !c))),
    ?\n
end
```

This code works the same way, so we know it was really a refactoring, with no changes to the
behavior of the code.

## Fun with Printing

The next line is actually the entire body of the block passed to `each`: the
[print](http://ruby-doc.org/core-2.0/Kernel.html#method-i-print) method takes multiple arguments,
and notably, does not automatically print a newline at the end (`puts` on the other hand, does
always print a newline).

But what in the world does `?\r` do? It turns out to be a poorly-documented
[character literal](http://en.wikibooks.org/wiki/Ruby_Programming/Syntax/Literals). 
It's one character shorter than creating a string, such as `"\r"`, but with the same result.

And what is `"\r"` anyway? It's a [carriage return](http://en.wikipedia.org/wiki/Carriage_return),
the little known sibling of the newline. Even in the 21st century, our computer screens still
basically behave like a typewriter. Advancing to the next line and moving the cursor to the start
of the line are two distinct actions, and so they have distinct character codes. Of course, the fact
that Windows requires both a carriage return and a newline character, whereas Linux and OS X systems
assume a carriage return with just a newline,[2] creates more than a little confusion.

So, in any case, what sort of behavior can a carriage return character give us? Let's run a few
experiments:

```Ruby
print "hello", " ",  "world", "\n" # => hello world
print "hello", "\r", "world", "\n" # => world
print "hello", "\r", nil    , "\n" # => hello
```

How interesting! A carriage return lets us write some text, and then later while writing the same
line, essentially decide to erase that text. Remembering the requirements of the Fizz Buzz problem,
and how one must ONLY print a number when neither Fizz nor Buzz are printed, the utility of this
behavior is obvious.

# Finally, flip-flop

At this point we can easily describe the overall structure of the code: it loops through the numbers
1 to 100, using control characters to optimistically print the number, and then based on the logic
of flip-flops, print Fizz and/or Buzz instead of the number when appropriate. But when is the
"appropriate" time to print Fizz or Buzz? And how does a flip-flop and only three temporary
variables achieve that? Lets take a look at just the first use of the flip-flop, on line 3 of the
original code.

The first thing to note is that the conditions of the flip-flop operator are actually assignment.
This took me a long while to spot, and indeed is a
[common](http://cwe.mitre.org/data/definitions/481.html) source of bugs. In this case though, it's
not a bug, its a feature.

The flip-flop operator is going to evaluate the "truthiness" of whatever expression is inside it,
and remembering that the assignment operator in many languages returns a value, we can figure out
what the flip-flop operator will do.

We know the initial value of `a`, `b`, and `c` is nil, so lets start there.

```Ruby
puts (!nil).inspect   # => true
puts (!true).inspect  # => false
puts (!false).inspect # => true
```

So each invocation of one "side" of the flip-flop will gracefully handle the initial nil value of
the variables, and then swap them between true and false. The flip-flop operator consists of two
identical expressions though, so what behavior will that produce?

```Ruby
a = nil
(1..9).each do |n|
  puts "#{n} #{a.inspect}"
  "Fizz" unless (a = !a) .. (a = !a) # no output here, we just care about the changes to a
end
# =>
# 1 nil
# 2 false
# 3 true
# 4 false
# 5 false
# 6 true
# 7 false
# 8 false
# 9 true
```

So the flip-flop operator, with just a single state variable, is able to create a pattern that sets
a to true every third time! This is exactly how often we want to print "Fizz"!

How does this happen? If the only operation used is negating a boolean, the boolean will return to
its original value after an even number of operations. So how are an even number (maybe 2, 4 or
6) of operations squeezed into three runs of a loop? Lets investigate the value of `a` after each
condition of the flip-flop, rather than once per loop. We'll use two simple functions to print
within the conditions of the flip-flop:

```Ruby
# given a value, print its negation, then return its negation
def print_negate1(value)
  puts "a #{(!value).inspect}"
  !value
end

#same as above, but print b instead of a so we can tell
#which condition is being checked
def print_negate2(value)
  puts "b #{(!value).inspect}"
  !value
end

a = nil
(1..3).each do |n|
  puts "#{n}"
  "Fizz" unless (a = print_negate1(a)) .. (a = print_negate2(a))
end

# =>
# 1
# a true
# b false
# 2
# b true
# 3
# a false
```

As can be seen in the output, the flip-flop operator does indeed cause `print_negate` to be called 4
times in every 3 iterations. How? The first time through, the first flip-flop condition evaluates to
true (nil negated is true), so the second condition is checked, and `a` is set to false (true
negated is false).

The flip-flop is now "open". It will only check the second condition now. In the second iteration of
the loop, the flip-flop checks if should "close". False negated is true, so the flip-flop does
close. Finally, in the third iteration, the flip-flop checks only if it should open. True negated is
false, so it stays closed, and the cycle repeats.

There's one more complication: the flip-flop doesn't return based on the value of `a`, but on its
internal state. A flip-flop starts "closed", meaning it will return false. Once the first condition
evaluates to true, it is "open", and will return true until the second conditional returns true,
"closing" the flip-flop. So what is the state of the flip-flop after each of the 3 cycles above?

The first time, it starts closed, opens, and then does not close. Because of the `unless`, this does
not print "Fizz". The second time, it starts open, and closes, but still returns true, since "Fizz"
is again not printed. Finally, the flip-flop fails to open at all in the third iteration, and thus
returns false. This allows "Fizz" to be printed, exactly when needed.

So an interesting property of the flip-flop is that it returns true if it starts open, but then
closes.

# Buzz!

After dissecting the logic for printing "Fizz", we can describe without even reading the code
how "Buzz" will be printed: two variables will be used with some flip-flops to create a cycle that
repeats every 5 iterations of the loop.

But that description leaves a lot of the details, and in fact there's quite a bit more to be
learned. Looking at line 4 in the original code, the first thing we notice is a new operator, or at
least a variation: here there is a familiar flip-flop nested in the second conditional of what looks
like another flip-flop operator at first glance. However its important to note this flip-flop
consists of three dots (`...`) rather than the more familiar two (`..`). What's the difference?
Using our test code from above with this variant tells us:

```Ruby
a = nil
(1..9).each do |n|
  puts "#{n} #{a.inspect}"
  "Fizz" unless (a = !a) ... (a = !a)
end
# =>
# 1 nil
# 2 true
# 3 false
# 4 true
# 5 false
# 6 true
# 7 false
# 8 true
# 9 false
```

This variant simply alternates between true and false, meaning it has an odd number of negations in
every cycle. Theres not much Ruby documentation on the flip-flop operator, but the
[Perl](http://perldoc.perl.org/perlop.html) documentation describes the difference:

{% blockquote %}
If you don't want it to test the right operand until the next evaluation, as in sed, just use
three dots ("...") instead of two. In all other regards, "..." behaves just like ".." does.
{% endblockquote %}

The Ruby flip-flop behaves the same way, and therefore will only ever perform one negation per
iteration of the loop. Another way to describe the difference: the first flip-flop variant will
allow itself to open and close in the same invocation, whereas the second will not.

Instead of instrumenting all 3 conditionals in the two flip-flops for this part of the code, lets
see if we can just reason about it, and describe how it works.

First, we recognise the inside of the second conditional: its the exact same pattern as in the
"Fizz" line, but with the `c` variable. We therefore know that it will cycle through returning true,
true, false. However, its output is negated, so the second conditional in the first flip-flop is
going to cycle through false, false, and true. Lets work through a couple iterations of the loop and
see where this goes.

The first time through, `b` and `c` are both nil, and both flip-flops are closed. The first flip-flop
will evaluate `b = !b` to determine if it should open. That will set `b` to true and return true, so
the first flip-flop is now open. This flip-flop variant doesn't check if it should immediately
close, so we're done.

The second time through, the first flip-flop checks the second conditional to see if it should
close. We don't need to work through the logic of the second flip-flop, we know it will return false
this time, and so the flip-flop stays open. Remember, the `unless` statement means we will only
print "Buzz" when the flip-flop returns false(is closed)!

We also know the result of the third time through: the flip-flop is open, and again the second-flip
flop will return false; the first flip-flop stays open, and nothing is printed.

The fourth time, the first flip-flop DOES close. However, remember that a flip-flop returns true
when it transitions from open to closed, so once again we don't print anything.

On the fifth iteration, the flip-flop starts closed, `b` is currently true. The first
conditional of the flip-flop is evaluated, and the result is false! This means the flip-flop doesn't
open, returns false, and finally, "Buzz" is printed, exactly when we need it.

# Fin

Wow, that was some serious thought for just a few lines of code. I've put all the example code 
on [Github](https://github.com/orangejulius/ruby-flip-flop), feel free to fool around further.

Needless to say, while I enjoyed the exercise, like most of the Perl-isms in Ruby, I won't be using
flip-flops in production code any time soon.

- - -

<div class="footnotes" markdown="1">
[1] If anyone knows or is the author, let me know!<br>

[2] Probably a gross simplification or outright lie. If anyone wants to suggest a more accurate
explanation that is also concise, please do!
</div>
