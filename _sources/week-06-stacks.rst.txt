.. -*- mode: rst -*-

Stacks
======

* File: ``Stacks.ml``

Stack is a good example of a simple abstract data type that implements
a set (with possibly repeating elements) with a small number of
operations for adding and removing elements. In doing so, stack
provides two main operations ``pop`` and ``push`` that implement a
discipline known as LIFO (last-in-first-out): an element added last is
retrieved first.

The Stack interface
-------------------

A simple stack interface is described by the following OCaml module signature::

 module type AbstractStack = sig
     type 'e t
     val mk_stack : int -> 'e t
     val is_empty : 'e t -> bool
     val push : 'e t -> 'e -> unit
     val pop : 'e t -> 'e option
   end

Notice that the first type member (``type 'e t``) is what makes this
data type abstract. The type declaration stands for and "abstract type
``t`` of the stack storing elements of type ``'e``. In reality, the
stack, as a data structure, can be implemented in various ways, but
this type definition does not reveal those details. Instead, it
provides four functions to manipulate with stacks --- and this is the
only vocabulary for doing so. Specifically:

* ``mk_stack`` creates a new empty stack (hence the output result is
  ``'e t``) with a suggested size ``n``
* ``is_empty`` checks is the stack is empty
* ``push`` adds new element to the top of the stack
* ``pop`` removes the latest added element ``e`` from the top of the
  stack and returns ``Some e``, if such element exists, or ``None`` if
  the stack is empty. The stack is then modified, so this element is
  removed.

Unlike OCaml list, is a *mutable* structure. This means each
"effectful" operation of it, such as ``push`` or ``pop``, changes its
contents, rather than returns a new copy, the result type of ``push``
is ``unit``. Both ``push`` and ``pop``, thus, modify the stack
contents, in addition to returning a result (in the case of ``pop``).


An List-Based Stack
-------------------

Our first concrete implementation of a stack ADT exploits the fact
that OCaml lists behave precisely like stacks, so we can build the
following implementation almost effortlessly::

 module ListBasedStack : AbstractStack = struct
     type 'e t = 'e list ref
     let mk_stack _ = ref []
     let is_empty s = match !s with
       | [] -> true
       | _ -> false
     let push s e = 
       let c = !s in
       s := e :: c
     let pop s = match !s with
       | h :: t ->
         s := t; Some h
       | _ -> None
   end

What is important to notice is that ``type 'e t`` in the concrete
implementation is defined to be ``'e list ref``, so in the rest of the
module we can use the properties of this concrete data type (i.e.,
dereference it and work with it as with an OCaml list). Notice also
that the concrete module ``ListBasedStack`` is annotated with the
abstract signature ``AbstractStack``, making sure that all definitions
have the matching types. The implication of this is that `no user` of
this module will be able to exploit the fact that our "stack type" is,
in fact, a reference to an OCaml list. An example of such an "exploit"
would be, for instance, making the stack empty foregoing the use of
``pop`` in order to deplete it first, element by element.

When implementing your own concrete implementation of an abstract data
type, it is recommended to ascribe the module signature (e.g.,
``AbstractStack``) as the `last` step of your implementation. If you
do it before the module is complete, the OCaml compiler/back-end will
not be complaining about your implementation of the module does not
match the signature, which makes the whole development process less
pleasant.

Let us now test our stack ADT implementation by pushing and popping
different elements, keeping in mind the expected LIFO behaviour. We
start by reating an empty stack::

 # let s = ListBasedStack.mk_stack ();;
 val s : '_weak101 ListBasedStack.t = <abstr>

Notice that the type ``'_weak101`` indicates that OCaml doesn't yet
know what is the type of stack elements, and it will be clear once we
push the first one. Furthermore the type of the stack itself is
presented as ``ListBasedStack.t``, i.e., it is not shown to be a
reference to list -- what we defined it to be. Let us now push three
elements to a stack and check it for emptiness::

 # push s (4, "aaa");;
 - : unit = ()
 # push s (5, "bbb");;
 - : unit = ()
 # push s (7, "ccc");;
 - : unit = ()
 # is_empty s;;
 - : bool = false

As the next step, we can start removing elements from the stack, making sure that they come up in the reverse order with respect to how they were added::

 # pop s;;
 - : (int * string) option = Some (7, "ccc")
 # pop s;;
 - : (int * string) option = Some (5, "bbb")
 # pop s;;
 - : (int * string) option = Some (4, "aaa")

Finally, we can test that, after we've removed all initially added
elements, the stack is empty and remains this way::

 # pop s;;
 - : (int * string) option = None
 # pop s;;
 - : (int * string) option = None

An Array-Based Stack
--------------------

An alternative implementation of stacks uses an array of some size
``n``, thus requiring constant-size memory. A natural shortcoming of
such a solution is the fact that the stack can hold only up to ``n``
elements. However, the advantage is that one can implement such a
stack in language that do not provide algebraic lists, but only
provide arrays (e.g., C)::

 module ArrayBasedStack : AbstractStack = struct
     type 'e t = {
       elems   : 'e option array;
       cur_pos : int ref 
     }

     (* More functions to be added here *)
   end

The abstract type ``'e t`` is now defined quite differently --- it is
a record that stores two fields. The first one is an array of options
of elements of type ``'e`` (representing the elements of the stack in
a desired order), while the second one is a pointer to the position
``cur_pos`` at which the next element of the stack must be added.
Defining the stack this way, we agree on the following invariant: the
"empty" elements in a stack are represented by ``None``, which the
array, serving as a "carrier" for the stack will be filled with
elements from its beginning, with ``cur_pos`` pointing to the next
empty position to fill. For instance, a stack with the maximal
capacity of 3 elements, with the elements ``"a"`` and ``"b"`` will be
represented by the array ``[|Some "b"; Some "a"; None|]``, with
``cur_pos`` being ``2``, indicating the next slot to insert an
element.

