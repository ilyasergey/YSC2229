.. -*- mode: rst -*-

.. _exercises-11:

Exercises
=========

Mandatory exercises
-------------------

* :ref:`exercise-rle-decoder`
  RLE decoder.

* :ref:`exercise-fixed-length`
  Fixed-length code

Recommended exercises
---------------------

None

.. _exercise-rle-decoder:

Exercise 1
----------

Implement a decoder for the binary compression based on Run-Length Evaluation described in Section :ref:`week-10-rle`. Test it by composing it with the binary compression/decompression of DNA strings as follows: DNA -> Binary DNA -> RLE compression -> RLE Decompression -> Binary DNA -> DNA to ensure that the initial input and the final output are identical.

Implement a pair of standalone compression runners for RLE-based compression of binaries, similarly to what has been implemented in Section :ref:`week-11-huffman`.

.. _exercise-fixed-length:

Exercise 2
----------

Implement a variation of RLE (see Section :ref:`week-11-rle`) that uses fixed-length encoding (i.e., all lengths are encoded via a code of a fixed size) to compress ASCII (8-bit character) strings that have relatively few different characters with many contiguous repetitions, such as ``AAAAAAAAAAAAAAACCCBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAAEEEEEE``.

Design the encoding for representing the alphabet (relevant characters in the encoded string), used to associate characters with lengths of the occurrences (you might not need to account for all ASCII characters, but only for those that occur in your string). Store this alphabet representation along with the encoded string, so it could be used for decoding. Implement a randomised test generator producing strings, on which this compression will work well and use it for automated testing of your compression/decompression procedure.

.. _exercise-tree-prev:

Exercise 3
----------

Implement a procedure ``find_prev`` for finding a predecessor for and element ``e`` from the BST. IT should return ``None`` if ``e`` is not present in the tree, or if it is the smallest element in it. Write automated randomised tests for your procedure.

.. _exercise-tree-print:

Exercise 4
----------

Using the idea of ``breadth_first_search_loop``, implement a procedure for printing the tree of 1-digit integers "vertically" (i.e., as we normally draw them on a white board). 

For instance, you should be able to obtain the following output for a tree that misses one leaf (left child of the node storing ``5``)::

      4
    2   5 
   1 3   6

Here are some ideas on what you can try:

* Use BFS-like traversal to associate the "level" with each node.

* Consider keeping a structure with counters for each level to keep track
  of the "missing" left/right children, so they could be renderred as
  white spaces.

* You might want to compute the expected number of leaves at the
  bottom level (which depends on the height of the tree) to calculate
  the initial offset and the spacing between nodes at each of the
  higher levels.

As a bonus (for additional points), try to generalise your printing algorithm for arbitrary strings produced from the values stored in the nodes.

.. _exercise-right-rotate:

Exercise 5
----------

In a BST, left and right rotations.

TODO

The following procedure that implements the left rotation of a node :math:`x`::
