.. -*- mode: rst -*-

Priority Queues
===============

Recall our main for studying binary heaps: efficient retrieval of an element with maximal/minimal key in an array, without re-sorting it from scratch between the changes. A data structure that allows for efficient retrieval of an element with the highest/lowest key is called a *priority queue*. In this section, we will design a priority queue based on the implementation of the heaps we already have.

The priority queue will be implemented by a dedicated data type and a number of operations, all residing within the following functor::

  module PriorityQueue(C: CompareAndPrint) = struct 

    (* To be filled *)

  end

A *carrier* of a priority queue (i.e., a container for its elements) will be, of course, an array. Therefore, a priority queue may only hold as many elements as is the size of the array. 

We introduce a small encoding tweak, which will be very helpful for accounting for the fact that the array might be not fully filled, allowing the priority queue to grow (as more elements are added to it) and shrink (as the elements are extracted). Let us add the following definitions into the body of ``PriorityQueue``::


  module COpt = struct
    type t = C.t option
    
    let comp x y = match x, y with 
      | Some a, Some b -> C.comp a b
      | None, Some _ -> -1
      | Some _, None -> 1
      | None, None -> 0
        
    let pp x = match x with 
      | Some x -> C.pp x
      | None -> "None"
  end

  module H = Heaps(COpt)
  (* Do no inline, just include *)
  open H

The module ``COpt`` "lifts" the pretty-printer and the comparator of a given module ``C`` (of signature ``CompareAndPrint``), to the elements of type ``option``. Specifically, if an element is ``None``, it is strictly smaller than any ``Some``-like elements. As you can guess, the ``None`` elements will denote the "empty space" in our priority queue. 


Creating Priority Queues
------------------------

The queue is represented by an OCaml *record* of the following shape (also to be added to the module)::

  type heap = {
    heap_size : int ref;
    arr : H.t array
  }

The records in OCaml are similar to those in C and are simply collections of named values (referred to as record *fields*). Specifically, the record type ``heap`` pairs the carrier array ``arr`` of elements of type ``H.t`` (i.e., ``C.t`` lifted to an option), and the dedicated "heap threshold" ``heap_size`` to determine which part of ``arr`` serves as a heap.

The following two functions allow to create an empty priority queue of a given size, and also turn an array into a priority queue (by effectively building a heap out of it)::

  let mk_empty_queue size = 
    assert (size >= 0);
    {heap_size = ref 0;
     arr = Array.make size None}

  (* Make a priority queue from an array *)
  let mk_queue a = 
    let ls = List.map (fun e -> Some e) (to_list a) in
    let a' = list_to_array ls in
    build_max_heap a';
    {heap_size = ref (Array.length a);
     arr = a'}

Finally, the following construction allows to print out the contents of a priority queue by reusing the functor ``ArrayPrinter`` defined at the beginning of this chapter::

  module P = ArrayPrinter(COpt)

  let print_heap h =     
    P.print_array h.arr

