.. -*- mode: rst -*-

Knuth–Morris–Pratt Algorithm
============================

This is the first algorithm for string matching in :math:`O(n)`, where :math:`n` is the size of the text where the search takes place). It has been independently invented by Donald Knuth and Vaughan Pratt, and James H. Morris, who published it together in a joint paper. 

It is known as one of the most non-trivial basic algorithms, and is commonly just presented as-is, with explanations of its pragmatics and the complexity. In this chapter, we will take a look at a systematic derivation of the algorithm from a naive string search, eventually touching upon a very interesting (although somewhat non-obvious) idea --- *interrupted partial matches can be used to optimise the search in the rest of the text by "fast-forwarding" through several positions*, without re-matching completely starting from the next character.

The material of this chapter is based on `this blog article <http://gallium.inria.fr/blog/kmp/>`_, which, in its turn is based on `this research paper <https://www.brics.dk/RS/02/32/BRICS-RS-02-32.pdf>`_ by `Prof. Olivier Danvy <https://www.yale-nus.edu.sg/about/faculty/olivier-danvy/>`_ and his co-authors.


Revisiting the naive algorithm
------------------------------

Let us start by re-implementing the naive research algorithm with a single loop that handles both indices ``k`` and ``j``, soe the former ranges over the text ,and the latter goes over the pattern::

 let naive_search_one_loop text pattern = 
   let n = length text in
   let m = length pattern in
   if n < m then None
   else
     let k = ref 0 in
     let j = ref 0 in
     let stop = ref false in
     let res = ref None in
     while !k <= n && not !stop do
       if !j = m
       then (
         res := Some (!k - !j);
         stop := true)
       else if !k = n then (stop := true)
       else if text.[!k] = pattern.[!j]
       then (
         k := !k + 1;
         j := !j + 1)
       else  (
         k := !k - !j + 1;
         j := 0)
     done;
     !res

If a mismatch occurs at a certain position of ``k`` and ``j`` (``text.[!k] = pattern.[!j]``), then ``k`` is set up for ``j`` positions back, plus one (to move forward), while ``j`` is restarted from 0. That is, the variant of the loop is still ``k``.

Returning the Interrupt Index
-----------------------------

Let us refactor the code of ``naive_search_one_loop`` into a recursive procedure ``search``. While doing so, we also make a dedicated data type `search_result` that either returns an index where the pattern begins (``Found i``) or a position ``j`` at a pattern, at which the text string has ended (``Interrupted j``):: 

 type search_result = 
   | Found of int
   | Interrupted of int

The result is than processed by a generic function ``global_search`` that converts it to a value of the option type::

 let global_search search text pattern = 
   let n = length text in
   let m = length pattern in
   let res = search pattern m text n 0 0 in
   match res with 
   | Found x -> Some x
   | _ -> None

 let search_rec = 
   let rec search pattern m text n j k =
     if j = m then
       Found (k - j)
     else if k = n then
       Interrupted j
     else if pattern.[j] = text.[k] then
       search pattern m text n (j + 1) (k + 1)
     else
       search pattern m text n 0 (k - j + 1)
   in
   global_search search

The signature of th inner ``search`` seems to verbose, but it is important for the derivation, which is coming: the first three parameters are the pattern, its size ``m`` and the text; ``n`` stands for the size of the text, but it also limits the search range on the right (and will be a subject to manipulation in the future). Finally, ``j`` and ``k`` are the current (and also initial for the first run) values of the running indices within ``pattern`` and ``text``, correspondingly.

So far, we don't make any interesting use of a interrupt index ``j`` in the case when the inner ``search`` returns ``Interrupted j``

Relating Matched Text and the pattern
-------------------------------------

Let us notice the first interesting detail: at any moment, the positions of ``j`` and ``k`` relate the **prefix** of the ``pattern`` and a substring of ``text`` that fully match. This can be reinforced by the following invariants, instrumenting the ``search`` body::

 let search_inv = 
   let rec search pattern m text n j k =
     assert (0 <= j && j <= m);
     assert (j <= k && k <= n);
     assert (sub pattern 0 j = sub text (k - j) j);

     if j = m then
       Found (k - j)
     else if k = n then
       Interrupted j
     else if pattern.[j] = text.[k] then
       search pattern m text n (j + 1) (k + 1)
     else
       search pattern m text n 0 (k - j + 1)
   in
   global_search search

Therefore, at the last call ``search pattern m text n 0 (k - j + 1)`` we might be dropping essential information -- the fact that the interval ``[k − j, k)`` of the text matches the interval ``[0, j)`` of the pattern.


Fast-Forwarding Search using Interrupt Index
--------------------------------------------

To exploit the information about already-matched prefix of the pattern, let us split the search, after the interruption, in the shifted range ``[k − j + 1, n)`` into the search in the intervals ``[k − j + 1, k)`` and ``[k, n)``. 

This is possible due to the following fact. For any ``l``, such that ``for k <= l <= n``, the call ``search pattern m text n j k`` is equivalent to::

 let result = search pattern m text l j k in
  match result with
  | Found _ ->
      result
  | Interrupted j' ->
      search pattern m text n j' l

