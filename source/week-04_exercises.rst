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
