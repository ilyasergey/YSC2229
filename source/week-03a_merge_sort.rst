.. -*- mode: rst -*-

Merge-Sort
==========



.. _exercise-fast-merge-sort:

Exercise 5 
----------

The merge sort presented above can be improved by getting rid of allocating new sub-arrays to copy elements to and sort recursively every time. The way to do it is to initially allocate jsut one auxiliary array ``aux`` of the same size as the initial one and use it as a "sanbox" for sorting, without ever allocating more arrays. Indeed, the ``merge`` procedure will have to be adapted as well. 

Implement this version of the merge_sort and compare its performance (using function ``time``) with the previous version of merge sort. Describe the invariant for the new version of merge and for the main function and check that it holds.

.. _exercise-three-way-merge-sort:

Exercise 6 
----------

Implement a version of merge-sort that splits the sub-arrays into three parts and then combines them together. Compare its performance to the ordinary 2-way merge-sort.

.. _exercise-index-sort:

Exercise 7
----------

Develop and implement a version of merge-sort that does not rearrange the input array ``arr``, but returns an array ``perm`` of type ``int array``, such that ``perm.(i)`` is the index in ``arr`` of the entry with ``i`` th smallest key in the array.

