.. -*- mode: rst -*-

Sorting Lists via Insertion Sort
================================

The task of finding the minimal and the second-minimal element in a
list can be made much simpler and fast, if the list is
*pre-processed*, namely, sorted. Indeed, for a sorted list we can just
take it first or a second element, knowing that it will be what we
need. Below, we will see our first implementation of sorting a list.

Insertion sort implementation
-----------------------------

The following OCaml code implement the sorting procedure::

  let insert_sort ls = 
    let rec walk xs acc =
      match xs with
      | [] -> acc
      | h :: t -> 
        let rec insert elem remaining = 
          match remaining with
          | [] -> [elem]
          | h :: t as l ->
            if h < elem 
            then h :: (insert elem t) else (elem :: l)
        in
        let acc' = insert h acc in
        walk t acc'
  in 
  walk ls []

Notice that there are two recursive auxiliary function in it: ``walk``
and ``insert``. They play the following roles:

* The ouoter ``walk`` traverses the entire lists and for each next
  *element, inserts* it at a correct position to the prefix via
  *``insert``, which is already assumed ordered.

* The inner ``insert`` traverses the sorted prefix (called
  ``remaining``) and inserts an element ``elem`` to a correct
  position.

Correctness of sorting
----------------------

[Stopped here]

**TODO** specification and tests

.. _exercise-merlin-sort-desc:

Exercise 7
----------

Implement a version of an insertion sort that sorts the elements in
the descending order and test it.
