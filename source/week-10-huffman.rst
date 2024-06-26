.. -*- mode: rst -*-

.. _week-10-huffman:

Huffman Encoding
================

File: ``HuffmanCodes.ml``

All the compression algorithms we explored so far did not really exploit any specifics of the file they are working on in order to adapt the compression scheme itself. 

The idea of `Huffman coding <https://en.wikipedia.org/wiki/Huffman_coding>`_ (named after its inventor David A. Huffman) is to encode a text by assigning longer bit sequences to more rare characters in it, while giving shorter codes (bit sequences) to more frequent characters. It builds on several simple but powerful ideas, which we will consider further below:

* Huffman tree of characters
* Character frequency analysis

Assigning Codes via Character Trees
-----------------------------------

Huffman tree is a binary tree that has characters in its leaves. It gives a simple way to assign `unique` binary codes (bit sequences) to individual characters by following paths in the tree. The key characterising of a Huffman tree is that **no** code for any character is a prefix of a code of another character. This makes it possible to use the tree for both encoding and decoding without any overhead from under-used encodings (as was the case with RLE).

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

 open BinaryEncodings

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
   let ftrees = Array.make n (Leaf 'a', 1) in
   for i = 0 to n - 1 do
     let (c, f) = freq_chars.(i) in
     ftrees.(i) <- (Leaf c, f)
   done;
   ftrees
 
To build the tree from those leaves, we are going to use a familiar structure min-priority queue. It can be defined by instantiating a functor from Chapter :ref:`priority_queues` with the following comparator::

 module CF = struct
   type t = char tree * int
   let comp x y = 
     if snd x < snd y then 1
     else if snd x > snd y then -1
     else 0
   let pp (_, f) = Printf.sprintf "[tree -> %d]" f
 end

 open PriorityQueue
 module PQ = PriorityQueue(CF)

The final tree is computed as follows. Having ``n`` leaves, we iterate
for ``n - 2`` times, each time extracting the trees with the minimal
cumulative frequency. Having those, we "merge" them by allocating a
node, assigning the cumulative frequency to it, and insert it back to
the priority queue. Having done that ``n - 2`` times, we will have
only one node left in the queue, corresponding to the root of the tree::

 let compute_frequency_tree freq_chars = 
   let open PQ in
   let open Util in
   let n = Array.length freq_chars in
   let ftrees = make_tree_array freq_chars in
   let q = mk_queue ftrees in
   for i = 0 to n - 2 do
     let (x, fx) = get_exn @@ heap_extract_max q in
     let (y, fy) = get_exn @@ heap_extract_max q in
     let n = (Node (x, y), fx + fy) in
     max_heap_insert q n
   done;
   fst @@ get_exn @@ heap_extract_max q

We can now test our implementation::

 let%test _ =
   let t = compute_frequency_tree cfreqs1 in
   test_tree_serialization t

Computing Relative Frequencies
------------------------------

For large texts, we can assume that any ASCII character occurs there, hence we can allocate a 256-slot array and fill it with frequencies by traversing the string::

 let compute_freqs s = 
   let n = String.length s in
   let m = 256 in
   let freqs = Array.make m 0 in
   for i = 0 to n - 1 do
     let i = int_of_char s.[i] in
     freqs.(i) <- freqs.(i) + 1
   done;
   let cfreqs = Array.make m ('a', 0) in
   for i = 0 to m - 1 do
     cfreqs.(i) <- (char_of_int i, freqs.(i))
   done;
   cfreqs

Encoding and Writing the Compressed Text
----------------------------------------

Having a tree, we can produce a table of Huffman codes by traversing it recursively, filling up a table of 256 characters::

 let build_table t = 
   let m = 256 in
   let table = Array.make m [] in 

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
     List.iter (fun bit ->
         write_bits out ~nbits:1 bit) bits
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

The developed compression/decompression algorithms are so useful that we should deliver them as standalone runnable programs:

* File ``runners/compress_test.ml``
* File ``runners/decompress_text.ml``

The following implementation from ``compress_text.ml`` defines the runnable that executes Huffman compression on a given file (first runtime argument) and outputs the result into a file named as a second argument::

 open Printf
 open HuffmanCodes
 open ArrayUtil

 let () =
   if Array.length (Sys.argv) < 3 
   then begin
     print_endline "No input or output file name provided!";
     print_endline "Format: compress input_file archive_name"
   end
   else begin
     let input = Sys.argv.(1) in   
     let archive = Sys.argv.(2) in 
     print_endline "Compressing...";
     time (compress_file input) archive;
     print_endline "Compression complete."   
   end

Once compiled, let us try to run it on some large text, such as `Leo Tolstoy's "War and Peace" <https://en.wikipedia.org/wiki/War_and_Peace>`_ taken from `Project Gutenberg <https://en.wikipedia.org/wiki/Project_Gutenberg>`_ (located in the ``resources`` folder of the project)::

 > bin/compress resources/war-and-peace.txt resources/war-and-peace.huf
 Compressing...
 Execution elapsed time: 0.171870 sec
 Compression complete.
  
As the result, as file ``war-and-piece.huf`` has been produced under ``resources``. Let us compare the sizes of the compressed and the original::

 1901334 war-and-peace.huf
 3293490 war-and-peace.txt

That is the compression rate is 1901334 / 3293490 = 58%.

The original file can be obtained by running, e.g.:: 

 bin/decompress resources/war-and-peace.huf resources/war-and-peace-copy.txt

It is easy to check (via ``md5`` of ``cksum``) that ``war-and-peace-copy.txt`` is identical to ``war-and-peace.txt``
