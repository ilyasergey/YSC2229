.. -*- mode: rst -*-

.. _sec-array-functors:

Printing and Validating Generic Arrays
======================================

* File ``ArrayUtil.ml``, search for ``Week 05 definitions``

The machinery to print whole arrays, as well as their sub-arrays has proven very
useful in the previous examples. Let us now generalise it for the future use.

The functor ``ArrayPrinter`` below takes a module parameter ``P`` with
some type ``t`` and a function ``pp`` (short name for *pretty-print*),
which constructs a string out of a value of type ``t``. The
implementation of ``ArrayPrinter`` then uses ``pp`` as a function to
define the two familiar machineries: ``print_sub_array`` and
``print_array``. As you recall, those two were previously defined to
work on arrays of integers only, but now they can be used for printing
arrays of any data type, for which an instance of ``P`` is provided::

 (* A functor for printing arrays *)
 module ArrayPrinter = functor (P : sig
     type t
     val pp : t -> string
   end) -> struct

     (* Printing machinery *)
     let print_sub_array l u arr =
       assert (l <= u);
       assert (u <= Array.length arr);
       Printf.printf "[| ";
       for i = l to u - 1 do
         Printf.printf "%s" (P.pp arr.(i));
         if i < u - 1
         then Printf.printf "; "
         else ()      
       done;
       Printf.printf " |] "

     let print_array arr = 
       let len = Array.length arr in
       print_sub_array 0 len arr              
   end

Notice that the *module type* (i.e., signature) for ``P`` is given
in-line via the ``sig ... end`` syntax, just to avoid the clutter with
extra definitions.

The following utility function to convert an array to a list function
is generic and hence is defined at the top level::

 let to_list arr = array_to_list arr

In this chapter, we will see yet another linearithmic (i.e., working
in :math:`O(\log n)`) algorithm for sorting. Therefore, it will be
useful to be able to test automatically that it indeed sorts arrays.
Since we have written the specification for sorting before, what seems
like a logical next step is to makes this definition generic
(similarly to what we have achieved by defining
:ref:`sec-functor-sorting`), so it would only rely on an operation of
comparing two elements in an array::

 (* Checking whether an array is sorted *)
 module SortChecker = functor (C : sig 
     type t 
     val comp : t -> t -> int 
   end) -> struct

   let rec sorted ls = 
     match ls with 
     | [] -> true
     | h :: t -> 
       List.for_all (fun e -> C.comp e h >= 0) t && sorted t

   let sub_array_sorted l u arr = 
     let ls = subarray_to_list l u arr in 
     sorted ls

   let array_sorted arr = 
     sub_array_sorted 0 (Array.length  arr) arr

   let sorted_spec arr1 arr2 = 
     array_sorted arr2 &&
     same_elems (to_list arr1) (to_list arr2)
 end

Finally, in the remainder of this chapter it will be so common for us
to require both a possibility to print and to compare values of a
certain data type, that we merge these two behavioural interfaces into
a single module signature, which will be later used to describe a
parameter module for various functors that take advantage of both
sorting and printing::

 module type CompareAndPrint = sig
   type t
   val comp : t -> t -> int
   (* For pretty-printing *)
   val pp : t -> string
 end
