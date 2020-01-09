.. -*- mode: rst -*-

Insertion Sort on Arrays
========================

Previously, we have studied insertion sort and its invariants on
lists. Let us now use the same idea to sort an array. Since adding an
element into an array prefix is more difficult than it would be for
lists, we are going to implement the sorting a bit differently:
namely, *swapping*, right-to-left, the elements of each prefix (taken
from the beginning of the array increasingly), until it becomes
sorted::

  let insert_sort arr = 
    let len = Array.length arr in
    for i = 0 to len - 1 do
      let j = ref i in 
      while !j > 0 && arr.(!j) < arr.(!j - 1) do
        swap arr !j (!j - 1);
        j := !j - 1
      done
    done

We can now sort our array (notice that the operation does not return a
new array, but rather modifies an old one)::

  # a1;;
  - : int array = [|6; 8; 5; 2; 3; 7; 0|]
  # insert_sort a1;;
  - : unit = ()
  # a1;;
  - : int array = [|0; 2; 3; 5; 6; 7; 8|]

Tracing Insertion Sort
----------------------

Why does insertion sort implemented this way works? An answer to that
could be obtained via suitable invariants. But before we discover
them, it might be a good idea to study what does the algorithm do,
step by step. We are going to do that by instrumenting the code as
follows::

  (* A function unit -> unit that prints two spaces *)
  let print_offset _ = Printf.printf "  "

  let insert_sort_print arr = 
    let len = Array.length arr in
    for i = 0 to len - 1 do
      print_int_sub_array 0 i arr; 
      print_int_sub_array i len arr;
      print_newline ();
      
     let j = ref i in 
      while !j > 0 && arr.(!j) < arr.(!j - 1) do
        print_offset ();
        print_int_sub_array 0 (i + 1) arr;
        print_int_sub_array (i + 1) len arr;
        print_newline ();
        
        swap arr !j (!j - 1);
        j := !j - 1;
      done;
      
      print_int_sub_array 0 (i + 1) arr; 
      * print_int_sub_array (i + 1) len arr; 
      print_newline (); print_newline ()
  done

That is, we print the array, divided via the current index ``i``, at
the beginning and at the end of each top-level iteration (at the end,
the index is incremented, as it would be at the beginning of the next
iteration or after the loop). In th inner loop, we pring the
intermediate arrays. Notice that ``print_int_sub_array l u arr`` does
not print the element ``arr.(u)``::

 # insert_sort_print a1;;
 [|  |] [| 6; 8; 5; 2; 3; 7; 0 |] 
 [| 6 |] [| 8; 5; 2; 3; 7; 0 |] 

 [| 6 |] [| 8; 5; 2; 3; 7; 0 |] 
 [| 6; 8 |] [| 5; 2; 3; 7; 0 |] 

 [| 6; 8 |] [| 5; 2; 3; 7; 0 |] 
   [| 6; 8; 5 |] [| 2; 3; 7; 0 |] 
   [| 6; 5; 8 |] [| 2; 3; 7; 0 |] 
 [| 5; 6; 8 |] [| 2; 3; 7; 0 |] 

 [| 5; 6; 8 |] [| 2; 3; 7; 0 |] 
   [| 5; 6; 8; 2 |] [| 3; 7; 0 |] 
   [| 5; 6; 2; 8 |] [| 3; 7; 0 |] 
   [| 5; 2; 6; 8 |] [| 3; 7; 0 |] 
 [| 2; 5; 6; 8 |] [| 3; 7; 0 |] 

 [| 2; 5; 6; 8 |] [| 3; 7; 0 |] 
   [| 2; 5; 6; 8; 3 |] [| 7; 0 |] 
   [| 2; 5; 6; 3; 8 |] [| 7; 0 |] 
   [| 2; 5; 3; 6; 8 |] [| 7; 0 |] 
 [| 2; 3; 5; 6; 8 |] [| 7; 0 |] 

 [| 2; 3; 5; 6; 8 |] [| 7; 0 |] 
   [| 2; 3; 5; 6; 8; 7 |] [| 0 |] 
 [| 2; 3; 5; 6; 7; 8 |] [| 0 |] 

 [| 2; 3; 5; 6; 7; 8 |] [| 0 |] 
   [| 2; 3; 5; 6; 7; 8; 0 |] [|  |] 
   [| 2; 3; 5; 6; 7; 0; 8 |] [|  |] 
   [| 2; 3; 5; 6; 0; 7; 8 |] [|  |] 
   [| 2; 3; 5; 0; 6; 7; 8 |] [|  |] 
   [| 2; 3; 0; 5; 6; 7; 8 |] [|  |] 
   [| 2; 0; 3; 5; 6; 7; 8 |] [|  |] 
 [| 0; 2; 3; 5; 6; 7; 8 |] [|  |] 

 - : unit = ()

