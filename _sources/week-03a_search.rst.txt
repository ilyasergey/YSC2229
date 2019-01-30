.. -*- mode: rst -*-

Searching in Arrays
===================

Let us put key-value arrays to some good use.

Linear Search
-------------

One of the most common operations with key-value arrays is *searching* looking for the index of an element with some known key, or reporting that there is not such element. The simples implementation of searching walks through the entire array until the sought element is found, or the whole array is traversed::

 let linear_search arr k = 
   let len = Array.length arr in
   let res = ref None in
   let i = ref 0 in 
   while !i < len && !res = None do
     (if fst arr.(!i) = k 
     then res := Some ((!i, arr.(!i))));
     i := !i + 1
   done;
   !res

We can now test it on a random array::

 let a = [|(9, "lgora"); (0, "hvrxd"); (2, "zeuvd"); (2, "powdp"); (8, "sitgt");
         (4, "khfnv"); (2, "omjkn"); (0, "txwyw"); (0, "wqwpu"); (0, "hwhju")|];;

 # linear_search a 4;;
 - : (int * (int * string)) option = Some (5, (4, "khfnv"))
 # linear_search a 10;;
 - : (int * (int * string)) option = None

In the first case, ``linear_search`` has returned the index (``5``) of an element with the key 4, as well as the element itself. In the second case, it returns ``None``, as there is no key ``10`` in the array ``a``.

.. _exercise-find-range-unsorted:

Exercise 5
----------

Find a procedure that takes an unsorted array and a given range of keys (represented by a pair of numbers ``lo < hi``, right boundary not included), and returns the list of all elements in the array, whose keys are in that range. Estimate the complexity of this procedure.

Binary Search
-------------

Binary search is an efficient search procedure that works on a *sorted array* and looks for an element in it, repeatedly dividing its search-space by half::

 let rec binary_search arr k = 
   let rec rank lo hi = 
     if hi <= lo 
     then 
       (* Empty array *)
       None
     (* Converged on a single element *)
     else 
       let mid = lo + (hi - lo) / 2 in
       if fst arr.(mid) = k 
       then Some (arr.(mid))
       else if fst arr.(mid) < k
       then rank (mid + 1) hi 
       else rank lo mid  
   in
   rank 0 (Array.length arr)

The auxiliary procedure ``rank`` keeps changing the search boundary by recomputing the median of the search range and comparing the element in it. This way it makes sure that the element is already found, or the search space contains it iff and only iff the original array contains it. Let us trace the  binary search and figure out its invariant::

 let rec binary_search_print arr k = 
   let rec rank lo hi = 
     Printf.printf "Subarray: [";
     let ls = array_to_list lo hi arr in
     List.iter (fun (k, v) -> Printf.printf "(%d, %s); " k v) ls;
     Printf.printf "]\n\n";
     if hi <= lo 
     then 
       (* Empty array *)
       None
     (* Converged on a single element *)
     else 
       let mid = lo + (hi - lo) / 2 in
       if fst arr.(mid) = k 
       then Some (arr.(mid))
       else if fst arr.(mid) < k
       then rank (mid + 1) hi 
       else rank lo mid  
   in
   rank 0 (Array.length arr)

 let a1 = [|(0, "vzxtx"); (1, "hjqxi"); (3, "wzgsx"); (4, "hkuiu"); (4, "bvyjr");
   (5, "hdgrv"); (5, "sobff"); (5, "bpelh"); (5, "xonjr"); (6, "qjzui");
   (6, "syhze"); (8, "xyzxu"); (9, "gaixr"); (10, "obght"); (11, "wmiwb");
   (11, "dzvmf"); (12, "teaum"); (13, "gazaf"); (14, "svemi"); (15, "rxpus");
   (15, "agajq"); (21, "vztoj"); (21, "oszgf"); (21, "ylxiy"); (23, "itosu");
   (26, "nondm"); (27, "yazoj"); (28, "nqzcl"); (29, "lfevj"); (31, "hfcds");
   (31, "pgrym"); (32, "yghgg")|];;

 new_insert_sort a1;;

