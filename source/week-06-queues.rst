.. -*- mode: rst -*-

.. _sec_queues:

Queues
======

Unlike stacks, in which the elements added the last, come out first (last-in-first-out, LIFO), *queues* implement a complementary adding/removal strategy, known as *first-in-first-out* (FIFO), allowing to process their elements in the order they come.

The Queue interface
-------------------

We can define an abstract data type for queues by means the following OCaml module signature::

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

Indeed, one is at freedom to decide which functionality should be added to an ADT interface --- a point we demonstrate by making the queue signature a bit more expressive, in terms of functionality it provides, than a stack interface. 

As in the example of stacks, a queue of elements of type ``'e`` is represented by an abstract parameterised type ``'e t``. Two methods, ``is_empty`` and ``is_full`` allow one to check whether it's empty or full, correspondingly. ``enqueue`` and ``dequeue`` provide the main FIFO functionality of the queue: the former adds elements to the "back" of the queue object, while the latter removes elements from its "front". Finally, the utility method ``queue_to_list`` transforms a current snapshot of the queue to an immutable OCaml list.

Similarly, to the stack ADT, queues defined by means of the ``Queue`` signature are mutable, i.e., functions ``enqueue`` and ``dequeue`` modify the contents of a queue in-place rather than create a new queue.

An Array-Based Queue
--------------------

The following module implements a queue based on a finite-size array::

 module ArrayBasedQueue : Queue =
   struct
     type 'e t = {
       elems : 'e option array;
       head : int ref;
       tail : int ref;
       size : int    
     }
     let mk_queue sz = {
       elems = Array.make sz None;
       head = ref 0;
       tail = ref 0;
       size = sz
     }

     (* More functions come here *)

 end

Since a queue, unlike stack, can be changed on both sides, "front" and "back", the empty slots may appear both in the beginning and at the end of its carrier array.  In order to utilise the array efficiently, we will engineer our concrete implementation, so it would "wrap" around and use the empty array cells in the beginning. 

In our representation the ``head`` pointer points to the next element to be removed via ``dequeue``, while ``tail`` points to the next array cell to install an element (unless the queue is full). This implementation requires some care in managing the head/tail references. For instance, both empty and fully packed queue are characterised by head and tail pointing to the same array cell::

     let is_empty q = 
       !(q.head) = !(q.tail) &&
       q.elems.(!(q.head)) = None

     let is_full q = 
       !(q.head) = !(q.tail) &&
       q.elems.(!(q.head)) <> None

The only difference is that in the case of the queue being full that cell, at which both head and tail point is occupied some element (and, hence, is not ``None``), whereas it is ``None`` if the queue is empty.

Adding and removing elements to/from the queue is implemented in a way that takes the "wrapping" around logic into the account. For instance, ``enqueue`` checks whether the queue is full and whether the ``tail`` reference has reached the end of the array. In case if it has, but the queue still has slots to add elements, it "wraps around" by setting ``tail`` to be 0 (i.e., point to the beginning of the array)::

     let enqueue q e = 
       if is_full q
       then raise (Failure "The queue is full!")
       else (
         let tl = !(q.tail) in
         q.elems.(tl) <- Some e;
         q.tail := 
           if tl = q.size - 1 
           then 0 
           else tl + 1)

Similarly, ``dequeue`` operates with the head pointer, wrapping it around in the case when it reaches the upper boundary of the array, but the queue is not yet empty::

     let dequeue q = 
       if is_empty q
       then None
       else (
         let hd = !(q.head) in
         let res = q.elems.(hd) in
         q.elems.(hd) <- None; 
         q.head := 
           (if hd = q.size - 1 
           then 0 
           else hd + 1);
         res)

Finally, ``queue_to_list`` constructs the queue by considering two possibilities:

* head reference points to the array slot less or equal than that of the tail reference, in which case it returns a sub-array enclosed between the two, and,

