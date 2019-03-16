.. -*- mode: rst -*-

.. _week-10-huffman:

Huffman Encoding
================

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_10_HuffmanCodes.ml

All the compression algorithms we explored so far did not really exploit any specifics of the file they are working on in order to adapt the compression scheme itself. 

The idea of `Huffman coding <https://en.wikipedia.org/wiki/Huffman_coding>`_ (named after its inventor David A. Huffman) is to encode a text by assigning longer bit sequences to more rare charaters in it, while giving shorter codes (bit sequences) to more frequent characters. It builds on several simple but powerful ideas, which we will consider further below:

* Huffman tree of charactes
* Character frequency analysis

Assigning Codes via Character Trees
-----------------------------------

Huffman tree is a binary tree that has characters in its leaves. It gives a simple way to assigne unique binary codes (bit sequences) to individual charactes by following paths in the tree. The key characterising of a Huffman tree is that no code for any character is a prefix of a code of another character. This makes it possible to use the tree for both encoding and decoding without any overhead from under-used encodings (as was the case with RLE).

The binary tree can be represented by the following OCaml type::

 type 'a tree = 
   | Node of 'a tree * 'a tree
   | Leaf of 'a

Consider the following example::

 let tree1 = 
   let le = Leaf 'e' in
   let ld = Leaf 'd' in
   let la = Leaf 'a' in
   let lb = Leaf 'b' in
   let lc = Leaf 'c' in
   let lf = Leaf 'f' in
   Node (la,
         Node (Node (lc, lb), 
               Node (Node (lf, le), 
                     ld)))

The encodings for ``'a'``, ``'b'``, etc can be restored by walking down the branches (0 - left, 1 - right) of the tree before reaching the corresponding leaf. This way we obtain the following codes::

 a -> 0
 b -> 101
 c -> 100
 d -> 111
 e -> 1101
 f -> 1100

It is easy to see that none of the codes is a prefix of another one, thus, using this particular Huffman tree, we can unambiguously restore the string ``"acd"`` from its code ``0100111``.

Serializing Huffman Trees
-------------------------

It is very easy to serialize the tree recursively by writing its characters for the leaves, or recursively serializing subtrees for nodes::

 let rec write_tree out t = 
   match t with 
   | Leaf c -> begin
       write_bits out ~nbits:1 1;
       write_bits out ~nbits:8 (int_of_char c)
     end
   | Node (l, r) ->
     write_bits out ~nbits:1 0;
     write_tree out l;
     write_tree out r

The deserialization works by reading the bits from an input, determining whether it sees a leaf or a node. In the latter case it proceeds recursively::

 let rec read_tree input = 
   match read_bits input 1 with
   | 1 -> 
     let c = read_bits input 8 |> char_of_int in
     Leaf c
   | 0 ->
     let l = read_tree input in
     let r = read_tree input in
     Node (l, r)
   | _ -> raise (Failure "Cannot unparse tree!")

We can test those two procedures as follows::

 open Week_10_BinaryEncodings

 (* Test functions *)
 let write_tree_to_binary = write_to_binary write_tree
 let read_tree_from_binary = read_from_binary read_tree

 let test_tree_serialization t = 
   let f = "tree.tmp" in
   write_tree_to_binary f t;
   let t' = read_tree_from_binary f in
   Sys.remove f;
   t = t'

Constructing Huffman tree from Frequencies
------------------------------------------

Naturally, we want to assign shorter codes to more common characters and longer codes to more rare ones. For now, assume that we know relative frequencies of the characters in our text, encoded, e.g., by the following array::

 let cfreqs1 = [|('a', 45); ('b', 13); ('c', 12); 
                 ('d', 16); ('e', 9); ('f', 5)|]

Using this information, we are going to build the Huffman tree iteratively, by "merging" a number of disparate trees and taking unioin of their frequencies. To do so, we first create an array of disparate leaves, along with their frequencies::

 let make_tree_array freq_chars = 
   let n = Array.length freq_chars in
   let ftrees = Array.create n (Leaf 'a', 1) in
   for i = 0 to n - 1 do
     let (c, f) = freq_chars.(i) in
     ftrees.(i) <- (Leaf c, f)
   done;
   ftrees
 
To build the tree from those leaves, we are going to use a familiar structure min-priority queue. It can be definined by instantiating a functor from Chapter :ref:`priority_queues` with the following comparator::

 module CF = struct
   type t = char tree * int
   let comp x y = 
     if snd x < snd y then 1
     else if fst x = fst y then 0
     else -1
   let pp (_, f) = Printf.sprintf "[tree -> %d]" f
 end

 open Week_05
 module PQ = PriorityQueue(CF)

