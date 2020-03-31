.. -*- mode: rst -*-

.. _exercises-12:

Exercises
=========

.. _exercise-monotonic:

Exercise 1
----------

Given a weighted directed graph, implement an algorithm to find a
monotonic shortest path from a node ``s`` to any other node. A path is
monotonic if the weight of its edges are either strictly increasing or
strictly decreasing. **Hint:** think about the *order* in which the
edges need to be relaxed. Implement tests for your algorithm and argue
about its asymptotic complexity.

.. _exercise-bitonic:

Exercise 2
----------

Given a weighted directed graph, implement an algorithm to find a
*bitonic* shortest path from a node ``s`` to any other node. A path is
bitonic if there is an intermediate node ``v`` in it such that the
weight of the edges on the path from ``s`` to ``v`` are strictly
increasing and the weight on edges from ``v`` to ``t`` (final path of
a node) are strictly decreasing.