* head reference points to the array slot greater than that of the tail reference, in which case it returns a concatenation of two sub-arrays, from the end and the beginning of the carrier array::

     let queue_to_list q = 
       let hd = !(q.head) in
       let tl = !(q.tail) in
       if is_empty q then [] 
       else if hd < tl then
         List.map get_exn (subarray_to_list hd (tl + 1) q.elems)
       else 
         let l1 = subarray_to_list hd q.size q.elems in
         let l2 = subarray_to_list 0 tl q.elems in
         List.map get_exn (l1 @ l2)

Debugging queue implementations
-------------------------------

We can pring the content of a queue using the following module::

 module QueuePrinter(Q: Queue) = struct

   let print_queue q pp = 
     Printf.printf "[";
     List.iter (fun e ->
       Printf.printf "%s; " (pp e))
       (Q.queue_to_list q);
     Printf.printf "]\n"
   end

For instance, it can be instantiated as follows for printing queues of pairs of type ``int * string``::

 module ABQPrinter = QueuePrinter(ArrayBasedQueue)

 let pp (k, v) = Printf.sprintf "(%d, %s)" k v

 let print_kv_queue q = ABQPrinter.print_kv_queue q pp

Let us experiment with the queue by first creating it::

 # open ArrayBasedQueue;;
 # let q = mk_queue 10;;
 val q : '_weak103 ArrayBasedQueue.t = <abstr>

We can then fill a queue from a randomly generater array ``a``::

 # let a = generate_key_value_array 10
 # a;;
 - : (int * string) array =
 [|(7, "sapwd"); (3, "bsxoq"); (0, "lfckx"); (7, "nwztj"); (5, "voeed");
   (9, "jtwrn"); (8, "zovuq"); (4, "hgiki"); (8, "yqnvq"); (3, "gjmfh")|]
 # for i = 0 to 9 do enqueue q a.(i) done;;
 - : unit = ()
 # print_kv_queue q;;
 [(7, sapwd); (3, bsxoq); (0, lfckx); (7, nwztj); (5, voeed); (9, jtwrn); (8, zovuq); (4, hgiki); (8, yqnvq); (3, gjmfh); ]
 - : unit = ()
 # is_full q;;
 - : bool = true

We can then start removing elements from the queue, checking that they come out in the same order as elements in the original array::

 # dequeue q;;
 - : (int * string) option = Some (7, "sapwd")
 # dequeue q;;
 - : (int * string) option = Some (3, "bsxoq")
 # dequeue q;;
 - : (int * string) option = Some (0, "lfckx")
 # print_kv_queue q;;
 [(7, nwztj); (5, voeed); (9, jtwrn); (8, zovuq); (4, hgiki); (8, yqnvq); (3, gjmfh); ]
 - : unit = ()
 # enqueue q (13, "lololo");;
 - : unit = ()
 # print_kv_queue q;;
 [(7, nwztj); (5, voeed); (9, jtwrn); (8, zovuq); (4, hgiki); (8, yqnvq); (3, gjmfh); (13, lololo); ]
 - : unit = ()
 # dequeue q;;
 - : (int * string) option = Some (7, "nwztj")

Doubly Linked Lists
-------------------

* File: ``DoubleLinkedList.ml``

The obvious limitation of an array-based queue is its limited
capacity, bounded by the size of the carrier array. To allow for the
queue of an arbitrary size, we will need an auxiliary data structure,
known as *doubly-linked list*.

A doubly-linked list is one of the most characteristic linked data
structures, which aggressively employs OCaml's references as its main
building component, and can be efficiently implemented in other
imperative programming languages, such as C and Java. As they embrace
mutability, doubly-linked lists provide a variety of ways to modify
their contents and structure by simply manipulating with the
references and exploiting the indirection in data structure encoding.

