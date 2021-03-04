.. -*- mode: rst -*-

.. _hash_tables:

Hash-tables
===========

* File: ``HashTables.ml``

Hash-tables generalise the ideas of ordinary arrays and also (somewhat
surprisingly) bucket-sort, providing an efficient way to store
elements in a collection, addressed by their keys, with average
:math:`O(1)` complexity for inserting, finding and removing elements
from the collection.

Allocation by hashing keys
--------------------------

At heart of hash-tables is the idea of a *hash-function* --- a mapping
from elements of a certain type to randomly distributed integers. This
functionality can be described by means of the following OCaml
signature::

 module type Hashable = sig
   type t
   val hash : t -> int
 end

Designing a good hash-function for an arbitrary data type (e.g., a
string) is highly non-trivial and is outside of the scope of this
course. The main complexity is to make it such that "similar" values
(e.g., ``s1 = "aaa"`` and ``s2 = "aab"``) would have very different
hashes (e.g., ``hash s1 = 12423512`` and ``s2 = 99887978``), thus
providing a uniform distribution. It is not required for a
hash-function to be injective (i.e., it *may* map different elements
to the same integer value --- phenomenon known as *hash collision*).
However, for most of the purposes of hash-functions, it is assumed
that collisions are relatively rare.

Operations on hash-tables
-------------------------

As we remember, in arrays, elements are indexed by integers ranging
form 0 to the size of the array minus one. Hash-tables provide an
interface similar to arrays, with the only difference that *any* type
``t`` can be used as keys for indexing elements (similarly to integers
in an array), as long as there is an implementation of ``hash``
available for it.

An interface of a hash-table is thus parameterised by the hashing
strategy, used for its implementation for a specific type of *keys*.
The following module signature the types and operations over a hash
table::

 module type HashTable = functor 
   (H : Hashable) -> sig
   type key = H.t
   type 'v hash_table
   val mk_new_table : int -> 'v hash_table 
   val insert : (key * 'v) hash_table -> key -> 'v -> unit
   val get : (key * 'v) hash_table -> key -> 'v option
   val remove : (key * 'v) hash_table -> key -> unit
 end

As announced ``key`` specifies the type of keys, used to refer to
elements stored in a hash table. One can create a new hash-table of a
predefined *size* (of type ``int``) via ``mk_new_table``. The next
three functions provide the main interface for hash-table, allowing to
insert and retrieve elements for a given key, as well as remove
elements by key, thus, changing the state of the hash table (hence the
return type of ``remove`` is ``unit``).


Implementing hash-tables
------------------------

Implementations of hash-table build on a simple idea. In order to fit
an arbitrary number of elements with different keys into a
limited-size array, one can use a trick similar to bucket sort,
enabled by the hashing function:

* Compute ``(hash k) mod n`` to compute the slot (aka *bucket*) in an
  array of size ``n`` for inserting an element with a key ``k``;
* if there are already elements in this bucket, add the new one,
  together with the old ones, storing them in a list.

Then, when trying to retrieve an element with a key ``k``, one has to

* Compute ``(hash k) mod n`` to compute the bucket where the element
  is located;
* Go through the bucket with a linear search, finding the element
  whose key is precisely ``k``.

That is, it is okay for elements with different keys to collide on the
same bucket, as more elaborated search will be performed in each
bucket.

Why hash-tables are so efficient? As long as the size of the carrier
array is greater or roughly the same as the number of inserted
elements so far, and there were not many collisions, we can assume
that each bucket has a very small number of elements (for which the
collisions have happened while determining their bucket). Therefore,
as long as the size of a bucket is limited by a certain constant, the
search will boil down to (a) computing a bucket for a key in a
constant time and (b) scanning the bucket for the right element, both
operations yielding :math:`O(1)` complexity.

Let us start by defining a simple hash-table that uses lists to
represent buckets::

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

Making a new hash table can be done by simply allocating a new array::

  let mk_new_table size = 
    let buckets = Array.make size [] in
    {buckets = buckets;
     size = size}

Inserting an element follows the scenario described above.
``List.filter`` is used to make sure that no elements with the same
key are lingering in the same bucket::

  let insert ht k v = 
    let hs = H.hash k in
    let bnum = hs mod ht.size in 
    let bucket = ht.buckets.(bnum) in
    let clean_bucket = 
      List.filter (fun (k', _) -> k' <> k) bucket in
    ht.buckets.(bnum) <- (k, v) :: clean_bucket

Retrieving an element by its key is done by using ``List.find_opt``
for retrieving the desired element from the bucket. Even though
``List.find_opt`` has linear complexity, it will not hurt
performance for small buckets::

  let get ht k = 
    let hs = H.hash k in
    let bnum = hs mod ht.size in 
    let bucket = ht.buckets.(bnum) in
    let res = List.find_opt (fun (k', _) -> k' = k) bucket in
    match res with 
    | Some (_, v) -> Some v
    | _ -> None

Finally, removing an element is similar to inserting a new one::

  let remove ht k = 
    let hs = H.hash k in
    let bnum = hs mod ht.size in 
    let bucket = ht.buckets.(bnum) in
    let clean_bucket = 
      List.filter (fun (k', _) -> k' <> k) bucket in
    ht.buckets.(bnum) <- clean_bucket


Hash-tables in action
---------------------

Let us adopt the simplest possible strategy for hashing the integer
keys::

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

Notice that the latest occurrence of an element with the key ``8``
(i.e., ``(8, "yqnvq")``) has overriden an earlier element ``(8,
"zovuq")`` in the hash-table.

