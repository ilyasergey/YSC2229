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

module type AbstractStack = 
  functor(E: sig type elem end) -> sig
    type 'e t
    val mk_stack : unit -> E.elem t
    val is_empty : E.elem t -> bool
    val push : E.elem t -> E.elem -> unit
    val pop : E.elem t -> E.elem option
  end

(* Stack based on lists *)

module ListBasedStack : AbstractStack = 
  functor (E: sig type elem end) ->
  struct
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

module KVStack_LB = 
  ListBasedStack(struct type elem = int * string end)

(* 

# open KVStack_LB;;
# let s = mk_stack ();;
val s : (int * string) KVStack_LB.t = <abstr>
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

module ArrayBasedStack : AbstractStack = 
  functor (E: sig type elem end) ->
  struct
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

module KVStack_AB = 
  ArrayBasedStack(struct type elem = int * string end)

(*

# open KVStack_AB;;
# let s = mk_stack ();;
val s : (int * string) KVStack_AB.t = <abstr>
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
  functor(E: sig type elem end)
    (P: sig val pp : E.elem -> string end)-> 
  sig
    type 'e t
    val mk_queue : int -> E.elem t
    val is_empty : E.elem t -> bool
    val is_full : E.elem t -> bool
    val enqueue : E.elem t -> E.elem -> unit
    val dequeue : E.elem t -> E.elem option
    val print_queue : E.elem t -> unit    
  end

(* 4. Queue based on arrays *)

module ArrayBasedQueue : Queue = 
  functor(E: sig type elem end)
    (P: sig val pp : E.elem -> string end)->
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

    let print_queue q = 
      let module AP = ArrayPrinter(struct
          type t = E.elem option
          let pp s = match s with
            | Some e -> P.pp e
            | None -> "None"
        end) in
      AP.print_array q.elems
  end

module KVQueue_Arr = 
  ArrayBasedQueue(struct type elem = int * string end)(KV)
open KVQueue_Arr

(* Testing the array-based queue *)

(*

# let q = mk_queue 10;;
val q : '_weak16 KVQueue_Arr.t =
  {elems = [|None; None; None; None; None; None; None; None; None; None|];
   head = {contents = 0}; tail = {contents = 0}; size = 10}
# for i = 0 to 9 do enqueue q a.(i) done;;
- : unit = ()
# q;;
- : (int * string) KVQueue_Arr.t =
{elems =
  [|Some (8, "kxnhw"); Some (5, "dfizp"); Some (2, "igxib");
    Some (6, "pseae"); Some (6, "jpvey"); Some (1, "hmayz");
    Some (7, "ieiig"); Some (1, "occuz"); Some (2, "qzitr");
    Some (3, "jksmq")|];
 head = {contents = 0}; tail = {contents = 0}; size = 10}
# is_full q;;
- : bool = true
# dequeue q;;
- : (int * string) option = Some (8, "kxnhw")
# dequeue q;;
- : (int * string) option = Some (5, "dfizp")
# is_full q;;
- : bool = false
# is_empty q;;
- : bool = false
# enqueue q (6, "qwerty");;
- : unit = ()
# q;;
- : (int * string) KVQueue_Arr.t =
{elems =
  [|Some (6, "qwerty"); None; Some (2, "igxib"); Some (6, "pseae");
    Some (6, "jpvey"); Some (1, "hmayz"); Some (7, "ieiig");
    Some (1, "occuz"); Some (2, "qzitr"); Some (3, "jksmq")|];
 head = {contents = 2}; tail = {contents = 1}; size = 10}
# dequeue q;;
- : (int * string) option = Some (2, "igxib")
# dequeue q;;
- : (int * string) option = Some (6, "pseae")
# q;;
- : (int * string) KVQueue_Arr.t =
{elems =
  [|Some (6, "qwerty"); None; None; None; Some (6, "jpvey");
    Some (1, "hmayz"); Some (7, "ieiig"); Some (1, "occuz");
    Some (2, "qzitr"); Some (3, "jksmq")|];
 head = {contents = 4}; tail = {contents = 1}; size = 10}

*)

(* 5. doubly-lined lists *)

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

(* module DoubleLinkedListInt = 
 *   DoubleLinkedList(struct type elem = int end)
 *     (struct let pp = string_of_int end)
 * open DoubleLinkedListInt *)

module DLLBasedQueue : Queue = 
  functor(E: sig type elem end)
    (P: sig val pp : E.elem -> string end)->
  struct
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

    let print_queue q = match !(q.head) with
      | Some n -> 
        let ls = to_list_from n in
        let a = list_to_array ls in
        let module AP = ArrayPrinter(struct
            type t = E.elem
            let pp = P.pp
            end) in
        AP.print_array a
      | _ -> Printf.printf "Empty"

  end

module KVQueue_DLL = 
  DLLBasedQueue(struct type elem = int * string end)(KV)
open KVQueue_DLL

let dq = mk_queue 0

(* Now an experiment with the queue *)

(*
val a : (int * string) array =
  [|(1, "pjbqh"); (6, "dhpyo"); (3, "ulkuw"); (7, "bohfu"); (0, "myxoh");
    (5, "ptlbv"); (7, "zmsaj"); (3, "amhja"); (7, "rxoai"); (2, "dhqma")|]
val hs : '_weak82 HashTableIntKey.hash_table = <abstr>
# for i = 0 to 9 do enqueue dq a.(i) done;;
- : unit = ()
# is_empty dq;;
- : bool = false
# dequeue dq;;
- : (int * string) option = Some (1, "pjbqh")
# dequeue dq;;
- : (int * string) option = Some (6, "dhpyo")
# dequeue dq;;
- : (int * string) option = Some (3, "ulkuw")
# dequeue dq;;
- : (int * string) option = Some (7, "bohfu")
# print_queue dq;;
[| (0, myxoh); (5, ptlbv); (7, zmsaj); (3, amhja); (7, rxoai); (2, dhqma) |] - : unit = ()

*)


(* 6. Binary trees and their traversals *)

(*
- Tree definition
- Tree traversal
- Depth-first-search
- Breadth-first-search


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

module type EnhancedHashTableSig = functor 
  (H : Hashable) -> sig
  type key = H.t
  type 'v hash_table
  val mk_new_table : int -> 'v hash_table 
  val insert : (key * 'v) hash_table -> key -> 'v -> unit
    val get : (key * 'v) hash_table -> key -> 'v option

  (* An additional interface *)
  type 'v entry
  val get_entry : (key * 'v) hash_table -> key -> 'v entry option
  val value : 'v entry -> 'v
  val remove : (key * 'v) hash_table -> 'v entry -> unit
end
    
module EnhancedListBasedHashTable 
  : HashTableSig = functor 
  (H : Hashable) -> struct
  type key = H.t
  type 'v entry = key * 'v

  let value = snd

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

  let get_entry ht k = 
    let hs = H.hash k in
    let bnum = hs mod ht.size in 
    let bucket = ht.buckets.(bnum) in
    let res = List.find_opt (fun (k', _) -> k' = k) bucket in
    match res with 
    | Some (_, v) -> Some (k, v)
    | _ -> None


  (* Slow remove - introduce for completeness *)
  let remove ht e = 
    let hs = H.hash (fst e) in
    let bnum = hs mod ht.size in 
    let bucket = ht.buckets.(bnum) in
    let clean_bucket = 
      List.filter (fun (k', _) -> k' <> (fst e)) bucket in
    ht.buckets.(bnum) <- clean_bucket
    
end 

(* A simple hash-table with ints *)
module HashTableIntKey = ListBasedHashTable 
    (struct type t = int let hash i = i end)

let a = generate_key_value_array 10

let hs = HashTableIntKey.mk_new_table 8
