.. -*- mode: rst -*-

Exercises
=========

.. _exercise-determ2: 

Exercise 1: Realistic Complexity of Laplace Expansion
-----------------------------------------------------

Recall the definition of a matrix determinant by Laplace expansion

.. math::

  |M| = \sum_{i = 0}^{n - 1}(-1)^{i} M_{0, i} \cdot |M^{0, i}|

where :math:`M^{0, i}` is the corresponding `minor of the matrix <https://en.wikipedia.org/wiki/Minor_(linear_algebra)>`_ :math:`M` of size :math:`n`, with indexing starting from :math:`0`.

This definition can be translated to OCaml as follows::

 let rec detLaplace m n = 
   if n = 1 then m.(0).(0)
   else
     let det = ref 0 in
     for i = 0 to n - 1 do
       let min = minor m 0 i in
       let detMin =  detLaplace min (n - 1) in
       det := !det + (power (-1) i) * m.(0).(i) * detMin
     done;
     !det

A matrix is encoded as a 2-dimensional array ``m``, whose rank (both
dimensions) is ``n``. Here, ``minor`` returns the minor of the matrix
``m``, and ``power a b`` returns the natural power of ``b`` of an
integer value ``a``.

Out of the explanations and the code above, estimate (in terms of
big-O notation) the time complexity :math:`t(n)` of the recursive
determinant computation. Start by writing down a recurrence relation
on :math:`t(n)`. Assume that the complexity of ``minor`` is :math:`c
\cdot n^2` for some constant :math:`c`. Consider the complexity of
returning an element of an array to be 0 (i.e., :math:`t(1) = 0`). For
:math:`n > 1`, ``power``, addition, multiplication and other primitive
operations to be constants and approximate all of them by a single
constant :math:`c`.

.. _exercise-randomised-testing:

Exercise 2
----------

Implement a function that generates takes (a) a sorting procedure
``sort`` for a key-value array, (b) a number ``n`` and a number
``length``, and generates ``n`` random arrays of the length
``length``, testing that ``sort`` is indeed correct on all those
arrays.

.. _exercise-find-range-unsorted:

Exercise 3
----------

Find a procedure that takes an unsorted array and a given range of
keys (represented by a pair of numbers ``lo < hi``, right boundary not
included), and returns the list of all elements in the array, whose
keys are in that range. Estimate the complexity of this procedure.

.. _exercise-binare-no-mid:
