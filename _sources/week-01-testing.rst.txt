.. -*- mode: rst -*-

Testing OCaml Code
==================

* File: ``Fact.ml``

In the introductory course on Computer Science, you have learned that testing is an important part of the software development process, which becomes particularly critical when designing and implementing intricate data structures and algorithms. 

In order to write tests more efficiently in quickly growing OCaml projects, the `dune` build-system provides a convenient way to write *in-line automated* tests immediately in your files.

For instance, consider the following `configuration file <https://github.com/ysc2229/ocaml-graphics-demo/blob/master/lib/graph/dune>`_, which defines dependencies of for the libraries of the second part of this course. The following lines::

  (inline_tests)                
  (preprocess (pps ppx_inline_test ppx_expect))

  (env
    (release (inline_tests enabled)))

allow one to write the tests immediately in your OCaml code (e.g., in a file ``fact.ml``), so they will be checked during the compilation of the project (you can do it via ``dune runtest`` or simply ``make``)::

 let rec fact n = if n = 1 then 1 else n * fact (n - 1)

 let%test _ = fact 5 = 120

 let%test "Failing test" = fact 5 = 121

The macro-construction ``let%test ...`` defines a test, which will be run during the build. Now executing `dune runtest` on this project, we will get::

  File "lib/Fact.ml", line 34, characters 0-38: Failing test is false.

That is, the first test (to which we gave no name via ``_``) has successfully passed, while the second one, called ``"Failing test"`` has failed.

One can also write tests that, instead of expecting a boolean value (like the two tests above), match an output produced by the function being tested, against some expected string. For instance, the following test will fail, as the produced and the expected strings are different::

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
