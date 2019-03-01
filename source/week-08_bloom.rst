.. -*- mode: rst -*-

.. _sec_bloom:

Bloom Filters and Their Applications
====================================

TODO: Motivation and examples

* Google Chrome web browser used to use a Bloom filter to identify
  malicious URLs.

* Bitcoin uses Bloom filters to speed up wallet synchronization.

* Medium uses Bloom filters to avoid recommending articles a user has
  previously read.


Bloom filter signature
----------------------

TODO::

 module type BloomHashing = sig
   type t
   val hash_functions : (t -> int) list  
 end

TODO:: 

 module type BloomFilter = functor
   (H: BloomHashing) -> sig
   type t
   val mk_bloom_filter : int -> t
   val insert : t -> H.t -> unit
   val contains : t -> H.t -> bool
   val print_filter : t -> unit
 end


Implementing a Bloom filter
---------------------------

TODO::

 module BloomFilterImpl : BloomFilter = functor
   (H: BloomHashing) -> struct

   (* Type of filter *)
   type t = {
     slots : bool array;
     size  : int
   }

   (* Functions come here *)    
 end

Main functions::

  let mk_bloom_filter n = 
    let a = Array.make n false in
    {slots = a; size = n}

  let insert f e = 
    let n = f.size in
    List.iter (fun hash ->
        let h = (hash e) mod n in
        f.slots.(h) <- true) H.hash_functions

  let contains f e = 
    if H.hash_functions = [] then false
    else
      let n = f.size in
      let res = ref true in
      List.iter (fun hash ->
          let h = (hash e) mod n in
          res := !res && f.slots.(h)) H.hash_functions;
      !res
        
  module BP = Week_05.ArrayPrinter(struct
      type t = bool
      let pp b = if b then "1" else "0"
    end)

  let print_filter t = 
    let open BP in
    print_array t.slots

Experimenting with Bloom filters
--------------------------------

Specific hashing strategy::

 module IntStringHashing = struct
   type t = int * string
   let hash1 (k, _) = Hashtbl.hash k
   let hash2 (_, v) = Hashtbl.hash v
   let hash3 (k, _) = k 
   let hash_functions = [hash1; hash2; hash3]
 end

Instantiating the filter::

  module IntStringFilter = BloomFilterImpl(IntStringHashing)

Filling a filter from an array::

 let fill_bloom_filter m n = 
   let open IntStringFilter in
   let filter = mk_bloom_filter m in
   let a = Week_03.generate_key_value_array n in
   for i = 0 to  n - 1 do    
     insert filter a.(i)
   done;
   (filter, a)

Let's do some experiments::

 utop # let (f, a) = fill_bloom_filter 20 10;;
 val f : IntStringFilter.t = <abstr>
 val a : (int * string) array =
   [|(4, "ayuys"); (7, "cdrhf"); (4, "ukobi"); (5, "hwsjs"); (8, "uyrla");
     (0, "uldju"); (3, "rkolw"); (7, "gnzzo"); (7, "nksfe"); (4, "geevu")|]

 utop # IntStringFilter.contains f (3, "rkolw");;
 - : bool = true

 utop # IntStringFilter.contains f (13, "aaa");;
 - : bool = false

 utop # IntStringFilter.print_filter f;;
 [| 1; 0; 0; 1; 1; 1; 0; 1; 1; 1; 1; 0; 1; 0; 1; 1; 0; 1; 1; 0 |] - : unit = ()

Testing Bloom Filters
---------------------

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_08_Tests.ml

Testing for no true positive::

 let%test "bloom filter true positives" = 
   let open IntStringFilter in
   let fsize = 2000 in
   let len = 1000 in
   let (f, a) = fill_bloom_filter fsize len in 
   for i = 0 to len - 1 do
     assert (contains f a.(i))
   done;
   true

