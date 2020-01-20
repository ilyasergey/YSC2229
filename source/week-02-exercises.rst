.. -*- mode: rst -*-

Exercises
=========
.. _exercise-selection-max: 

Exercise 1
----------

Rewrite selection sort, so it would walk the array right-to-left,
looking for a maximum rather than a minimum for a currently
unprocessed sub-array, while sorting the overall array in an ascending
order. Write the invariants for this version and explain how the inner
loop invariant, upon the loop's termination, implies the outer loop's
invariant.

.. _exercise-comparison-order:

Exercise 2
----------

* Which sorting method executes less primitive operations, such as
  swapping and comparing array elements, for an array in reverse
  order, selection sort or insertion sort?

* Which method runs faster on a fully sorted array?

Conduct experiments and justify your answer by explaining the
mechanics of the algorithms.

.. _exercise-matrix-sum-complexity: 

Exercise 3
-----------

One can represent a matrix of :math:`n \times n` elements in OCaml as a
two-dimensional array::

  #   let m = [| [|1; 2; 3|]; [|4; 5; 6|]; [|7; 8; 9 |] |];;
  val m : int array array = [|[|1; 2; 3|]; [|4; 5; 6|]; [|7; 8; 9|]|] 

Implement a procedure that takes a matrix and its dimension and
traverses it, summing up *all* elements in it. Express the complexity
of this procedure using big-O notation and justify your answer using
the material above.

.. _exercise-big-o-defs4: 

Exercise 4
----------

Algorithms *A* and *B* spend exactly :math:`T_A(n) = c_A \cdot n \cdot
\log_2 n` and :math:`T_B(n) = c_B \cdot n^2` nanoseconds,
respectively, for a problem of size :math:`n`. Find the best algorithm
for processing :math:`n = 2^{20}` data items if the algorithm *A*
spends 10 nanoseconds to process 1024 items, while the algorithm *B*
spends only 1 nanosecond to process 1024 items.

.. _exercise-bubble-sort-complexity: 

Exercise 5
-----------

Express the complexity of Bubble Sort (see the homework for Week 02)
using big-O notation. Justify your answer.



