.. -*- mode: rst -*-

Quicksort and its Variations
============================

* File: ``QuickSort.ml``

One of the fastest algorithms for comparison-based sorting (i.e.,
sorting that only relies on the fact that two key in an arrays can be
compared with each other) to date is **Quicksort**. Invented in 1959
by `Sir Tony Hoare <https://en.wikipedia.org/wiki/Tony_Hoare>`_, this
algorithm now is a part of the standard Unix library (known as
``qsort``) and Java Developer Kit (JDK).

.. _sec-partition: 

Partitioning an array
---------------------

Similarly to Merge sort, Quicksort belongs to the family of
divide-and-conquer algorithms: it splits the problem into multiple
"simpler" sub-tasks, which are solved recursively, with a base case
(array of length 0 or 1) being trivial to sort. Unlike Merge sort, the
main work happens on the "divide" step, i.e., before the problem is
partitioned. As Merge sort's key ingredient is the procedure ``merge``
that creates a sorted array our of two sorted arrays of a smaller
size, at the heart of Quicksort is the procedure ``partition``, whose
implementation in OCaml is shown below::

 let partition arr lo hi = 
   if hi <= lo then lo
   else
     let pivot = arr.(hi - 1) in
     let i = ref lo in 
     for j = lo to hi - 2 do
       if arr.(j) <= pivot 
       then begin
         swap arr !i j;
         i := !i + 1
       end
     done;
     swap arr !i (hi - 1);
     !i

The procedure ``partition`` takes, as arguments, and array ``arr`` and two boundaries to do the partitioning, ``lo`` and ``hi`` correspondingly. Its goal is to reposition elements in an array with respect to some "pivot" element (typically chosen randomly) and return its position ``i`` in the resulting array. All elements with positions ``k`` such that ``lo <= k < i`` will have keys that are less or equal than the one of ``pivot``, while al elements with indices ``k`` from the range that ``i <= k < hi`` will have the keys larger than the one of ``pivot``.

There are multiple ways to choose the ``pivot``, typically tailored to optimise for randomness. A better choice of a pivot, which should hit closer to the "median" of the keys in the range, guarantees a better performance of the algorithm. For simplicity, we will assume the uniform distribution of keys (i.e., the probability of getting a particular key from an array at a certain position is the same), and will be always choosing as pivot the *last* element of the array (it could be also the first, but the algorithm would be slightly different).

The ``partition``-ing, thus, works as follows. If the subarray is empty, it just returns its lower end. Otherwise, it picks the ``pivot`` to be its last element (``arr.(hi - 1)``). It then allocates two counters ``i`` and ``j``, with ``j`` starting to iterate through the range ``lo ... hi``. Any element with a key smaller or equal than the one ``pivot``, gets swapped to the "beginning", i.e., in the range ``lo ... i``, and then ``i`` is advanced. Any element with a key larger than the one of ``pivot`` remains where it is. Therefore, at any moment all keys that are less ot equal than pivot are in the range ``[lo ... i)`` and all keys that are larger than ``pivot`` are in the range ``[i ... j]``. Therefore, once ``j`` reaches the end (``hi - 2)``, the only unprocessed element is ``pivot`` itself, which can be thus swapped with the element at the position ``i`` (Why is it correct? Convince yourself). The procedure returns the position of ``i`` as the position of ``pivot``. At that moment all elements with smaller or equal keys are left of ``i``, and all elements with larger keys are on the right of ``i``. 

Partitioning in action
----------------------

Let us trace the execution of the ``partition`` on a small array::

 # let a = [|4; 5; 1; 2; 3|];;

Now let's instrument ``partition`` with tracing as follows::

 let partition_print arr lo hi = 
   let open Printf in
   if hi <= lo then lo
   else
     let pivot = arr.(hi - 1) in
     printf "pivot = %d\n" pivot;
     let i = ref lo in 
     for j = lo to hi - 2 do

       printf "lo = %d to  i = %d: " lo !i;
       print_int_sub_array lo !i arr; print_newline ();
       printf "i = %d  to j = %d: " !i j;
       print_int_sub_array !i j arr; print_newline ();
       printf "j = %d  to hi = %d: " j hi;
       print_int_sub_array j (hi - 1) arr; print_newline ();
       print_newline ();

       if arr.(j) <= pivot 
       then begin
         swap arr !i j;
         i := !i + 1
       end
     done;
     swap arr !i (hi - 1);
     print_int_sub_array lo hi arr; print_newline ();
     !i

Running it with ``a`` will produce the following output::

 # partition_print a 0 5;;

  pivot = 3
  lo = 0 to  i = 0: [|  |] 
  i = 0  to j = 0: [|  |] 
  j = 0  to hi = 5: [| 4; 5; 1; 2 |] 

  lo = 0 to  i = 0: [|  |] 
  i = 0  to j = 1: [| 4 |] 
  j = 1  to hi = 5: [| 5; 1; 2 |] 

  lo = 0 to  i = 0: [|  |] 
  i = 0  to j = 2: [| 4; 5 |] 
  j = 2  to hi = 5: [| 1; 2 |] 

  lo = 0 to  i = 1: [| 1 |] 
  i = 1  to j = 3: [| 5; 4 |] 
  j = 3  to hi = 5: [| 2 |] 

  [| 1; 2; 3; 5; 4 |] 
  - : int = 2

That is, at each loop iteration for ``j = 0 .. 4`` (since the length
is ``5``), we can see the three segments of the partitioned array
(less-or-equal than pivot, greater than pivot and unprocessed), withe
the final array being as follows with the pivot element ``3`` standing
at the position ``i = 2``::

 # a;;
 - : int array = [|1; 2; 3; 5; 4|]

.. _sec-qsort: 


Sorting via partitioning
------------------------

Having seen the main working horse of Quicksort, namely ``partition``,
the main procedure is surprisingly simple::

 let quick_sort arr = 
   let rec sort arr lo hi = 
     if hi - lo <= 1 then ()
     else 
       let mid = partition arr lo hi in
       sort arr lo mid;
       sort arr mid hi
   in
   sort arr 0 (Array.length arr)

As a classical divide-and-conquer sorting algorithm, it does nothing
for the sub-arrays of size 0 an 1. For arrays of a larger size, it
performs the partitioning, obtaining the index ``mid`` of the newly
acquired position of the pivot, and runs itself recursively. One might
wonder: why does this work at all? The answer to that is not
difficult, and follows directly from the postcondition of
``partition``, which does all the heavy lifting. It is suggested that
you answer this question by means of providing an invariant (see
:ref:`exercise-qsort-invariant`).

By the way, what do you think, why do we exclude the pivot with index
``mid`` when running ``sort`` recursively, so it is not a part of
either of sub-arrays to be sorted?