Insertion Sort Invariants
-------------------------

From the trace above, we can see that at the beginning and the end of
each top-level iteration, the prefix ``arr.(0) .. arr.(i)`` is sorted.
Furthermore, from the intermediate steps of the inner loop, we can see
that in each iteration the new element "crawls" from the end towards
the beginning, until it finds its position in the sorted prefix. 

Importantly, at each iteration of the inner loop, the element at the
position ``j`` is the smallest element of the prefix's suffix, i.e., 
``arr.(!j) .. arr.(i)``. We can capture that via the following
definitions, which check that a sub-array of array is indeed sorted::

  let array_to_list l u arr = 
    assert (l <= u);
    let res = ref [] in
    let i = ref (u - 1) in
    while l <= !i do
      res := arr.(!i) :: !res;
      i := !i - 1             
    done;
    !res

  let rec sorted ls = 
    match ls with 
    | [] -> true
    | h :: t -> 
      List.for_all (fun e -> e >= h) t && sorted t

  let sub_array_sorted l u arr = 
    let ls = array_to_list l u arr in 
    sorted ls

  let array_sorted arr = 
    sub_array_sorted 0 (Array.length  arr) arr

The following functions check that an elemen ``min`` is a minimum with
resepct to a particular sub-array::

 let is_min ls min = 
   List.for_all (fun e -> min <= e) ls

 let is_min_sub_array l u arr min = 
   let ls = array_to_list l u arr in 
   is_min ls min

We can now state the invariants::

 let insert_sort_inner_loop_inv j i arr = 
   is_min_sub_array !j i arr arr.(!j) &&
   sub_array_sorted 0 !j arr && 
   sub_array_sorted (!j + 1) (i + 1) arr

 let insert_sort_outer_loop_inv i arr = 
   sub_array_sorted 0 i arr

and write the invariant-annotated version of the sorting::

 let insert_sort_inv arr = 
   let len = Array.length arr in
   for i = 0 to len - 1 do
     assert (insert_sort_outer_loop_inv i arr);    
     let j = ref i in 
     while !j > 0 && arr.(!j) < arr.(!j - 1) do
       assert (insert_sort_inner_loop_inv j i arr);
       swap arr !j (!j - 1);
       j := !j - 1;
       assert (insert_sort_inner_loop_inv j i arr);
     done;
     assert (insert_sort_outer_loop_inv (i + 1) arr)
   done

Notice that at the end of the inner loop, the three conjuncts of
``insert_sort_inner_loop_inv`` together imply that the entire prefix
``arr.(0) ... arr.(i)`` is sorted, i.e., the new element is correctly
positioned within it.

Termination of Insertion Sort
-----------------------------

It is not difficult to prove that insertion sort terminates: its outer
loop is an iteration, bounded by ``len - 1``. Its inner loop's
termination measure (variant) is ``j``, so the loop terminates when
``j`` reaches 0.

.. _exercise-insert-sort-backwards: 

Exercise 1
----------

Implement a version of insertion sort for arrays called
``insert_sort_backwards``, so that its outer loop would be starting
not from the beginning (i.e., index 0), but from the end of an array
(i.e., ``(Array.length arr) - 1``). Encode and check the invariants
for this versionm and explain how the inner loop invariant, upon the
loop's termination, implies the outer loop's invariant.

