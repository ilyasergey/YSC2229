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

[Stopped here]


Measuring execution time
------------------------

To measure execution time, we will use the following helper function::

  let time f x =
    let t = Sys.time () in
    let fx = f x in
    Printf.printf "execution elapsed time: %f sec\n"
        (Sys.time () -. t);
    fx

Randomised array generation and testing
---------------------------------------

[Automatically testing insert-sort]

Let us re-implement insert-sort, so it would be useful for our new setting of arrays with key-value pairs::

  let new_insert_sort arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    let j = ref i in
    while !j > 0 && (fst arr.(!j - 1)) > (fst arr.(!j)) do
      swap arr !j (!j - 1);
      j := !j - 1
    done
  done

[TODO]

Exercise 1
----------
Randomised testing


