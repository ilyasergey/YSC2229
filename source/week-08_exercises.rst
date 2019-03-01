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

* :ref:`exercise-url-shortener`
  Implementing a URL shortener.


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

Implement a resizable insert-only hash-table with a bloom filter.  Compare its performance to a regular resizable hash-table.

.. _exercise-url-shortener:

Exercise 4
----------

How to shorten the URL? You can imagine a service (a function with a state) run on a server, to which you make a call and it generates a fresh random URL and sends it back. But how does it check for uniqueness of the fresh URL? Implement such a structure by useing a Bloom filter to tell if this short URL has already been generated earlier, and keep generating new ones unti it returns false. As the filter is in memory, this will be cheaper than querying a database of previously generated URLs.
