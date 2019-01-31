.. -*- mode: rst -*-

Selection Sort
==============

Selection sort is another sorting algorithm based on finding a minimum
in an array. Unlike insertion sort, which locates each new element in
an already sorted prefix, selection sort obtains the sorted prefix by
"extending" it, at each iteration, with a minimum of a not-yet sorted
suffix of the array::

 let select_sort arr = 
   let len = Array.length arr in
   for i = 0 to len - 1 do
     for j = i to len - 1 do
       if arr.(j) < arr.(i)
       then swap arr i j
       else ()
     done
   done

Tracing Selection Sort
----------------------

Let us print intermediate stages of the selection sort as follows::

 let select_sort_print arr = 
   let len = Array.length arr in
   for i = 0 to len - 1 do
     print_int_sub_array 0 i arr; 
     print_int_sub_array i len arr;
     print_newline ();

     for j = i to len - 1 do
       print_offset ();
       Printf.printf "j = %d, a[j] = %d, a[i] = %d: " j arr.(j) arr.(i);
       print_int_sub_array 0 i arr;
       print_int_sub_array i len arr;
       print_newline ();

       if arr.(j) < arr.(i)
       then swap arr i j
       else ()
     done;

     print_int_sub_array 0 (i + 1) arr; 
     print_int_sub_array (i + 1) len arr;
     print_newline (); print_newline ();
   done

This results in the following output::

 # select_sort_print a1;;
 [|  |] [| 6; 8; 5; 2; 3; 7; 0 |] 
   j = 0, a[j] = 6, a[i] = 6: [|  |] [| 6; 8; 5; 2; 3; 7; 0 |] 
   j = 1, a[j] = 8, a[i] = 6: [|  |] [| 6; 8; 5; 2; 3; 7; 0 |] 
   j = 2, a[j] = 5, a[i] = 6: [|  |] [| 6; 8; 5; 2; 3; 7; 0 |] 
   j = 3, a[j] = 2, a[i] = 5: [|  |] [| 5; 8; 6; 2; 3; 7; 0 |] 
   j = 4, a[j] = 3, a[i] = 2: [|  |] [| 2; 8; 6; 5; 3; 7; 0 |] 
   j = 5, a[j] = 7, a[i] = 2: [|  |] [| 2; 8; 6; 5; 3; 7; 0 |] 
   j = 6, a[j] = 0, a[i] = 2: [|  |] [| 2; 8; 6; 5; 3; 7; 0 |] 
 [| 0 |] [| 8; 6; 5; 3; 7; 2 |] 

 [| 0 |] [| 8; 6; 5; 3; 7; 2 |] 
   j = 1, a[j] = 8, a[i] = 8: [| 0 |] [| 8; 6; 5; 3; 7; 2 |] 
   j = 2, a[j] = 6, a[i] = 8: [| 0 |] [| 8; 6; 5; 3; 7; 2 |] 
   j = 3, a[j] = 5, a[i] = 6: [| 0 |] [| 6; 8; 5; 3; 7; 2 |] 
   j = 4, a[j] = 3, a[i] = 5: [| 0 |] [| 5; 8; 6; 3; 7; 2 |] 
   j = 5, a[j] = 7, a[i] = 3: [| 0 |] [| 3; 8; 6; 5; 7; 2 |] 
   j = 6, a[j] = 2, a[i] = 3: [| 0 |] [| 3; 8; 6; 5; 7; 2 |] 
 [| 0; 2 |] [| 8; 6; 5; 7; 3 |] 

 [| 0; 2 |] [| 8; 6; 5; 7; 3 |] 
   j = 2, a[j] = 8, a[i] = 8: [| 0; 2 |] [| 8; 6; 5; 7; 3 |] 
   j = 3, a[j] = 6, a[i] = 8: [| 0; 2 |] [| 8; 6; 5; 7; 3 |] 
   j = 4, a[j] = 5, a[i] = 6: [| 0; 2 |] [| 6; 8; 5; 7; 3 |] 
   j = 5, a[j] = 7, a[i] = 5: [| 0; 2 |] [| 5; 8; 6; 7; 3 |] 
   j = 6, a[j] = 3, a[i] = 5: [| 0; 2 |] [| 5; 8; 6; 7; 3 |] 
 [| 0; 2; 3 |] [| 8; 6; 7; 5 |] 

 [| 0; 2; 3 |] [| 8; 6; 7; 5 |] 
   j = 3, a[j] = 8, a[i] = 8: [| 0; 2; 3 |] [| 8; 6; 7; 5 |] 
   j = 4, a[j] = 6, a[i] = 8: [| 0; 2; 3 |] [| 8; 6; 7; 5 |] 
   j = 5, a[j] = 7, a[i] = 6: [| 0; 2; 3 |] [| 6; 8; 7; 5 |] 
   j = 6, a[j] = 5, a[i] = 6: [| 0; 2; 3 |] [| 6; 8; 7; 5 |] 
 [| 0; 2; 3; 5 |] [| 8; 7; 6 |] 

 [| 0; 2; 3; 5 |] [| 8; 7; 6 |] 
   j = 4, a[j] = 8, a[i] = 8: [| 0; 2; 3; 5 |] [| 8; 7; 6 |] 
   j = 5, a[j] = 7, a[i] = 8: [| 0; 2; 3; 5 |] [| 8; 7; 6 |] 
   j = 6, a[j] = 6, a[i] = 7: [| 0; 2; 3; 5 |] [| 7; 8; 6 |] 
 [| 0; 2; 3; 5; 6 |] [| 8; 7 |] 

 [| 0; 2; 3; 5; 6 |] [| 8; 7 |] 
   j = 5, a[j] = 8, a[i] = 8: [| 0; 2; 3; 5; 6 |] [| 8; 7 |] 
   j = 6, a[j] = 7, a[i] = 8: [| 0; 2; 3; 5; 6 |] [| 8; 7 |] 
 [| 0; 2; 3; 5; 6; 7 |] [| 8 |] 

 [| 0; 2; 3; 5; 6; 7 |] [| 8 |] 
   j = 6, a[j] = 8, a[i] = 8: [| 0; 2; 3; 5; 6; 7 |] [| 8 |] 
 [| 0; 2; 3; 5; 6; 7; 8 |] [|  |] 

 - : unit = ()

