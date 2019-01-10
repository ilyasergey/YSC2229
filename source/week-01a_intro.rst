.. -*- mode: rst -*-

Introduction
============

A programming language is a notation to express computations. A program is something written according to this notation. It can be executed to perform a computation. A computation is some kind of processing operation over some data. Data are representations of information.

Here is an analogy. A natural language (Danish, for example) is a collection of words assembled into sentences. Words are composed of letters, and sentences are composed of words and punctuation marks. There is a common agreement about correct Danish words (spelling) and about correct Danish sentences (grammar). Spelling and grammar pertain to the syntax of Danish. Sentences are then communicated, either orally or in writing, from someone to someone else, to convey a meaning. Meaning pertains to the semantics of Danish. To stay within the analogy, let us only consider written communication in the rest of this paragraph. Improperly spelled words and improperly constructed sentences are misunderstood or not understood at all. Understandable sentences carry information.

T.T.T.
—Piet Hein

Here is a comparison. A cooking recipe is a notation that conveys how to cook something. It specifies data (the ingredients, e.g., eggs, butter, salt, pepper, thyme), resources and tools (e.g., a stove and a pan), and an algorithm (a method to operate on the data, e.g., to beat the eggs towards cooking an omelet). To make a dish, a cook can then operate over the ingredients according to the recipe.

About this course
-----------------

Intuitively, the unit-test function is simple to write -- for any given
binary tree, the candidate function should return the mirror image of
this tree::

  let test_mirror candidate_mirror =
   (* test_mirror : (binary_tree -> binary_tree) -> bool *)
       (candidate_mirror
          (Leaf 10)
        = (Leaf 10))
    && (candidate_mirror
          (Node (Leaf 10,
                 Leaf 20))
        = (Node (Leaf 20,
                 Leaf 10)))
    && (candidate_mirror
          (Node (Leaf 10,
                 Node (Leaf 20,
                       Leaf 30)))
        = (Node (Node (Leaf 30, 
                       Leaf 20),
                 Leaf 10)))
    && (candidate_mirror
          (Node (Node (Leaf 10,
                       Leaf 20),
                 Node (Leaf 30,
                       Leaf 40)))
        = (Node (Node (Leaf 40,
                       Leaf 30),
                 Node (Leaf 20,
                       Leaf 10))))
    (* etc.*);;


.. _exercise-more-clauses-for-test-mirror:

Exercise 1
----------

Add two conjunctive clauses in ``test_mirror``:

* one with a tree of depth 4 where all the left subtrees are leaves, and

* one with a tree of depth 4 where all the right subtrees are leaves.



* The abstract-syntax tree of the regular expression ``(seq (seq (atom 1)
  (atom 2)) (seq (atom 3) (atom 4)))`` reads as follows::
  
                        <regexp>
                           |
                           |
                           |
                        (seq <regexp> <regexp>)
                                /          \
                               /            \
                              /              \
       (seq <regexp> <regexp>)                (seq <regexp> <regexp>)
              /          \                           /          \
             /            \                         /            \
            /              \                       /              \
      (atom <atom>)   (atom <atom>)          (atom <atom>)    (atom <atom>)
              |               |                      |                |
              1               2                      3                4

  And indeed ``(seq (seq (atom 1) (atom 2)) (seq (atom 3) (atom 4)))``
  can be derived from left to right as follows::

    <regexp> ->
    (seq <regexp> <regexp>) ->
    (seq (seq <regexp> <regexp>) <regexp>) ->
    (seq (seq (atom <atom>) <regexp>) <regexp>) ->
    (seq (seq (atom 1) <regexp>) <regexp>) ->
    (seq (seq (atom 1) (atom <atom>)) <regexp>) ->
    (seq (seq (atom 1) (atom 2)) <regexp>) ->
    (seq (seq (atom 1) (atom 2)) (seq <regexp> <regexp>)) ->
    (seq (seq (atom 1) (atom 2)) (seq (atom <atom>) <regexp>)) ->
    (seq (seq (atom 1) (atom 2)) (seq (atom 3) <regexp>)) ->
    (seq (seq (atom 1) (atom 2)) (seq (atom 3) (atom <atom>))) ->
    (seq (seq (atom 1) (atom 2)) (seq (atom 3) (atom 4)))

  It can also be derived from right to left.



Recap: Information and Data
---------------------------



