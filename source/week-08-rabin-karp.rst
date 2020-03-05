.. -*- mode: rst -*-

Rabin-Karp Search
=================

* File: ``RabinKarp.ml``

Th idea of hashing studied before for the implementations of hash-tables and bloom filters, is also very useful for improving the efficiency of detecting patterns in strings. 

The idea of Rabin-Karp algorithm is to speed up the ordinary search by means of computing the *rolling hash* of the sub-string currently being checked, and comparing it to the hash of the of the pattern.

First, define a special hash::

 let rk_hash text = 
   let h = ref 0 in
   for i = 0 to String.length text - 1 do
     h := !h + Char.code text.[i]
   done;
   !h

The search procedure now takes advantage of it::

 let rabin_karp_search text pattern = 
   let n = String.length text in
   let m = String.length pattern in
   if n < m then None
   else
     (* Compute as the sum of all characters in pattern *)
     let hpattern = rk_hash pattern in
     let rolling_hash = ref @@ rk_hash (String.sub text 0 m) in
     let i = ref 0 in
     let res = ref None in
     while !i <= n - m && !res = None do
       (if hpattern = !rolling_hash &&
           String.sub text !i m = pattern then
         res := Some !i);

       (* Update the hash *)
       (if !i <= n - m - 1
        then
          let c1 = Char.code text.[!i] in
          let c2 = Char.code text.[!i + m] in
          rolling_hash := !rolling_hash - c1 + c2);
       i := !i + 1
     done;
     !res

**Question:** what is the worst-case complexity of Rabin-Karp search?

**Question:** What do you think would be the strings on which Rabin-Karp search performs more efficiently than naive search?

.. Complexity: :math:`O(n)`

Testing Rabin-Karp search can be done easily with the help of the ``search_tested procedure``::

 let%test "Rabin-Karp Search Works" = 
   search_tester rabin_karp_search

 let%test _ = 
   search_tester rabin_karp_search_rec


Recursive version of Rabin-Karp search
--------------------------------------

One can implement the recursive search version as follows::

 let rabin_karp_search_rec text pattern = 
   let n = String.length text in
   let m = String.length pattern in
   if n < m then None
   else
     (* Compute as the sum of all characters in pattern *)
     let hpattern = rk_hash pattern in

     let rec walk i rolling_hash =
       if i > n - m then None
       else if hpattern = rolling_hash &&
               String.sub text i m = pattern 
       then Some i
       else if i <= n - m - 1
       then 
         let c1 = Char.code text.[i] in
         let c2 = Char.code text.[i + m] in
         let rolling_hash' = rolling_hash - c1 + c2 in
         walk (i + 1) rolling_hash'
       else None
     in 
     walk 0 (rk_hash (String.sub text 0 m))


Comparing performance of search procedures
----------------------------------------------

* File ``StringSearchComparison.ml``

Let us design the experiment to compare RK search and nive search::

 let evaluate_search search name s ps pn = 
   print_endline "";
   Printf.printf "[%s] Pattern in: " name;
   Week_03.time (List.iter (fun p -> test_pattern_in search s p)) ps;
   Printf.printf "[%s] Pattern not in: " name;
   Week_03.time (List.iter (fun p -> test_pattern_not_in search s p)) pn

First, let's compare on  random strings::

 let compare_string_search n m =
   let (s, ps, pn) = generate_string_and_patterns n m in
   evaluate_search naive_search "Naive" s ps pn;
   evaluate_search rabin_karp_search "Rabin-Karp" s ps pn

That does not show so much difference::

 utop # compare_string_search 20000 50;;

 [Naive] Pattern in: Execution elapsed time: 0.999535 sec
 [Naive] Pattern not in: Execution elapsed time: 1.951543 sec

 [Rabin-Karp] Pattern in: Execution elapsed time: 1.112753 sec
 [Rabin-Karp] Pattern not in: Execution elapsed time: 2.155506 sec

In fact, Rabin-Karp is even a bit slower!

Now, let us show when it shines. For this, let us create very
repetitive strings::

 let repetitive_string n = 
   let ast = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa" in
   let pat1 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab" in
   let pat2 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaac" in
   let mk n = 
     let t = List.init n (fun x -> if x = n - 1 then pat1 else ast) in
     String.concat "" t 
   in
   (mk n, [pat1], [pat2])

Now, let us re-design the experiment using the following function::

 let compare_string_search_repetitive n =
   let (s, ps, pn) = repetitive_string n in
   evaluate_search naive_search  "Naive"  s ps pn;
   evaluate_search rabin_karp_search "Rabin-Karp"  s ps pn

Once we run it::

 utop # compare_string_search_repetitive 50000;;

 [Naive] Pattern in: Execution elapsed time: 1.298623 sec
 [Naive] Pattern not in: Execution elapsed time: 1.305244 sec

 [Rabin-Karp] Pattern in: Execution elapsed time: 0.058651 sec
 [Rabin-Karp] Pattern not in: Execution elapsed time: 0.058463 sec
 - : unit = ()

The superiority of Rabin-Karp algorithm becomes obvious.
