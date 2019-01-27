.. -*- mode: rst -*-

Merge Sort
==========

Merge sort is a algorithm that applies the divide-and-conquer idea to sorting. 

Merging two sorted arrays
-------------------------

The heart of merge sort heart is the procedure ``merge`` that merges two already sorted arrays, ``from1`` and ``from2``, into a dedicated subarray ranging from ``lo`` to ``hi`` of an initial "destination" array ``dest``::

 let merge from1 from2 dest lo hi =
   let len1 = Array.length from1 in 
   let len2 = Array.length from2 in 
   let i = ref 0 in
   let j = ref 0 in
   for k = lo to hi - 1 do
     if !i >= len1 
     then (dest.(k) <- from2.(!j); j := !j + 1)
     else if !j >= len2
     then (dest.(k) <- from1.(!i); i := !i + 1)
     else if fst from1.(!i) <= fst from2.(!j)
     then (dest.(k) <- from1.(!i); i := !i + 1)
     else (dest.(k) <- from2.(!j); j := !j + 1)
   done

Invariant of ``merge``
----------------------

We can check that ``merge`` indeed creates a sorted array out of two smaller sorted arrays using the following familiar auxiliary functions::

 let rec sorted ls = 
   match ls with 
   | [] -> true
   | h :: t -> 
     List.for_all (fun e -> fst e >= fst h) t && sorted t

 let array_to_list l u arr = 
   assert (l <= u);
   let res = ref [] in
   let i = ref (u - 1) in
   while l <= !i do
     res := arr.(!i) :: !res;
     i := !i - 1             
   done;
   !res

 let sub_array_sorted l u arr = 
   let ls = array_to_list l u arr in 
   sorted ls

 let array_sorted arr = 
   sub_array_sorted 0 (Array.length  arr) arr

 let same_elems ls1 ls2 =
   List.for_all (fun e ->
       List.find_all (fun e' -> e = e') ls2 =
       List.find_all (fun e' -> e = e') ls1
     ) ls1 &&
   List.for_all (fun e ->
       List.find_all (fun e' -> e = e') ls2 =
       List.find_all (fun e' -> e = e') ls1
     ) ls2

The pre- and post-condition of merge the would look as follows::

 let merge_pre from1 from2 = 
   array_sorted from1 && array_sorted from2

 let merge_post from1 from2 arr lo hi = 
   array_sorted arr &&
   (let l1 = array_to_list 0 (Array.length from1) from1 in
   let l2 = array_to_list 0 (Array.length from2) from2 in
   let l = array_to_list lo hi arr in
   same_elems (l1 @ l2) l)

Main sorting procedure and its invariants
-----------------------------------------

The main merge sort procedure preforms sorting recursively by (a) by splitting the given array range into two new smaller arrays repeatedly until reaching the primitive arrays (of size of 0 or 1, which are already sorted) and (b) merging the small arrays bottom-up into the larger arrays, until the top range is reached::

 let copy_array arr lo hi =
   let len = hi - lo in
   assert (len >= 0);
   if len = 0 then [||]
   else 
     let res = Array.make len arr.(lo) in
     for i = 0 to len - 1 do
       res.(i) <- arr.(i + lo)
     done;
     res

 let rec merge_sort arr = 
   let rec sort a = 
     let lo = 0 in
     let hi = Array.length a in
     if hi - lo <= 1 then ()
     else
       let mid = lo + (hi - lo) / 2 in
       let from1 = copy_array a lo mid in
       let from2 = copy_array a mid hi in
       sort from1; sort from2;
       merge from1 from2 a lo hi
   in
   sort arr

This style of merge sort is known as a top-down merge-sort.

Having checked the invariants for ``merge`` it's almost trivial to annotate ``merge_sort`` with invariants::

 let rec merge_sort_inv arr = 
   let rec sort a = 
     let hi = Array.length a in
     let lo = 0 in
     if hi - lo <= 1 then ()
     else
       let mid = lo + (hi - lo) / 2 in
       let from1 = copy_array a lo mid in
       let from2 = copy_array a mid hi in
       sort from1; sort from2;
       assert (merge_pre from1 from2);
       merge from1 from2 a lo hi;
       assert (merge_post from1 from2 a lo hi)
   in
   sort arr
 
.. _exercise-fast-merge-sort:

Exercise 5 
----------

The merge sort presented above can be improved by getting rid of allocating new sub-arrays to copy elements to and sort recursively every time. The way to do it is to initially allocate just one auxiliary array ``aux`` of the same size as the initial one and use it as a "sandbox" for sorting, without ever allocating more arrays. Indeed, the ``merge`` procedure will have to be adapted as well.

Implement this version of the merge sort and compare its performance (using function ``time``) with the previous version of merge sort. Describe the invariant for the new version of merge and for the main function and check that it holds.

.. _exercise-three-way-merge-sort:

Exercise 6 
----------

Implement a version of merge sort that splits the sub-arrays into three parts and then combines them together. Compare its performance to the ordinary 2-way merge sort.

.. _exercise-index-sort:

Exercise 7
----------

Develop and implement a version of merge sort that does not rearrange the input array ``arr``, but returns an array ``perm`` of type ``int array``, such that ``perm.(i)`` is the index in ``arr`` of the entry with ``i`` th smallest key in the array.