Testing for true negatives::

 let%test "bloom filter false positives" = 
   let open IntStringFilter in
   let fsize = 2000 in
   let len = 1000 in
   let (f, a) = fill_bloom_filter fsize len in 
   let al = array_to_list 0 len a in


   let b = generate_key_value_array len in
   for i = 0 to len - 1 do
     let e = b.(i) in
     if (not (contains f e))
     then assert (not (List.mem e al))
   done;
   true

However, there can be also *false positives*.

Improving Simple Hash-table with a Bloom filter
-----------------------------------------------

TODO: Ratinoale --- too much time spent on filtering buckets

TODO: Say that we cannot remove

TODO::

 module BloomHashTable (K: BloomHashing) = struct 
   type key = K.t

   (* Adding bloom filter *)
   module BF = BloomFilterImpl(K)

   type 'v hash_table = {
     buckets : 'v list array;
     capacity : int; 
     filter   : BF.t
   }
  
   (* Functions come here *)
 end

Insertion also updates the filter::

  let insert ht k v = 
    let hs = Hashtbl.hash k in
    let bnum = hs mod ht.capacity in 
    let bucket = ht.buckets.(bnum) in
    let filter = ht.filter in
    let clean_bucket = 
      (* New stuff *)
      if BF.contains filter k
      (* Only filter if ostensibly contains key *)
      then List.filter (fun (k', _) -> k' <> k) bucket 
      else bucket in
    (* Missed in the initial the implementation *)
    BF.insert filter k;
    ht.buckets.(bnum) <- (k, v) :: clean_bucket

Fetching consults the filter first::

  let get ht k = 
    let filter = ht.filter in
    if BF.contains filter k then
      let hs = Hashtbl.hash k in
      let bnum = hs mod ht.capacity in 
      let bucket = ht.buckets.(bnum) in
      let res = List.find_opt (fun (k', _) -> k' = k) bucket in
      match res with 
      | Some (_, v) -> Some v
      | _ -> None
    else None

Removal is prohibited::

  let remove _ _ = raise (Failure "Removal is deprecated!")


Comparing performance
---------------------

Let us instantiate the Bloom-table::

 module BHT = BloomHashTable(IntStringHashing)
 module BHTTester = HashTableTester(BHT)

Similarly to methods for testing performance of previiously defined
hash-tables, we implement the following function::

 let insert_and_get_bulk_bloom a m = 
   Printf.printf "Creating Bloom hash table:\n";
   let ht = Week_03.time (BHTTester.mk_test_table_from_array_length a) m in
   Printf.printf "Fetching from Bloom hash table on the array of size %d:\n" (Array.length a);
   let _ = Week_03.time BHTTester.test_table_get ht a in ()

Now, leet us compare the Bloom filter-powered simple table versus
vanilla simple hash-table::

 let compare_hashing_time_simple_bloom n m = 
   let a = Week_03.generate_key_value_array n in
   insert_and_get_bulk_simple a m;
   print_endline "";
   insert_and_get_bulk_bloom a m

Running the expriments. Not so much gain when a number of elements and
the buckets are in the same ballpark::

 utop # compare_hashing_time_simple_bloom 10000 5000;;
 Creating simple hash table:
 Execution elapsed time: 0.003352 sec
 Fetching from simple hash table on the array of size 10000:
 Execution elapsed time: 0.000001 sec

 Creating Bloom hash table:
 Execution elapsed time: 0.007994 sec
 Fetching from Bloom hash table on the array of size 10000:
 Execution elapsed time: 0.000001 sec

However, the difference is noticeable when the number of buckets is
small, and the sie of the filter is still comparable with the number
of elements being inserted::

 utop # compare_hashing_time_simple_bloom 15000 20;;
 Creating simple hash table:
 Execution elapsed time: 0.370876 sec
 Fetching from simple hash table on the array of size 15000:
 Execution elapsed time: 0.000002 sec

 Creating Bloom hash table:
 Execution elapsed time: 0.234405 sec
 Fetching from Bloom hash table on the array of size 15000:
 Execution elapsed time: 0.000000 sec
