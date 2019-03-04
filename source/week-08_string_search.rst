.. -*- mode: rst -*-

Searching in Strings
====================

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_08_StringSearch.ml

Hashing is also very useful for detecting patterns in substrings. 

Imagine that you are searching for a word on a web page or a Word document. This problem is known and pattern search in a string, and in this lecture we will see several solutions for it. 

Testing that a search procedure
-------------------------------

The procedure ``search`` takes a string ``s`` and a patern ``p`` and returns a result of type ``int option``, where ``Some i`` denotes the first index in the string ``s``, such that ``p`` starts from it and is fully contained within ``s``. If no such index exist (i.e., ``p`` is not in ``s``), ``search`` returns ``None``.

Even before we implement the search procedure itself, we develop a test for it.  The first test function checkes if a pattern ``p`` is indeed in the string ``s``, as reported by the function ``search``::

 let test_pattern_in search s p =
   let index = Week_01.get_exn @@ search s p in
   let p' = String.sub s index (String.length p) in
   assert (p = p')

 let test_pattern_not_in search s p =
   assert (search s p = None)


A naive search
--------------

We can implement a naive search as follows::

 let naive_search s p = 
   let n = String.length s in
   let m = String.length p in
   if n < m then None
   else
     let i = ref 0 in
     let res = ref None in
     while !i <= n - m && !res = None do
       let j = ref 0 in
       while !j <= m - 1 && 
             String.get s (!i + !j) = String.get p (!j)
       do 
         j := !j + 1 
       done;
       (if !j = m
        then res := Some !i);
       i := !i + 1
     done;
     !res

It tries to identify the pattern starting from each position ``i``, checking the characters in the substring one by one. If it fails in the inner search, it simply tries the next position.

**Question:** what is the worst-case complexity of this search in terms of sizes ``n`` and ``m`` of ``s`` and ``p`` correspondingly?

.. TODO: Complexity: :math:`O(n \times m)`.

Generating strings for testing search function
----------------------------------------------

How do we generate random strings for testing search? 

This can be done using the function ``generate_words``, which we generated before. We simply  create a list of words and concatenate it to produce the string ``s``. We can also create the list of words that are (with a very hight probability) are not in the obtained string ``s``::

 let generate_string_and_patterns n m = 
   let ps_in = Week_03.generate_words n m in
   let ps_not_in = 
     List.filter (fun p -> not (List.mem p ps_in)) @@
     Week_03.generate_words n m in
   let s = String.concat "" (List.rev ps_in) in
   (s, ps_in, ps_not_in)


Testing naive search
--------------------

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_08_Tests.ml

Let us construct a number of tests, starting from a simple one::

 open Week_08_StringSearch

 let big = "abcdefghijklmnopeqrstuvabcsrtdsdqewgdcvaegbdweffwdajbjrag"

 let patterns = ["dsd"; "jrag"; "abc"]

 let%test "Naive Search Works" = 
   List.iter (fun p -> test_pattern_in naive_search big p) patterns;
   true

We can also check, on a random string, that our search returns no false positives and no false negatives::

 let%test "Naive Search True Positives" = 
   let (s, ps, _) = generate_string_and_patterns 500 5 in
   List.iter (fun p -> test_pattern_in naive_search s p) ps;
   true

 let%test "Naive Search True Negatives" = 
   let (s, _, pn) = generate_string_and_patterns 500 5 in
   List.iter (fun p -> test_pattern_not_in naive_search s p) pn;
   true


Rabin-Karp search
-----------------

The idea of Rabin-Karp algorithm is to speed up the ordinary search by means of computing the *rolling hash* of the sub-string currently being checked, and comparing it to the hash of the of the pattern.

First, define a special hash::

 let rk_hash s = 
   let h = ref 0 in
   for i = 0 to String.length s - 1 do
     h := !h + Char.code (String.get s i)
   done;
   !h

The search procedure now takes advantage of it::

 let rabin_karp_search s p = 
   let n = String.length s in
   let m = String.length p in
   if n < m then None
   else
     (* Compute as the sum of all characters in p *)
     let hpattern = rk_hash p in
     let rolling_hash = ref @@ rk_hash (String.sub s 0 m) in
     let i = ref 0 in
     let res = ref None in
     while !i <= n - m && !res = None do
       (if hpattern = !rolling_hash &&
           String.sub s !i m = p then
         res := Some !i);

       (* Update the hash *)
       (if !i <= n - m - 1
        then
          let c1 = Char.code (String.get s (!i)) in
          let c2 = Char.code (String.get s (!i + m)) in
          rolling_hash := !rolling_hash - c1 + c2);
       i := !i + 1
     done;
     !res

**Question:** what is the complexity of Rabin-Karp search?

.. Complexity: :math:`O(n)`

Testing Rabin-Karp search::

 let%test "Rabin-Karp Search Works" = 
   List.iter (fun p -> test_pattern_in rabin_karp_search big p) patterns;
   true

 let%test "Rabin-Karp Search True Positives" = 
   let (s, ps, _) = generate_string_and_patterns 500 5 in
   List.iter (fun p -> test_pattern_in rabin_karp_search s p) ps;
   true

 let%test "Rabin-Karp Search True Negatives" = 
   let (s, _, pn) = generate_string_and_patterns 500 5 in
   List.iter (fun p -> test_pattern_not_in rabin_karp_search s p) pn;
   true

Comparing performance of two search procedures
----------------------------------------------

Desining the experiment::

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
