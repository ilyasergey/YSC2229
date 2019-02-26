.. -*- mode: rst -*-

Exercises
=========

Mandatory exercises
-------------------

None

Recommended exercises
---------------------

* :ref:`exercise-stack-test`
  Testing a stack.

* :ref:`exercise-stack-test`
  Testing a queue.

* :ref:`exercise-queue`
  A purely functional queue.

* :ref:`exercise-rev-dll`
  Reversing a doubly-linked list.

* :ref:`exercise-hash-map-resize`
  Resizable hash-map  

.. _exercise-stack-test:

Exercise 1
----------

Design and implement a randomised testing procedure for stacks, which would insert an arbitrary sequence of elements via ``push``, extract them via ``pop`` and ensured that LIFO property holds.

.. _exercise-queue-test:

Exercise 2
----------

Design and implement a randomised testing procedure for queues, which would insert an arbitrary sequence of elements via ``enqueue``, extract them via ``dequeue`` and ensured that FIFO property holds.

.. _exercise-queue:

Exercise 3
----------

Implement a queue data structure, which does not use OCaml arrays or double-linked lists, and at most two values of type ``ref``. Make sure it satisfies the ``Queue`` interface. To do so, use two OCaml lists to represent the part for "enqueueing" and "dequeueing". What happens if one of them gets empty? Argue that the average-case complexity for enqueue and dequeue operations of your implementation is linear.

.. _exercise-rev-dll:

Exercise 4
----------

Implement a procedure for "reversing" a doubly-linked list, starting from its arbitrary node (which might be at its beginning, end, or in the middle). Make sure that your procedure works in linear time.

.. _exercise-hash-map-resize:

Exercise 5
----------

Implement a hash map that automatically grows if a number of stored elements in buckets become too large. Explain your design choices and the average-case complexity of your implementation.

.. * An n-leaf tree
.. * A fully-linked tree and its traversals   
