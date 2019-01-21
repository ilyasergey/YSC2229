.. -*- mode: rst -*-

Correctness of Recursive Algorithms
===================================

Data types, present in the modern computer languages, allow one to
provide finite descriptions of arbitrary-size data. As an example of
such description, remember the definition of the list data type in
OCaml, following the grammar::

  <list-of-things> ::= []
                     | <thing> :: <list-of-things>

That is, to recall, a list is either empty `[]` or constructed by
appending a head `<thing>` to an already constructed list.

Warm-up: finding a minimum in a list of integers
------------------------------------------------

Being defined recursively, lists are commonly processed by means of
recursive functions (which shouldn't be too surprising). As a warm-up,
just to remind us what it's like to work with lists, let us write a
function that walks the list finding its minimal element ``min``, and
returns ``Some min``, if it's found and ``None`` if the list is
empty::

  let find_min ls = 
    let rec walk xs min = 
      match xs with
      | [] -> min
      | h :: t ->
        let min' = if h < min then h else min in
        walk t min'
    in match ls with
    | h :: t -> 
      let min = walk t h in
      Some min
    | _ -> None

Reasoning about termination
---------------------------

How do we know that ``find_min`` indeed terminates on every input?
Since the only source of non-termination in functional programs is
recursion, in order to argue for the termination of ``find_min`` we
have to take a look at its recursive subroutine, namely ``walk``. Let
us notice that ``walk``, whenever it calls itself recursively, always
does so taking the tail ``t`` of its initial argument list ``xs`` as a
new input. Therefore, every time it runs on a *smaller* list, and
whenever it reaches the empty list ``[]``, it simply outputs the
result ``min``. 

The list argument ``xs``, or, more precisely, its size, is commonly
referred to as a **termination measure** or **variant** of a recursive
function. A somewhat more formal definition of *variant* of a
recursive procedure ``f`` is a function that maps arguments of ``f``
to an integer number ``n``, such that every recursive call to ``f``
decreases it, such that eventually it reaches some value, which
corresponds to the final step of a computation, at which points the
function terminates, returning the result.

.. _exercise-find-min-termination-measure:

Exercise 3
----------

What is the termination measure of ``walk`` within ``find_min``?
Define it as a function ``f : 'a list -> int -> int`` and change the
implementation of ``walk`` annotating it with outputs to check that
the measure indeed decreases.

* **Hint:** use OCaml's ``Printf.printf`` utility to output results of
  the termination measure mid-execution.

Reasoning about correctness
---------------------------

How do we know that the function is indeed correct, i.e., does what
it's supposed to do? A familiar way to probe the implementation it for
the *presence* of bugs is to give the function a specification and
write some tests.

The declarative specification, defined as a function in OCaml, defines
``m`` as a minimum for a list ``ls``, if *all* elements of ``ls`` are
not smaller than ``m``, and also ``m`` is indeed an element of
``ls``::

  let is_min ls m = 
    List.for_all (fun e -> m <= e) ls &&
    List.mem m ls

Let us now use it in the following specification, which makes use of
the function ``get_exn`` to *unpack* the value wrapped into an option
type::

  let get_exn o = match o with
    | Some e -> e
    | _ -> raise (Failure "Empty result!") 

  let find_min_spec find_min_fun ls = 
    let result = find_min_fun ls in
    ls = [] && result = None ||
    is_min ls (get_exn result) 

The specification checker ``find_min_spec`` is parameterised by both
the function candidate ``find_min_fun`` to be checked, and a list
``ls`` provided as an argument. We can now test is as follows::

  # find_min_spec find_min [];;
  - : bool = true
  # find_min_spec find_min [1; 2; 3];;
  - : bool = true
  # find_min_spec find_min [31; 42; 239; 5; 100];;
  - : bool = true

Those test cases are only meaningful if we trust that our
specification ``find_min_spec`` indeed correctly describes the
expected behaviour of its argument ``find_min_fin``. In other words,
to recall, the tests are only as good as the specification they check:
if the specification captures a wrong property or ignores some
essential relations between an input and a result of an algorithm,
then such tests can make more harm than good, giving a false sense of
an implementation not having any issues.

What we really want to ensure is that the recursive ``walk`` function
processes the lists correctly, iteratively computing the minimum
amongst the list's elements, getting closer to it with every
iteration. That is, since each "step" of ``walk`` either returns the
result or recomputes the minimum, for the part of the list *already
observed*, it would be good to capture it in some form of a
specification.

Such a specification for an arbitrary, possibly recursive, function
``f x1 ... xn`` with arguments ``x1``, ..., ``xn`` can be captured by
means of a **precondition** and a **postcondition**, which are boolean
functions that play the following role:

* A precondition ``P x1 ... xn`` describes the relation between the
  arguments of ``f`` *right before* ``f`` is called. It is usually the
  duty of the client of the function (i.e., the code that calls it) to
  make sure that the precondition holds whenever ``f`` is about to be
  called.

* A postcondition ``Q x1 ... xn res`` describes the relation between
  the arguments of ``f`` and its result right after ``f`` returns
  ``res``, being called with ``x1 ... xn`` as its arguments. It is a
  duty of the function implementer of ``f`` to ensure that the
  postcondition holds. 

Together the pre- and postcondition ``P``/``Q`` of a function are
frequently referred to as its **contract**, **specification**, or
**invariant**. Even though we will be using those notions
interchangeably, *contract* is most commonly appears in the context of
dynamic correctness checking (i.e., testing), while *invariant* is
most commonly used in the context of imperative computations, which we
will see below.

A function ``f`` is called **correct** with respect to a specification
``P``/``Q``, if whenever its input satisfies ``P`` (i.e., ``P x1 ...
xn = true``), its result ``res`` satisfies ``Q`` (i.e., ``Q x1 ... xn
res = true)``. The process of checking that an implementation of a
function obeys its ascribed specification is called **program
verification**.

Indeed, any function can be given multiple specifications. For
instance, both ``P`` and ``Q`` can just be constant ``true``,
trivially making the function correct. The real power of being able to
ascribe and check the specifications comes from the fact that they
allow to reason about correctness of the computations that employ the
specified function. Let us see how it works on our ``find_min``
example.

What should be the pre-/postcondition we should ascribe to ``walk``?
That very much depends on what do we want to be true of its result.
Since it's supposed to deliver the minimum of the list ``ls``, it
seems reasonable to fix the postcondition to be as follows::

  let find_min_walk_post ls xs min res = 
    is_min ls res
   
We can even use it for annotating (via OCaml's ``assert``) the body of
``find_min`` making sure that it holds once we return from the
top-level call of ``walk``. Notice, that since ``walk`` is an internal
function of ``find_min``, its postcondition also includes ``ls``,
which it uses, so it can be considered as another parameter (remember
lambda-lifting?).

Choosing the right precondition for ``walk`` is somewhat trickier, as
it needs to assist us in showing the two following executions
properties of the function being specified:

* In the base case of a recursion (in case of ``walk``, it's the
  branch `[] -> ...`), it trivially gives us the desired property of
  the result, i.e., the postcondition holds.

* It can be established before the initial and the recursive call. 

Unfortunately, coming up with the right preconditions for given
postconditions is known to be a work of art. More problematically, it
*cannot* be automated, and the problem of finding a precondition is
similar to finding good initial hypotheses for theorems in
mathematics. Ironically, this is also one of the problems that itself
is not possible to solve algorithmically: we cannot have an algorithm,
which, given a postcondition and a function, would infer a
precondition for it in a general case. Such a problem, thus is
equivalent to the infamous `Halting Problem
<https://en.wikipedia.org/wiki/Halting_problem>`_, but the proof of
such an equivalence is outside the scope of this course.

Nevertheless, we can still try to *guess* a precondition, and, for
most of the algorithms it is quite feasible. The trick is to look at
the postcondition (i.e., ``find_min_walk_post`` in our case) as the
"final" state of the computation, and try to guess, from looking at
the initial and intermediate stages, what is different, and who
exactly the program brings us to the state captured by the
postcondition, approaching it gradually as it executes its body.

In the case of ``walk``, every iteration (the case ``h :: t -> ...``)
recomputes the minium based on the head of the current remaining list.
In this it makes sure that it has the most "up-to-date" value as a
minimum, such that it either is already a global minimum (but we're
not sure in it yet, as we haven't seen the rest of the list), or the
minimum is somewhere in the tail yet to be explored. This property is
a reasonable precondition, which we can capture by the following
predicate (i.e., a boolean function)::

  let find_min_walk_pre ls xs min = 
    (* min is a global minimum, *)
    is_min ls min ||
    (* or, the minimum is in the remaining tail xs *)
    List.exists (fun e -> e < min) xs

Notice the two critical components of a good precondition:

* ``find_min_walk_pre`` holds before the first time we call ``walk``
  from the main function's body.
* Assuming it holds at the beginning of the base case, we know it
  implies the desired result ``is_min ls min``, as the second
  component of the disjunction ``List.exists (fun e -> e < min) xs``,
  with ``xs = []`` becomes ``false``.

What remains is to make sure that the precondition is satisfied at
each recursive call. We can do so by annotating our program suitably
with assertions (it requires small modifications in order to assert
postconditions of the result)::

  let find_min_with_invariant ls = 

    let rec walk xs min = 
      match xs with
      | [] -> 
        let res = min in
        (* Checking the postcondition *)
        assert (find_min_walk_post ls xs min res);
        res
      | h :: t ->
        let min' = if h < min then h else min in
        (* Checking the precondition of the recursive call *)
        assert (find_min_walk_pre ls t min');
        let res = walk t min' in
        (* Checking the postcondition *)
        assert (find_min_walk_post ls xs min res);
        res

    in match ls with
    | h :: t -> 
      (* Checking the precondition of the initial call *)
      assert (find_min_walk_pre ls t h);
      let res = walk t h in
      (* Checking the postcondition *)
      assert (find_min_walk_post ls t h res);
      Some res
    | _ -> None

Adding the ``assert`` statements makes us enforce the pre- and
postcondition: had we have guessed them wrongly, a program would crash
on some inputs. For instance, we can change ``<`` to ``>`` in the main
iteration of the ``walk``, and it will crash. We can now run now
invariant-annotated program as before ensuring that on all provided
test inputs it doesn't crash and returns the expected results.

Why would the assertion right before the recursive call to `walk`
crash, should we change ``<`` to ``>``? Let us notice that the way
``min'`` is computed, it is "adapted" for the updated state, in which
the recursive call is made: specifically, it accounts for the fact
that ``h`` might have been the new global minimum of ``ls`` ---
something that would have been done wrongly with an opposite
comparison.

Once we have checked the annotation function, we known that on those
test inputs, not only we get the right answers (which could be a sheer
luck), but also at every internal computation step, the main worker
function ``walk`` maintains a consistent invariant (i.e., satisfies
its pre/postconditions), thus, keeping the computation "on track"
towards the correct outcome.

Does this mean that the function is correct with respect to its
invariant? Unfortunately, even though adding intermediate assertions
gave us stronger confidence in this, the only tool we have at our
disposal are still only tests. In order to gain the full confidence in
the function's correctness, we would have to use a tool, such as
`Coq <https://coq.inria.fr/>`_. Having pre-/postconditions would also
be very helpful in that case, as they would specify precisely the
induction hypothesis for our correctness proof. However, those
techniques are explained in a course on Functional Programming and
Proving, and we will not be covering them here.

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

..
   Quick outline of the remainder
   ------------------------------

   * Imperative version of `find_min`
     * tests
     * loop invariant

   * Loop invariant for counting

   * sorting the list via insertion
     * what is the desired property
     * precondition / postcondition

