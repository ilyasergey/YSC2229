.. -*- mode: rst -*-

Searching in Strings
====================

TODO: Explain the problem

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_08_StringSearch.ml

Testing that a search procedure
-------------------------------

See the following::

 let test_pattern_in search s p =
   let index = Week_01.get_exn @@ search s p in
   let p' = String.sub s index (String.length p) in
   assert (p = p')

 let test_pattern_not_in search s p =
   assert (search s p = None)


A naive search
--------------

As follows::

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


TODO: Complexity: :math:`O(n \times m)`.

Testing naive search
--------------------

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_08_Tests.ml

See the following definitions::

 open Week_08_StringSearch

 let big = "abcdefghijklmnopeqrstuvabcsrtdsdqewgdcvaegbdweffwdajbjrag"

 let patterns = ["dsd"; "jrag"; "abc"]

 let%test "Naive Search Works" = 
   List.iter (fun p -> test_pattern_in naive_search big p) patterns;
   true

 let%test "Naive Search True Positives" = 
   let (s, ps, _) = generate_string_and_patterns 500 5 in
   List.iter (fun p -> test_pattern_in naive_search s p) ps;
   true

 let%test "Naive Search True Negatives" = 
   let (s, _, pn) = generate_string_and_patterns 500 5 in
   List.iter (fun p -> test_pattern_not_in naive_search s p) pn;
   true


Generating strings for testing search function
----------------------------------------------

TODO::

 let generate_string_and_patterns n m = 
   let ps_in = Week_03.generate_words n m in
   let ps_not_in = 
     List.filter (fun p -> not (List.mem p ps_in)) @@
     Week_03.generate_words n m in
   let s = String.concat "" (List.rev ps_in) in
   (s, ps_in, ps_not_in)

Rabin-Karp search
-----------------

First, define a special hash::

 let rk_hash s = 
   let h = ref 0 in
   for i = 0 to String.length s - 1 do
     h := !h + Char.code (String.get s i)
   done;
   !h

The search procedure::

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

Complexity: :math:`O(n)`

Testing Rabin-Karp search::

 let%test "Rabin-Kapr Search Works" = 
   List.iter (fun p -> test_pattern_in rabin_karp_search big p) patterns;
   true

 let%test "Rabin-Kapr Search True Positives" = 
   let (s, ps, _) = generate_string_and_patterns 500 5 in
   List.iter (fun p -> test_pattern_in rabin_karp_search s p) ps;
   true

 let%test "Rabin-Kapr Search True Negatives" = 
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

In fact, Rabin-Karp is even slower!

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