That is, we can search up to ``l``, and, if interrupted, start from searching ``l`` from an fast-forwarded position ``j'``. That is due to the fact that we have managed to reach ``l`` and got ``Interrupted j'``, so there is no need to re-check the first ``j' - 1`` pattern characters as they match the suffix ``[k, l)`` of ``text``.

By using this observation, we can split the last call in the previous version of ``search`` into the case ``j = 0`` (which is simple to handle by just incrementing ``k``), and the case of ``j <> 0``, in which case we will calculate the interruption index for computing the search starting at ``k + 1 - j``::

 let search_with_shift = 
   let rec search pattern m text n j k =
   if j = m then
     Found (k - j)
   else if k = n then
     Interrupted j
   else if pattern.[j] = text.[k] then
     search pattern m text n (j + 1) (k + 1)
   else if j = 0 then
     search pattern m text n 0 (k + 1)
   else 
     let result = search pattern m text k 0 (k - j + 1) in
     match result with
     | Found _ ->
         result
     | Interrupted j' -> search pattern m text n j' k
   in
   global_search search

Let us notice that the search ``search pattern m text k 0 (k - j + 1)`` is deemed to fail, as it searches in the range ``k - (k - j + 1) = j - 1 < m``. However, when it fails, it will give us ``j'``, such that it can be used as an initial position in a pattern when starting at ``k``.

Notice that there is some nicely hidden dependency there: the call to ``search pattern m text k 0 (k - j + 1)`` might run multiple smaller searches recursively, eventually hitting the right end of the range (i.e., ``k``). As ``Interrupted j'`` is only returned when it happens, we can be sure that this is correct answer to the question "which position" should I start from processing the pattern, when I start processing the text from ``k``. It might very well be the case that ``j' = 0``.

Extracting the Interrupt Index
------------------------------

As the goal of calling ``search pattern m text k 0 (k - j + 1)`` in the code above is only to extract the fast-forwarding information, and it always fails, we can now make use of this information and eliminate some administrative "boilerplate" code::

 let assertInterrupted = function
   | Found _       -> assert false
   | Interrupted j -> j


 let search_assert = 
   let rec search pattern m text n j k =
   if j = m then
     Found (k - j)
   else if k = n then
     Interrupted j
   else if pattern.[j] = text.[k] then
     search pattern m text n (j + 1) (k + 1)
   else if j = 0 then
     search pattern m text n 0 (k + 1)
   else
     let j' = assertInterrupted @@ search pattern m text k 0 (k - j + 1) in
     search pattern m text n j' k
   in
   global_search search

Exploiting the Prefix Equality
------------------------------

