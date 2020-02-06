.. -*- mode: rst -*-

Generalising Comparison-Based Sorting
=====================================

* File: ``GeneralisedSorting.ml``

So far we have seen a number of sorting algorithms that were useful on arrays of particular shape, such as filled with just integers, or pairs having integers as their first components. However, the only operation we required of a data inhabiting the array to provide is the ability to *compare* its elements with each other. Such an ability has been provided by means of comparing integers, but the very same algorithms can be used, e.g., for sorting arrays of lists (ordered via length) or strings (ordered lexicographically), or even arrays of arrays.

Let us generalise the latest introduced sorting algorithm, namely, Quicksort via two different mechanisms OCaml provides.


Comparator as a parameter
-------------------------

The following implementation of ``generic_quick_sort`` takes a *named* parameter ``comp`` (hence the syntax with ``~``). It serves as a *comparator* --- a function that takes an element of an array and returns an integer. The contract the implementation follows is that if ``comp x y`` returns a negative integer, it is interpreted as ``x < y``, a positive integer means ``x > y`` and zero means ``x = y``::

 let generic_quick_sort arr ~comp = 
   let partition arr lo hi = 
     if hi <= lo then lo
     else
       let pivot = arr.(hi - 1) in
       let i = ref lo in 
       for j = lo to hi - 2 do
         if comp arr.(j) pivot <= 0 
         then
           (swap arr !i j;
            i := !i + 1)
       done;
       swap arr !i (hi - 1);
     !i
   in
   let rec sort arr lo hi = 
     if hi - lo <= 1 then ()
     else 
       let mid = partition arr lo hi in
       sort arr lo mid;
       sort arr mid hi
   in
   sort arr 0 (Array.length arr)

Notice that nothing else is known about the elements of an array, only the fact that they can be passed to ``comp`` getting an integer in return.

We can now instantiate ``generic_quick_sort`` with different comparators, sorting arrays of arbitrary elements, which we know how to compare, in an ascending or a descending order. For instance, the following comparator restores the familiar logic of sorting an array of integers::

 let int_order_asc = 
   fun x y -> if
     x < y then -1
     else if x = y then 0
     else 1

We can test it with success::

 let%test _ =
   random_sorting_test_int 
     (generic_quick_sort ~comp:int_order_asc) 500

.. _sec-functor-sorting: 

A functor for sorting
---------------------

Another way to define generic sorting is by using OCaml's mechanisms of *modules* as a way to bundle several dependent definitions together, and *functors* --- modules that take other modules as parameters.

The following code defines a *module signature* --- an abstract interface that postulates that the modules satisfying this signature will feature a concrete type ``t`` and a function ``comp`` of type ``t -> t -> int``::

 module type Comparable = sig
   type t
   val comp : t -> t -> int
 end

Intuitively, you can think of the module signature ``Comparable`` as of a "promise" to give a data type ``t``, whose elements we will know how to compare via ``comp`` that comes "bundled" with it.

Without even having specific instances of this signature, we can go ahead and describe a higher-order module (functor) ``Sorting``, which, if given an instance ``Comp`` of a signature ``Comparable``, will provide a function to sort arrays, whose elements are of type ``Comp.t``::

 module Sorting (Comp: Comparable) = struct
   include Comp

   let sort arr  = 
     let partition arr lo hi = 
       if hi <= lo then lo
       else
         let pivot = arr.(hi - 1) in
         let i = ref lo in 
         for j = lo to hi - 2 do
           if comp arr.(j) pivot <= 0 
         then
           (swap arr !i j;
            i := !i + 1)
       done;
       swap arr !i (hi - 1);
     !i
   in
   let rec sort_aux arr lo hi = 
     if hi - lo <= 1 then ()
     else 
       let mid = partition arr lo hi in
       sort_aux arr lo mid;
       sort_aux arr mid hi
   in
   sort_aux arr 0 (Array.length arr)
 end

As you can notice, ``Sorting`` imports all definitions from ``Comp``, i.e., its concrete ``t`` and implementation of ``comp`` to be provided, and uses the latter in its implementation of Quicksort.

Now, in order to obtain procedures for sorting particular elements (e.g., integers), we need to provide the  corresponding *concrete* modules, whose "shape" satisfies the constraints imposed by the signature ``Comparable``::

 module IntAsc = struct
   type t = int
   let comp = int_order_asc
 end

Notice that both modules above have their members named in the same
way as per the signature ``Comparable``, and the type of ``comp`` is
both corresponds to the one in ``Comparable``, module the concrete
nature of ``t``, which in ``IntAsc`` is taken to be ``int``.

We can now create an instance of the sorting module by providing a
comparator module to our sorting functor::

 module AscIntSorting = Sorting(IntAsc)

Finally, we can export the corresponding sorting function::

 let int_sort_asc = AscIntSorting.sort

and test it::

 let%test _ = random_sorting_test_int int_sort_asc 500

At the beginning, the machinery of modules and functors might seem
much more heavy-weight that that of simply passing comparators.
However, it will pay off to be familiar with it, once we will start
working with *abstract data types* that provide a *rich vocabulary* of
useful procedures to work with certain data, should they be given a
small corresponding module instance with *basic operations on that
data*.

In this sense, signatures, modules and functors in OCaml are similar
to interfaces and classes in languages such as Java and C#, but
provide somewhat more succinct way to parameterise libraries by
client-defined primitive operations. That said, OCaml features an
object model as well (similar to Java), which we won't be using very
actively in this class.
