.. -*- mode: rst -*-

Abstract Data Types
===================


TODO: tell that most of the tasks are about representing sets

TODO: Why do we need them



TODO

An abstract interface for a queue
---------------------------------

An abstract data type for queues is described by the following OCaml
module signature::

 module type Queue = 
   sig
     type 'e t
     val mk_queue : int -> 'e t
     val is_empty : 'e t -> bool
     val is_full : 'e t -> bool
     val enqueue : 'e t -> 'e -> unit
     val dequeue : 'e t -> 'e option
     val queue_to_list : 'e t -> 'e list
   end

