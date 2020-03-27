.. -*- mode: rst -*-

Exercises
=========

.. _exercise-partition-invariants: 

Exercise 1
----------

Implement and check the loop invariants (described in the text) of the
``partition`` procedure from Section :ref:`sec-partition`, as well as
as the procedure's postcondition. The assertions should relate the
initial array, the final array and returned ``i``. You might need to
introduce an initial copy of an unmodified array to assert those
statements.

.. _exercise-partition-different-pivot: 

Exercise 2
----------

Change the procedure ``partition`` from Section :ref:`sec-partition`
so it would take as ``pivot`` the first element of an array.


.. _exercise-qsort-invariant: 

Exercise 3
----------

Implement and check a precondition of the ``sort`` subrouting within
``quick_sort`` from Section :ref:`sec-partition`. It should relate the
initial array, and the sub-arrays, obtained as results of
partitioning, stating something about the arrangement of elements in
them wrt. element at the position ``mid`` and others.

.. _exercise-change-var: 

Exercise 4
----------

Solve, by means of changing a variable, the following recurrence
relation:

.. math::

  \begin{align*}
  f(1) &= 1 \\
  f(n) &= 4 f(n/2) + n^2, \text{if}~n > 1
  \end{align*}

.. _exercise-quicksort-worst: 

Exercise 5
----------

What is the worst-case complexity of Quicksort? Obtain it by stating
and solving the corresponding recurrence relations. Give an example of
an array when the worst-case complexity is achieved (hint: think of a
case insert sort does its best).

.. _exercise-more-notations:

Exercise 6
----------

Prove, out of definitions that for ay two functions :math:`f(n)` and
`:math:`g(n)`, one has :math:`f(n) \in \Theta(g(n))` if and only if
:math:`f(n) \in O(g(n))` and :math:`f(n) \in \Omega(g(n))`.

.. _exercise-functor-printing:

Exercise 7
----------

Enhance :ref:`sec-functor-sorting` ``Sorting``, so it would also take
an instance of a signature ``Printable`` that provides an
implementation for printing elements of an array. With that
``Sorting`` should also feature a second version of sorting,
``sort_print``, which will print a sorting trace using the machinery
imported from ``Printable``.

.. _exercise-radix-sort:

Exercise 8
----------

Implement and test the invariant for the ``while``-loop of
:ref:`sec-radix-sort`.