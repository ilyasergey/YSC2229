.. -*- mode: rst -*-

Substring Search
================

* File: ``StringSearch.ml``

Imagine that you are searching for a word on a web page or a Word
document. 

This problem is known and pattern search in a string. Despite being seemlingly a simple challenge to solve, in order to do efficiently, it requires a lot of ingenuity.

In this lecture we will see several solutions for it, of the increased implementation complexity, while reduced time demand.

Testing a search procedure
--------------------------

The procedure ``search`` takes a string ``text`` and a patern ``pattern`` and returns a result of type ``int option``, where ``Some i`` denotes the first index in the string ``text``, such that ``pattern`` starts from it and is fully contained within ``text``. If no such index exist (i.e., ``pattern`` is not in ``text``), ``search`` returns ``None``.

Even before we implement the search procedure itself, we develop a test for it.  The first test function checkes if a pattern ``pattern`` is indeed in the string ``text``, as reported by the function ``search``::

 let test_pattern_in search text pattern =
   let index = get_exn @@ search text pattern in
   let p' = String.sub text index (String.length pattern) in
   assert (pattern = p')

 let test_pattern_not_in search text pattern =
   assert (search text pattern = None)

A naive search
--------------

We can implement a naive search as follows. Notice that OCaml syntax ``s.[i]`` allows one to refer to a character of a string ``s`` at a position ``i``::

 let naive_search text pattern = 
   let n = String.length text in
   let m = String.length pattern in
   if n < m then None
   else
     let k = ref 0 in
     let res = ref None in
     let stop = ref false in
     while !k <= n - m && not !stop do
       let j = ref 0 in
       while !j <= m - 1 && 
             text.[!k + !j] = pattern.[!j]
       do  j := !j + 1  done;
       if !j = m
       then (
         res := Some !k; 
         stop := true)
       else
         k := !k + 1
     done;
     !res

It tries to identify the pattern starting from each position ``i``, checking the characters in the substring one by one. If it fails in the inner search, it simply tries the next position by incrementing ``i``.

**Question:** what is the worst-case complexity of this search in terms of sizes ``n`` and ``m`` of ``text`` and ``pattern`` correspondingly?

.. TODO: Complexity: :math:`O(n \times m)`.

A recursive version of the naive search
---------------------------------------

The same implementation can be, obviously rewritten so it would be tail-recursive::

 let naive_search_rec text pattern = 
   let n = String.length text in
   let m = String.length pattern in
   if n < m then None
   else
     let rec walk k =
       if k > n - m then None
       else (
       let j = ref 0 in
       while !j <= m - 1 && 
             text.[k + !j] = pattern.[!j]
       do  j := !j + 1  done;

       if !j = m
       then Some k
       else walk @@ k + 1)

     in walk 0


Generating strings for testing search function
----------------------------------------------

How do we generate random strings for testing search? 

This can be done using the function ``generate_words``, which we generated before. We simply  create a list of words and concatenate it to produce the string ``text``. We can also create the list of words that are (with a very hight probability) are not in the obtained string ``text``::

 let generate_string_and_patterns n m = 
   let ps_in = generate_words n m in
   let ps_not_in = 
     List.filter (fun p -> not (List.mem p ps_in)) @@
     generate_words n m in
   let s = String.concat "" (List.rev ps_in) in
   (s, ps_in, ps_not_in)

We can provide a higher-order testing procedure for strings, so it would test on a specific string, and on randomly-generated strings (for true positives and negatives), as follows::

 let search_tester search = 
   let (s, ps, pn) = generate_string_and_patterns 500 5 in
   List.iter (fun p -> test_pattern_in search big p) patterns;
   List.iter (fun p -> test_pattern_in search s p) ps;
   List.iter (fun p -> test_pattern_not_in search s p) pn;
   true

Testing naive search
--------------------

Let us construct a number of tests, starting from a simple one::

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


