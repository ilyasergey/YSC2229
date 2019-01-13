.. -*- mode: rst -*-

Introduction
============

About this course
-----------------

Data represents information and computations represent data
processing, i.e., obtaining **new** information for what we already
know about the world.

An **algorithm** is any well-defined computational procedure that
takes some data value, or set of values, as input and produces some
value, or set of values, as output, always terminating with a result.
An algorithm is thus a sequence of computational steps that transform
the input data into the output data.

In this course, we will take a look at some of the problems that can
be solved by algorithms, learn how to approach challenges that require
algorithmic solution, and, most important, will learn how to *reason*
about crucial properties of algorithms: correctness, termination, and
complexity.

What problems are solved by algorithms?
---------------------------------------

Algorithms describe a problem in a way that it could be implemented as
a computer program and solved automatically. You can think of an
algorithm as of a description of a procedure that achieves that.

For example, we might need to sort a sequence of numbers in a
non-decreasing order. This problem arises frequently in practice and
provides fertile ground for introducing many standard design
techniques and analysis tools. Here is how we formally define the
sorting problem:

* **Input**: a sequence of numbers ``a1``, ``a2``, ..., ``an``.

* **Output**: a permutation (or, reordering) of the initial sequence
  ``b1``, ``b2``, ..., ``bn``, such that ``b1 <= b2 <= ... <= bn``.

The description above presents a specification of a problem, but does
not describe how to come from input to an output. Indeed, there might
be many *ways* to approach the same specification, and, as an
characteristic example, there multiple algorithms for solving the
sorting problem, some of which we will see in this course.

Obviously, sorting sequences is not the only class of problems that
can be solved by means of an algorithm. Some other problems include:

* Searching -- quickly finding an element satisfying certain
  requirements in a large collection of other elements. This is a
  problem frequently appearing in the context of e-commerce (think
  about searching for a book to buy on Amazon).

* Data compression/decompression -- representing an information so it
  would take the least memory, making it easier to store and transmit,
  while retaining the ability to restore it without any losses. As an
  example, think of video and audio encoders and decoders, whose goal
  is to minimise the size of a file to be streamed, while keeping its
  high quality.

* Path finding -- navigating from a point A to a point B, in a
  quickest way, given a fixed map.

* Optimisations in manufacturing and other commercial enterprises. For
  instance, you can think of an algorithm that computes an arrangement
  of cables allowing to connect a number of call centers in a least
  expensive way.

* Various geometric problems: for instance, locating the closes
  facility to one's position on a map, or installing a set of security
  cameras in an art gallery in the most efficient way.

Some real-world problems might require multiple algorithms to solve.
As instances of such a problem, on the lectures we discussed (a)
*move-and-tag* problem, in which a number of robots need to awake in a
shortest possible period of time, by waking up each other, and (b)
*room furnishing* problem, in which one need to cover the maximal room
surface with furniture. We will discuss those problems and how to
approach them in a class.

Data structures
---------------

Obviously, some of the tasks outlined above can benefit from a data
arranged in a more convenient way. For example, if one is interested
in finding the largest element in a collection, it would help to have
this collection first sorted. As another example, if one wants to
represent a map of roads of different length, which is suitable for
calculating shortest paths, it is wise to invest some time into
thinking on how to arrange this information to facilitate retrieving
the relevant topographical properties.

Data structures are means to organise information in ways that make it
conceptually simpler and faster to retrieve the bits we might need in
the future. Some of the data structures you have already seen in the
past are lists, trees, and arrays. However, more intricate problems
will require more sophisticated data structures. 

Therefore, on the goals of this course is to show how to pick a right
data structure for a corresponding problem.

What is analysis of algorithms?
-------------------------------

When we solve a problem algorithmically, we need the solution (i.e.,
an algorithm providing an answer) to satisfy the following hard
criteria:

* **Correctness**: Does the algorithm really do what it’s supposed to
  do?

* **Termination**: Does the algorithm terminate for any given input.

* **Complexity**: Why the algorithm consumes so much resource (time,
  memory) and how can we improve it?

An algorithm that is simply not correct is not worth much (although
the notion of correctness is, as we will see, in the eye of the
beholder). An algorithm that does not terminate, but only on very
special cases, might be actually useful. Finally, the analysis of
computational complexity tells us how slow will be an algorithm in
certain cases or how much memory will it consume.

In terms of time consumption, problems that can be solved
algorithmically can be themselves partitioned to several classes:

- **tractable problems** - admit solutions that run in "reasonable"
  time: sorting, searching, compression/decompression.

- **possibly intractable** — probably don’t have reasonable-time
  algorithmic solutions: SAT, graph isomorphism

- **practically intractable** — definitely don’t have such solutions:
  the Towers of Hanoi

- **non-computable** — can’t be solved algorithmically at all: the
  halting problem

A good programmer should be able to guess correctly whether the
problem she is trying to solve algorithmically belongs to one of those
classes.

There are two ways to analyse algorithms for correctness, termination
and complexity:

* **Empirical** -- repeatedly run algorithm with different inputs to get
  some idea of behaviour on different sizes of input. This approach is
  very practical (and we are going to rely on it a lot), but has
  certain shortcomings:
  - was our selection of inputs representative?
  - this consumes the very resource (time) we are trying to conserve!

* **Theoretical** -- a mathematical analysis of a "paper" version of the
  algorithm:
  - can deal with all cases (even impractically large input instances);
  - machine-independent.

Useful Resources
----------------

* Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, Clifford
  Stein. 
  **Introduction to Algorithms**; 3rd edition.
* Robert Sedgewick, Kevin Wayne. 
  **Algorithms**; 4th edition.


.. _exercise-algo-example:

Exercise 1
----------

Give an example of a real-life application that requires an
implementation of and algorithm (or several algorithms) as its part,
and discuss the algorithms involved: how do they interact, what are
they inputs and outputs.

.. _exercise-merlin-setup:

Exercise 2
----------

Programming in OCaml in Emacs is much more pleasant with instant
navigation, auto-completion and type information available. It is
recommended that you install Merlin_ mode for this and learn its
shortcuts

.. _Merlin: https://github.com/ocaml/merlin/wiki/emacs-from-scratch