Let us start the definition of a concrete module implementing the doubly-linked list data structure by defining its key components::

 module DoublyLinkedList = 
   struct
     type 'e dll_node = {
       value : 'e ref;
       prev  : 'e dll_node option ref;
       next  : 'e dll_node option ref
     }
     type 'e t = 'e dll_node option

     let mk_node e = {
       value = ref e;
       prev = ref None;
       next = ref None
     }
     
     (* More of implementation comes here *)
   end 

The "elements" of doubly linked list (DLL) are represented by the ``'e dll_node`` record type, which accounts for the possibility of them storing arbitrary data of type ``'e`` as "payload". In addition to payload, each node has references to other nodes, namely the "previous" and the "next" one in the list. As a node might not have a previous or a next one, and the predecessor/successor might change over time, the type of those fields is ``'e dll_node option ref`` (a reference to an option containing a node of element of type ``'e``).

The function ``mk_node e`` creates a new "detached" node that contains an payload ``e``, and has no designated predecessor/successor.  Some other utility functions, allowing to refer to elements of a node, as well as to change a node's payload, are as follows::

  let prev n =  !(n.prev)
  let next n =  !(n.next)
  let value n = !(n.value)
  let set_value n v = n.value := v

How do we construct a list out of those disparate nodes? The following
two functions allow to *insert* new nodes before and after some other
existing nodes, thus, updating the linked structure::
  
     let insert_after n1 n2 = 
       let n3 = next n1 in
       (match n3 with 
        | Some n -> n.prev := Some n2
        | _ -> ());
       n2.next := n3;
       n1.next := Some n2;
       n2.prev := Some n1

     let insert_before n1 n2 = 
       let n0 = prev n2 in
       (match n0 with 
        | Some n -> n.next := Some n1
        | _ -> ());
       n1.prev := n0;
       n1.next := Some n2;
       n2.prev := Some n1

Specifically the function ``insert_after n1 n2`` inserts a node ``n2`` after a node ``n1``, "re-wiring" their both's references to a predecessor/successor. Similarly, ``insert_before n1 n2`` inserts ``n1`` before ``n2``. Using these two functions, one can update the structure of the list by inserting nodes in the middle of it (in contrast OCaml's immutable lists only allow to insert/remove nodes at the head).

.. admonition:: Warning

  Both functions ``insert_after`` and ``insert_before`` make some implicit assumptions about the topology of the nodes, i.e., the set-up of the links. Specifically, when using ``insert_before n1 n2``, one is assumed to be sure that ``n2`` is not yet transitively reachable from ``n1``, otherwise the resulting list might become circular. The same applies to ``insert_before n1 n2``.

In a similar spirit, we can removing an arbitrary node from a DLL in :math:`O(1)` time --- something that would be impossible in an OCaml list (as it would require its traversal)::

     let remove n = 
       (match prev n with
       | None -> ()
       | Some p -> p.next := next n);
       (match next n with
       | None -> ()
       | Some nxt -> nxt.prev := prev n);

Given an arbitrary node of a DLL, we can now "walk" forward/backwards by its predecessors/successors, in order to reach both ends of the list::

    let rec move_to_head n = 
       match prev n with
       | None -> None
       | Some m -> move_to_head m

We can use a similar walking logic to conver the "tail" of a double linked list to an ordinary OCaml list by walking by the successors::

     let to_list_from n = 
       let res = ref [] in
       let iter = ref (Some n) in
       while !iter <> None do
         let node = (get_exn !iter) in
         res := (value node) :: ! res;
         iter := next node  
       done;
       List.rev !res

A queue based on doubly linked lists
------------------------------------

* File: ``Queues.ml`` (continued)

Let us now put doubly-linked lists to some good use and implement a
queue that can grow arbitrarily large (or, at least, as large as one's
computer memory permits)::

 module DLLBasedQueue : Queue = struct
  open DoublyLinkedList
    
    type 'e t = {
      head : 'e dll_node option ref;
      tail : 'e dll_node option ref;
    }

    let mk_queue _sz = 
      {head = ref None; 
       tail = ref None}

    (*  More functions coming here *)

 end

