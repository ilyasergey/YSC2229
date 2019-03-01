.. -*- mode: rst -*-

Hash-Tables, Revisited
======================

[`Code <https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_08_HashTable.ml>`_]

We have briefly considered hash-tables in Section :ref:`hash_tables`.  Given their ubiquity and importance, we arge going to elaborate on their construction in this lecture.


OCaml's universal hashing
-------------------------

As many other mainstream languages, OCaml provides a polymorphic function for hashing any values, no matter what type they have::

 utop # Hashtbl.hash;;
 - : 'a -> int = <fun>
 ─( 20:48:43 )─< command 1 >───────────────────{ counter: 0 }─
 utop # Hashtbl.hash "abc";;
 - : int = 767105082
 ─( 20:58:02 )─< command 2 >───────────────────{ counter: 0 }─
 utop # Hashtbl.hash 42;;
 - : int = 395478795

This function, unfortunately, has some limitations for particularly deep data structures (such as, e.g., long lists). In particular, for list beyond certain length there will be collisions::

 utop # Hashtbl.hash [1;2;3;4;5;6;7;8;9;0];;
 - : int = 67023335
 ─( 20:58:08 )─< command 4 >───────────────────{ counter: 0 }─
 utop # Hashtbl.hash [1;2;3;4;5;6;7;8;9;0;1];;
 - : int = 67023335

Redefining hash-table signature
-------------------------------

