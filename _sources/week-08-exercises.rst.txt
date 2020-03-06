.. -*- mode: rst -*-

.. _exercises-8:

Exercises
=========

Exercise 1
----------

How to shorten a URL? One can imagine a service (a function with a
state) invoked on a server, to which you make a call and it generates
a fresh random URL and sends it back. But how can it efficiently check
for uniqueness of the fresh URL?

Implement such an abstract data type with a method
``generate_fresh_url : unit -> string`` by employing a Bloom filter to
tell if this short URL has already been generated earlier, and keep
generating new ones unti it returns false. As the filter is in memory,
this will be cheaper than querying a database of previously generated
URLs.

Exercise 2
----------

Write a program that, given two strings, determines whether one is a
cyclic rotation of the other. For instance it should identify
``lenusya`` as a cyclic rotation of ``yalenus``. Design automated
randomised tests for this algorithm.

Exercise 3
----------

Using the idea of a rolling hash from Rabin-Karp algorithm, implement
the procedure for efficiently finding a smallest number ``i > 1`` of a
string ``s``, such that that the substring ``s[0 .. i]`` is a
palindrome. For instance, for ``s = "abcbadef``, the result is ``i =
Some 5``, and for ``s = "abcbgdef`` the result is ``None``.
