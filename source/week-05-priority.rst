.. -*- mode: rst -*-

.. _priority_queues:

Priority Queues
===============

* File: ``PriorityQueue.ml``

Recall our main for studying binary heaps: efficient retrieval of an
element with maximal/minimal key in an array, without re-sorting it
from scratch between the changes. A data structure that allows for
efficient retrieval of an element with the highest/lowest key is
called a *priority queue*. In this section, we will design a priority
queue based on the implementation of the heaps we already have.

The priority queue will be implemented by a dedicated data type and a
number of operations, all residing within the following functor::

  module PriorityQueue(C: CompareAndPrint) = struct 

    (* To be filled *)

  end

A *carrier* of a priority queue (i.e., a container for its elements)
will be, of course, an array. Therefore, a priority queue may only
hold as many elements as is the size of the array.

We introduce a small encoding tweak, which will be very helpful for
accounting for the fact that the array might be not fully filled,
allowing the priority queue to grow (as more elements are added to it)
and shrink (as the elements are extracted). Let us add the following
definitions into the body of ``PriorityQueue``::


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

The module ``COpt`` "lifts" the pretty-printer and the comparator of a
given module ``C`` (of signature ``CompareAndPrint``), to the elements
of type ``option``. Specifically, if an element is ``None``, it is
strictly smaller than any ``Some``-like elements. As you can guess,
the ``None`` elements will denote the "empty space" in our priority
queue.


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

.. _sec-pq-impl:

Operations on Priority Queues
-----------------------------

The first and the simplest operation on a priority queue ``h`` is to take its highest-ranked element (i.e., the one with the greatest priority, expressed by means of its key value)::

  let heap_maximum h = (h.arr).(0)

The next operation allows not just look at, but also extract (i.e., obtain and remove) the maximal element from the priority queue::

  let heap_extract_max h = 
    if !(h.heap_size) < 1 then None
    else
      let a = h.arr in
      let max = a.(0) in
      a.(0) <- a.(!(h.heap_size) - 1);
      a.(!(h.heap_size) - 1) <- None;
      h.heap_size := !(h.heap_size) - 1;
      max_heapify !(h.heap_size) h.arr 0;
      max

The way ``heap_extract_max`` works for a non-empty heap is by taking its maximal element, and then putting one of the smallest elements (``a.(!(h.heap_size) - 1)``) to its place, reducing the heap size and restoring the heap shape via already familiar procedure ``max_heapify`` applied to the first element in the array (which is the only heap offender after swapping). 

The following auxiliary function ``heap_increase_key`` is somewhat dual to ``max_heapify``. It inserts an element ``key`` into a position ``i``, assuming that its key is larger than what's currently at that position. It then restores the heap property (which might be broken if the parents in the chain are smaller) by "walking up" the chain of parents and performing swaps until the correct order is restored::

  let heap_increase_key h i key =
    let a = h.arr in
    let c = comp key (a.(i)) >= 0 in
    if not c then (
      Printf.printf "A new key is smaller than current key!";
      assert false);
    a.(i) <- key;
    let j = ref i in
    while !j > 0 && comp (snd (H.parent a (!j))) a.(!j) < 0 do
      let pj = fst (H.parent a (!j)) in
      swap a !j pj;
      j := pj
    done

**Question:** What is the complexity of ``heap_increase_key``?

Finally, the function ``max_heap_insert`` implements an insertion of a
new element ``elem`` into a priority heap ``h``::

  let max_heap_insert h elem = 
    let hs = !(h.heap_size) in
    if hs >= Array.length h.arr 
    then raise (Failure "Maximal heap capacity reached!");
    h.heap_size := hs + 1;
    heap_increase_key h hs (Some elem)

It only succeeds in the case if there is still vacant space in the
queue (i.e., at the end of the array), which can be determined by
examining the ``heap_size`` field of ``h``. If the space permits, the
limit ``heap_size`` is increased. Since we know that ``None`` used to
be installed to the vacant place (which is an invariant maintained by
means of ``heap_size``), we can simply install the new element ``Some
elem`` (which is guaranteed to be larger than ``None`` as per our
defined comparator) and let the heap rebalance using
``heap_increase_key``.

Given the complexity of ``max_heap_insert``, it is easy to show that
the complexity of element insertion is :math:`O(\log n)`. This brings
us to an important property of priority queues implemented by means of
heaps:

.. admonition:: Complexity of priority queue operations

  For a priority queue of size :math:`n`,

  * Finding the largest element has complexity :math:`O(1)`,
  * Extraction of the largest element has complexity :math:`O(\log n)`,
  * Insertion of a new element has complexity :math:`O(\log n)`.

Working with Priority Queues
----------------------------

Let us see a priority queue in action. We start by creating it from a randomly generated array::

  module PQ = PriorityQueue(KV)
  open PQ
  
  let q = mk_queue (
   [|(6, "egkbs"); (4, "nugab"); (4, "xcwjg");
     (4, "oxfyr"); (4, "opdhq"); (0, "huiuv");
     (0, "sbcnl"); (2, "gzpyp"); (4, "hymnz");
     (2, "yxzro")|]);;

Let us see what's inside::

 # q;;
 - : PQ.heap =
 {heap_size = {contents = 10};
  arr =
   [|Some (6, "egkbs"); Some (4, "nugab"); Some (4, "xcwjg");
     Some (4, "oxfyr"); Some (4, "opdhq"); Some (0, "huiuv");
     Some (0, "sbcnl"); Some (2, "gzpyp"); Some (4, "hymnz");
     Some (2, "yxzro")|]}

We can proceed by checking the maximum::

 # heap_maximum q;;
 - : PQ.H.t = Some (6, "egkbs")
 
 (* It is indeed a heap! *)
 #  PQ.H.is_heap q.arr;; 
 - : bool = true

Let us extract several maximum elements::

 # heap_extract_max q;;
 - : PQ.H.t option = Some (6, "egkbs")
 # heap_extract_max q;;
 - : PQ.H.t option = Some (4, "nugab")
 # heap_extract_max q;;
 - : PQ.H.t option = Some (4, "oxfyr")
 # heap_extract_max q;;
 - : PQ.H.t option = Some (4, "hymnz")

Is it still a heap?::

 # q;;
 - : PQ.heap =
 {heap_size = {contents = 6};
  arr =
   [|Some (4, "opdhq"); Some (2, "yxzro"); Some (4, "xcwjg");
     Some (0, "sbcnl"); Some (2, "gzpyp"); Some (0, "huiuv"); 
     None; None; None; None|]}
 #  PQ.H.is_heap q.arr;;
 - : bool = true

Finally, let us insert a new element and check whether it is still a heap::

 # max_heap_insert q (7, "abcde");;
 - : unit = ()
 # q;;
 - : PQ.heap =
 {heap_size = {contents = 7};
  arr =
   [|Some (7, "abcde"); Some (2, "yxzro"); Some (4, "opdhq");
     Some (0, "sbcnl"); Some (2, "gzpyp"); Some (0, "huiuv");
     Some (4, "xcwjg"); None; None; None|]}
 # heap_maximum q;;
 - : PQ.H.t = Some (7, "abcde")
