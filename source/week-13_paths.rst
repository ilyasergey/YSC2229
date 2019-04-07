.. -*- mode: rst -*-

.. _paths:

Single-Source Shortest Paths
============================



Definitions of Shortest Paths
-----------------------------

* Weights
* Shortest paths

Some Properties
---------------

TODO: Say about the following:

* Subpaths of a shortest path
* Negative-weight edges
* Negative cycles
* Cycles


Representing Shortest Paths
---------------------------

* Predecessors


Relaxation
----------


* Initialise single source
* Relax
* Path-relaxation property


Bellman-Ford Algorithm
----------------------

TODO


Dijkstra's Algorithm
--------------------

Dijkstra relies on all weights on edges being non-negative. This way, adding an edge to a path can never make a it shorter (which is not the case with negative edges). This is why taking the shortest candidate edge (local optimality) always ends up being correct (global optimality). If that is not the case, the "frontier" of candidate edges does not send the right signals; a cheap edge might lure you down a path with positive weights while an expensive one hides a path with negative weights.

Testing Shortest-Path Algorithms
--------------------------------
