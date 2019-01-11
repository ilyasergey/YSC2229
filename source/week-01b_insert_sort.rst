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
  element, inserts it at a correct position to the prefix via
  ``insert``, which is already assumed ordered.

* The inner ``insert`` traverses the sorted prefix (called
  ``remaining``) and inserts an element ``elem`` to a correct
  position.

Correctness of sorting
----------------------

In order to reason about ht ecorrectness of sorting, we first need to
say what its specification is, i.e., what is a correctly sorted list.
This notion is described by the following definition::

  let rec sorted ls = 
    match ls with 
    | [] -> true
    | h :: t -> List.for_all (fun e -> e >= h) t && sorted t

A list ``res`` is a correctly sorted version of a list ``ls`` if
it's (a) sorted and (b) has all the same elements as ``res``, which we
can define as follows::

  let same_elems ls1 ls2 =
     List.for_all (fun e -> 
        List.find_all (fun e' -> e' = e) ls2 = 
        List.find_all (fun e' -> e' = e) ls1) 
       ls1

  let sorted_spec ls res = 
    same_elems ls res && sorted res

With the following functions we can now test insertion sort::

  let sort_test sorter ls = 
    let res = sorter ls in
    sorted_spec ls res;;

  # insert_sort [];;
  - : 'a list = []
  # sort_test insert_sort [];;
  - : bool = true
  # insert_sort [5; 7; 8; 42; 3; 3; 1];;
  - : int list = [1; 3; 3; 5; 7; 8; 42]
  # sort_test insert_sort [5; 7; 8; 42; 3; 3; 1];;
  - : bool = true

.. _exercise-sort-desc:

Exercise 7
----------

Implement a version of an insertion sort that sorts the elements in
the descending order and test it.

Sorting invariants
------------------

