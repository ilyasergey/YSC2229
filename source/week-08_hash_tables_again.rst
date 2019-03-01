.. -*- mode: rst -*-

Hash-Tables, Revisited
======================

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_08_HashTable.ml

We have briefly considered hash-tables in Section :ref:`hash_tables`.  Given their ubiquity and importance, we arge going to elaborate on their construction in this lecture.


OCaml's universal hashing
-------------------------

As many other mainstream languages, OCaml provides a polymorphic function for hashing any values, no matter what type they have::

 utop # Hashtbl.hash;;
 - : 'a -> int = <fun>

 utop # Hashtbl.hash "abc";;
 - : int = 767105082

 utop # Hashtbl.hash 42;;
 - : int = 395478795

This function, unfortunately, has some limitations for particularly deep data structures (such as, e.g., long lists). In particular, for list beyond certain length there will be collisions::

 utop # Hashtbl.hash [1;2;3;4;5;6;7;8;9;0];;
 - : int = 67023335

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

 let pp_kv (k, v) = Printf.sprintf "(%d, %s)" k v

We can now create a simple hash-table and observe its contents::

 utop # let a = Week_03.generate_key_value_array 15;;
 val a : (int * string) array =
   [|(7, "ayqtk"); (12, "kemle"); (6, "kcrtm"); (1, "qxcnk"); (3, "czzva");
     (4, "ayuys"); (6, "cdrhf"); (6, "ukobi"); (10, "hwsjs"); (13, "uyrla");
     (2, "uldju"); (5, "rkolw"); (13, "gnzzo"); (4, "nksfe"); (7, "geevu")|]

 utop # let t = SimpleHTTester.mk_test_table_from_array_length a 10;;
 val t : (SHT.key * SHT.key) SHT.hash_table = ...

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