The final tree is computed as follows. Having ``n`` leaves, we iterate for ``n - 2`` times, each time extracting the trees with the minimal cumulative frequency. Having those, we "merge" them by allocating a node, assigning the cumulative frequence to it, and insert it back to the priority queue. Having fone that ``n - 2`` times, we will have only one node leftin the queue, corresponding to the root of the tree::

 let compute_frequency_tree freq_chars = 
   let open PQ in
   let open Week_01 in
   let n = Array.length freq_chars in
   let ftrees = make_tree_array freq_chars in
   let q = mk_queue ftrees in
   for i = 0 to n - 2 do
     (* TODO: fix this in Week_05! *)
     let (x, fx) = get_exn @@ get_exn @@ heap_extract_max q in
     let (y, fy) = get_exn @@ get_exn @@ heap_extract_max q in
     let n = (Node (x, y), fx + fy) in
     max_heap_insert q n
   done;
   fst @@ get_exn @@ get_exn @@ heap_extract_max q

Computing Relative Frequencies
------------------------------

For large texts, we can assume that any ASCII character occurs there, hence we can allocate a 256-slot array and fill it with frequencies by traversing the string::

 let compute_freqs s = 
   let n = String.length s in
   let m = 256 in
   let freqs = Array.create ~len:m 0 in
   for i = 0 to n - 1 do
     let i = int_of_char s.[i] in
     freqs.(i) <- freqs.(i) + 1
   done;
   let cfreqs = Array.create ~len:m ('a', 0) in
   for i = 0 to m - 1 do
     cfreqs.(i) <- (char_of_int i, freqs.(i))
   done;
   cfreqs

Encoding and Writing the Compressed Text
----------------------------------------

Having a tree, we can produce a table of Huffman codes by traversing it recursively, filling up a table of 256 characters::

 let build_table t = 
   let m = 256 in
   let table = Array.create ~len:m [] in 

   let rec make_codes t acc = 
     match t with
     | Leaf c -> 
       let i = int_of_char c in
       table.(i) <- acc
     | Node (l, r) -> begin
         make_codes l (acc @ [0]);
         make_codes r (acc @ [1])
       end
   in
   make_codes t [];
   table

Now, with the tree, encoding table at hand, and the text itself, we can proceed to write the compressed binary file. The file will contain

(a) The serialized Huffman tree with the codes, necessary to decode the rest and
(b) The string encoded using the table built via the ``build_table`` function.

Since we serialize the tree, there is no need to serialize the table. 

The following function writes the tree and the encoded string to the output bit-channel ``out``::

 let write_tree_and_data out (t, s) = 
   write_tree out t;
   let table = build_table t in
   let n = String.length s in 
   (* Write length *)
   write_bits out ~nbits:30 n;
   for i = 0 to n - 1 do
     let bits = table.(int_of_char s.[i])  in
     List.iter bits ~f:(fun bit ->
         write_bits out ~nbits:1 bit;)
   done

Notice that due to the padding, we also store the length of the string, as there might be some "garbage" zeroes at the end of the stream.

The following two functions compress the string and the file (``source``) into a compressed file ``target``::

 let compress_string target s = 
   let freqs = compute_freqs s in
   let t = compute_frequency_tree freqs in 
   write_to_binary write_tree_and_data target (t, s)

 let compress_file source target = 
   let s = read_file_to_single_string source in
   compress_string target s

Decompression
-------------

In order to decompress a file, we need to know how to interpret the stream of bits via the Huffman tree. This can be done via the procedure that reads bits as long as there is a tree to walk by, and returns a character once it encounters a leaf::

 let rec read_char_via_tree t input =
   match t with
   | Leaf c -> c
   | Node (l, r) ->
     let b = read_bits input 1 in 
     match b with
     | 0 -> read_char_via_tree l input
     | 1 -> read_char_via_tree r input
     | _ -> raise (Failure "This cannot happen!")

The following function first reads a serialized Huffman tree from the given ``input`` and then uses it to decode the rest of the file::

 let read_encoded input = 
   let t = read_tree input in
   let n = read_bits input 30 in
   let buf = Buffer.create 100 in 
   for i = 0 to n - 1 do
     let ch = read_char_via_tree t input in
     Buffer.add_char buf ch
   done;
   Buffer.contents buf

We can finally put everything together for decompression::

 let decompress_file filename = 
   read_from_binary read_encoded filename

Testing and Running Huffman Compression
---------------------------------------

We can test Huffman compression similarly to previous encoding algorithms::

 let huffman_test s = 
   let filename = "archive.huf" in
   compress_string filename s;
   let s' = decompress_file filename in
   Sys.remove filename;
   s = s'
