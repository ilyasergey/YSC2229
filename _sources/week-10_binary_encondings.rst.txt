.. -*- mode: rst -*-

.. _week-10-binary:

Binary Encoding of Data
=======================

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_10_BinaryEncodings.ml

As discussed in the previous section, there is no big difference between text and binary files, as all of those are represented similarly by sequences of bits, with the former being given a special treatment in the case if an operational system identifies them following a certain encoding pattern.

Let us now learn how to work with binary data (i.e., reading/writing the corresponding files) in OCaml. We will largely rely on the library ``Extlib.IO`` that comes as a part of the ``batteries`` package::

 open Core
 open Extlib.IO

The standard terminology for writing/reading data to/from its binary representation is to *serialize*/*deserialize* it.

Writing and Reading Binary Files
--------------------------------

Standard OCaml library does not provide means to work with binary data explicitly: with standard functions one can read/write sequences of bits that are multipliers of 8 (i.e., bytes etc), but not individual bits. The functions ``output_bits`` and ``input_bits`` from ``Extlib.IO`` provide this possibility by giving "wrappers" around standard input/output channels for manipulating with files.

The following function, implemented by us, uses ``input_bits`` to read bits from a file ``filename`` and process them via the client-provided function ``deseiralize``::

 let read_from_binary deserialize filename =  
   In_channel.with_file ~binary:true filename 
     ~f:(fun file_input ->
         let bits_input = input_bits @@ input_channel file_input in
         deserialize bits_input)
 
Writing bits to a file is almost as straightforward and is done with the help of the following function that makes use of the ``output_bits`` wrapper::

 let write_to_binary serialize filename data = 
   Out_channel.with_file filename ~append:false ~binary:true ~f:(fun file ->
       let bits_output = output_bits @@ output_channel file ~cleanup:true in
       serialize bits_output data;
       (* Padding from the end -- important! *)
       flush_bits bits_output)

Notice the last statement ``flush_bits bits_output``. What it does is to add "missing" bits (as zeroes) to the binary file so its length (in bits) would be divisible by 8. If this is not done, then reading such a file might result in an error. The procedure ``write_to_binary`` takes as arguments, the function ``serialize`` that handles the data to be written to an output file , the ``filename`` of the file and the ``data`` itself. 

Writing and Reading OCaml Strings
---------------------------------

Let us now use the binary-manipulating machinery to read/write OCaml strings as if they were just sequences of bits.

Writing is done via the following function::

 let write_string_to_binary filename text = 
   let serialize out text = 
     let size = String.length text in
     for i = 0 to size - 1 do
       let ch = int_of_char text.[i] in      
       write_bits out ~nbits:8 ch;
     done
   in
   write_to_binary serialize filename text

The implementation above has a couple of interesting aspects. First, it treats a string as an array of characters that it converts to integers (``int_of_char text.[i]``). Second, it writes those integers as bits (i.e., 8-bit sequence) into the output file ``out`` (``write_bits out ~nbits:8 ch``). Since OCaml uses 32 bits to represent integers, such a truncation to 8 bits could be unsafe, but we know that our integers are converted from ``char`` and hence range at ``0-255``.

The resulting file thus contains a sequence of bytes precisely encoding the string. 

Reading is done similarly::

 let read_string_from_binary filename =  
   let deserialize input = 
     let buffer = Buffer.create 1 in
     (try
        while true do
          let bits = read_bits input 8 in
          let ch = char_of_int bits in   
          Buffer.add_char buffer ch
        done;
      with BatInnerIO.No_more_input -> ());
     Buffer.contents buffer    
   in
   read_from_binary deserialize filename

For an arbitrary file, we don't know what is the length of the string it has. Therefore, we just keep adding byte-encoded characters to a buffer in a ``while true`` loop, until we hit the end file (each invocation of ``read_bits`` advances our reading "position" in the file, ultimately reaching the end). Once it happens an exception ``BatInnerIO.No_more_input`` is raised, which we can catch and  return the result accumulated in the buffer.

We can also test that our serialization is implemented correctly::

 let string_serialization_test s = 
   let filename = "text.tmp" in
   write_string_to_binary filename s;
   let s' = read_string_from_binary filename in
   Sys.remove filename;
   s = s'

Compressing DNA Sequences
-------------------------

There is no gain in reading strings in binary, as we use the same format for representing them as plain OCaml. 

Some domains, however, have data, which, which would be too wasteful to represent as strings. Realising this gives an initial idea of implementing *data compression* --- exploiting properties of data to find more compact representation of it as a bit-string.

A good example of data that can be efficiently represented are `DNA sequences <https://en.wikipedia.org/wiki/DNA>`_. The sequences are very long strings of only four characters: 

* A (Adenosine)
* G (Guanine)
* C (Cytosine)
* T (Thymidine)

Therefore, a typical sequences look as follows::

 let dna_string1 = "CGT"
 let dna_string2 = "ATAGATGCATAGCGCATAGCTAGATAGTGCTAG"
 let dna_string3 = "ATAGATGCATAGCGCATAGCTAGATAGTGCTAGCGATGCATAGCGCAGATGCATAGCGCAGGGGG"
 let dna_string4 = "ATAGATGCATAGCGCATAGCTAGATAGTGCTAGCGATGCATAGCGCAGATGCATAGCGCAGGGGGATAGATGCATAGCGCATAGCTAGATAGTGCTAGCGATGCATAGCGCAGATGCATAGCGCAGGGGGATAGATGCATAGCGCATAGCTAGATAGTGCTAGCGATGCATAGCGCAGATGCATAGCGCAGGGGGATAGATGCATAGCGCATAGCTAGATAGTGCTAGCGATGCATAGCGCAGATGCATAGCGCAGGGGGATAGATGCATAGCGCATAGCTAGATAGTGCTAGCGATGCATAGCGCAGATGCATAGCGCAGGGGGATAGATGCATAGCGCATAGCTAGATAGTGCTAGCGATGCATAGCGCAGATGCATAGCGCAGGGGG"

Since there are only 4 characters in DNA strings, we don't need 8 bits to encode them --- just two bits would do::

 let dna_encoding_size = 2

We can the implement the encoding from DNA characters to 2-bit integers and vice verse::

 let dna_encoder = function
   | 'A' -> 0
   | 'C' -> 1
   | 'G' -> 2
   | 'T' -> 3
   | _ -> raise (Failure "DNA encoding error")

 let dna_decoder = function
   | 0 -> 'A'
   | 1 -> 'C'
   | 2 -> 'G'
   | 3 -> 'T'
   | _ -> raise (Failure "DNA decoding error")

Let us not implement the binary serializers/deserializers for DNA data using this format. This can be accomplished using the general binary-manipulating primitives defined above.

The writing procedure starts by putting a *header* to the bit file of size 30 (the largest size of a bit-sequence supported by ``Extlib.IO``), which is a serialised integer indicating the length of the following sequence of 2-bit encoded DNA characters. We did not need to put this information for 8-bit strings, but need it here because of the file padding via ``flush_bits``::

 let write_dna_to_binary filename text = 
   let serialize out text = 
     let size = String.length text in
     write_bits out ~nbits:30 size;
     for i = 0 to size - 1 do
       let ch = dna_encoder text.[i] in
       write_bits out ~nbits:dna_encoding_size ch;
     done
   in
   write_to_binary serialize filename text

The deserializer proceeds by first retrieving the header and learning the length of the stream of 2-bit characters, and then using this information to read the DNA string into a buffer and return it is OCaml string::

 let read_string_from_binary filename =  
   let deserialize input = 
     let buffer = Buffer.create 1 in
     (try
        while true do
          let bits = read_bits input 8 in
          let ch = char_of_int bits in   
          Buffer.add_char buffer ch
        done;
      with BatInnerIO.No_more_input -> ());
     Buffer.contents buffer    
   in
   read_from_binary deserialize filename

We can now test our compression/decompression procedure for DNAs::

 let dna_compression_test d = 
   let filename = "dna.tmp" in
   write_dna_to_binary filename d;
   let d' = read_dna_from_binary filename in
   Sys.remove filename;
   d = d'

**Question:** How can we see if the compression is beneficial?
