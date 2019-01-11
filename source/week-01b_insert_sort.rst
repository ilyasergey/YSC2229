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

Let us now make the intuition about the correctness of sorting formal,
capturing it in the form of specifications for the two recursive
functions it uses, ``walk`` and ``insert``.

Since ``walk`` is tail-recursive, we can get away without its
postcondition, and just specify the precondition, which is also its
invariant::

  let insert_sort_walk_inv ls t acc = 
    sorted acc &&
    same_elems (acc @ t) ls

The invariant ``insert_sort_walk_inv`` ensures that the prefix ``acc``
processed so far is sorted, and also that the concatenation of the
tail ``t`` to be processed has the same elements as the original list
``ls``. 

The recursive procedure ``insert`` is not tail-recursive, hence we
will have to provide both the pre- and the postcondition::

  let insert_sort_insert_pre elem prefix = sorted elem prefix

  let insert_sort_insert_post res elem prefix  = 
    sorted res &&
    same_elems res (elem :: prefix)

That is, whenever insert is run on a ``prefix``, it expects it to be
sorted. Once it finishes, it returns a sorted list ``res``, which has
all alements of ``prefxi``, and also the inserted ``elem``. 

It's easy to see that the postcondition of ``insert`` implies the
precondition of ``walk``, at each recursive iteration. Furthermore,
the invariant of ``walk`` becomes the correcntess specification of the
top-level sorting function, once ``t`` becomes empty, i.e., in its
base case. 

Let us now check all of those sepcifications by annotating the code
with them::

  let insert_sort_with_inv ls = 
    let rec walk xs acc =
      match xs with
      | [] -> 
        let res = acc in
        (* walk's postcondition *)
        assert (sorted_spec ls res); 
        res
      | h :: t -> 

        let rec insert elem remaining = 
          match remaining with
          | [] -> 
            (* insert's postcondition *)
            assert (insert_sort_insert_post [elem] elem remaining);
            [elem]
          | h :: t as l ->
            if h < elem 
            then (
              (* insert's precondition *)
              assert (insert_sort_insert_pre elem t);
              let res = insert elem t in
              (* insert's postcondition *)
              (assert (insert_sort_insert_post (h :: res) elem remaining);
              h :: res))
            else 
              let res = elem :: l in
              (* insert's postcondition *)
              (assert (insert_sort_insert_post res elem remaining);
               res)
        in

        let acc' = (
           (* insert's precondition *)
           assert (insert_sort_insert_pre h acc);
           insert h acc) in
        (* walk's precondition *) 
        assert (insert_sort_walk_inv ls t acc');
        walk t acc'
    in 
    assert (insert_sort_walk_inv ls ls []);
    walk ls []

.. _exercise-sort-tail:

Exercise 8
----------

It is possible to implement (quite unelegantly and not very
efficiently) the insertion sort on lists, so it would be
tail-recursive. For this, we will have to rewrite it, so ``insert``
would use the boolean flug ``run`` in order to indicate whether the
insertion has already taken place, or the iteration should continue::

  let insert_sort_tail ls = 
    let rec walk xs prefix =
      match xs with
      | [] -> prefix
      | h :: t -> 
          let rec insert elem acc remaining run = 
            if not run then acc
            else match remaining with
              | [] -> acc @ [elem]
              | h :: t as l ->
                if h < elem 
                then 
                  let run' = true in
                  let acc' = acc @ [h] in
                  insert elem acc' t run'
                else 
                  let run' = false in
                  let acc' = acc @ (elem :: l) in
                  insert elem acc' t run'
          in

          let acc' = insert h [] prefix true in
          walk t acc'
    in 
    walk ls []

* Define the invariants for auxiliary functions::

    let insert_inv prefix elem acc remaining run = (* ... *)
    let insert_sort_tail_walk_inv ls xs acc = (* ... *)

  Annotate the implementation above with them and test it.

* Transform ``insert_sort_tail`` into an imperative version, which
  uses (nested) loops instead of recursion.

