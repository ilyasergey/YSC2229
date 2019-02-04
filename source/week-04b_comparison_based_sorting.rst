.. -*- mode: rst -*-

Generalising Comparison-Based Sorting
=====================================

So far we have seen a number of sorting algorithms that were useful on
arrays of particular shape, such as filled with just integers, or
pairs having integers as their first components. However, the only
operation we required of a data inhabiting the array to provide is the
ability to *compare* its elements with each other. Such an ability has
been provided by means of comparing integers, but the very same
algorithms can be used, e.g., for sorting arrays of lists (ordered
via length) or strings (ordered lexicographically), or even arrays of
arrays. 

Let us generalise the latest introduced sorting algorithm, namely,
Quicksort via two different mechanisms OCaml provides.


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

A functor of sorting
--------------------

