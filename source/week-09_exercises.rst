.. -*- mode: rst -*-

.. _exercises-9:

Exercises
=========

Mandatory exercises
-------------------

* :ref:`exercise-url-shortener`
  Implementing a URL shortener.

* :ref:`exercise-find-all`
  Finding all pattern occurrences.

* :ref:`exercise-cyclic-rotation-check`
  Cyclic rotation check.

* :ref:`exercise-right-to-left`
  Processing a pattern right-to-left

Recommended exercises
---------------------

* :ref:`exercise-palindrome`
  Detecting palindromes using hashing.

.. _exercise-url-shortener:

Exercise 1
----------

How to shorten the URL? You can imagine a service (a function with a state) run on a server, to which you make a call and it generates a fresh random URL and sends it back. But how does it check for uniqueness of the fresh URL? Implement such an abstract data type with a method ``generate_fresh_url : unit -> string`` by employing a Bloom filter to tell if this short URL has already been generated earlier, and keep generating new ones unti it returns false. As the filter is in memory, this will be cheaper than querying a database of previously generated URLs.

.. _exercise-find-all:

Exercise 2
----------

Modify a naive pattern search and Rabin-Karp search (either loop-based or recursive) so they would return a list of all occurrences of a pattern in a string (including overlapping ones). Design an automated randomised test suite for those procedures in the style of the ones shown in this lecture.

.. _exercise-cyclic-rotation-check:

Exercise 3
----------

Write a program that, given two strings, determins whether one is a cyclic rotation of the other. For instance it should identify ``lenusya`` as a cyclic rotation of ``yalenus``. Design automated randomised tests for this program.

.. _exercise-right-to-left:

Exercise 4
----------

Implement a pattern search in a text, os it would explore the pattern right-to-left, but the main text left-to-right. Try to think of optimisations based on the characters in the pattern to optimise your search and explain them in your report. Use the randomised automated tests to validate your implementation.

.. _exercise-palindrome:

Exercise 5
----------

Using the idea of a rolling hash from Rabin-Karp algorithm, implement the procedure for efficiently finding a smallest number ``i > 1`` of a string ``s``, such that that the substring ``s[0 .. i]`` is a palindrome. For instance, for ``s = "abcbadef``, the result is ``i = Some 5``, and for ``s = "abcbgdef`` the result is ``None``.
