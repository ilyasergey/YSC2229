.. -*- mode: rst -*-

Sorting in Linear Time
======================

As we have just determined, one cannot do comparison-based sorting
better than in :math:`O(n \log n)` in the worst case. However, we can
improve this complexity if we base the complexity *not* just on
comparisons, but will also exploit the intrinsic properties of the
data used as keys for elements to be sorted (e.g., integers). To see
how it's done, let us re-introduce the following auxiliary functions
for generating an printing simple arrays of pairs::

 let generate_array_small_keys len = 
   let kvs = list_zip (generate_keys 10 len) (generate_words 5 len) in
   let almost_array = list_zip (iota (len - 1)) kvs in
   let arr = Array.make len (0, "") in
   List.iter (fun (i, kv) -> arr.(i) <- kv) almost_array;
   arr

 let list_to_array ls = match ls with
   | [] -> [||]
   | h :: t ->
     let len = List.length ls in
     let arr = Array.make len h in
     let almost_array = list_zip (iota (len - 1)) ls in
     List.iter (fun (i, e) -> arr.(i) <- e) almost_array;
     arr


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

Therefore, the first ``for``-loop has a complexity :math:`\Theta(n)`,
where :math:`n` is the size of ``arr``. The second loop walks through
the array of buckets all the buckets (making ``bnum`` iterations) and
concatenates all the lists, returning the result as the array. It is
straightforward to show that the resulting complexity of the algorithm
is in :math:`O(\mathtt{bnum} \cdot n)`, i.e., it is linear in ``n``.

We can see ``simple_bucket_sort`` in action::

 # let c = generate_key_value_array 10;;
 val c : (int * string) array =
   [|(4, "xkjgv"); (0, "zjjvz"); (4, "tijke"); (2, "mgvxx"); (9, "rafyc");
     (8, "cmklf"); (6, "rvlup"); (9, "agxjw"); (1, "jdxvc"); (8, "pxuqc")|]
 # simple_bucket_sort 10 c;;
 - : (int * string) array =
 [|(0, "zjjvz"); (1, "jdxvc"); (2, "mgvxx"); (4, "xkjgv"); (4, "tijke");
   (6, "rvlup"); (8, "cmklf"); (8, "pxuqc"); (9, "rafyc"); (9, "agxjw")|]


.. _sec-bucket-sort:

Enhanced Bucket Sort
--------------------

If the size of the space of keys exceeds the number of the buckets,
one can still use the same idea, while also sorting each bucket
individually with a suitable sorting, such as insertion sort
(implemented for lists), as it will be operating on small and almost
sorted sub-arrays::

 (* An auxiliary insertion sort on lists *)
 let kv_insert_sort ls = 
   let rec walk xs acc =
     match xs with
     | [] -> acc
     | h :: t -> 
       let rec insert elem remaining = 
         match remaining with
         | [] -> [elem]
         | h :: t as l ->
           if fst h < fst elem 
           then h :: (insert elem t) else (elem :: l)
       in
       let acc' = insert h acc in
       walk t acc'
   in 
   walk ls []

 let bucket_sort max ?(bnum = 10) arr = 
   let buckets = Array.make bnum [] in
   let len = Array.length arr in 
   for i = 0 to len - 1 do
     let key = fst arr.(i) in
     let bind = key * bnum / max in
     let b = buckets.(bind) in
     buckets.(bind) <- arr.(i) :: b
   done;
   let res = ref [] in
   for i = bnum - 1 downto 0 do
     let bucket_contents = List.rev (buckets.(i)) in 
     let sorted_bucket = kv_insert_sort bucket_contents in
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
required. This is what is done in the second ``for``-loop by means of
``kv_insert_sort``. Let us test this implementation::

 # let e = generate_key_value_array 10000;;
 val e : (int * string) array =
   [|(484, "xrhbk"); (559, "pvutw"); (874, "wgdxj"); (979, "ouofg");
     (361, "xnxlo"); (224, "vhxve"); (601, "xpfyi"); (488, "ntsnf");
     (72, "ysvjh"); (422, "lczdj"); (720, "vilpf"); (68, "ianve");
     (781, "ztrvz"); (574, "ubkss");
     (790, "xz"... (* string length 5; truncated *)); (760, ...); ...|]
 # bucket_sort 10000 e;;
 - : (int * string) array =
 [|(1, "vcuch"); (2, "tldlv"); (3, "owbvp"); (4, "zejvp"); (5, "zaoyg");
   (8, "zgnsp"); (8, "geapp"); (9, "vkuvw"); (9, "givqp"); (10, "opcim");
   (12, "yrffh"); (13, "nbekg"); (15, "iaxua"); (16, "gxswv"); (16, "ahqri");
   (97, "qcemp"); (99, "xitxo"); (99, "wtqmh");
   (99, "hd"... (* string length 5; truncated *)); (100, ...); ...|]

