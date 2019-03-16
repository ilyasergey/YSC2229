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

* :ref:`exercise-rle-decoder`
  RLE decoder.

* :ref:`exercise-fixed-length`
  Fixed-length code

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

.. _exercise-rle-decoder:

Exercise 3
----------

Implement a decoder for the binary compression based on Run-Length Evaluation described in Section :ref:`week-10-rle`. Test it by composing it with the binary compression/decompression of DNA strings as follows: DNA -> Binary DNA -> RLE compression -> RLE Decompression -> Binary DNA -> DNA to ensure that the initial input and the final output are identical.

Implement a pair of standalone compression runners for RLE-based compression of binaries, similarly to what has been implemented in Section :ref:`week-10-huffman`.

.. _exercise-fixed-length:

Exercise 4
----------

Implement a variation of RLE (see Section :ref:`week-10-rle`) that uses fixed-length encoding (i.e., all lengths are encoded via a code of a fixed size) to compress ASCII (8-bit character) strings that have relatively few different characters with many repetitions, such as ``AAAAAAAAAAAAAAACCCBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAAEEEEEE``.

Design the encoding for representing the alphabet (relevant characters in the encoded string), used to associate characters with lengths of the occurrences (you might not need to account for all ASCII characters, but only for those that occur in your string). Store this alphabet representation along with the encoded string, so it could be used for decoding. Implement a randomised test generator producing strings, on which this compression will work well and use it for automated testing of your compression/decompression procedure.
