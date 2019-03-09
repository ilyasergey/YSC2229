.. -*- mode: rst -*-

Knuth–Morris–Pratt Algorithm
============================

This is the first algorithm for string matching in :math:`O(n)`, where :math:`n` is the size of the text where the search takes place). It has been independently invented by Donald Knuth and Vaughan Pratt, and James H. Morris, who published it together in a joint paper. 

It is known as one of the most non-trivial basic algorithms, and is commonly just presented as-is, with explanations of its pragmatics and the complexity. In this chapter, we will take a look at a systematic derivation of the algorithm from a naive string search, eventually touching upon a very interesting (although somewhat non-obvious) idea --- *failed partial matches can be used to optimise the search in the rest of the text by "fast-forwarding" through several positions*, without re-matching completely starting from the next character.

The material of this chapter is based on `this blog article <http://gallium.inria.fr/blog/kmp/>`_, which, in its turn is based on `this research paper <https://www.brics.dk/RS/02/32/BRICS-RS-02-32.pdf>`_ by `Prof. Olivier Danvy <https://www.yale-nus.edu.sg/about/faculty/olivier-danvy/>`_ and his co-authors.




Comparing performance, again
----------------------------

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_09_Comparison.ml

Let us compare the three algorithms on regular and repetitive strings::

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

