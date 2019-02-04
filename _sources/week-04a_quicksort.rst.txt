.. -*- mode: rst -*-

Quicksort and Its Variations
============================



One of the fastest algorithms for comparison-based sorting (i.e., sorting that only relies on the fact that two key in an arrays can be compared with each other) to date is **Quicksort**. Invented in 1959 by `Sir Tony Hoare <https://en.wikipedia.org/wiki/Tony_Hoare>`_, this algorithm now is a part of the standard Unix library (known as ``qsort``) and Java Developer Kit (JDK).

.. _sec-partition: 

Partitioning an array
---------------------

Similarly to Merge sort, Quicksort belongs to the family of divide-and-conquer algorithms: it splits the problem into multiple "simpler" sub-tasks, which are solved recursively, with a base case (array of length 0 or 1) being trivial to sort. Unlike Merge sort, the main work happens on the "divide" step, i.e., before the problem is partitioned. As Merge sort's key ingredient is the procedure ``merge`` that creates a sorted array our of two sorted arrays of a smaller size, at the heart of Quicksort is the procedure ``partition``, whose implementation in OCaml is shown below::

 open Week_02
 open Week_03

 let partition arr lo hi = 
   if hi <= lo then lo
   else
     let pivot = arr.(hi - 1) in
     let i = ref lo in 
     for j = lo to hi - 2 do
       if fst arr.(j) <= fst pivot 
       then
         (swap arr !i j;
          i := !i + 1)
     done;
     swap arr !i (hi - 1);
     !i

``partition`` takes, as arguments, and array ``arr`` and two boundaries to do the partitioning, ``lo`` and ``hi`` correspondingly. Its goal is to reposition elements in an array with respect to some "pivot" element (typically chosen randomly) and return its position ``i`` in the resulting array. All elements with positions ``k`` such that ``lo <= k < i`` will have keys that are less or equal than the one of ``pivot``, while al elements with indices ``k`` from the range that ``i <= k < hi`` will have the keys larger than the one of ``pivot``.

There are multiple ways to choose the ``pivot``, typically tailored to optimise for randomness. A better choice of a pivot, which should hit closer to the "median" of the keys in the range, guarantees a better performance of the algorithm. For simplicity, we will assume the uniform distribution of keys (i.e., the probability of getting a particular key from an array at a certain position is the same), and will be always choosing as pivot the *last* element of the array (it could be also the first, but the algorithm would be slightly different).

The ``partition``-ing, thus, works as follows. If the subarray is empty, it just returns its lower end. Otherwise, it picks the ``pivot`` to be its last element (``arr.(hi - 1)``). It then allocates two counters ``i`` and ``j``, with ``j`` starting to iterate through the range ``lo ... hi``. Any element with a key smaller or equal than the one ``pivot``, gets swapped to the "beginning", i.e., in the range ``lo ... i``, and then ``i`` is advanced. Any element with a key larger than the one of ``pivot`` remanins where it is. Therefore, at any moment all keys that are less ot equal than pivot are in the range ``[lo ... i)`` and all keys that are larger than ``pivot`` are in the range ``[i ... j]``. Therefore, once ``j`` reaches the end (``hi - 2)``, the only unprocessed element is ``pivot`` itself, which can be thus swapped with the element at the position ``i`` (Why is it correct? Explain yourself). The procedure returns the position of ``i`` as the position of ``pivot``. At that moment all elements with smaller or equal keys are left of ``i``, and all elements with larger keys are on the right of ``i``. 

Partitioning in action
----------------------

Let us trace the execution of the ``partition`` on a small array::


 # let a = generate_key_value_array 10;;
 val a : (int * string) array =
   [|(4, "cwvyy"); (8, "rawbx"); (9, "trvdz"); (5, "tbqlr"); (9, "stmdj");
     (6, "uowou"); (1, "fioxt"); (9, "dxnzs"); (7, "bdhpb"); (7, "clqfy")|]