Thanks to OCaml's universal hashing, we no longer have to provide a hashing strategy for the keys of a hash-table, and can simply redefine its signature as follows::

 module type HashTable = sig
   type key
   type 'v hash_table
   val mk_new_table : int -> (key* 'v) hash_table 
   val insert : (key * 'v) hash_table -> key -> 'v -> unit
   val get : (key * 'v) hash_table -> key -> 'v option
   val remove : (key * 'v) hash_table -> key -> unit
   val print_hash_table : 
     (key -> string) ->
     ('v -> string) ->
     (key * 'v) hash_table -> unit
 end

For design reasons that will become clear further in this lecture, we still mention the type ``key`` of keys separately in the signature. We also add a convenience function ``print_hash_table`` to output the contents of the data structure.

A framework for testing hash-tables
-----------------------------------

Before we re-define the hash-table, let us define a module for automated testing of hash-tables. The module starts with the following preamble::

 module HashTableTester
     (H : HashTable with type key = int * string) = struct

   module MyHT = H
   open MyHT

   (* More functions will come here. *)
 end

Notice that it is a functor that takes a hash-table implementation ``H``. The following function, which fill the hash-table from an array::


  let mk_test_table_from_array_length a m = 
    let n = Array.length a in
    let ht = mk_new_table m in
    for i = 0 to n - 1 do
      insert ht a.(i) a.(i)
    done;
    (ht, a)

The following function takes a hash-table ``ht`` and an array ``a`` used for its creating and tests that all elements in the array are in hash-table (we optimistically assume that an array does not have repetitions)::

  let test_table_get ht a = 
    let len = Array.length a in
    for i = 0 to len - 1 do
      let e = get ht a.(i) in
      assert (e <> None);
      let x = Week_01.get_exn e in
      assert (x = a.(i))
    done;
    true

A simple list-based hash-table
------------------------------

With the new signature at hand, let us now redefine a simple implementation of a list-based hash-table.

Even though not strictly necessary at the moment, we are going to make the type of keys used by the hash-table implementation explicit, and expose in the following signature::

 module type KeyType = sig
   type t
 end

The reason why we need to do it will become in the next Section :ref:`sec_bloom`, in which we will *need* to be able to introspect on the structure of the keys, prior to instantiating a hash-table. 

We proceed with the fining our simple hash-table based on lists as previously::

 module SimpleListBasedHashTable(K: KeyType) = struct
   type key = K.t

   type 'v hash_table = {
     buckets : 'v list array;
     capacity : int; 
   }

   let mk_new_table cap = 
     let buckets = Array.make cap [] in
     {buckets = buckets;
      capacity = cap}

   let insert ht k v = 
     let hs = Hashtbl.hash k in
     let bnum = hs mod ht.capacity in 
     let bucket = ht.buckets.(bnum) in
     let clean_bucket = 
       List.filter (fun (k', _) -> k' <> k) bucket in
     ht.buckets.(bnum) <- (k, v) :: clean_bucket

   let get ht k = 
     let hs = Hashtbl.hash k in
     let bnum = hs mod ht.capacity in 
     let bucket = ht.buckets.(bnum) in
     let res = List.find_opt (fun (k', _) -> k' = k) bucket in
     match res with 
     | Some (_, v) -> Some v
     | _ -> None

   (* Slow remove - introduce for completeness *)
   let remove ht k = 
     let hs = Hashtbl.hash k in
     let bnum = hs mod ht.capacity in 
     let bucket = ht.buckets.(bnum) in
     let clean_bucket = 
       List.filter (fun (k', _) -> k' <> k) bucket in
     ht.buckets.(bnum) <- clean_bucket

   (* Another function is coming here *)

 end 

As the last touch, we add the function to print the contents of the table::

  let print_hash_table ppk ppv ht = 
    let open Printf in
    print_endline @@ sprintf "Capacity: %d" (ht.capacity);
    print_endline "Buckets:";
    let buckets = (ht.buckets) in
    for i = 0 to (ht.capacity) - 1 do
      let bucket = buckets.(i) in
      if bucket <> [] then (
        (* Print bucket *)
        let s = List.fold_left 
            (fun acc (k, v) -> acc ^ (sprintf "(%s, %s); ") (ppk k) (ppv v)) "" bucket in
        printf "%d -> [ %s]\n" i s)
    done

Let us not instantiate the table to use pairs of type ``int * string`` as keys, as well as the corresponding testing framework::

 module IntString = struct type t = int * string end
 module SHT = SimpleListBasedHashTable(IntString)
 module SimpleHTTester = HashTableTester(SHT)

We can now create a simple hash-table and observe its contents::

 utop # let a = Week_03.generate_key_value_array 15;;
 val a : (int * string) array =
   [|(7, "ayqtk"); (12, "kemle"); (6, "kcrtm"); (1, "qxcnk"); (3, "czzva");
     (4, "ayuys"); (6, "cdrhf"); (6, "ukobi"); (10, "hwsjs"); (13, "uyrla");
     (2, "uldju"); (5, "rkolw"); (13, "gnzzo"); (4, "nksfe"); (7, "geevu")|]
 ─( 22:00:09 )─< command 2 >───────────────────{ counter: 0 }─
 utop # let t = SimpleHTTester.mk_test_table_from_array_length a 10;;
 val t : (SHT.key * SHT.key) SHT.hash_table = ...
 ─( 22:00:12 )─< command 3 >───────────────────{ counter: 0 }─
 utop # SimpleHTTester.MyHT.print_hash_table pp_kv pp_kv t;;
 Capacity: 10
 Buckets:
 0 -> [ ((7, geevu), (7, geevu)); ((3, czzva), (3, czzva)); ((12, kemle), (12, kemle)); ]
 1 -> [ ((7, ayqtk), (7, ayqtk)); ]
 2 -> [ ((13, uyrla), (13, uyrla)); ((6, cdrhf), (6, cdrhf)); ]
 6 -> [ ((13, gnzzo), (13, gnzzo)); ]
 7 -> [ ((5, rkolw), (5, rkolw)); ((6, ukobi), (6, ukobi)); ((1, qxcnk), (1, qxcnk)); ((6, kcrtm), (6, kcrtm)); ]
 8 -> [ ((4, ayuys), (4, ayuys)); ]
 9 -> [ ((4, nksfe), (4, nksfe)); ((2, uldju), (2, uldju)); ((10, hwsjs), (10, hwsjs)); ]


As we can see, due to hash collisions some buckets are not used at all (e.g., ``3``), while others hold multiple values (e.g., ``9``).

Testing a Simple Hash-Table
---------------------------

[`Code <https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_08_Test.ml>`_]

We can also add a number of test for the implementation of our hash-table. For instance, the following test checks that the hash table stores all (distinct) elements of a randomly generated array::

 open Week_08_HashTable

 let%test "ListBasedHashTable insert" = 
   let open SimpleHTTester in
   let a = generate_key_value_array 1000 in
   let ht = mk_test_table_from_array_length a 50 in
   test_table_get ht a

A Resizable hash-table
----------------------

TODO

We can test a resizable implementation of a hash table similarly to how we tested a simple one::

 let%test "ResizableHashTable insert" = 
   let open ResizableHTTester in
   let a = generate_key_value_array 1000 in
   let ht = mk_test_table_from_array_length a 50 in
   test_table_get ht a



Comparing performance of different implementations
--------------------------------------------------

TODO


