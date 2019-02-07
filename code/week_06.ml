(* Compiling the previous weeks modules:

 ocamlc week_01.ml week_02.ml week_03.ml week_04.ml week_05.ml

Creating the new REPL:

 ocamlmktop -o mytoplevel week_01.ml week_02.cmo week_03.cmo week_04.cmo week_05.cmo

Then just load ./mytoplevel as your REPL command (instead of ocaml).

*)

open Week_01
open Week_03
open Week_04
open Week_05

(* Linked objects *)

(* 1. Representing stacks and queues as arrays *)

module type AbstractStack = sig
    type 'e t
    val mk_stack : unit -> 'e t
    val is_empty : 'e t -> bool
    val push : 'e t -> 'e -> unit
    val pop : 'e t -> 'e option
  end

(* Stack based on lists *)

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

open ListBasedStack

(* 

# let s = mk_stack ();;
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

*)

(* 2. Stack based on arrays *)

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

(* Testing array-based stack *)


(*

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

*)

(* 3. An abstract specification for a queue *)

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

(* 4. Queue based on arrays *)

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

module QueuePrinter(Q: Queue) = struct

  let print_queue q pp = 
    Printf.printf "[";
    List.iter (fun e ->
      Printf.printf "%s; " (pp e))
      (Q.queue_to_list q);
    Printf.printf "]\n"
  end


open ArrayBasedQueue
module ABQPrinter = QueuePrinter(ArrayBasedQueue)

(* let pp e = match e with
 *   | Some (k, v) -> Printf.sprintf "(%d, %s)" k v
 *   | None -> "None" *)

let pp (k, v) = Printf.sprintf "(%d, %s)" k v

let print_queue q = ABQPrinter.print_queue q pp

(* Testing the array-based queue *)

(*

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
*)

(* 5. doubly-linked lists *)

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

    let prev n =  !(n.prev)
    let next n =  !(n.next)
    let value n = !(n.value)
    let set_value n v = n.value := v

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

    let rec move_to_head n = 
      match prev n with
      | None -> None
      | Some m -> move_to_head m
      
    let rec move_to_tail n = 
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

    let remove n = 
      (match prev n with
      | None -> ()
      | Some p -> p.next := next n);
      (match next n with
      | None -> ()
      | Some nxt -> nxt.prev := prev n);

  end 


 module DLLBasedQueue : Queue = struct
  open DoubleLinkedList
    
    type 'e t = {
      head : 'e dll_node option ref;
      tail : 'e dll_node option ref;
    }

    (* Tell about aliasing! *)
    let mk_queue sz = 
      {head = ref None; 
       tail = ref None}
    
    let is_empty q = 
      !(q.head) = None
      
    let is_full q = false
      
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

    let dequeue q =
      match !(q.head) with
      | None -> None
      | Some n -> 
        let nxt = next n in
        q.head := nxt;
        remove n; (* This is not necessary *)
        Some (value n)

    let queue_to_list q = match !(q.head) with
      | None -> []
      | Some n -> to_list_from n

  end

open DLLBasedQueue
module DLQPrinter = QueuePrinter(DLLBasedQueue)

(* let pp e = match e with
 *   | Some (k, v) -> Printf.sprintf "(%d, %s)" k v
 *   | None -> "None" *)

let pp (k, v) = Printf.sprintf "(%d, %s)" k v

let print_queue q = DLQPrinter.print_queue q pp

let dq = mk_queue 0


(* Experiments *)

(*
# let dq = mk_queue 0;;
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

*)

 (* 
 * (\* 6. Binary trees and their traversals *\)
 * 
 * module type BinaryTree = functor(C: Comparable) -> sig
 * 
 *   type 'e tree_node
 * 
 *   val value : 'e tree_node -> 'e
 *   val left : 'e tree_node -> 'e tree_node option
 *   val right : 'e tree_node -> 'e tree_node option
 *   val parent : 'e tree_node -> 'e tree_node option
 * 
 *   val get_root : 'e tree_node -> 'e tree_node
 * 
 *   val update_value : 'e tree_node -> 'e -> unit
 * 
 * end
 * 
 * module BinaryTreeImpl : BinaryTree = 
 *   functor (C: Comparable) -> struct
 * 
 *   type 'e tree_node = {
 *     value : 'e ref;
 *     parent  : 'e tree_node option ref;
 *     left  : 'e tree_node option ref;
 *     right  : 'e tree_node option ref;
 *   }
 * 
 *   let value n = !(n.value)
 *   let left n = !(n.left)
 *   let right n = !(n.right)
 *   let parent n = !(n.parent)
 * 
 *   let is_root n =  parent n = None
 *                    
 *   let rec get_root n = match parent n with
 *     | None -> n
 *     | Some m -> get_root m
 * 
 *   let update_value n v = n.value := v
 * 
 *   let rec insert_element n e = 
 *     if C.comp e (value n) < 0
 *     then match left n with
 *       | Some m -> insert_element m e
 *       | None ->
 *         let m = {value = ref e;
 *                  parent = ref @@ Some n;
 *                  left = ref None;
 *                  right = ref None} in
 *         n.left := Some m;
 *         m
 *     else match left n with
 *       | Some m -> insert_element m e
 *       | None ->
 *         let m = {value = ref e;
 *                  parent = ref @@ Some n;
 *                  left = ref None;
 *                  right = ref None} in
 *         n.right := Some m;
 *         m
 * 
 *   let dfs n = 
 *     let rec walk n acc = 
 *       let acc' = value n :: acc in
 *       
 * 
 *       
 * 
 * end
 * 
 * (\*
 * - Tree definition
 * - Tree traversal
 * - Depth-first-search
 * - Breadth-first-search
 * 
 * 
 * *\)
 * 
 *)
 
 (* X. Hash-tables *)