<https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_08_Test.ml>`

We can also add a number of test for the implementation of our hash-table. For instance, the following test checks that the hash table stores all (distinct) elements of a randomly generated array::

 open Week_08_HashTable

 let%test "ListBasedHashTable insert" = 
   let open SimpleHTTester in
   let a = generate_key_value_array 1000 in
   let ht = mk_test_table_from_array_length a 50 in
   test_table_get ht a

A Resizable hash-table
----------------------

Let us change the implementation of a hash-table, so it could grow, as the number of the added elements greatly exceeds the number of buckets. We start from the following definition in the module::

 module ResizableListBasedHashTable(K : KeyType) = struct
   type key = K.t

   type 'v hash_table = {
     buckets : 'v list array ref;
     size : int ref; 
     capacity : int ref; 
   }

   let mk_new_table cap = 
     let buckets = Array.make cap [] in
     {buckets = ref buckets;
      capacity = ref cap;
      size = ref 0}

    (* More functions are coming here *)

 end

That is, the hash table now includes its own ``capacity`` (a number of buckets), along with the ``size`` (a number of stored elements). Both are subject of future change, as more elements are added, and the table is resized.

Adding new elements by means of ``insert`` can now trigger the growth of the hash-table structure. Since it is convenient to define resizing by means of insertion into a *new* hash-table, which is going to be then swapped with the previous one, we define those two functions as mutually recursive via OCaml's ``let rec ... and ...`` construct::

  let rec insert ht k v = 
    let hs = Hashtbl.hash k in
    let bnum = hs mod !(ht.capacity) in 
    let bucket = !(ht.buckets).(bnum) in
    let clean_bucket = 
      List.filter (fun (k', _) -> k' <> k) bucket in
    let new_bucket = (k, v) :: clean_bucket in
    !(ht.buckets).(bnum) <- new_bucket;
    (* Increase size *)
    (if List.length bucket < List.length new_bucket
    then ht.size := !(ht.size) + 1);
    (* Resize *)
    if !(ht.size) > !(ht.capacity) + 1
    then resize_and_copy ht

  and resize_and_copy ht =
    let new_capacity = !(ht.capacity) * 2 in
    let new_buckets = Array.make new_capacity [] in
    let new_ht = {
      buckets = ref new_buckets;
      capacity = ref new_capacity;
      size = ref 0;
    } in
    let old_buckets = !(ht.buckets) in
    let len = Array.length old_buckets in 
    for i = 0 to len - 1 do
      let bucket = old_buckets.(i) in
      List.iter (fun (k, v) -> insert new_ht k v) bucket
    done;
    ht.buckets := !(new_ht.buckets);
    ht.capacity := !(new_ht.capacity);
    ht.size := !(new_ht.size)

Fetching elements from a resizable hash-table is not very different from doing so with a simple one::

  let get ht k = 
    let hs = Hashtbl.hash k in
    let bnum = hs mod !(ht.capacity) in 
    let bucket = !(ht.buckets).(bnum) in
    let res = List.find_opt (fun (k', _) -> k' = k) bucket in
    match res with 
    | Some (_, v) -> Some v
    | _ -> None

Removal of elements requires a bit of care, so the size of the table would be suitably decreased::

  (* Slow remove - introduce for completeness *)
  let remove ht k = 
    let hs = Hashtbl.hash k in
    let bnum = hs mod !(ht.capacity) in 
    let bucket = !(ht.buckets).(bnum) in
    let clean_bucket = 
      List.filter (fun (k', _) -> k' <> k) bucket in
    !(ht.buckets).(bnum) <- clean_bucket;
    (if List.length bucket > List.length clean_bucket
    then ht.size := !(ht.size) - 1);
    assert (!(ht.size) >= 0)

Finally, printing is defined in almost the same way as before::

  let print_hash_table ppk ppv ht = 
    let open Printf in
    print_endline @@ sprintf "Capacity: %d" !(ht.capacity);
    print_endline @@ sprintf "Size:     %d" !(ht.size);
    print_endline "Buckets:";
    let buckets = !(ht.buckets) in
    for i = 0 to !(ht.capacity) - 1 do
      let bucket = buckets.(i) in
      if bucket <> [] then (
        (* Print bucket *)
        let s = List.fold_left 
            (fun acc (k, v) -> acc ^ (sprintf "(%s, %s); ") (ppk k) (ppv v)) "" bucket in
        printf "%d -> [ %s]\n" i s)
    done

Let us experiment with the resizable implementation by means of defining the following modules::

 module RHT = ResizableListBasedHashTable(IntString)
 module ResizableHTTester = HashTableTester(RHT)

Let us see how the table grows::

 utop # let a = Week_03.generate_key_value_array 20;;
 val a : (int * string) array =
   [|(17, "hvevv"); (9, "epsxo"); (14, "prasb"); (5, "ozdnt"); (10, "hglck");
     (18, "ayqtk"); (4, "kemle"); (11, "kcrtm"); (14, "qxcnk"); (19, "czzva");
     (4, "ayuys"); (7, "cdrhf"); (5, "ukobi"); (19, "hwsjs"); (3, "uyrla");
     (0, "uldju"); (7, "rkolw"); (6, "gnzzo"); (19, "nksfe"); (4, "geevu")|]

 utop # let t = ResizableHTTester.mk_test_table_from_array_length a 5;;
 val t : (SHT.key * SHT.key) RHT.hash_table = ...
    size = {contents = 20}; capacity = {contents = 20}}

 utop # RHT.print_hash_table pp_kv pp_kv t;;
 Capacity: 20
 Size:     20
 Buckets:
 2 -> [ ((14, qxcnk), (14, qxcnk)); ]
 3 -> [ ((7, rkolw), (7, rkolw)); ((0, uldju), (0, uldju)); ((19, hwsjs), (19, hwsjs)); ]
 4 -> [ ((19, nksfe), (19, nksfe)); ((4, kemle), (4, kemle)); ((18, ayqtk), (18, ayqtk)); ((5, ozdnt), (5, ozdnt)); ]
 5 -> [ ((19, czzva), (19, czzva)); ]
 6 -> [ ((3, uyrla), (3, uyrla)); ]
 8 -> [ ((4, ayuys), (4, ayuys)); ]
 9 -> [ ((6, gnzzo), (6, gnzzo)); ]
 10 -> [ ((17, hvevv), (17, hvevv)); ((7, cdrhf), (7, cdrhf)); ]
 11 -> [ ((14, prasb), (14, prasb)); ]
 12 -> [ ((11, kcrtm), (11, kcrtm)); ]
 13 -> [ ((5, ukobi), (5, ukobi)); ]
 16 -> [ ((9, epsxo), (9, epsxo)); ]
 17 -> [ ((4, geevu), (4, geevu)); ((10, hglck), (10, hglck)); ]

To emphasise, even though we have created the table with capacity 5 (via ``mk_test_table_from_array_length a 5``), it has then grew, as more elements were added, so its capacity has quadrupled, becoming 20.

We can also test a resizable implementation of a hash table similarly to how we tested a simple one::

 let%test "ResizableHashTable insert" = 
   let open ResizableHTTester in
   let a = generate_key_value_array 1000 in
   let ht = mk_test_table_from_array_length a 50 in
   test_table_get ht a

Comparing performance of different implementations
--------------------------------------------------

Which implementation of a hash-table behaves better in practice? We are going to answer this questions by setting up an experiment. For this, we define the following two functions for stress-testing our two implementations::

 let insert_and_get_bulk_simple a m = 
   Printf.printf "Creating simple hash table:\n";
   let ht = Week_03.time (SimpleHTTester.mk_test_table_from_array_length a) m in
   Printf.printf "Fetching from simple hash table on the array of size %d:\n" (Array.length a);
   let _ = Week_03.time SimpleHTTester.test_table_get ht a in ()

 let insert_and_get_bulk_resizable a m = 
   Printf.printf "Creating resizable hash table:\n";
   let ht = Week_03.time (ResizableHTTester.mk_test_table_from_array_length a) m in
   Printf.printf "Fetching from resizable hash table on the array of size %d:\n" (Array.length a);
   let _ = Week_03.time ResizableHTTester.test_table_get ht a in ()

The next function is going to run both of them on the same array (of a given size ``n``), creating two hash-tables of the initial size ``m`` and measuring

* (a) How long does it take to fill up the table, and
* (b) How long does it take to fetch the elements

This is done as follows::

 let compare_hashing_time n m = 
   let a = Week_03.generate_key_value_array n in
   insert_and_get_bulk_simple a m;
   print_endline "";
   insert_and_get_bulk_resizable a m;

When the number of buckets is of the same order of magnitude as the number of items being inserted, the simple hash-table exhibits performance better than the resizable one (as resizing takes considerable amount of time)::

 utop # compare_hashing_time 10000 1000;;
 Creating simple hash table:
 Execution elapsed time: 0.005814 sec
 Fetching from simple hash table on the array of size 10000:
 Execution elapsed time: 0.000000 sec

 Creating resizable hash table:
 Execution elapsed time: 0.010244 sec
 Fetching from resizable hash table on the array of size 10000:
 Execution elapsed time: 0.000000 sec

However, for a number of buckets much smaller than the number of elements to be inserted, the benefits of dynamic resizing become clear::

 utop # compare_hashing_time 25000 50;;
 Creating simple hash table:
 Execution elapsed time: 0.477194 sec
 Fetching from simple hash table on the array of size 25000:
 Execution elapsed time: 0.000002 sec

 Creating resizable hash table:
 Execution elapsed time: 0.020068 sec
 Fetching from resizable hash table on the array of size 25000:
 Execution elapsed time: 0.000000 sec


