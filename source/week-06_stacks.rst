.. -*- mode: rst -*-

Stacks
======


The Stack interface
-------------------

TODO

A simple stack interface is described by the following OCaml module
signature::

 module type AbstractStack = sig
     type 'e t
     val mk_stack : unit -> 'e t
     val is_empty : 'e t -> bool
     val push : 'e t -> 'e -> unit
     val pop : 'e t -> 'e option
   end

TODO: emphasise the role of ``'e t``.


An List-Based Stack
-------------------

TODO

As OCaml lists behave precisely like stacks, we can build the following implementation almost quite effortlessly::

 module ListBasedStack : AbstractStack = struct
     type 'e t = 'e list ref
     let mk_stack _ = ref []
     let is_empty s = match !s with
       | [] -> true
       | _ -> false
     let push s e = 
       let c = !s in
       s := e :: c
     let pop s = match !s with
       | h :: t ->
         s := t; Some h
       | _ -> None
   end

We can now experiment with it by pushing and popping different elements::

 # let s = ListBasedStack.mk_stack ();;
 val s : '_weak101 ListBasedStack.t = <abstr>
 # push s (4, "aaa");;
 - : unit = ()
 # push s (5, "bbb");;
 - : unit = ()
 # push s (7, "ccc");;
 - : unit = ()
 # is_empty s;;
 - : bool = false
 # pop s;;
 - : (int * string) option = Some (7, "ccc")
 # pop s;;
 - : (int * string) option = Some (5, "bbb")
 # pop s;;
 - : (int * string) option = Some (4, "aaa")
 # pop s;;
 - : (int * string) option = None
 # pop s;;
 - : (int * string) option = None


An Array-Based Stack
--------------------

An alternative implementation of stacks uses an array of some size ``n``, thus requiring constant-size memory. A natural shortcoming of such a solution is the fact that the stack can hold only up to ``n`` elements::

 module ArrayBasedStack : AbstractStack = struct
     type 'e t = {
       elems   : 'e option array;
       cur_pos : int ref 
     }
     let mk_stack _ = {
       elems = Array.make 10 None;
       cur_pos = ref 0
     }
     let is_empty s = !(s.cur_pos) = 0

     let push s e = 
       let pos = !(s.cur_pos) in 
       if pos >= Array.length s.elems 
       then raise (Failure "Stack is full")
       else (s.elems.(pos) <- Some e;
             s.cur_pos := pos + 1)

     let pop s = 
       let pos = !(s.cur_pos) in
       let elems = s.elems in
       if pos <= 0 then None
       else (
         let res = elems.(pos - 1) in
         s.elems.(pos - 1) <- None;
         s.cur_pos := pos - 1;
         res)
   end


Let us test the implementation::

 # open ArrayBasedStack;;
 # let s = mk_stack ();;
 val s : '_weak102 ArrayBasedStack.t = <abstr>
 # push s (3, "aaa");;
 - : unit = ()
 # push s (5, "bbb");;
 - : unit = ()
 # push s (7, "ccc");;
 - : unit = ()
 # pop s;;
 - : (int * string) option = Some (7, "ccc")
 # pop s;;
 - : (int * string) option = Some (5, "bbb")
 # pop s;;
 - : (int * string) option = Some (3, "aaa")
 # is_empty s;;
 - : bool = true
 # pop s;;
 - : (int * string) option = None
