.. -*- mode: rst -*-

Exercises
=========


Mandatory exercises
-------------------

* :ref:`exercise-small`
  Properties of heaps.

* :ref:`exercise-heapify`
  Non-recursive heapify.

* :ref:`exercise-build-heap`
  An invariant of heap building.

* :ref:`exercise-heapsort-inv`
  Heapsort invariant.

* :ref:`exercise-min-heap`
  Fun with min-heaps.


Recommended exercises
---------------------

None

.. _exercise-small:

Exercise 1
----------

Answer the following small questions about heaps:

1. What is a maximal and a minimal number of elements in a heap of the height :math:`h`? Explain your answer and give examples.
2. Is an array that is sorted a min-heap?
3. Where in a max-heap might the elements with the *smallest* keys reside, assuming that all keys are distinct?

.. _exercise-heapify:

Exercise 2
----------

* Let us remove a self-recursive call at the end of ``max_heapify``. Give a concrete example of an array ``arr``, which is almost a heap (with just one offending triple rooted at ``i``), such that the procedure ``max_heapify (Array.length arr) arr i`` does not restore a heap, unless run recursively.

* Rewrite ``max_heapify`` so it would use a ``while``-loop instead of the recursion. Provide a variant for this loop.

.. _exercise-build-heap:

Exercise 3
----------

Implement in OCaml and check an invariant from Section :ref:`sec-build-heap`. Explain how it implies the postcondition of `build_max_heap` (which should be expressed in terms of ``is_heap``).

.. _exercise-heapsort-inv:

Exercise 4
----------

Implement in OCaml and check the invariant of the ``for``-loop of heapsort. How does it imply the postcondition (i.e., that the whole array is sorted)? **Hint:** how does it relate the elements of the original array (you might need a copy of it), the sub-array before ``heap-size`` and the sub-array beyond the ``heap_size``?

.. _exercise-min-heap:

Exercise 5
----------

Reimplement the heapsort, so it would work with a min-heaps instead of max-heaps. For this, you might also reimplement or, better, generalise the prior definitions of the ``Heap`` module.


.. Resizeable PQ 