Stability of sorting
--------------------

An important property of a sorting algorithm is **stability**. A sorting
algorithms is *stable* if it preserves the ordering between the elements
with equali keys. 

An example of a stable sorting algorithm is ``simple_bucket_sort``. As
an example, consider its outcome above. The initial array has elements
``(8, "cmklf")`` and ``(8, "pxuqc")`` in this very order. In the same
order, the appear in the resulting array. Other stable sorting
algorithm is insertion sort. Not all sorting algorithms are stable
though. Try to answer, whether merge sort is stable? What about
Quicksort?

.. _sec-radix-sort:

Radix Sort
----------

The stability comes into play, when one sorting algorithm uses another one as a black-box, relying on the fact that original order of elements partially-sorted arrays with "almost-same" keys will be preserved.

As an example, radix sort is a linear-time sorting, building on the idea of bucket-sort, but making it scale logarithmically, which is necessary if the space of possible keys is too large (e.g., comparable with the length of an array, in which case bucket sort's complexity becomes quadratic). It makes use of bucket sort as its component, applying it iteratively and sorting a list of integer-keyed elements *per key digit*, startgin from the smallest register::

 let radix_sort arr = 
   let len = Array.length arr in
   let max_key = 
     let res = ref 0 in
     for i = 0 to len - 1 do
       if fst arr.(i) > !res 
       then res := fst arr.(i)
     done; !res
   in
   if len = 0 then arr
   else
     let radix = ref max_key in
     let ls = array_to_list 0 len arr in
     let keys = List.map fst ls in
     let combined = list_to_array (list_zip keys ls) in
     let res = ref combined in
     while !radix > 0 do
       res := simple_bucket_sort 10 !res;
       for i = 0 to len - 1 do
         let (k, v) = !res.(i) in
         !res.(i) <- (k / 10, v)
       done;
       radix := !radix / 10
     done;
     let result_list = array_to_list 0 len !res in
     list_to_array @@ List.map snd result_list

It starts by determining the largest key ``max_key`` in the initial array. Next, it creates an array ``combined``, which pairs all elements in the original array with their keys. In the ``while`` loop, it sorts elements, using ``simple_bucket_sort``, based on their digit.  It starts from the lowest register, and then keeps dividing the key component of each element, "attached" for the sorting purposes, by 10, repeating the bucket sort, until it runs out of registers.

How many iterations the ``while``-loop will make? Notice that each time it divides the key space by 10, so it will only run for :math:`\log_{10}( \mathtt{max\_key})` iterations. This determines the complexity of the radix sort, which is, therefore :math:`O(n \log(\mathtt{max\_key}))`, i.e., it is linear if ``max\_key`` is considered as a constant.

One can test the implementation of radix sort using the following function::

 let test_radix_sort arr = 
   let len = (Array.length arr) in
   same_elems (array_to_list 0 len arr) 
     (array_to_list 0 len (radix_sort arr))
