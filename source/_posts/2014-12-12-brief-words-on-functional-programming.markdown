---
layout: post
title: "Brief Words on Functional Programming"
date: "2014-12-12 10:31:43 +0100"
comments: true
categories: ruby functional-programming
---

_A few days ago I
[reviewed](http://exercism.io/submissions/7e7c495ab72742afa2848db0937f9748) some code on the awesome
[Exercism](http://exercism.io) project. My comments touched on a lot of ideas
I've been meaning to jot down about functional programming, or at least some
aspects of it when using Ruby, so I've adapted the comments into the following
blog post._

Whenever you have a loop that is modifying a variable in each iteration of the
loop, consider a functional programming approach. It will usually result in less
code setting up and returning variables, which makes the code that actually does
the interesting stuff stand out more.

Any time you are taking every element of an array and want to produce another
array with modified variables, you can use `map`. And any time you have an array
and want to use each value in the array to construct a single result at the end,
you want `reduce`.

To explain the difference, from a more common, imperative approach, let's
imagine you have a short array of integers, and you want to create a new array
with all those integers incremented by one. You might do it like this:

``` ruby
def add_one_to_array(old_array)
  new_array = []

  old_array.each do |element|
    new_array<< element+1
  end
  new_array
end
```

That will work just fine. And because you've probably written tons of loops just
like that one, it feels intuitive. But I would argue you can make the code much
clearer, while doing the same thing, and reducing the chance of bugs sneaking
in. Here's how:

``` ruby
def add_one_to_array(old_array)
  old_array.map do |element|
    element + 1
  end
end
```

When you call `.each` on an Enumerable (the module that handles all sorts of
stuff regarding working with arrays and other collections), all `.each` does is
execute whatever is in the block (everything inside the do...end in each method
is a block). Thats why the code in the first example has to actually do the
heavy lifting of pushing data into the `new_array` variable.

The `.map` method on Enumerable does a bit more for you: it uses the return
value of the block you pass to it, and collects all the return values from
running the block with each element, turning that into a new array. You don't
have to bother creating a variable and assigning it into an empty array,
explicitly updating the array, or even returning the array. The return
value of `.map` is the array that results.

It also tells everyone reading the code something very important: the code that
follows takes some code and uses it to transform one array into another. With
`.each`, it could do anything, so you have to carefully read the code to ensure
it doesn't do something weird.

There's a whole bunch of helpful methods defined on Enumerable, and the
[docs](http://ruby-doc.org/core-2.1.5/Enumerable.html) are quite helpful. They
all do different things, but the idea is similar: they all work on a collection
of some sort, and each one can be thought of as a single, specialized, powerful
tool. Go read through the documentation and fool around with a couple.

The best part about is all this functionality is available across many
languages.  After a while, you'll be able to jump into countless languages:
Scala, Javascript, Haskell, and of course all the Lisps share these ideas, even
if the details or names differ.

Rather than simply learning the quirks of a Ruby library, you're learning a
vocabulary and toolset that all functional programming languages share!
