.. -*- mode: rst -*-

.. _exercises-11:

Exercises
=========

Mandatory exercises
-------------------

* :ref:`exercise-rle-decoder`
  RLE decoder

* :ref:`exercise-fixed-length`
  Fixed-length code

* :ref:`exercise-uf-linear`
  Constant-time find in Union-Find

* :ref:`exercise-uf-compression`
  Union-Find with path compression

Recommended exercises
---------------------

None

.. _exercise-rle-decoder:

Exercise 1
----------

Implement a decoder for the binary compression based on Run-Length Evaluation described in Section :ref:`week-11-rle`. Test it by composing it with the binary compression/decompression of DNA strings as follows: DNA -> Binary DNA -> RLE compression -> RLE Decompression -> Binary DNA -> DNA to ensure that the initial input and the final output are identical.

Implement a pair of standalone compression runners for RLE-based compression of binaries, similarly to what has been implemented in Section :ref:`week-11-huffman`.

.. _exercise-fixed-length:

Exercise 2
----------

Implement a variation of RLE (see Section :ref:`week-11-rle`) that uses fixed-length encoding (i.e., all lengths are encoded via a code of a fixed size) to compress ASCII (8-bit character) strings that have relatively few different characters with many contiguous repetitions, such as ``AAAAAAAAAAAAAAACCCBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAAEEEEEE``.

Design the encoding for representing the alphabet (relevant characters in the encoded string), used to associate characters with lengths of the occurrences (you might not need to account for all ASCII characters, but only for those that occur in your string). Store this alphabet representation along with the encoded string, so it could be used for decoding. Implement a randomised test generator producing strings, on which this compression will work well and use it for automated testing of your compression/decompression procedure.

.. _exercise-uf-linear:

Exercise 3
----------

Implement a version of Union-Find, such that ``union`` has :math:`O(n)` complexity (doing more massive update than the version from the lecture), but the ``find`` has only :math:`O(1)` complexity.

.. _exercise-uf-compression:

Exercise 4
----------

Implement a version of Union-Find to include *path compression*, by
adding a code to ``find`` that links every element on the path from
``p`` to the root (thus making a short-cut for the path). Give a
sequence of inputs that causes this function to produce a path of
length 4 (and compress it). *Note*: The amortised cost per operation
for this algorithm is known to be logarithmic.

