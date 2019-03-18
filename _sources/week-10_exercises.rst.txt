.. -*- mode: rst -*-

.. _exercises-10:

Exercises
=========

Mandatory exercises
-------------------

* :ref:`exercise-knapsack-permutations`
  Implementing a solution for Knapsack problem via permutations.

* :ref:`exercise-knapsack-backtracking`
  Implementing a solution for Knapsack problem via backtracking.

* :ref:`exercise-sat`
  SAT-solver

* :ref:`exercise-dna-encoding`
  Better DNA-encoding.

Recommended exercises
---------------------

None

.. _exercise-knapsack-permutations:

Exercise 1
----------

Implement a version of a solver for the Knapsack Problem (finding a list of items to include) by using the function ``perm`` for enumerating all permutations of an array, implemented as a part of your midterm project. Implement randomised testing for the Knapsack solvers and use it to test your implementation with respect to the one implemented in the lecture.

.. _exercise-knapsack-backtracking:

Exercise 2
----------

Implement a version of a solver for the Knapsack Problem using the back-tracking technique (similarly to how n-queens problem has been solved), by selecting subsets of items, optimising for the weight and maximising the price. Test your solution as in :ref:`exercise-knapsack-permutations`.

.. _exercise-sat:

Exercise 3
----------

In this exercise you will be asked to implement a solver for `Boolean satisfiability problem <https://en.wikipedia.org/wiki/Boolean_satisfiability_problem>`_ using both the brute-force and the backtracking technique. Take the following data type defining boolean formulae::

 type formula = 
   | Var of string
   | And of formula * formula
   | Or  of formula * formula
   | Not of formula

Implement thew following functions:

* ``eval : formula -> (string * bool) list -> bool`` for evaluating the boolean value of a formula (``true`` or ``false``) given the list of bindings, mapping the variables occurring in the formula to their boolean values.
* ``generate_random_formula : string list -> int -> formula`` for creating a random formula featuring variables from a given list of names, as well as other connectives. Use the ``int`` parameter to control the size of the forumla.
* ``solve_brute_force : formula -> (string * bool) list option`` -- a function for finding a list of substitutions from variable names that make the given formula evaluate to ``true`` or ``None`` if no such list exists. Do it by enumerating all possible assignments to variables. 
* ``solve_backtracking : formula -> (string * bool) list option`` -- the same solver as before, but implemented by means of back-tracking, assigning individual values to the involved variables and partially simplifying the forumla as it goes (as discussed in the class).
* Test both solvers using ``generate_random_formula`` and compare their performance on large formulae.

.. _exercise-dna-encoding:

Exercise 4
----------

Improve the encoding format of DNA strings so instead of storing the overall length (and wasting 30 bits) in the beginning, it would store a 2-bit number :math:`P`, indicating how many of 2-bit sequences (0-3) will be appended for padding at the end. Notice that :math:`P` will depend on the length of the DNA sequence, and storing :math:`P` will impact the value of :math:`P`, as it consumes 2 additional bits. 

Read :math:`P` when deserializing and then use the same trick as when reading ASCII strings for reading a DNA from the rest of the file. As added :math:`P` 2-bit 0-sequences (for padding) at the end would contribute "junk" ``'A'`` characters at the end of the decoded DNA, use the stored information to strip them in a deserialized DNA string.