We do that by means of the following procedures::

 open Printf

 let print_kv_array arr lo hi = 
   printf "[|";
   for i = lo to hi - 1 do
     printf "(%d, %s)" (fst arr.(i)) (snd arr.(i));
     if i < hi - 1 then printf "; "
   done;
   printf "|]"

used to annotate the main procedure::

 let partition_print arr lo hi = 
   if hi <= lo then lo
   else
     let pivot = arr.(hi - 1) in
     let i = ref lo in 
     for j = lo to hi - 2 do

       printf "pivot = (%d, %s)\n" (fst pivot) (snd pivot);
       printf "lo = %d to  i = %d: " lo !i;
       print_kv_array arr lo !i; print_newline ();
       printf "i = %d  to j = %d: " !i j;
       print_kv_array arr !i j; print_newline ();
       printf "j = %d  to hi = %d: " j hi;
       print_kv_array arr j (hi -1); print_newline ();
       print_newline ();

       if fst arr.(j) <= fst pivot 
       then
         (swap arr !i j;
          i := !i + 1)
     done;
     swap arr !i (hi - 1);
     !i

producing the output::

 # partition_print a 0 10;;
 pivot = (7, clqfy)
 lo = 0 to  i = 0: [||]
 i = 0  to j = 0: [||]
 j = 0  to hi = 10: [|(4, cwvyy); (8, rawbx); (9, trvdz); (5, tbqlr); (9, stmdj); (6, uowou); (1, fioxt); (9, dxnzs); (7, bdhpb)|]

 pivot = (7, clqfy)
 lo = 0 to  i = 1: [|(4, cwvyy)|]
 i = 1  to j = 1: [||]
 j = 1  to hi = 10: [|(8, rawbx); (9, trvdz); (5, tbqlr); (9, stmdj); (6, uowou); (1, fioxt); (9, dxnzs); (7, bdhpb)|]

 pivot = (7, clqfy)
 lo = 0 to  i = 1: [|(4, cwvyy)|]
 i = 1  to j = 2: [|(8, rawbx)|]
 j = 2  to hi = 10: [|(9, trvdz); (5, tbqlr); (9, stmdj); (6, uowou); (1, fioxt); (9, dxnzs); (7, bdhpb)|]

 pivot = (7, clqfy)
 lo = 0 to  i = 1: [|(4, cwvyy)|]
 i = 1  to j = 3: [|(8, rawbx); (9, trvdz)|]
 j = 3  to hi = 10: [|(5, tbqlr); (9, stmdj); (6, uowou); (1, fioxt); (9, dxnzs); (7, bdhpb)|]

 pivot = (7, clqfy)
 lo = 0 to  i = 2: [|(4, cwvyy); (5, tbqlr)|]
 i = 2  to j = 4: [|(9, trvdz); (8, rawbx)|]
 j = 4  to hi = 10: [|(9, stmdj); (6, uowou); (1, fioxt); (9, dxnzs); (7, bdhpb)|]

 pivot = (7, clqfy)
 lo = 0 to  i = 2: [|(4, cwvyy); (5, tbqlr)|]
 i = 2  to j = 5: [|(9, trvdz); (8, rawbx); (9, stmdj)|]
 j = 5  to hi = 10: [|(6, uowou); (1, fioxt); (9, dxnzs); (7, bdhpb)|]

 pivot = (7, clqfy)
 lo = 0 to  i = 3: [|(4, cwvyy); (5, tbqlr); (6, uowou)|]
 i = 3  to j = 6: [|(8, rawbx); (9, stmdj); (9, trvdz)|]
 j = 6  to hi = 10: [|(1, fioxt); (9, dxnzs); (7, bdhpb)|]

 pivot = (7, clqfy)
 lo = 0 to  i = 4: [|(4, cwvyy); (5, tbqlr); (6, uowou); (1, fioxt)|]
 i = 4  to j = 7: [|(9, stmdj); (9, trvdz); (8, rawbx)|]
 j = 7  to hi = 10: [|(9, dxnzs); (7, bdhpb)|]

 pivot = (7, clqfy)
 lo = 0 to  i = 4: [|(4, cwvyy); (5, tbqlr); (6, uowou); (1, fioxt)|]
 i = 4  to j = 8: [|(9, stmdj); (9, trvdz); (8, rawbx); (9, dxnzs)|]
 j = 8  to hi = 10: [|(7, bdhpb)|]

 - : int = 5

