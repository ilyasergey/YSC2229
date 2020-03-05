.. -*- mode: rst -*-

.. _exercises-8:

Exercises
=========

Mandatory exercises
-------------------

None

Recommended exercises
---------------------

* :ref:`exercise-queue-test`
  Testing a stack.

* :ref:`exercise-stack-test`
  Testing a queue.

* :ref:`exercise-resize-bloom`
  A resizable insert-only hash-table with a Bloom filter.

.. _exercise-queue-test:

Exercise 1
----------

Following the design from Section :ref:`sec-queue-test`, design and implement an in-line randomised testing procedure for stacks, which would insert an arbitrary sequence of elements via ``push``, extract them via ``pop`` and ensured that LIFO property holds.

.. _exercise-stack-test:

Exercise 2
----------

Design and implement a randomised testing procedure for queues, which would insert an arbitrary sequence of elements via ``enqueue``, extract them via ``dequeue`` and ensured that FIFO property holds.

.. _exercise-resize-bloom:

Exercise 3
----------

Implement a resizable insert-only hash-table with a Bloom filter.  Compare its performance to a regular resizable hash-table.
