.. -*- mode: rst -*-

Sorting in Linear Time
======================

* File: ``LinearTimeSorting.ml``

As we have just determined, one cannot do comparison-based sorting better than
in :math:`O(n \log n)` in the worst case. However, we can improve this
complexity if we base the logic of our algorithm *not* just on comparisons, but
will also exploit the `intrinsic` properties of the data used as keys for
elements to be sorted (e.g., integers). In this chapter we will see some
examples of such specialised sorting procedures.

Simple Bucket Sort
------------------

Bucket sort works well for the case, when the size of the set, from
which we draw the keys is limited by a certain number `bnum`. In this
case, we can allocate an auxiliary array of "buckets" (implemented as
lists), which will serve to collect elements with the key corresponding
to the bucket number. The code is as follows::

 let simple_bucket_sort bnum arr = 
   let buckets = Array.make bnum [] in
   let len = Array.length arr in 
   for i = 0 to len - 1 do
     let key = fst arr.(i) in
     let bindex = key mod bnum in
     let b = buckets.(bindex) in
     buckets.(bindex) <- arr.(i) :: b
   done;
   let res = ref [] in
   for i = bnum - 1 downto 0 do
     res := List.append (List.rev (buckets.(i))) !res
   done;
   list_to_array !res

Having created an array ``buckets``, the sort than traverses the
initial array ``arr``, and puts each element with a key ``key`` into
the bucket with the corresponding index, obtained as ``bindex = key
mod bnum``.  Notice that if the all keys are in range limited by
``bnum``, the ``mod`` operation returns the key itself.

Therefore, the first ``for``-loop has a complexity :math:`\Theta(n)`, where
:math:`n` is the size of ``arr``. The second loop walks through the array of
buckets all the buckets (making ``bnum`` iterations) and concatenates all the
lists, returning the result as the array. It is straightforward to show that the
resulting complexity of the algorithm is in :math:`O(\mathtt{bnum} \cdot n)` (it
can be made :math:`O(\mathtt{bnum} + n)` if we use append-only buffers, so we
don't have to re-traverse the lists), i.e., it is linear in ``n``.

We can see ``simple_bucket_sort`` in action::

 # let c =[|9; 9; 0; 9; 4; 7; 9; 2; 3; 3|];;
 
 # simple_bucket_sort 10 c;;
   - : int array = [|0; 2; 3; 3; 4; 7; 9; 9; 9; 9|]


.. _sec-bucket-sort:

Enhanced Bucket Sort
--------------------

If the size of the space of keys exceeds the number of the buckets,
one can still use the same idea, while also sorting each bucket
individually with a suitable sorting, such as insertion sort
(implemented for lists), as it will be operating on small and almost
sorted sub-arrays::

 let bucket_sort max ?(bnum = 1000) arr = 
   let buckets = Array.make bnum [] in
   let len = Array.length arr in 
   for i = 0 to len - 1 do
     let key = arr.(i) in
     let bind = key * bnum / max in
     let b = buckets.(bind) in
     buckets.(bind) <- arr.(i) :: b
   done;
   let res = ref [] in
   for i = bnum - 1 downto 0 do
     let bucket_contents = List.rev (buckets.(i)) in 
     let sorted_bucket = InsertSort.insert_sort bucket_contents in
     res := List.append sorted_bucket !res
   done;
   list_to_array !res


The code of ``bucket_sort`` above takes an optional parameter ``bnum``
for the number of buckets (default is 10, if omitted) and a parameter
``max`` to indicate the maximal possible key (should be guessed by the
client of the sorting). When allocating elements to the corresponding
buckets, it divides the entire space of keys (up to the maximal one)
into ``bnum`` portions, and puts the corresponding element into the
appropriate bucket. Since elements with different keys (from the same
segment) may end up in the same bucket, and additional sorting is
required. Let us test this implementation::

 # let e = generate_int_array 10000;;
 val e : int array = [|4505; 6905; 5076; 9250; 5101; 2539; 1721; ... |]

 # bucket_sort 10000 e;;
 - : int array = [|0; 1; 3; 3; 5; 5; 5; 6; 6; 9; 10; ... |]


Stability of sorting
--------------------

An important property of a sorting algorithm is **stability**. A sorting
algorithms is *stable* if it preserves the ordering between the elements
with equal keys in the initial array. 

An example of a stable sorting algorithm is ``kv_bucket_sort`` shown
below, which sorts an array of key-value pairs based on the keys::

 let kv_bucket_sort bnum arr = 
   let buckets = Array.make bnum [] in
   let len = Array.length arr in 
   for i = 0 to len - 1 do
     let key = fst arr.(i) in
     let bindex = key mod bnum in
     let b = buckets.(bindex) in
     buckets.(bindex) <- arr.(i) :: b
   done;
   let res = ref [] in
   for i = bnum - 1 downto 0 do
     res := List.rev_append buckets.(i) !res
   done;
   list_to_array !res


As an example, consider its following execution::
  
 # let f = [|(3, "zqped"); (8, "esmup"); (7, "tvqej"); (8, "xhlzj"); (4, "blann");
             (9, "ouors"); (0, "iocvx"); (3, "dacht"); (7, "rncpn");
             (7, "khott")|];;

 # kv_bucket_sort 10 f;;
 - : (int * string) array =
 [|(0, "iocvx"); (3, "zqped"); (3, "dacht"); (4, "blann"); (7, "tvqej");
   (7, "rncpn"); (7, "khott"); (8, "esmup"); (8, "xhlzj"); (9, "ouors")|]

