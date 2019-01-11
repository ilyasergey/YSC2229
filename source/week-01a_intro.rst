.. -*- mode: rst -*-

Introduction
============

About this course
-----------------

Data represent information and computations represent data processing,
i.e., obtaining **new** information for what one already has.

An **algorithm** is any well-defined computational procedure that
takes some value, or set of values, as input and produces some value,
or set of values, as output, always terminating with a result. An
algorithm is thus a sequence of computational steps that transform the
input into the output.

In this course, we will take a look at some of the problems that can
be solved by algorithms, learn how to approach new problems that
require algorithmic solution, and, most important, will learn how to
*reason* about crucial properties of algorithms: correctness,
termination and complexity.

What problems are solved by algorithms?
---------------------------------------

Algorithms are a way to describe a problem in a way that it could be
implemented as a computer program and solved automatically. You can
think of an algorithm as of a description of a procedure that achieves
that.

For example, we might need to sort a sequence of numbers into
nondecreasing order. This problem arises frequently in practice and
provides fertile ground for introducing many standard design
techniques and analysis tools. Here is how we formally define the
sorting problem:

* **Input**: a sequence of numbers ``a1``, ``a2``, ..., ``an``.

* **Output**: a permutation (or, reordering) of the initial sequence
  ``b1``, ``b2``, ..., ``bn``, such that ``b1 <= b2 <= ... <= bn``.

The description above presents a specification of a problem, but does
not describe how to come from input to an output. Indeed, there might
be many ways to approach the same specifications, and, as an examples,
there multiple algorithms, solving a sorting problem, some of which we
will see in this course. 

Obviously, sorting is not the only class of problems that can be
solved by means of an algorithm. Some other problems include:

* Sorting -- quickly finding an element satisfying certain
  requirements in a large collection of other elements. This is a
  problem frequently appearing in the context of e-commerce.

* Path finding -- navigating from a point A to a point B, in a
  quickest way, given a fixed map.

* Optimisations in manufacturing and other commercial enterprises. For
  instance, how to connect a number of call centers in a least
  expensive way.

* Various geometric problems: for instance, locating a point on a
  plane.

Some real-world problems might require multiple algorithms to solve.
As instances of such a problem, on the lectures we discussed (a)
*move-and-tag* problem, in which a number of robots need to awake in a
shortest possible period of time, by waking up each other, and *room
furnishing* problem, in which one need to cover the maximal room
surface with furniture.

Data structures
---------------

Obviously, some of the tasks outlined above can benefit from a data
arranged in a more convenient way. For example, if one is interested
in finding the largest element in a collection, it would help to have
this collection sorted first. As another example, if one wants to
represent a map of roads of different length, which is suitable for
calculating shortest paths, it is wise to invest som time into
thinking on how to arrange this information.

Data structures are ways to organise information in a way that makes
it simple and faster to retrieve the bits we might need in the future.
Some of the data structures you have already seen in the past are
lists, trees, and arrays. However, more intricate problems will
require more sophisticated data structures, and this course's goal is
to show how to pick a right data structure for a corresponding
problem.

What is analysis of algorithms?
-------------------------------

When we solve a problem algorithmically, we need the solution (i.e.,
the algorithm providing an answer) to satisfy the following hard
criteria:

* **Correctness**: Does my algorithm really do what it’s supposed to
  do?

* **Termination**: Does my algorithm terminate for any given input.

* **Complexity**: Why my algorithm consumes so much resource (time,
  memory) and how can I improve it?

An algorithm that is simply not correct is not worth much. An
algorithm that does not terminate, but only on very special cases,
might be actually useful. The analysis of complexity tells us how slow
will be an algorithm in certain cases or how much memory will it
consume. 

In terms of time consumption, problems that can be solved
algorithmically can be themselves partitioned to several classes:

- **tractable problems** - admit solutions that run in "reasonable"
  time: sorting, searching, compression/decompression

- **possibly intractable** — probably don’t have reasonable-time
  algorithmic solutions: SAT, graph isomorphism

- **practically intractable** — definitely don’t have such solutions:
  the Towers of Hanoi

- **non-computable** — can’t be solved algorithmically at all: the
  halting problem

A good programmer should be able to guess correctly whether the
problem she is trying to solve algorithmically belongs to one of those
classes.

There are two ways to analyse algorithms:

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
implementation of and algorithm (or algorithms) as its part, and
discuss the algorithms involved: how do they interact, what are they
inputs and outputs.

.. _exercise-merlin-setup:

Exercise 2
----------

Programming in OCaml in Emacs is much more pleasant with instant
navigation, auto-completion and type information available. It is
recommended that you install Merlin_ mode for this and learn its
shortcuts

.. _Merlin: https://github.com/ocaml/merlin/wiki/emacs-from-scratch