Now, as ``a1`` is sorted, we can run the binary search on it::

 # binary_search_print a1 32;;
 Subarray: [(0, vzxtx); (1, hjqxi); (3, wzgsx); (4, hkuiu); (4, bvyjr); (5, hdgrv); (5, sobff); (5, bpelh); (5, xonjr); (6, qjzui); (6, syhze); (8, xyzxu); (9, gaixr); (10, obght); (11, wmiwb); (11, dzvmf); (12, teaum); (13, gazaf); (14, svemi); (15, rxpus); (15, agajq); (21, vztoj); (21, oszgf); (21, ylxiy); (23, itosu); (26, nondm); (27, yazoj); (28, nqzcl); (29, lfevj); (31, hfcds); (31, pgrym); (32, yghgg); ]

 Subarray: [(13, gazaf); (14, svemi); (15, rxpus); (15, agajq); (21, vztoj); (21, oszgf); (21, ylxiy); (23, itosu); (26, nondm); (27, yazoj); (28, nqzcl); (29, lfevj); (31, hfcds); (31, pgrym); (32, yghgg); ]

 Subarray: [(26, nondm); (27, yazoj); (28, nqzcl); (29, lfevj); (31, hfcds); (31, pgrym); (32, yghgg); ]

 Subarray: [(31, hfcds); (31, pgrym); (32, yghgg); ]

 Subarray: [(32, yghgg); ]

 - : (int * string) option = Some (32, "yghgg")

Notice that at each iteration the sub-array halves, so ``binary_sort`` does not even have consider the entire array!

.. _exercise-binare-no-mid:

Exercise 6
----------

Modify ``binary_search`` in a way that it does not test the equality of ``fst arr.(mid) = k`` and does not exclude the middle element, but rather considers it as a part of one of the recursively processed array subparts.

Binary Search Invariant
-----------------------

Binary search crucially relies on the fact that the given array (and hence its contiguous sub-arrays) are sorted, so, upon comparing the key to the middle, it can safely ignore the half that is irrelevant for it. This can be captured by the following precondition we are going to give to ``rank``. It postulates that a sought element with a key ``k`` is in the whole arrays if and only if it is in the sub array, bound by ``lo .. hi`` that we are about to consider::

 let binary_search_rank_pre arr lo hi k = 
   let len = Array.length arr in 
   let ls = array_to_list 0 len arr in
   let ls' = array_to_list lo hi arr in
   if List.exists (fun e -> fst e = k) ls
   then List.exists (fun e -> fst e = k) ls'
   else not (List.exists (fun e -> fst e = k) ls')
 
We can also annotate our implementation with this invariant and test it::

 let binary_search_inv arr k = 
   let rec rank lo hi = 
     Printf.printf "lo = %d, hi = %d\n" lo hi;
     Printf.printf "Subarray: [";
     let ls = array_to_list lo hi arr in
     List.iter (fun (k, v) -> Printf.printf "(%d, %s); " k v) ls;
     Printf.printf "]\n";
     if hi <= lo 
     then 
       (* Empty array *)
       None
     (* Converged on a single element *)
     else 
       let mid = lo + (hi - lo) / 2 in
       Printf.printf "mid = %d\n" mid;
       if fst arr.(mid) = k 
       then Some (arr.(mid))
       else if fst arr.(mid) < k
       then
         (Printf.printf "THEN: lo = %d, hi = %d\n\n" (mid + 1) hi;
         assert (binary_search_rank_pre arr (mid + 1) hi k);
         rank (mid + 1) hi) 
       else 
         (Printf.printf "ELSE: lo = %d, hi = %d\n\n" lo mid;
         assert (binary_search_rank_pre arr lo mid k);
          rank lo mid)
   in
   let len = Array.length arr in 
   assert (binary_search_rank_pre arr 0 len k);
   rank 0 len

.. _exercise-exponential-search:

Exercise 7
----------

Exponential search is a more efficient version of binary-search, which can also work on infinite sorted arrays (e.g., never-ending streams of given key-value pairs). It starts by choosing the initial search range by making it to be an increasing power of two. Once a suitable range is determined, it works similarly to binary search on that range. Implement exponential search and formally explain its worst-case complexity.

The Main Idea of Divide-and-Conquer algorithms
----------------------------------------------

Both Binary and Exponential search algorithms are examples of the so-called *divide-and-conquer* approach. In this approach the processing of a data (a key-value array in our case) is based on multi-branched recursion. A divide-and-conquer algorithm works by recursively breaking down a problem into two or more sub-problems of the same or related type, until these become simple enough to be solved directly (such as reporting an element). The solutions to the sub-problems are then combined to give a solution to the original problem.

**Checkpoint question:** What is the "divide" and what is a "conquer" phase of the binary search?




