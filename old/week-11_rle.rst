.. -*- mode: rst -*-

.. _week-11-rle:

Run-Length Encoding
===================

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_11_RunLengthEncoding.ml

Run-length encoding is a compression methods that works well with bit-strings with large contiguous segments of repeating 0s and 1s by encoding the lengths of such segments in the interleaved fashion, starting from 0. For instance, the following string::

 0000000000000001111111000000011111111111

Can be encoded via 4 4-bit integer representation as follows::

 1111011101111011

Tis would ben that we have 15 (1111 in binary) 0s, then 7 (0111 in binary) 1s, then 7 0s and finally 11 (0111) ones.  

Design Considerations
---------------------

In order to turn this example into an effective data compression method, we need to answer the following questions:

* How many bits do we use for representing the counts?
* What if we encounter a sequence longer that a maximal value of a counter encoding permits?
* What to do about short runs that under-use the length encoding?

We resolve those questions in the following way

* Counts are between 0 and 255, so we use 8-bit representations.
* We make all run lengths less than 256 by including runs of length 0 if needed
* We encode short runs even though doing so might lengthen the output encoding.

Implementation
--------------

The resulting encoding procedure, which makes use of the previously implemented queue data type, is as follows::

 open Core
 open Extlib.IO
 open Week_06
 open DLLBasedQueue
 open Week_10_BinaryEncodings

 let read_next_bit input = try
     let bit = read_bits input 1 in
     Some bit
   with BatInnerIO.No_more_input -> None

It starts by reading the lengths of contiguous interleaving bit sequences from the file ``input`` to a queue::

 let compute_lengths input =
   let m = 256 in
   let q = mk_queue 100 in
   let rec read_segments acc b = 
     if acc >= m - 1 then begin
       enqueue q acc;
       read_segments 0 (1 - b)
     end
     else match read_next_bit input with
       | Some x -> 
         if x = b 
         then read_segments (acc + 1) b
         else begin
           enqueue q acc;
           read_segments 1 (1 - b)
         end
       | None -> enqueue q acc
   in
   read_segments 0 0;
   queue_to_list q

The obtained list is then used to write the corresponding bytes to the output channel::

 let compress_binary_via_rle binary new_binary = 
   let segments = read_from_binary compute_lengths binary in
   let rec loop out segs = match segs with
     | [] -> ()
     | h :: t -> (write_bits out ~nbits:8 h; 
                  loop out t)
   in
   write_to_binary loop new_binary segments

We leave the implementation of the RLE decoder and the corresponding testing procedure as a homework :ref:`exercise-rle-decoder`.