In order to make a new stack, we create a fixed-length array for size
``n``, setting ``cur_ref`` to point to 0::

     let mk_stack n = {
       elems = Array.make n None;
       cur_pos = ref 0
     }

We can also use ``cur_pos`` to determine whether the stack is empty or
not::

     let is_empty s = !(s.cur_pos) = 0

Pushing a new element requires us to insert a new element into the
next vacant position in the "carrier" array and then increment the
current position. If the current position points outside of the scope
of the array, it means that the stack is full and cannot accommodate
more elements, so we just throw an exception::

     let push s e = 
       let pos = !(s.cur_pos) in 
       if pos >= Array.length s.elems 
       then raise (Failure "Stack is full")
       else (s.elems.(pos) <- Some e;
             s.cur_pos := pos + 1)

Similarly, ``pop`` returns an element (wrapped into ``Some``) right
before ``cur_pos``, if ``cur_pos > 0``, or ``None`` otherwise::

     let pop s = 
       let pos = !(s.cur_pos) in
       let elems = s.elems in
       if pos <= 0 then None
       else (
         let res = elems.(pos - 1) in
         s.elems.(pos - 1) <- None;
         s.cur_pos := pos - 1;
         res)

Let us test the implementation to make sure that it indeed behaves as
a stack::

 # open ArrayBasedStack;;
 # let s = mk_stack 10;;
 val s : '_weak102 ArrayBasedStack.t = <abstr>
 # push s (3, "aaa");;
 - : unit = ()
 # push s (5, "bbb");;
 - : unit = ()
 # push s (7, "ccc");;
 - : unit = ()
 # pop s;;
 - : (int * string) option = Some (7, "ccc")
 # pop s;;
 - : (int * string) option = Some (5, "bbb")
 # pop s;;
 - : (int * string) option = Some (3, "aaa")
 # is_empty s;;
 - : bool = true
 # pop s;;
 - : (int * string) option = None
