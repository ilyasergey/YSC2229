.. -*- mode: rst -*-

Exercises
=========


Mandatory exercises
-------------------

* :ref:`exercise-heapify`
  Non-recursive heapify.

Recommended exercises
---------------------


.. _exercise-heapify:

Exercise 1
----------

* Let us remove a self-recursive call at the end of ``max_heapify``. Give a concrete example of an array ``arr``, which is almost a heap (with just one offending triple rooted at ``i``), such that the procedure ``max_heapify (Array.length arr) arr i`` does not restore a heap, unless run recursively.

* Rewrite ``max_heapify`` so it would use a ``while``-loop instead of the recursion. Provide a variant for this loop.