The queue is defined by means of holding two mutable references to
(optional) nodes of a doubly-linked list, representing the head and
the tail of the queue. The ``option`` accounts for the fact that the
queue might be empty, which is the case for a freshly created instance
(vai ``mk_queue _``).

The emptyness of the queue can be checked by examining its head, and
the ``is_full`` check now always returns ``false``, as the queue may
grow infinitely::

    let is_empty q = 
      !(q.head) = None
      
    let is_full _q = false

Enqueueing an element is implemented by means of creating a new node and inserting it behind the tail (if it exists). Since ``mk_node`` always returns a new node, there is no risc of creating a circular DLL::

    let enqueue q e = 
      let n = mk_node e in
      (* Set the head *)
      (if !(q.head) = None
       then q.head := Some n);
      (* Extend the tail *)
      (match !(q.tail) with
       | Some t -> insert_after t n;
       | None -> ());
      q.tail := Some n 

Dequeueing an element simply returns the payload of the node pointed to by ``head`` and moves the references to its successor::

    let dequeue q =
      match !(q.head) with
      | None -> None
      | Some n -> 
        let nxt = next n in
        q.head := nxt;
        remove n; (* This is not necessary, but helps GC *)
        Some (value n)

The removal of an node ``n`` on the penultimate line of ``dequeue`` is
not necessary for the correctness of the data structure, but it helps
to save the memory. To understand why it is essential, we need to know
a bit about how *Tracing* `Garbage Collector
<https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)>`_
works in OCaml. While the garbage collection and automated memory
management are outside of the scope of this course, let us just notice
that not removing the node will make OCaml runtime treat it as being
in use (as it is *reachable* from its successor), and hence keep it in
memory, which could be otherwise used for something else.

A conversion to list is almost trivial, given the functionality of a doubly-linked list::

    let queue_to_list q = match !(q.head) with
      | None -> []
      | Some n -> to_list_from n


Now, with this definition complete, we can do some experiments. First, as before, let us define a printer for the contents of the queue::

 module DLQPrinter = QueuePrinter(DLLBasedQueue)

 let pp (k, v) = Printf.sprintf "(%d, %s)" k v

 let print_kv_queue q = DLQPrinter.print_kv_queue q pp

Finally, let us put and remove some elements from the queue::

 # let dq = DLLBasedQueue.mk_queue 0;;
 val dq : '_weak105 DLLBasedQueue.t = <abstr>
 # a;;
 - : (int * string) array =
 [|(7, "sapwd"); (3, "bsxoq"); (0, "lfckx"); (7, "nwztj"); (5, "voeed");
   (9, "jtwrn"); (8, "zovuq"); (4, "hgiki"); (8, "yqnvq"); (3, "gjmfh")|]

Similarly to previous examples, we will up the queue from a randomly
generated array::

 # for i = 0 to 9 do enqueue dq a.(i) done;;
 - : unit = ()
 # print_kv_queue dq;;
 [(7, sapwd); (3, bsxoq); (0, lfckx); (7, nwztj); (5, voeed); (9, jtwrn); (8, zovuq); (4, hgiki); (8, yqnvq); (3, gjmfh); ]
 - : unit = ()

We can then ensure that the elements come out in the order they were
added::

 # is_empty dq;;
 - : bool = false
 # dequeue dq;;
 - : (int * string) option = Some (7, "sapwd")
 # dequeue dq;;
 - : (int * string) option = Some (3, "bsxoq")
 # dequeue dq;;
 - : (int * string) option = Some (0, "lfckx")
 # enqueue dq (13, "lololo");;
 - : unit = ()
 # print_kv_queue dq;;
 [(7, nwztj); (5, voeed); (9, jtwrn); (8, zovuq); (4, hgiki); (8, yqnvq); (3, gjmfh); (13, lololo); ]
 - : unit = ()
