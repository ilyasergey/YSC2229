.. -*- mode: rst -*-

Correctness of Recursive Algorithms
===================================

Data types, present in the modern computer languages, allow one to
provide finite descriptions of arbitrary-size data. A classical
example of such description, recall the definition of the list data
type in OCaml, following the grammar::

  <list-of-things> ::= []
                     | <thing> :: <list-of-things>

That is, to recall, a list is either empty `[]` or constructed by
appending a head `<thing>` to an already constructed list.

Warm-up: finding a minimum in a list of integers
------------------------------------------------

Being defined recursively, lists are commonly processed by means of
recursive functions. As a warm-up, just to remind us what it's like to
work with lists, let us write a function that walks the list finding
its minimal element ``min``, and returns ``Some min``, if it's found and
``None`` if the list is empty::

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

Checking termination of ``find_min``
------------------------------------

How do we know that ``find_min`` indeed terminates on every input?
Since the only source of non-termination in functional programs is
recursion, in order to argue for the termination of ``find_min`` we
have to take a look at its recursive subroutine, namely ``walk``. Let
us notice that ``walk``, whenever it calls itself recursively, always
does so taking the tail ``t`` of its initial argument list ``xs`` as a
new input. Therefore, every time it runs on a *smaller* list, and
whenever it reaches the empty list ``[]``, it simply outputs the
result ``min``. 

The list argument ``xs``, or, more precisely, it size, is commonly
referred to as a **termination measure** or **variant** of a recursive
function. A somewhat more formal definition of *variant* of a
recursive procedure ``f`` is a function that maps arguments of ``f``
to an integer number ``n``, such that every recursive call to ``f``
decreases it, such that eventually it reaches some value, which
corresponds to the final step of a computation, at which points the
function terminates, returning the result.

.. _exercise-find-min-termination-measure:

Exercise 1
----------

What is the termination measure of ``walk`` within ``find_min``?
Define it as a function ``f : 'a list -> int -> int`` and change the
implementation of ``walk`` annotating it with outputs to check that
the measure indeed decreases.

* Hint: use OCaml's ``Printf.printf`` utility to output results of the
  termination measure mid-execution.

Checking correctness of ``find_min``
------------------------------------

How do we know that the function is indeed correct, i.e., does what
it's supposed to do? A familiar way to probe it for the *presence* of
bugs is to give the function a specification and write some tests.

The declarative specification, defined as a function in OCaml, defines
``m`` as a minimum for a list ``ls``, if all elements of ``ls`` are not
smaller than ``m``::

  let is_min ls m = List.for_all (fun e -> e >= m) ls

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

Those test cases are indeed only meaningful if we trust that our
specification ``find_min_spec`` indeed correctly describes the
expected behaviour of its argument ``find_min_fin``. In other words,
to recall, the tests are only as good as the specification they check:
if the specification cpatures a wrong property or ignores some
essential relations between an input and a result of an algorithm,
then such tests can make more harm than good.

What we really want to ensure is that the recursive ``walk`` function
processes the lists correctly, iteratively computing the minimum
amongst the list's elements, getting closer to it with every
iteration. That is, since each "step" of ``walk`` either returns the
result or recomputes the minimum, for the part of the list *already
observed*, it would be good to capture it in some form of a
specification.

Such a specification for an arbitrary function ``f x1 ... xn`` with
arguments ``x1``, ..., ``xn`` can be captured by means of a
*precondition* and a *postcondition*, which are boolean functions that
play the following role:

* A precondition ``P x1 ... xn`` describes the relation between the
  arguments of ``f`` *right before* ``f`` is called. It is usually the
  duty of the client of the function (i.e., the code that calls it) to
  make sure that the precondition holds.

* A postcondition ``Q x1 ... xn res`` describes the relation between
  the arguments of ``f`` and its result right after ``f`` returns
  ``res``, being called with ``x1 ... xn`` as its arguments. It is a
  duty of the function implementer of ``f`` to ensure that the
  postcondition holds. 

Together the pre- and postcondition ``P``/``Q`` of a function are
frequently referred to as a *contract*, *specification*, or
*invariant*. Even though we will be using those notions
interchangeably, *contract* is most commonly appears in the context of
dynamic correctness checking (i.e., testing), while *invariant* is
most commonly used in the context of imperative computations, which we
will see below.

A function ``f`` is called **correct** with respect to a specification
``P``/``Q``, if whenever its input satisfies ``P`` (i.e., ``P x1 ...
xn = true``), its result satisfies ``Q``. The process of checking that
an implementation of a function obeys its ascribed specification is
called **program verification**.

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

Choosing the right precondition for ``walk`` is somewhat trickier

[TODO: Stopped here]


**TODO**: say how precondition should be chosen as such that
  * In the base case it trivially gives us the desired property of the
    result
  * It can be established before the initial and the recursive call. 


Therefore, let us choose the following precondition for ``walk``::

  let find_min_walk_pre ls xs min = 
    is_min ls min ||
    List.exists (fun e -> e < min) xs


And now let us annotate the function with both pre- and
postconditions::

  let find_min_with_invariants ls = 

    let rec walk xs min = 
      match xs with
      | [] -> 
        let res = min in
        (* Checking the postcondition *)
        assert (find_min_walk_post ls xs min res);
        res
      | h :: t ->
        let min' = if h < min then h else min in
        (* Checking the precondition *)
        assert (find_min_walk_pre ls t min');
        let res = walk t min' in
        (* Checking the postcondition *)
        assert (find_min_walk_post ls xs min res);
        res

    in match ls with
    | h :: t -> 
      (* Checking the precondition *)
      assert (find_min_walk_pre ls t h);
      let res = walk t h in
      (* Checking the postcondition *)
      assert (find_min_walk_post ls t h res);
      Some res
    | _ -> None

* TODO: explain what is being tested.





Quick outline of the remainder
------------------------------

* `find_min`
  * tests
  * assertions about correcntess
  * pre/postconditions -- preservation of the effect / invariant

* Imperative version of `find_min`
  * tests
  * loop invariant

* Loop invariant for countinting

* sorting the list via insertion
  * what is the desired property
  * precondition / postcondition