module type Hashable = sig
  type t
  val hash : t -> int
end

module type HashTable = functor 
  (H : Hashable) -> sig
  type key = H.t
  type 'v hash_table
  val mk_new_table : int -> 'v hash_table 
  val insert : (key * 'v) hash_table -> key -> 'v -> unit
  val get : (key * 'v) hash_table -> key -> 'v option
  val remove : (key * 'v) hash_table -> key -> unit
end
    
module ListBasedHashTable 
  : HashTable = functor 
  (H : Hashable) -> struct
  type key = H.t

  type 'v hash_table = {
    buckets : 'v list array;
    size : int 
  }

  let mk_new_table size = 
    let buckets = Array.make size [] in
    {buckets = buckets;
     size = size}
  
  let insert ht k v = 
    let hs = H.hash k in
    let bnum = hs mod ht.size in 
    let bucket = ht.buckets.(bnum) in
    let clean_bucket = 
      List.filter (fun (k', v) -> k' <> k) bucket in
    ht.buckets.(bnum) <- (k, v) :: clean_bucket

  let get ht k = 
    let hs = H.hash k in
    let bnum = hs mod ht.size in 
    let bucket = ht.buckets.(bnum) in
    let res = List.find_opt (fun (k', _) -> k' = k) bucket in
    match res with 
    | Some (_, v) -> Some v
    | _ -> None

  (* Slow remove - introduce for completeness *)
  let remove ht k = 
    let hs = H.hash k in
    let bnum = hs mod ht.size in 
    let bucket = ht.buckets.(bnum) in
    let clean_bucket = 
      List.filter (fun (k', _) -> k' <> k) bucket in
    ht.buckets.(bnum) <- clean_bucket
    
end 

(* A simple hash-table with ints *)
module HashTableIntKey = ListBasedHashTable 
    (struct type t = int let hash i = i end)

let a = generate_key_value_array 10

let hs = HashTableIntKey.mk_new_table 8

(*

val a : (int * string) array =
  [|(0, "gyqzm"); (8, "ccurj"); (9, "hwupm"); (3, "ttvno"); (4, "bkyoh");
    (6, "rcugr"); (1, "hlbhi"); (8, "quknb"); (0, "cbrsj"); (9, "jbhos")|]
val hs : '_weak80 HashTableIntKey.hash_table = <abstr>
# for i = 0 to 9 do HashTableIntKey.insert hs (fst a.(i)) a.(i) done;;
- : unit = ()
#  HashTableIntKey.get hs 4;;
- : (int * string) option = Some (4, "bkyoh")

*)





(****************************************************************)
(*******               Obsolete stuff below                 *****)
(****************************************************************)

(* module type EnhancedHashTable = functor 
 *   (H : Hashable) -> sig
 *   type key = H.t
 *   type 'v hash_table
 *   val mk_new_table : int -> 'v hash_table 
 *   val insert : (key * 'v) hash_table -> key -> 'v -> unit
 *     val get : (key * 'v) hash_table -> key -> 'v option
 * 
 *   (\* An additional interface *\)
 *   type 'v entry
 *   val get_entry : (key * 'v) hash_table -> key -> 'v entry option
 *   val value : 'v entry -> 'v
 *   val remove : (key * 'v) hash_table -> 'v entry -> unit
 * end
 *     
 * module EnhancedListBasedHashTable 
 *   : EnhancedHashTable = functor 
 *   (H : Hashable) -> struct
 *   type key = H.t
 *   type 'v entry = key * 'v
 * 
 *   let value = snd
 * 
 *   type 'v hash_table = {
 *     buckets : 'v list array;
 *     size : int 
 *   }
 * 
 *   let mk_new_table size = 
 *     let buckets = Array.make size [] in
 *     {buckets = buckets;
 *      size = size}
 *   
 *   let insert ht k v = 
 *     let hs = H.hash k in
 *     let bnum = hs mod ht.size in 
 *     let bucket = ht.buckets.(bnum) in
 *     let clean_bucket = 
 *       List.filter (fun (k', v) -> k' <> k) bucket in
 *     ht.buckets.(bnum) <- (k, v) :: clean_bucket
 * 
 *   let get ht k = 
 *     let hs = H.hash k in
 *     let bnum = hs mod ht.size in 
 *     let bucket = ht.buckets.(bnum) in
 *     let res = List.find_opt (fun (k', _) -> k' = k) bucket in
 *     match res with 
 *     | Some (_, v) -> Some v
 *     | _ -> None
 * 
 *   let get_entry ht k = 
 *     let hs = H.hash k in
 *     let bnum = hs mod ht.size in 
 *     let bucket = ht.buckets.(bnum) in
 *     let res = List.find_opt (fun (k', _) -> k' = k) bucket in
 *     match res with 
 *     | Some (_, v) -> Some (k, v)
 *     | _ -> None
 * 
 * 
 *   (\* Slow remove - introduce for completeness *\)
 *   let remove ht e = 
 *     let hs = H.hash (fst e) in
 *     let bnum = hs mod ht.size in 
 *     let bucket = ht.buckets.(bnum) in
 *     let clean_bucket = 
 *       List.filter (fun (k', _) -> k' <> (fst e)) bucket in
 *     ht.buckets.(bnum) <- clean_bucket
 *     
 * end *)