Notice that at each iteration of the inner loop, a new minimum of the
remaining suffix is identified and at the end this is what becomes and
"extension" of the currently growing prefix: ``0``, ``2``, ``3``,
``5``, etc. During the inner iteration, we look for minimum in the
same way we were looking for a minimum in a list. All elements in the
non-sorted suffix are larger or equal than elements in the prefix. The
current element ``arr.(i)`` is, thus a minimum of the
prefix-of-the-suffix of the array, yet it's larger than any element in
the prefix.

Invariants of Selection Sort
----------------------------

The observed above intuition can be captured by the following
invariants::

 let suffix_larger_than_prefix i arr =
   let len = Array.length arr in
   let prefix = array_to_list 0 i arr in
   let suffix = array_to_list i len arr in
   List.for_all (fun e -> 
       List.for_all (fun f -> e <= f)  suffix
     ) prefix

 let select_sort_outer_inv i arr =
   sub_array_sorted 0 i arr &&
   suffix_larger_than_prefix i arr

 let select_sort_inner_inv j i arr = 
   is_min_sub_array i j arr arr.(i) &&
   sub_array_sorted 0 i arr &&
   suffix_larger_than_prefix i arr

leading to the following annotated version::

 let select_sort_inv arr = 
   let len = Array.length arr in
   for i = 0 to len - 1 do
     assert (select_sort_outer_inv i arr);
     for j = i to len - 1 do
       assert (select_sort_inner_inv j i arr);
       if arr.(j) < arr.(i)
       then swap arr i j
       else ();
       assert (select_sort_inner_inv (j + 1) i arr);
     done;
     assert (select_sort_outer_inv (i + 1) arr);
   done

Notice that the inner invariant, when ``j`` becomes ``len`` (i.e.,
right before the end of the last iteration), implies that the found
element ``arr.(i)`` is the global minimum of the suffix (which is all
larger than prefix), and, hence the sorted prefix can be extended with
this element, while remaining sorted.

Termination of Selection Sort
-----------------------------

the algorithm terminates, as both loops in it, inner and outer are
bounded and iterate over finite sub-arrays of a given array.

.. _exercise-selection-max: 

Exercise 2
----------

Rewrite selection sort, so it would walk the array right-to-left,
looking for a maximum rather than a minimum for a currently
unprocessed sub-array, while sorting the overall array in an ascending
order. Write the invariants for this version and explain how the inner
loop invariant, upon the loop's termination, implies the outer loop's
invariant.

.. _exercise-generalised-sort: 


Exercise 3
----------

Generalise either insertion or selection sort to take an array of
arbitrary type ``'a array`` and comparator ``less_than`` of type ``'a
-> 'a -> bool``, and return an array sorted in an ascending order
according to this comparator. Test your implementation by sorting an
array of lists by length.

.. _exercise-comparison-order:

Exercise 4
----------

* Which sorting method executes less primitive operations, such as
  swapping and comparing array elements, for an array in reverse
  order, selection sort or insertion sort?

* Which method runs faster on a fully sorted array?

Conduct experiments and justify your answer by explaining the
mechanics of the algorithms.

.. _exercise-bubble-sort: 

Exercise 5
----------

Bubble Sort is a popular, but inefficient, sorting algorithm, similar
to selection sort. Instead of selecting a new minimum, it works by
repeatedly swapping adjacent elements in the suffix that are out of
order. In *pseudocode* it is implemented as follows::

  BubbleSort (A):
    for i = 1 to A.length - 1
      for j = A.length - 1 downto i + 1
        if A[j] < A[j - 1]
          swap A[j] and A[j - 1]

* Implement the algorithm in OCaml using ``for-to`` and ``for-downto``
  constructs.

* Implement tracing for it. 

* State the inner and the outer loop invariants. Explain in text how
  the inner invariant, upon finishing the inner loop, implies the
  invariant of the outer loop.