The initial array has elements ``(7, "rncpn")`` and ``(7, "khott")``
in this very order. In the same order, the appear in the resulting
array. Other stable sorting algorithm is insertion sort. Not all
sorting algorithms are stable though. Try to answer, whether merge
sort is stable? What about Quicksort?

.. _sec-radix-sort:

Radix Sort
----------

The stability comes into play, when one sorting algorithm uses another
one as a black-box, relying on the fact that original order of
elements in partially-sorted arrays with "almost-same" keys will be
preserved.

As an example, radix sort is a linear-time sorting, building on the
idea of bucket-sort, but making it scale logarithmically, which is
necessary if the space of possible keys is too large (e.g., comparable
with the length of an array, in which case bucket sort's complexity
becomes quadratic). It makes use of bucket sort as its component,
applying it iteratively and sorting a list of integer-keyed elements
*per key digit*, startgin from the smallest register::

 let radix_sort arr = 
   let len = Array.length arr in
   let max_key = 
     let res = ref 0 in
     for i = 0 to len - 1 do
       if arr.(i) > !res 
       then res := arr.(i)
     done; !res
   in
   if len = 0 then arr
   else
     let radix = ref max_key in
     let ls = array_to_list arr in
     let combined = list_to_array (list_zip ls ls) in
     let res = ref combined in
     while !radix > 0 do
       res := kv_bucket_sort 10 !res;
       for i = 0 to len - 1 do
         let (k, v) = !res.(i) in
         !res.(i) <- (k / 10, v)
       done;
       radix := !radix / 10
     done;
     let result_list = array_to_list !res in
     list_to_array result_list |> Array.map snd

It starts by determining the largest key ``max_key`` in the initial
array. Next, it creates an array ``combined``, which pairs all
elements in the original array with their keys. In the ``while`` loop,
it sorts elements, using ``kv_bucket_sort``, based on their digit. It
starts from the lowest register, and then keeps dividing the key
component of each element, "attached" for the sorting purposes, by 10,
repeating the bucket sort, until it runs out of registers.

How many iterations the ``while``-loop will make? Notice that each
time it divides the key space by 10, so it will only run for
:math:`\log_{10}( \mathtt{max\_key})` iterations. This determines the
complexity of the radix sort, which is, therefore :math:`O(n
\log(\mathtt{max\_key}))`, i.e., it is linear if ``max_key`` is
considered as a constant.

One can test the implementation of radix sort as follows::

 let%test "radix-sort" = 
   let a = generate_int_array 1000 in 
   let b = radix_sort a in
   array_sorted b && 
   same_elems (array_to_list a) (array_to_list b)
