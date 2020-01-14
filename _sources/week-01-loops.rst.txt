.. -*- mode: rst -*-

From Recursion to Imperative Loops
==================================

* File: ``Loops.ml``

The way the auxiliary function ``walk`` function `find_min` has been
implemented is known as *tail-call-recursion*: each recursive call
happens to be the very last thing the function does in a non-base
(recursive) case. 

Due to this structure, which leaves "nothing to do" after the
recursive call, a tail-recursive function can be transformed to an
imperative ``while``-loop. The benefits of such transformation is the
possibility not to use the `Call Stack`_, necessary to stall the
calling structure of the program, but rather keep the computation
"flat".

.. _`Call Stack`: https://en.wikipedia.org/wiki/Call_stack

The transformation of a tail-recursive program into a program that
uses the ``while``-loop happens in two phases:

* Make the parameters of the functions *mutable* references, so they
  could be re-assigned at each loop iteration.
* Make the branch-condition of  "base" case to be that of the
  ``while``-loop. Whatever post-processing of the result takes place
  in the base cases, should now be done after the loop.

The result of transforming `find_min` into a loop is as follows::

  let find_min_loop ls = 
  
    let loop cur_tail cur_min = 
      while !cur_tail <> [] do
        let xs = !cur_tail in
        let h = List.hd xs in
        let min = !cur_min in
        cur_min := if h < min then h else min;
        cur_tail := List.tl xs
      done;
      !cur_min

    in match ls with
    | h :: t -> 
      let cur_tail = ref t in
      let cur_min = ref h in
      let min = loop cur_tail cur_min in
      Some min
    | _ -> None

Notice that the function ``walk`` has been renamed ``loop``, which is
no longer recursive: the tail recursion has been "unfolded" into the
loop, and pattern-matching has been replaced by the loop condition
``!cur_tail <> []``. Furthermore, all parameters are now just
references that are being reassigned at each loop iteration.

An important observation is that reassigning the mutable variables in
an imperative implementation is equivalent to passing new arguments in
the corresponding recursive implementation. Knowing that makes it easy
to "switch" between loop-based imperative and tail-recursive
functional implementations.

Loop variants
-------------

The function ``find_min_loop`` still terminates. The main source of
non-termination in imperative programs, in addition to recursion, are
loops. However, we can reason about the loop termination in the same
way we did for recursive programs: by means of finding a **loop
variant** (i.e., termination measure), expressed as a function of
values stored in variables, affected by the loop iteration. 

In the case of ``loop`` above the loop variant is the size of a list
stored in the variable ``cur_tail``, which keeps decreasing, leading
to the loop termination when the it becomes zero.

Loop invariants
---------------

Now, as we have a program with a loop, can we use the same methodology
to ensure its correctness using pre- and postconditions? The answer is
yes, and, in fact, we are only going to need the definitions that we
already have.

The precondition of what used to be ``walk`` and is now ``loop``
becomes *loop invariant*, which serves exactly the same purpose as the
precondition of a recursive version. Specifically, it should 

* be true before and after each iteration;

* when conjoined with the loop condition, allow for establishing the
  property of the loop-affected state, implying the client-imposed
  specification.

Notice that the first quality of the loop invariant is the same as of
the precondition. The fact that it must hold not just at the
beginning, but also at the end of each iteration is because in a loop,
a new iteration begins right after the previous one ends, and hence it
expects its "precondition"/"invariant" to hold. The second quality
corresponds to the intuition that the invariant/precondition should be
chosen in a way that when a loop terminates (or, equivalently, a
recursive function returns), the invariant allows to infer the
postcondition.

All that said, for our imperative version of finding a minimum, we can
use ``find_min_walk_pre`` as the loop invariant, annotating the
program as follows::

  let find_min_loop_inv ls = 
  
    let loop cur_tail cur_min = 
      (* The invariant holds at the beginning of the loop *)
      assert (find_min_walk_pre ls !cur_tail !cur_min);
      while !cur_tail <> [] do
        let xs = !cur_tail in
        let h = List.hd xs in
        let min = !cur_min in
        cur_min := if h < min then h else min;
        cur_tail := List.tl xs;
        (* The invariant holds at the end of the iteration *)
        assert (find_min_walk_pre ls !cur_tail !cur_min);
      done;
      !cur_min

    in match ls with
    | h :: t -> 
      let cur_tail = ref t in
      let cur_min = ref h in
      (* The invariant holds at the beginning of the loop *)
      assert (find_min_walk_pre ls !cur_tail !cur_min);
      let min = loop cur_tail cur_min in
      (* Upon finishing the loop, the invariant implies the postcondition. *)
      assert (find_min_walk_post ls !cur_tail !cur_min min);
      Some min
    | _ -> None