That is, at each loop iteration for ``j = 0 .. 8`` (since the length is ``10``), we can see the three segments of the partitioned array (less-or-equal than pivot, greater than pivot and unprocessed), withe the final array being as follows with the pivot element ``(7, "clqfy")`` standing at the position ``i = 5``::

 # a;;
 - : (int * string) array =
 [|(4, "cwvyy"); (5, "tbqlr"); (6, "uowou"); (1, "fioxt"); (7, "bdhpb");
   (7, "clqfy"); (8, "rawbx"); (9, "dxnzs"); (9, "stmdj"); (9, "trvdz")|]


.. _sec-qsort: 


Sorting via partitioning
------------------------

Having seen the main working horse of Quicksort, namely ``partition``, the main procedure is surprisingly simple::

 let quick_sort arr = 
   let rec sort arr lo hi = 
     if hi - lo <= 1 then ()
     else 
       let mid = partition arr lo hi in
       sort arr lo mid;
       sort arr mid hi
   in
   sort arr 0 (Array.length arr)

As a classical divide-and-conquet sorting algorithm, it does nothing for the sub-arrays of size 0 an 1. For arrays of the larger size, it performs the partitioning, obtaning the index ``mid`` of the newly acquired position of the pivot, and runs itself recursively. Why does this work? The answer to that is not difficult, and follows directly from the postcondition of ``partition``, which does all the heavy lifting. It is suggested that you answer this question by means of providing an invariant (see :ref:`exercise-qsort-invariant`).

We can also trace the results of sub-calls to ``sort`` via the following annotations::

 let quick_sort_print arr = 
   let rec sort arr lo hi = 
     if hi - lo <= 1 then ()
     else 
       let mid = partition arr lo hi in
       printf "lo = %d, hi = %d\n" lo hi;
       print_kv_array arr lo hi; print_newline ();
       printf "mid = %d\n" mid; print_newline ();
       sort arr lo mid;
       sort arr (mid + 1) hi
   in
   sort arr 0 (Array.length arr)

and test it by running::

 # let a = generate_key_value_array 10;;
 val a : (int * string) array =
   [|(2, "pcpbj"); (1, "xvuho"); (5, "jlokm"); (0, "txuad"); (5, "dafhd");
     (0, "mmjsq"); (2, "qmmpd"); (6, "odtel"); (8, "lfpqy"); (4, "mjlco")|]
 # quick_sort_print a;;
 lo = 0, hi = 10
 [|(2, pcpbj); (1, xvuho); (0, txuad); (0, mmjsq); (2, qmmpd); (4, mjlco); (5, dafhd); (6, odtel); (8, lfpqy); (5, jlokm)|]
 mid = 5

 lo = 0, hi = 5
 [|(2, pcpbj); (1, xvuho); (0, txuad); (0, mmjsq); (2, qmmpd)|]
 mid = 4

 lo = 0, hi = 4
 [|(0, txuad); (0, mmjsq); (2, pcpbj); (1, xvuho)|]
 mid = 1

 lo = 2, hi = 4
 [|(1, xvuho); (2, pcpbj)|]
 mid = 2

 lo = 6, hi = 10
 [|(5, dafhd); (5, jlokm); (8, lfpqy); (6, odtel)|]
 mid = 7

 lo = 8, hi = 10
 [|(6, odtel); (8, lfpqy)|]
 mid = 8

 - : unit = ()
 # a;;
 - : (int * string) array =
 [|(0, "txuad"); (0, "mmjsq"); (1, "xvuho"); (2, "pcpbj"); (2, "qmmpd");
   (4, "mjlco"); (5, "dafhd"); (5, "jlokm"); (6, "odtel"); (8, "lfpqy")|]

By the way, what do you think, why do we exclude the pivot with index ``mid`` when running ``sort`` recursively on sub arrays, so it is not a part of either of sub-arrays to be sorted?
