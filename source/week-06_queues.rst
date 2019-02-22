.. -*- mode: rst -*-

Queues
======


The Queue pragmatics
--------------------

TODO

Unlike stacks, in which the elements added the last, come out first
(last-in-first-out, LIFO), *queues* implement a complementary
adding/removal strategy, known as first-in-first-out (FIFO), allowing
to process their elements in the order they come.

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
     let is_empty q = 
       !(q.head) = !(q.tail) &&
       q.elems.(!(q.head)) = None
     let is_full q = 
       !(q.head) = !(q.tail) &&
       q.elems.(!(q.head)) <> None

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

     let queue_to_list q = 
       let hd = !(q.head) in
       let tl = !(q.tail) in
       if is_empty q then [] 
       else if hd < tl then
         List.map get_exn (array_to_list hd (tl + 1) q.elems)
       else 
         let l1 = array_to_list hd q.size q.elems in
         let l2 = array_to_list 0 tl q.elems in
         List.map get_exn (l1 @ l2)

 end

We can pring the content of a queue using the following module::

 module QueuePrinter(Q: Queue) = struct

   let print_queue q pp = 
     Printf.printf "[";
     List.iter (fun e ->
       Printf.printf "%s; " (pp e))
       (Q.queue_to_list q);
     Printf.printf "]\n"
   end

For instance, it can be instantiated as follows for printing queues of
pairs of type ``int * string``::

 module ABQPrinter = QueuePrinter(ArrayBasedQueue)

 let pp (k, v) = Printf.sprintf "(%d, %s)" k v

 let print_queue q = ABQPrinter.print_queue q pp

Let us experiment with the queue::

 # open ArrayBasedQueue;;
 # let q = mk_queue 10;;
 val q : '_weak103 ArrayBasedQueue.t = <abstr>
 # for i = 0 to 9 do enqueue q a.(i) done;;
 - : unit = ()
 # print_queue q;;
 [(7, sapwd); (3, bsxoq); (0, lfckx); (7, nwztj); (5, voeed); (9, jtwrn); (8, zovuq); (4, hgiki); (8, yqnvq); (3, gjmfh); ]
 - : unit = ()
 # a;;
 - : (int * string) array =
 [|(7, "sapwd"); (3, "bsxoq"); (0, "lfckx"); (7, "nwztj"); (5, "voeed");
   (9, "jtwrn"); (8, "zovuq"); (4, "hgiki"); (8, "yqnvq"); (3, "gjmfh")|]
 # is_full q;;
 - : bool = true
 # dequeue q;;
 - : (int * string) option = Some (7, "sapwd")
 # dequeue q;;
 - : (int * string) option = Some (3, "bsxoq")
 # dequeue q;;
 - : (int * string) option = Some (0, "lfckx")
 # print_queue q;;
 [(7, nwztj); (5, voeed); (9, jtwrn); (8, zovuq); (4, hgiki); (8, yqnvq); (3, gjmfh); ]
 - : unit = ()
 # enqueue q (13, "lololo");;
 - : unit = ()
 # print_queue q;;
 [(7, nwztj); (5, voeed); (9, jtwrn); (8, zovuq); (4, hgiki); (8, yqnvq); (3, gjmfh); (13, lololo); ]
 - : unit = ()
 # dequeue q;;
 - : (int * string) option = Some (7, "nwztj")


Double Linked Lists
-------------------

To allow for the queue of an arbitrary size, we will need an auxiliary
data structure, known as double-linked list.

Let us start the definition of a doubly-linked list by defining its
signature::

 module DoubleLinkedList = 
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


Some utility functions::

  let prev n =  !(n.prev)
  let next n =  !(n.next)
  let value n = !(n.value)
  let set_value n v = n.value := v

Inserting new nodes::
  
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

Converting to an OCaml list:: 

    let rec move_to_head n = 
       match prev n with
       | None -> None
       | Some m -> move_to_head m

     let to_list_from n = 
       let res = ref [] in
       let iter = ref (Some n) in
       while !iter <> None do
         let node = (get_exn !iter) in
         res := (value node) :: ! res;
         iter := next node  
       done;
       List.rev !res

Removing an element::

     let remove n = 
       (match prev n with
       | None -> ()
       | Some p -> p.next := next n);
       (match next n with
       | None -> ()
       | Some nxt -> nxt.prev := prev n);



A queue based on double linked lists
------------------------------------

Defining a queue::

 module DLLBasedQueue : Queue = struct
  open DoubleLinkedList
    
    type 'e t = {
      head : 'e dll_node option ref;
      tail : 'e dll_node option ref;
    }

  (* More functions coming here *)

    let mk_queue _sz = 
      {head = ref None; 
       tail = ref None}


 end

Checking if empty of full::

    let is_empty q = 
      !(q.head) = None
      
    let is_full _q = false

Enqueueing an element::

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

Dequeueing an element::

    let dequeue q =
      match !(q.head) with
      | None -> None
      | Some n -> 
        let nxt = next n in
        q.head := nxt;
        remove n; (* This is not necessary *)
        Some (value n)

Convering to list::

    let queue_to_list q = match !(q.head) with
      | None -> []
      | Some n -> to_list_from n


Now, with this definition complete, we can do some experiments. First,
as before, let us define a printer for the contents of the queue::

 module DLQPrinter = QueuePrinter(DLLBasedQueue)

 let pp (k, v) = Printf.sprintf "(%d, %s)" k v

 let print_queue q = DLQPrinter.print_queue q pp

Finally, let us put and remove some elements from the queue::

 # let dq = DLLBasedQueue.mk_queue 0;;
 val dq : '_weak105 DLLBasedQueue.t = <abstr>
 # a;;
 - : (int * string) array =
 [|(7, "sapwd"); (3, "bsxoq"); (0, "lfckx"); (7, "nwztj"); (5, "voeed");
   (9, "jtwrn"); (8, "zovuq"); (4, "hgiki"); (8, "yqnvq"); (3, "gjmfh")|]
 # for i = 0 to 9 do enqueue dq a.(i) done;;
 - : unit = ()
 # print_queue dq;;
 [(7, sapwd); (3, bsxoq); (0, lfckx); (7, nwztj); (5, voeed); (9, jtwrn); (8, zovuq); (4, hgiki); (8, yqnvq); (3, gjmfh); ]
 - : unit = ()
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
 # print_queue dq;;
 [(7, nwztj); (5, voeed); (9, jtwrn); (8, zovuq); (4, hgiki); (8, yqnvq); (3, gjmfh); (13, lololo); ]
 - : unit = ()
