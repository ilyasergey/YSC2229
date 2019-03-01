.. -*- mode: rst -*-

Managing and Testing OCaml Projects
===================================

As our developments keeps growing, we will naturally build on the data structures and will reuse the algorithms developed and studied in the previous parts of this course. To do so smoothly, you are encouraged to master the `git` version control systems, and host your project provided by the `GitHub <https://github.com/>`_ site. For instance, all the data structures for Weeks 1-6 of this course, as well as an example project making use of them, are now available on GitHub:

* Week 1-6 libraries: https://github.com/ilyasergey/ysc2229-part-one
* Example project: https://github.com/ilyasergey/ysc2229-examples

The following repository will be gradually filled with the developments from the upcoming lectures:

* Week 8-14 libraries: https://github.com/ilyasergey/ysc2229-part-two

All the repositories above come with the extensive documentation (by means of `README.md` files) on how to use the code hosted in them.

.. _sec-queue-test:

Testing OCaml Code
------------------

In the previous lectures we have learned that testing as an important part of the software development process, which becomes particularly critical when designing and implementing intricate data structures and algorithms. 

In order to write tests more efficiently in quickly growing OCaml projects, the `dune` build-system provides a convenient way to write *in-line automated* tests immediately in your files.

For instance, consider the following `configuration file <https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/dune>`_, which defines dependencies of for the libraries of the second part of this course. THe following lines::

  (inline_tests)                
  (preprocess (pps ppx_inline_test ppx_expect))

allow to write the tests immediately in your OCaml code (e.g., in a file ``fact.ml``), so they will be checked during the compilation of the project (you can do it via ``dune runtest`` or simply ``make``)::

 let rec fact n = if n = 1 then 1 else n * fact (n - 1)

 let%test _ = fact 5 = 120

 let%test "Failing test" = fact 5 = 121

The macro-construction ``let%test ...`` defines a test, which will be run during the build. Now executing `dune runtest` on this project, we will get::

 File "fact.ml", line 93, characters 1-39: Failing test is false.

That is, the first test (to which we gave no name via ``_``) has successfully passed, while the second one, called ``"Failing test"`` has failed.

One can also write tests that, instead of expecting a boolean value (like the two tests above), match an output produced by the function being tested, agains some expected string. For instance, the following test will fail, as those strings are different::

 let%expect_test "todo" =
   print_endline "Hello, world!";
   [%expect{|
     Hello, world?
   |}]

The result will be the following output, pointing out the discrepancy between the produced output and the expectations::

 --- file.ml	2019-03-01 20:29:39.000000000 +0800
 +++ file.ml.corrected	2019-03-01 20:29:39.000000000 +0800
 @@ -103,7 +103,7 @@
  let%expect_test "todo" =
    print_endline "Hello, world!";
    [%expect{|
 -    Hello, world?
 +    Hello, world!
    |}]

The following file contains more examples of tests for our project, discussed later in these notes:

* https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_08_Tests.ml

Finally, `this page <https://dune.readthedocs.io/en/latest/tests.html>`_ contains a detailed tutorial on writing automated tests for OCaml.

Testing an Abstract Data Type
-----------------------------

When possible, the lecture notes will now feature links to GitHub, with the implementations, denoted as follows:

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_08_ArrayQueue.ml

Recall how Section :ref:`sec_queues`, we have defined an abstract signature for the queues as follows::

 module type Queue = 
   sig
     type 'e t
     val mk_queue : int -> 'e t
     val is_empty : 'e t -> bool
     val is_full : 'e t -> bool
     val enqueue : 'e t -> 'e -> unit
     val dequeue : 'e t -> 'e option
     val queue_to_list : 'e t -> 'e list
   end

As a particular implementation of a queue, we have considered an array-based queue, implemented as shown below (we reuse the definitions from modules `Week_01` etc which are available through dependencies from the `Part One Libraries <https://github.com/ilyasergey/ysc2229-part-one>`_)::

 open Week_01
 open Week_03
 open Week_06

 module ArrayQueue : Queue = 
   struct
     type 'e t = {
       elems : 'e option array;
       head : int ref;
       tail : int ref;
       size : int    
     }
     let mk_queue sz = {
       elems = Array.make sz None;
       head = ref 0;
       tail = ref 0;
       size = sz
     }
     let is_empty q = 
       !(q.head) = !(q.tail) &&
       q.elems.(!(q.head)) = None

     let is_full q = 
       !(q.head) = !(q.tail) &&
       q.elems.(!(q.head)) <> None

     let enqueue q e = 
       if is_full q
       then raise (Failure "The queue is full!")
       else (
         let tl = !(q.tail) in
         q.elems.(tl) <- Some e;
         q.tail := 
           if tl = q.size - 1 
           then 0 
           else tl + 1)

     let dequeue q = 
       if is_empty q
       then None
       else (
         let hd = !(q.head) in
         let res = q.elems.(hd) in
         q.elems.(hd) <- None; 
         q.head := 
           (if hd = q.size - 1 
           then 0 
           else hd + 1);
         res)

     let queue_to_list q = 
       let hd = !(q.head) in
       let tl = !(q.tail) in
       if is_empty q then [] 
       else if hd < tl then
         List.map get_exn (array_to_list hd (tl + 1) q.elems)
       else 
         let l1 = array_to_list hd q.size q.elems in
         let l2 = array_to_list 0 tl q.elems in
         List.map get_exn (l1 @ l2)

 end

Let us implement some tests for this version of the queue. For instance, we can set-up a new queue by filling it from an array::

 open ArrayQueue

 (* Make a test_queue *)
 let mk_test_q n = 
   let q = mk_queue n in
   let a = generate_key_value_array n in
   for i = 0 to n - 1 do enqueue q a.(i) done;
   (q, a)

A natural thing to check then would be that the first element to be dequeued of such a queue is the same as the first element of the array::

 let%test "dequeue-first" =
   let (q, a) = mk_test_q 10 in
   let first = get_exn @@ dequeue q in
   first = a.(0)

The Section :ref:`exercises-8` suggests more tests that can be written in a similar vein for the previously studied data structures.
