.. -*- mode: rst -*-

Hash-tables
===========

Allocation by hashing keys
--------------------------

TODO

The crux of hash-tables is the following interface for hashing::

 module type Hashable = sig
   type t
   val hash : t -> int
 end


Operations on hash-tables
-------------------------

The following interface describes the types and operations over a hash table::

 module type HashTable = functor 
   (H : Hashable) -> sig
   type key = H.t
   type 'v hash_table
   val mk_new_table : int -> 'v hash_table 
   val insert : (key * 'v) hash_table -> key -> 'v -> unit
   val get : (key * 'v) hash_table -> key -> 'v option
   val remove : (key * 'v) hash_table -> key -> unit
 end


Implementing hash-tables
------------------------

Let us start by definind, as the following functor, a simple hash-table that uses lists to represent buckets::

 module ListBasedHashTable 
   : HashTable = functor 
   (H : Hashable) -> struct
   type key = H.t

   type 'v hash_table = {
     buckets : 'v list array;
     size : int 
   }

   (* More functions are coming *)
 
   end

Making a new hash table::

  let mk_new_table size = 
    let buckets = Array.make size [] in
    {buckets = buckets;
     size = size}

Inserting an element::

  let insert ht k v = 
    let hs = H.hash k in
    let bnum = hs mod ht.size in 
    let bucket = ht.buckets.(bnum) in
    let clean_bucket = 
      List.filter (fun (k', _) -> k' <> k) bucket in
    ht.buckets.(bnum) <- (k, v) :: clean_bucket

Retrieving an element by its key::

  let get ht k = 
    let hs = H.hash k in
    let bnum = hs mod ht.size in 
    let bucket = ht.buckets.(bnum) in
    let res = List.find_opt (fun (k', _) -> k' = k) bucket in
    match res with 
    | Some (_, v) -> Some v
    | _ -> None

Finally, removing an element::

  let remove ht k = 
    let hs = H.hash k in
    let bnum = hs mod ht.size in 
    let bucket = ht.buckets.(bnum) in
    let clean_bucket = 
      List.filter (fun (k', _) -> k' <> k) bucket in
    ht.buckets.(bnum) <- clean_bucket


Hash-tables in action
---------------------

Let us adopt the simplest possible strategy for hashing the integer keys::

 module HashTableIntKey = ListBasedHashTable 
     (struct type t = int let hash i = i end)
 
As before, let us fill up a hash-table from an array::

 # let a = generate_key_value_array 10

 # a;;
 - : (int * string) array =
 [|(7, "sapwd"); (3, "bsxoq"); (0, "lfckx"); (7, "nwztj"); (5, "voeed");
   (9, "jtwrn"); (8, "zovuq"); (4, "hgiki"); (8, "yqnvq"); (3, "gjmfh")|]

 # for i = 0 to 9 do HashTableIntKey.insert hs (fst a.(i)) a.(i) done;;
 - : unit = ()

We can now retrieve the values::

 # HashTableIntKey.get hs 4;;
 - : (int * string) option = Some (4, "hgiki")
 # HashTableIntKey.get hs 8;;
 - : (int * string) option = Some (8, "yqnvq")
 # HashTableIntKey.get hs 10;;
 - : (int * string) option = None

Notice that the latest occurrence of an element with the key ``8`` (i.e., ``(8, "yqnvq")``) has overriden an earlier element ``(8, "zovuq")`` in the hash-table.

