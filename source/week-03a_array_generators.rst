.. -*- mode: rst -*-

Generating Arrays
=================

Searching and sorting are the two main procedures one perfroms on arrays, and this is why the performance of the corresponding algorithms plays crucial role in practical applications. In this chapter we will explore more efficient ways to do so. 

In order to not duplicate the development let us include some of the files from the previous weeks, as they already contain a number of useful functions. This can be done in OCaml by first compiling the corresponding file and then loading it in a current development. For instance, if the previous week's file has been called `week_02.ml`, it can be included into the current one by first running the following command from the terminal::

  ocamlc week_02.ml

and then, assuming that the current file is in the same folder, adding the following lines to the current development::

  #load "week_02a_arrays.cmo";;
  open Week_02a_arrays

Simple random generators
------------------------

To test not only the correctness, but also the performance of our search and sorting algorithms, let us invest some time into creating the procedures for random arrays. In this chapter and further we will consider slightly more interesting arrays than just arrays of integers of type ``int array``. Specifically, each element of an array will hold a *pair*: a *key* (typically an integer), identifying an element, and a *value*, which carries some interesting payload. In a general case, some elements might have duplicating keys, and different keys can correspond to the same element. Do not confuse the array indices (which are used for efficient access to specific array entries) with element keys (which are domain-specific and can be anything identifying the corresponding payload).

Let us start from implementing a random generator for lists of rundom numbers in a range from ``0`` to a given ``bound``, of a specified length ``len``::

 let generate_keys bound len = 
   let acc = ref [] in
   for i = 0 to len - 1 do
     acc := (Random.int bound) :: ! acc
   done;
   !acc

Notice, that for the sake of efficiency (and diversity) the program is implemented via a loop rather than as a recursion.

Our next procedure is more interesting and will generate strings of a fixed ``length`` containing lowercase characters of the standard latin alphabet::

 let generate_words length num =
   let random_ascii_char _ = 
     let rnd = (Random.int 26) + 97 in
     Char.chr rnd
   in
   let random_string _ = 
     let buf = Buffer.create length in
     for i = 0 to length - 1 do
       Buffer.add_char buf (random_ascii_char ())
     done;
     Buffer.contents buf
   in
   let acc = ref [] in
   for i = 0 to num - 1 do
     acc := (random_string ()) :: ! acc
   done;
   !acc

The first function, ``random_ascii_char`` generates a random lowercase `ASCII <https://en.wikipedia.org/wiki/ASCII>`_ character (of which there are 26), and 97 corresponds to ``'a'``. ``random_string`` will create a string up to the fixed ``length``. Finally, the main body function will add this string to the result list.

To generate arrays, let us first implement a familiar function ``iota`` that creates a list of increasing natural numbers::

 let iota n = 
   let rec walk acc m = 
     if m < 0 
     then acc
     else walk (m :: acc) (m - 1)
   in
   walk [] n

Finally, we define an auxiliary function ``list_zip``, which is similar in its functionality to the standard function ``List.combine``, but, unlike the latter does not exhaust call stack, as it is implemented in `Continuation-Passing Style <https://en.wikipedia.org/wiki/Continuation-passing_style>`_ and is, hence, in a tail-call form::

 let list_zip ls1 ls2 = 
   let rec walk xs1 xs2 k = match xs1, xs2 with
     | h1 :: t1, h2 :: t2 -> 
       walk t1 t2 (fun acc -> k ((h1, h2) :: acc))
     | _ -> k []
   in
   walk ls1 ls2 (fun x -> x)    

We can finally implement an generator for key-value arrays::

 let generate_key_value_array len = 
   let kvs = list_zip (generate_keys len len) (generate_words 5 len) in
   let almost_array = list_zip (iota (len - 1)) kvs in
   let arr = Array.make len (0, "") in
   List.iter (fun (i, kv) -> arr.(i) <- kv) almost_array;
   arr

It can be used as follows::

 # generate_key_value_array 10;;
 - : (int * string) array =
 [|(1, "emwbq"); (3, "yyrby"); (7, "qpzdd"); (7, "eoplb"); (6, "wrpgn");
   (7, "jbkbq"); (7, "nncgq"); (1, "rruxr"); (8, "ootiw"); (7, "halys")|]


Measuring execution time
------------------------

For our future experiments with algorithms and data structures, it is useful to be able to measure execution time, hence we implement the following helper function::

 let time f x =
   let t = Sys.time () in
   let fx = f x in
   Printf.printf "execution elapsed time: %f sec\n" (Sys.time () -. t);
   fx

It can be used with any arbitrary computation that takes at least one argument.


Randomised array generation and testing
---------------------------------------

Let us re-implement insert-sort, so it would be useful for our new setting of arrays with key-value pairs and test its performance::

 let new_insert_sort arr = 
   let len = Array.length arr in
   for i = 0 to len - 1 do
     let j = ref i in
     while !j > 0 && (fst arr.(!j - 1)) > (fst arr.(!j)) do
       swap arr !j (!j - 1);
       j := !j - 1
     done
   done

 # let a = generate_key_value_array 5000;;
 val a : (int * string) array =
   [|(894, "goavt"); (2768, "hvjjb"); (3535, "pbkoy"); (1615, "ybzua");
     (2820, "ssriq"); (2060, "sfxsu"); (2328, "kjgff"); (112, "xuoht");
     (1188, "xxfcs"); (2384, "xbwgb");
     (1134, "oi"... (* string length 5; truncated *)); (3102, ...); ...|]

 # time new_insert_sort a;;
 execution elapsed time: 0.395832 sec
 - : unit = ()

.. _exercise-randomised-testing:

Exercise 4
----------
Implement a function that generates takes (a) a sorting procedure ``sort`` for a key-value array, (b) a number ``n`` and a number ``length``, and generates ``n`` random arrays of the length ``length``, testing that ``sort`` is indeed correct on all those arrays. 


