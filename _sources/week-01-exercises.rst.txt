.. -*- mode: rst -*-

Exercises
=========

.. _exercise-algo-example:

Exercise 1
----------

Give an example of a real-life application that requires an
implementation of and algorithm (or several algorithms) as its part,
and discuss the algorithms involved: how do they interact, what are
they inputs and outputs.

.. _exercise-merlin-setup:

Exercise 2
----------

Programming in OCaml in Emacs is much more pleasant with instant
navigation, auto-completion and type information available. Install
all the necessary sofwtare following the provided :ref:`prerequisites`.

.. _exercise-find-min-termination-measure:

Exercise 3
----------

What is the termination measure of ``walk`` within ``find_min``?
Define it as a function ``f : 'a list -> int -> int`` and change the
implementation of ``walk`` annotating it with outputs to check that
the measure indeed decreases.

* **Hint:** use OCaml's ``Printf.printf`` utility to output results of
  the termination measure mid-execution.

.. _exercise-find-min2: 

Exercise 4
----------

* Implement the function ``find_min2``, similar to ``find_min`` (also
  using the auxiliary ``walk``, but without relying on any other
  auxiliary functions, e.g., sorting) that finds not the minimal
  element, but the *second* minimal element. For instance, it should
  bive the following output on a list ``[2; 6; 78; 2; 5; 3; 1]``::

    # find_min2  [2; 6; 78; 2; 5; 3; 1];;
    - : int option = Some 2

  **Hint:** ``walk`` is easier to implement if it takes both the
  "absolute" minimum ``m1`` and the second minimum ``m2``, i.e., has
  the type ``int list -> int -> int -> int``.

* Write its specification (a relation between its input/output).

  **Hint:** the following definition might be helpful::
  
    let is_min2 ls m1 m2 = 
      m1 < m2 &&
      List.for_all (fun e -> e == m1 || m2 <= e) ls &&
      List.mem m2 ls

* Write the precondition for ``walk`` and annotate the function with
  the assertions, enforcing the pre- and postconditions. 

  **Hint:** you might want to start from devising the second disjunct
  of ``find_min2_walk_pre ls xs m1 m2`` to state that "a list has an
  element that is its second minimum, positioned appropriately with
  respect to ``m1`` and ``m2``".

* Test your annotated function ``find_min2_with_invariant``.

.. _exercise-tail_rec:

Exercise 5
----------

Give an example of an interesting non-tail recursive function in OCaml
and show, if possible, an equivalent tail-recursive function.

.. _exercise-find_min2_loop:

Exercise 6
----------

Implement an imperative version of the function ``find_min2`` from
:ref:`exercise-find-min2`, annotate its with loop invariants and run
the tests.

.. _exercise-sort-desc:

Exercise 7
----------

Implement a version of an insertion sort that sorts the elements in
the descending order and test it.


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

