.. -*- mode: rst -*-

Merge Sort
==========

* File: ``MergeSort.ml``

Merge sort is an algorithm that applies the divide-and-conquer idea to sorting. 

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
     (* from1 is exhausted, copy everythin from from2 *)   
     then (dest.(k) <- from2.(!j); j := !j + 1)
     else if !j >= len2
     (* from2 is exhausted, copy everythin from from1 *)   
     then (dest.(k) <- from1.(!i); i := !i + 1)
     else if from1.(!i) <= from2.(!j)
     (* from1 has a smaller element, copy it, advance its index *)
     then (dest.(k) <- from1.(!i); i := !i + 1)
     (* from2 has a smaller element, copy it, advance its index *)
     else (dest.(k) <- from2.(!j); j := !j + 1)
   done

Main sorting procedure and its invariants
-----------------------------------------

The main merge sort procedure preforms sorting recursively by (a) by
splitting the given array range into two new smaller arrays repeatedly
until reaching the primitive arrays (of size of 0 or 1, which are
already sorted) and (b) merging the small arrays bottom-up into the
larger arrays, until the top range is reached::

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

This style of merge sort is known as a `top-down merge-sort`.

We can supplement this procedure with standard randomised tests::

  let%test _ =
    generate_int_array 10 |>
    generic_array_sort_tester merge_sort

  let%test _ =
    generate_string_array 10 |>
    generic_array_sort_tester merge_sort

  let%test _ =
    generate_key_value_array 10 |>
    generic_array_sort_tester merge_sort

The correctness of merge sort relies on the correctness of the
``merge`` procedure, which generates a sorted array out of two smalle
sorted arrays by copying them in the correct interleaving order. We
can check that ``merge`` indeed does so, by employing the familiar
auxiliary functions for testing. The pre- and post-condition of merge
the would look as follows::

 (* The two small arrays are sorted *)
 let merge_pre from1 from2 = 
   array_sorted from1 && array_sorted from2

 (* The merging is correct *) 
 let merge_post from1 from2 arr lo hi = 
   array_sorted arr &&
   (let l1 = array_to_list from1 in
    let l2 = array_to_list from2 in
    let l = subarray_to_list lo hi arr in
    same_elems (l1 @ l2) l)


Having checked the invariants for ``merge`` it's almost trivial to
annotate ``merge_sort`` with invariants::

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
 