From the explanations above, recall that the sub-strings ``sub pattern 0 j`` and ``sub text (k - j) j`` are equal. Therefore, the sub-call ``search pattern m text k 0 (k - j + 1)`` searches for the pattern (or, rather, the interrupt index) within (a prefix of a suffix of) the pattern itself. Therefore, we can remove ``text`` from there, thus making this call work exclusively on a pattern::

 let search_via_pattern =
   let rec search pattern m text n j k =
   if j = m then
     Found (k - j)
   else if k = n then
     Interrupted j
   else if pattern.[j] = text.[k] then
     search pattern m text n (j + 1) (k + 1)
   else if j = 0 then
     search pattern m text n 0 (k + 1)
   else
     (* So we're looking in our own prefix *)
     let j' = assertInterrupted @@ search pattern m pattern j 0 1 in
     assert (j' < j);
     search pattern m text n j' k

   in 
   global_search search

Tabulating the interrupt indices
--------------------------------

Since the information about interruptions and fast-forwarding can be calculating only using the ``pattern``, without ``text`` involved, we might want to pre-compiled it and tabulate before running the search, obtaining a ``table : int array`` with this inforations. In other words the value ``j' = table.(j)`` answers a question: how many positions ``j'`` of the pattern can I skip when starting to look in a text, that begins with my pattern's substring ``pattern[1 .. j]`` (i.e., precisely the value ``search pattern m pattern j 0 1``).

If we had a table like this, we could forumlate ``search`` as the following tail-recursive procedure::

 let rec loop table pattern m text n j k =
   if j = m then
     Found (k - j)
   else if k = n then
     Interrupted j
   else if pattern.[j] = text.[k] then
     loop table pattern m text n (j + 1) (k + 1)
   else if j = 0 then
     loop table pattern m text n 0 (k + 1)
   else
     loop table pattern m text n table.(j) k

To populate such a table, however, we will need the search procedure itself. However, the size of the pattern ``m`` is typically much smaller than the size of the text, so creating this table pays off. Int the following implementation the inner procedure ``loop_search`` defines the standard ``search`` (as before) and uses to populate the table, which is the used for the main matching procedure::

 let search_with_inefficient_init =

   let loop_search pattern _ text n j k = 
     let rec search pattern m text n j k =
       if j = m then
         Found (k - j)
       else if k = n then
         Interrupted j
       else if pattern.[j] = text.[k] then
         search pattern m text n (j + 1) (k + 1)
       else if j = 0 then
         search pattern m text n 0 (k + 1)
       else
         (* So we're looking in our own prefix *)
         let j' = assertInterrupted @@ search pattern m pattern j 0 1 in
         assert (j' < j);
         search pattern m text n j' k
     in

     let m = length pattern in
     let table = Array.make m 0 in
     for j = 1 to m - 1 do
       table.(j) <- assertInterrupted @@ search pattern m pattern j 0 1
     done;

     let rec loop table pattern m text n j k =
       if j = m then
         Found (k - j)
       else if k = n then
         Interrupted j
       else if pattern.[j] = text.[k] then
         loop table pattern m text n (j + 1) (k + 1)
       else if j = 0 then
         loop table pattern m text n 0 (k + 1)
       else
         loop table pattern m text n table.(j) k
     in

     loop table pattern m text n j k
   in

   global_search loop_search

Boot-strapping the table
------------------------

We can rewrite the code in a more efficient manner by using the same ``loop`` function to populate the table. To do so, let us notice the two following intricate observation.

The value ``table.(j)`` can be computed in terms of the tabulated values at ``j - 1`` and smaller. The base case is ``j = 1`` corresponds to an empty interval, so ``table.(j) = 0``, and we can start populating the table from ``j = 2``. With this in mind, we can rewrite the search as follows::

 let search_kmp =

   let loop_search pattern _ text n j k = 
     let rec loop table pattern m text n j k =
       if j = m then
         Found (k - j)
       else if k = n then
         Interrupted j
       else if pattern.[j] = text.[k] then
         loop table pattern m text n (j + 1) (k + 1)
       else if j = 0 then
         loop table pattern m text n 0 (k + 1)
       else
         loop table pattern m text n table.(j) k
     in
     let m = length pattern in
     let table = Array.make m 0 in

     (*  In the case of j = 1, j' is 0 *)
     for j = 2 to m - 1 do
       table.(j) <- assertInterrupted @@ 
         loop table pattern m pattern j table.(j - 1) (j - 1)
     done;
     loop table pattern m text n j k
   in

   global_search loop_search

Notice that the mutual dependency between ``loop`` and ``table`` is resolved, as ``table`` is mutable, hence it can be altered by ``loop`` a-posteriori (the trick known and Landin's knot -- A technique named after `Pater Landin <https://en.wikipedia.org/wiki/Peter_Landin>`_ for implementing recursive functions using mutable state).

This concludes our derivation of the Knuth-Morris-Pratt (KMP) algorithm, whose main idea is to *pre-compute* the table of fast-forwarding shifts for a given pattern, which is then used to avoid redundant work for re-matching already observed parts and the corresponding back-tracking.

The fact that the lookup in the table takes constant and the main iteration through ``text`` always progresses without backtracking, yields the linear complexity result :math:`O(n)` for the final algorithm.

Comparing performance, again
----------------------------

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_09_Comparison.ml

Let us compare the three studies string matching algorithms on regular and repetitive strings::

 let compare_string_search n m =
   let (s, ps, pn) = generate_string_and_patterns n m in
   evaluate_search naive_search "Naive" s ps pn;
   evaluate_search rabin_karp_search "Rabin-Karp" s ps pn;
   evaluate_search search_kmp "Knuth-Morris-Pratt"  s ps pn

 let compare_string_search_repetitive n =
   let (s, ps, pn) = repetitive_string n in
   evaluate_search naive_search  "Naive"  s ps pn;
   evaluate_search rabin_karp_search "Rabin-Karp"  s ps pn;
   evaluate_search search_kmp "Knuth-Morris-Pratt"  s ps pn

Here's the result for repetitive strings, showing that RK and KMP are very close::

 utop # compare_string_search_repetitive 50000;;

 [Naive] Pattern in: Execution elapsed time: 1.310680 sec
 [Naive] Pattern not in: Execution elapsed time: 1.312447 sec

 [Rabin-Karp] Pattern in: Execution elapsed time: 0.060640 sec
 [Rabin-Karp] Pattern not in: Execution elapsed time: 0.059571 sec

 [Knuth-Morris-Pratt] Pattern in: Execution elapsed time: 0.078809 sec
 [Knuth-Morris-Pratt] Pattern not in: Execution elapsed time: 0.077379 sec

And here's the result for arbitrary strings, showing the superiority of KMP on randomised inputs::

 utop #  compare_string_search 20000 50;;

 [Naive] Pattern in: Execution elapsed time: 1.027522 sec
 [Naive] Pattern not in: Execution elapsed time: 2.001959 sec

 [Rabin-Karp] Pattern in: Execution elapsed time: 1.106642 sec
 [Rabin-Karp] Pattern not in: Execution elapsed time: 2.166105 sec

 [Knuth-Morris-Pratt] Pattern in: Execution elapsed time: 0.762785 sec
 [Knuth-Morris-Pratt] Pattern not in: Execution elapsed time: 1.421093 sec

