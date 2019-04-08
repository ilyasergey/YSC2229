.. -*- mode: rst -*-

.. _exercises-13:

Exercises
=========

Mandatory exercises
-------------------

* :ref:`exercise-graph-bfs`
  Breadth-first search in a graph

* :ref:`exercise-chess`
  Movements of a chess knight

* :ref:`exercise-monotonic`
  Monotonic shortest path

* :ref:`exercise-testing-msp`
  Testing minimal spanning trees

Recommended exercises
---------------------

* :ref:`exercise-bitonic`
  Bitonic shortest path


.. _exercise-graph-bfs:

Exercise 1
----------

Following Depth-First Search for a graph as an example, implement a
procedure ``bfs`` for breadth-first traversal of a graph. It should
return a tuple with the following components:

* a list of roots of the trees (similarly to DFS)
* a hash-map, representing the children of a node in a tree (similar
  to DFS)
* a hash map that for each node ``u`` returns an integer "distance"
  ``d``, corresponding to the length of the path to ``u`` from the
  root of the tree that it is in.

In your implementation, make use of the queue structure, as well as
the idea of White-Gray-Black colouring of a node. Design and implement
tests for ``bfs`` (preferably using randomly generated graphs).
Explain the relation between the colouring scheme and the behaviour of
the traversal in your report.

Which properties ``dfs`` and ``bfs`` have in common? Please, reflect
them in your tests.

Finally, implement a function for rendering the resulting trees of a
graph via GraphViz.

.. _exercise-chess:

Exercise 2
----------

Model an ``8x8`` chess board via a ``64``-node graph, where each node
corresponds to a square. For instance, you can encode ``a1`` as ``0``,
``b3`` as ``11`` etc. The edges then represent one-time movements of
knight figure.

* Encode and automatically populate this graph using the linked graph
  data structure from the lecture.
* Using the graph encoding, implement a function ``knight_path g init
  final``, which, for given two positions on a board, initial and
  final, encoded as strings (e.g., ``a3`` and ``d8``), returns a path
  (represented a list of pairs of positions) for reaching the final
  position from the initial one.
* Test your implementation using random queries.

.. _exercise-monotonic:

Exercise 3
----------

Given a weighted directed graph, implement an algorithm to find a
monotonic shortest path from a node ``s`` to any other node. A path is
monotonic if the weight of its edges are either strictly increasing or
strictly decreasing. **Hint:** think about the *order* in which the
edges need to be relaxed. Implement tests for your algorithm and argue
about its asymptotic complexity.

.. _exercise-bitonic:

Exercise 4
----------

Given a weighted directed graph, implement an algorithm to find a
*bitonic* shortest path from a node ``s`` to any other node. A path is
bitonic if there is an intermediate node ``v`` in it such that the
weight of the edges on the path from ``s`` to ``v`` are strictly
increasing and the weight on edges from ``v`` to ``t`` (final path of
a node) are strictly decreasing.

.. _exercise-testing-msp:

Exercise 5
----------

Implement a procedure that constructs random spanning trees (checking
that those are indeed trees) of a connected weighted undirected graph
(represented via a linked structure), and tests that the weights of
those is not smaller than the one of an MST, returned by Kruskal's
algorithm.
