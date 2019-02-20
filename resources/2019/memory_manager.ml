(* Introduction to Data Structures and Algorithms (YSC2229), Sem2, 2018-2019 *)
(* Ilya Sergey <ilya.sergey@yale-nus.edu.sg> *)
(* Version of Wed 20 Feb 2019 *)


(*

The signature of the allocator module.

Implement a concrete module that instantiates it and use this
   signature to provide it an interface for the clients to use.

* N.B.: The "heap" structure should internally keep track of "free"
   memory segments; you can use an OCaml list (or lists) of for
   tracking free slots in "memory" arrays.

* N.B.: All interaction with the heap goes through the signature of
   the Allocator module.

* N.B.: Ordinary pointers can be implemented as integers (athough the
   clients of the module may not know it).

* N.B.: You will have to figure out how to "dispatch" pointers when
   they are dereferenced (via deref_as_* functions). That is you will
   have to determine whether a given pointer p points to another
   pointer, integer, or a string in order to chose the correct array.
   Devise a discipline to discriminate the pointers into those three
   catergories based on their value.

**)

module type Allocator = sig
  (* An abstract type for dynamic storage                                          *)
  type heap
  (* An abstract type for the pointer (address in the dynamic storage)             *)
  type ptr

  (* Create a new heap.                                                            *)
  val make_heap : unit -> heap

  (* Returns the "null" pointer. Noting can be assigned to it.                     *)
  val null : heap -> ptr
  val is_null : heap -> ptr -> bool

  (***                       Operations with pointers                            ***)
  (* All should throw exceptions for if the pointer is_null                        *)  

  (* Allocating a contiguous segment of dynamically-typed pointers in a heap.      *)
  (* Throws an specific "Out-Of-Memory" error if no allocation is possible.        *)
  val alloc : heap -> int -> ptr
  (* Frees the space in heap taken by the pointer.                                 *)
  val free : heap -> ptr -> int -> unit

  (* Dereferencing a pointer with an offset [0 .. n] obtainin a value it points to *)

  (* Dereference as an pointer, throw an exception if the target is not an pointer *)  
  val deref_as_ptr : heap -> ptr -> ptr
  (* Dereference as an integer, throw an exception if the target is not an integer *)  
  val deref_as_int : heap -> ptr -> int
  (* Dereference as an integer, throw an exception if the target is not an string  *)  
  val deref_as_string : heap -> ptr -> string

  (* Assigning values to a pointer with an offset.                                 *)
  (* Should throw an "Out-Of-Memory" error if not possible to create a new value   *)
  (* The last argument is a value being assigned (of the corresponding type)       *)
  val assign_ptr : heap -> ptr -> int -> ptr -> unit
  val assign_int : heap -> ptr -> int -> int -> unit
  val assign_string : heap -> ptr -> int -> int -> unit

end


(*

An incomplete double-linked list implemented via bare pointers,
   parameterised over the memory allocator interface A.

* N.B.: The dll_node is no longer type-safe, it is just a pointer, and
   you will have to implement all the functions in a memory-safe way.
   The only allowed crashes are "Out-Of-Memory" exceptions.

*)
module DoubleLinkedList(A: Allocator) = 
  struct
    open A
    type dll_node = ptr

    (* Example: creating a node with an integer and a string *)
    let mk_node heap i s = 
      let segment = alloc heap 4 in
      assign_int heap segment 0 i;
      assign_string heap segment 1 s;
      let z = null heap in
      assign_ptr heap segment 2 z;
      assign_ptr heap segment 3 z;
      segment
       
    let prev heap (n : dll_node) = () (* Implement me! *)
    let next heap (n : dll_node) = () (* Implement me! *)
    let int_value heap (n : dll_node) = () (* Implement me! *)
    let string_value heap (n : dll_node) = () (* Implement me! *)
          
    let insert_after heap (n1 : dll_node) (n2 : dll_node) = 
      () (* Implement me! *)
      
    (* Prints the double-linked list starting from the node *)
    let print_from_node heap n = () (* Implement me! *)

    let remove heap n = () (* Implement me! *)
  end 

(*

A familiar Queue interface:

*)

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



(* A queue based on a double-linked list *)
module HeapDLLQueue(A: Allocator) = struct
  module DLL = DoubleLinkedList(A)
  open A
  open DLL

  type 'e t = {
    store : heap;
    head : dll_node;
    tail : dll_node;
  }

  let mk_queue _ = () (* Implement me! *)
  let is_empty q = () (* Implement me! *) 
  let enqueue q e = () (* Implement me! *) 
  let dequeue q = () (* Implement me! *) 
  let queue_to_list q = () (* Implement me! *) 
        
end
