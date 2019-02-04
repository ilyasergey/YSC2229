.. -*- mode: rst -*-

Exercises
=========

Mandatory exercises
-------------------
None

Recommended exercises
---------------------

* :ref:`exercise-partition-invariants`: 
  Partition invariants.

* :ref:`exercise-partition-different-pivot`
  Changing the pivot.

* :ref:`exercise-qsort-invariant`
  Changing the pivot.

* :ref:`exercise-change-var`
  Solving divide-and-conquer recurrence relations.

* :ref:`exercise-quicksort-worst`
  Achieving worst-case complexity of Quicksort.

* :ref:`exercise-more-notations`
  Relating big-O, :math:`\Omega`, and :math:`\Theta`-notation.


.. _exercise-partition-invariants: 

Exercise 1
----------

Implement and check the loop invariants (described in the text) of the ``partition`` procedure from Section :ref:`sec-partition`, as well as as the procedure's postcondition. The assertions should relate the initial array, the final array and returned ``i``. You might need to inroduce an initial copy of an unmodified array to assert those statements.

.. _exercise-partition-different-pivot: 

Exercise 2
----------

Change the procedure ``partition`` from Section :ref:`sec-partition` so it would take as ``pivot`` the first element of an array. 


.. _exercise-qsort-invariant: 

Exercise 3
----------

Implement and check a precondition of the ``sort`` subrouting withint ``quick_sort`` from Section :ref:`sec-partition`. It should relate the initial array, and the sub-arrays, obtained as results of partitioning, stating something about the arrangement of elements in them wrt. element at the position ``mid`` and others.

.. _exercise-change-var: 

Exercise 4
----------

Solve, by means of changing a variable, the following recurrence relation:

.. math::

  \begin{align*}
  f(1) &= 1 \\
  f(n) &= 4 f(n/2) + n^2, \text{if}~n > 1
  \end{align*}

.. _exercise-quicksort-worst: 

Exercise 5
----------

What is the worst-case complexity of Quicksort? Obtain it by stating and solving the corresponding recurrence relations. Give an example of an array when the worst-case complexity is achieved (hint: think of a case insert sort does its best).

.. _exercise-more-notations:

Exercise 6
----------

Prove, out of definitions that for ay two functions :math:`f(n)` and `:math:`g(n)`, one has :math:`f(n) \in \Theta(g(n))` if and only if :math:`f(n) \in O(g(n))` and :math:`f(n) \in \Omega(g(n))`.
