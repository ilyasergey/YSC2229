.. -*- mode: rst -*-

Generalising Comparison-Based Sorting
=====================================

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

We can now instantiate ``generic_quick_sort`` with different comparators, sorting arrays of arbitrary elements, which we know how to compare, in an ascending or a descending order. For instance, the following comparator restores the familiar logic of sorting an array of pairs whose first elements are integers::

 let key_order_asc = 
   fun x y -> if
     fst x < fst y then -1
     else if fst x = fst y then 0
     else 1

 let kv_quick_sort_asc =
   generic_quick_sort ~comp:key_order_asc

We can test it::

 # let b = generate_key_value_array 5;;
 val b : (int * string) array =
   [|(2, "sjbkp"); (4, "ztfxs"); (4, "mbjka"); (2, "ccxze"); (0, "nmdbm")|]
 # kv_quick_sort_asc b;;
 - : unit = ()
 # b;;
 - : (int * string) array =
 [|(0, "nmdbm"); (2, "ccxze"); (2, "sjbkp"); (4, "ztfxs"); (4, "mbjka")|]

In a similar vein, almost without any effort, we can sort an array in a descending order, simply by "reverting" the logic of a comparator::

  let key_order_desc x y = key_order_asc y x
  
  let kv_quick_sort_desc =  
    generic_quick_sort ~comp:key_order_desc

Let's test this implementation::

 # kv_quick_sort_desc b;;
 - : unit = ()
 # b;;
 - : (int * string) array =
 [|(4, "ztfxs"); (4, "mbjka"); (2, "sjbkp"); (2, "ccxze"); (0, "nmdbm")|]

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

Now, in order to obtain procedures for sorting particular elements (e.g., pairs with keys), we need to provide the  corresponding *concrete* modules, whose "shape" satisfies the constraints imposed by the signature ``Comparable``::

 module KeyAsc = struct
   type t = int * string
   let comp = key_order_asc
 end

 module KeyDesc = struct
   type t = int * string
   let comp = key_order_desc
 end

Notice that both modules above have their members named in the same way as per the signature ``Comparable``, and the type of ``comp`` is both corresponds to the one in ``Comparable``, module the concrete nature of ``t``.

We can now create two instance of sorting modules by providing two comparator modules to our sorting functor::

  module AscKVSorting = Sorting(KeyAsc)
  module DescKVSorting = Sorting(KeyDesc)

Finally, we can export the corresponding sorting functions::

  let kv_sort_asc = AscKVSorting.sort
  let kv_sort_desc = DescKVSorting.sort

and test them::

 # kv_sort_asc b;;
 - : unit = ()
 # b;;
 - : (int * string) array =
 [|(0, "nmdbm"); (2, "sjbkp"); (2, "ccxze"); (4, "mbjka"); (4, "ztfxs")|]

At the beginning, the machinery of modules and functors might seem much more heavy-weight that that of simply passing comparators. However, it will pay off to be familiar with it, once we will start working with *abstract data types* that provide a *rich vocabulary* of useful procedures to work with certain data, should they be given a small corresponding module instance with *basic operations on that data*. 

In this sense, signatures, modules and functors in OCaml are similar to interfaces and classes in languages such as Java and C#, but provide somewhat more succinct way to parameterise libraries by client-defined primitive operations. That said, OCaml features an object model as well (similar to Java), which we won't be using very actively in this class.
