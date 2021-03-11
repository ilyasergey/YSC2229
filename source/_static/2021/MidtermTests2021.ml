open Util

(**********************************************)
(*              Testing allocator             *)
(**********************************************)

open Allocator
open AllocatorImpl
open DoublyLinkedList
module DLLImpl = DoublyLinkedList(AllocatorImpl)
open DLLImpl
open Queue
module Q = HeapDLLQueue(AllocatorImpl)
open Q
open ArrayUtil

(**********************************************)
(*             Eric & Kosuke                  *)
(**********************************************)

(* Allocator *)

let %test "alloc test 1" =
  let open AllocatorImpl in
  let hp = make_heap 8 in
  let ptr = alloc hp 4 in
  let ptr_2 = alloc hp 4 in
  assign_int hp ptr 0 32;
  assign_int hp ptr_2 1 44;
  let res1 = deref_as_int hp ptr 0 in
  let res2 = deref_as_int hp ptr_2 1 in
  res1 = 32 && res2 = 44

let %test "alloc test 2" =
  let open AllocatorImpl in
  let hp = make_heap 8 in
  let ptr = alloc hp 4 in
  let ptr_2 = alloc hp 4 in
  assign_string hp ptr 3 "abc";
  assign_ptr hp ptr_2 1 (null hp);
  try let _ = alloc hp 1 in false
  with _ -> true

let %test "alloc test 3" =
  let open AllocatorImpl in
  let hp = make_heap 8 in
  let ptr = alloc hp 8 in
  assign_int hp ptr 2 18;
  free hp ptr 8;
  let ptr_2 = alloc hp 8 in
  assign_int hp ptr_2 0 32;
  let res1 = deref_as_int hp ptr_2 0 in
  res1 = 32

let %test "memory reclamation 1" =
  let open AllocatorImpl in
  let hp = make_heap 30 in
  let ptr_1 = alloc hp 10 in
  let ptr_2 = alloc hp 10 in
  let ptr_3 = alloc hp 10 in
  assign_ptr hp ptr_1 1 (null hp);
  assign_ptr hp ptr_2 1 ptr_3;
  assign_int hp ptr_2 2 34;
  assign_ptr hp ptr_3 1 (null hp);
  free hp ptr_2 10;
  let ptr_4 = alloc hp 10 in
  assign_int hp ptr_4 2 32;
  assign_string hp ptr_1 3 "abc";
  let res1 = deref_as_ptr hp ptr_3 1 in
  let res2 = deref_as_int hp ptr_4 2 in
  let res3 = deref_as_string hp ptr_1 3 in
  (is_null hp res1) && res2 = 32 && res3 = "abc"

(* DLL *)

let%test "basic node removal" = 
 let heap = AllocatorImpl.make_heap 20 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b"
  and n3 = mk_node heap 3 "c"
  in
  insert_after heap n1 n2;
  insert_after heap n1 n3;
  remove heap n3;
  let n = prev heap n2 in
  let i = int_value heap n in
  let s = string_value heap n in
  i = 1 && s = "a"
                              

let%test "test space management" =
  let heap = AllocatorImpl.make_heap 12 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b"
  and n3 = mk_node heap 3 "c"
  in
  remove heap n3;
  let n4 = mk_node heap 4 "d" in
  insert_after heap n1 n4;
  insert_after heap n4 n2;
  int_value heap (next heap n1) = 4 &&
    int_value heap (next heap (next heap n1)) = 2

(* Queue *)

let%test "basic queue operations_2" = 
  let q = mk_queue 10 in
  enqueue q (42, "a");
  enqueue q (42, "a");
  enqueue q (12, "a");
  enqueue q (42, "a");
  enqueue q (43, "a");
  let _ = dequeue q and _ = dequeue q in
  let e = dequeue q in
  e = Some (12, "a")

let%test "basic queue operations_3" = 
  let q = mk_queue 10 in
  dequeue q = None

(*  Changed to not make extra assumptions about heap size *)
let%test "basic queue operations_4" = 
  let q = mk_queue 1 in
  enqueue q (42, "a");
  true

let%test "basic queue operations_5" =   
   let q = mk_queue 2 in
  enqueue q (42, "a");
  enqueue q (12, "a");
  let _ = dequeue q and _ = dequeue q in
  is_empty q

let%test "basic queue operations_6" =
  let q = mk_queue 2 in
  enqueue q (42, "a");
  enqueue q (12, "a");
  queue_to_list q = [(42, "a"); (12, "a")]

  
let%test "heap reclamation: enqueue N > 2 items on size 2 queue" =
  let q = mk_queue 2 in  
  enqueue q (42, "a");
  enqueue q (42, "a");
  let _ = dequeue q in
  enqueue q (12, "b");
  let e = dequeue q in
  e = Some (42, "a")

(**********************************************)
(*      Jachym & Sam                          *)
(**********************************************)

(* Allocator *)

let%test "string ptr preservation" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 2 in
  assign_string hp ptr 0 "foo";
  assign_string hp ptr 1 "bar";
  let res1 = deref_as_string hp ptr 0 in
  let res2 = deref_as_string hp ptr 1 in
  res1 = "foo" && res2 = "bar"

let%test "ptr ptr preservation" =
  let open AllocatorImpl in 
  let hp = make_heap 10 in
  let ptr1 = alloc hp 2 in 
  let ptr2 = alloc hp 2 in
  assign_ptr hp ptr1 0 ptr2;
  deref_as_ptr hp ptr1 0 = ptr2

let%test "null pointer allocation" =
  let open AllocatorImpl in 
  let hp = make_heap 10 in
  let ptr1 = alloc hp 2 in 
  assign_ptr hp ptr1 0 (null hp);
  deref_as_ptr hp ptr1 0 = null hp

(* DLL *)

let%test "remove n1" = 
  let open AllocatorImpl in
  let heap = make_heap 10 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" in
  insert_after heap n1 n2;
  remove heap n1;
  prev heap n2 = null heap &&
  next heap n2 = null heap

let%test "full heap" = 
  let open AllocatorImpl in
  let hp = make_heap 7 in
  let _ = mk_node hp 1 "a" in
  try let _ = mk_node hp 2 "b" in false
  with _ -> true

let%test "remove n2" = 
  let heap = AllocatorImpl.make_heap 15 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b"
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n2;
  insert_after heap n2 n3;
  let x = next heap n1 = prev heap n3 in
  remove heap n2;
  x && next heap n1 = n3 &&
  prev heap n1 = next heap n3
  
(* Queue *)

let%test "heap reclamation: enqueue N > 2 items on size 2 queue" =
  let q = mk_queue 2 in
  enqueue q (42, "a");
  enqueue q (43, "b");
  let _ = dequeue q in
  try let _ = enqueue q (44, "c") in true
  with _ -> false

let%test "heap reclamation from SLL" = 
  let q = mk_queue 5 in
  enqueue q (42, "a");
  enqueue q (15, "b");
  enqueue q (33, "c");
  enqueue q (52, "d");
  enqueue q (31, "e");
  let e1 = dequeue q in
  let e2 = dequeue q in
  let e3 = dequeue q in
  enqueue q (300, "new");
  enqueue q (235, "alloced");
  e1 = Some (42, "a") &&
  e2 = Some (15, "b") &&
  e3 = Some (33, "c")

let%test "deque on empty" =
  let q = mk_queue 2 in
  enqueue q (42, "a");
  enqueue q (43, "b");
  let _ = dequeue q in
  let _ = dequeue q in
  let mt = dequeue q in mt = None

let%test "queueu_to_list_test" = 
  let q = mk_queue 5 in
  enqueue q (42, "a");
  enqueue q (15, "b");
  enqueue q (33, "c");
  let l = queue_to_list q in 
  l = [(42, "a"); (15, "b"); (33, "c") ]

(**********************************************)
(*       Karolina & Fedi                      *)
(**********************************************)

(* Allocator *)

let%test "string ptr preservation" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 2 in
  assign_string hp ptr 0 "a";
  assign_string hp ptr 1 "b";
  let res1 = deref_as_string hp ptr 0 in
  let res2 = deref_as_string hp ptr 1 in
  res1 = "a" && res2 = "b"

let%test "pointer ptr preservation" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 10 in
  let p1 = null hp in 
  let p2 = alloc hp 4 in
  assign_ptr hp ptr 0 p1;
  assign_ptr hp ptr 1 p2;
  let res1 = deref_as_ptr hp ptr 0 in
  let res2 = deref_as_ptr hp ptr 1 in
  res1 = p1 && res2 = p2

(* Slightly changed *)
let%test "can't assign to free memory" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 4 in
  assign_string hp ptr 0 "abcd";
  assign_int hp ptr 1 35;
  free hp ptr 4;
  try assign_int hp ptr 0 1; false
  with _ -> true

(* Slightly changed *)
let%test "can't deref a string as int" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 4 in
  assign_string hp ptr 0 "abcd";
  assign_int hp ptr 1 35;
  try let _ = deref_as_int hp ptr 0 in false
  with _ -> true

let%test "sequence of operations" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let p1 = alloc hp 2 in
  assign_string hp p1 0 "a";
  assign_int hp p1 1 35;
  let p2 = alloc hp 4 in 
  assign_string hp p2 0 "b";
  assign_ptr hp p2 1 (null hp);
  assign_int hp p2 2 10;
  assign_string hp p2 3 "c";
  free hp p2 3;
  free hp p1 1;
  let i = deref_as_int hp p1 1 
  in let s = deref_as_string hp p2 3
  in i = 35 && s = "c"

(* DLL *)

let%test "insert between two nodes" = 
  let heap = AllocatorImpl.make_heap 12 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" 
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n3;
  insert_after heap n1 n2;
  let is_n2_next = next heap n1 in
  let is_n2_prev = prev heap n3 in
  let i_next = int_value heap is_n2_next in
  let i_prev = int_value heap is_n2_prev in
  let s_next = string_value heap is_n2_next in
  let s_prev = string_value heap is_n2_prev in
  i_next = 2 && s_next = "b" && i_next = i_prev && s_next = s_prev

let%test "remove between two nodes" = 
  let heap = AllocatorImpl.make_heap 12 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" 
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n2;
  insert_after heap n2 n3;
  remove heap n2;
  let is_n3_next = next heap n1 in
  let is_n1_prev = prev heap n3 in
  let i_next = int_value heap is_n3_next in
  let i_prev = int_value heap is_n1_prev in
  let s_next = string_value heap is_n3_next in
  let s_prev = string_value heap is_n1_prev in
  i_next = 3 && s_next = "c" && i_prev = 1 && s_prev = "a"

let%test "sequence of remove and insert" = 
  let heap = AllocatorImpl.make_heap 12 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" 
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n2;
  insert_after heap n2 n3;
  remove heap n1;
  let n4 = mk_node heap 4 "d" in 
  insert_after heap n3 n4;
  remove heap n3;
  let is_n4_next = next heap n2 in
  let is_n2_prev = prev heap n4 in
  let i_next = int_value heap is_n4_next in
  let i_prev = int_value heap is_n2_prev in
  let s_next = string_value heap is_n4_next in
  let s_prev = string_value heap is_n2_prev in
  i_next = 4 && s_next = "d" && i_prev = 2 && s_prev = "b"

let%test "mk_node when no free memory" = 
  let heap = AllocatorImpl.make_heap 12 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" 
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n2;
  insert_after heap n2 n3;
  try let _ = mk_node heap 4 "d" in false
  with _ -> true

(* Queue *)

let%test "Queue to list" = 
  let q = mk_queue 10 in
  enqueue q (42, "a");
  queue_to_list q = [(42, "a")]
  
let%test "Enqueing and dequeuing before queue to list" = 
  let q = mk_queue 10 in
  enqueue q (42, "a");
  enqueue q (462, "ab");
  dequeue q = Some (42, "a") &&
  queue_to_list q = [(462, "ab")]

let%test "First in first out queue strucuture" =
  let q = mk_queue 10 in
  enqueue q (42, "a");
  enqueue q (1, "ab");
  enqueue q (123, "abc");
  dequeue q = Some (42, "a") && queue_to_list q = [(1, "ab"); (123, "abc")]

let%test "Dequeue in correct order simple version" =
  let q = mk_queue 10 in
  enqueue q (42, "a");
  enqueue q (1, "ab");
  enqueue q (123, "abc");
  dequeue q = Some (42, "a") &&
  dequeue q = Some (1, "ab") &&
  dequeue q = Some (123, "abc") &&
  is_empty q = true &&
  dequeue q = None && 
  queue_to_list q = []

let%test "Dequeue in correct order" = 
  let kv_arr = generate_key_value_array 100 in 
  let q = mk_queue 100 in
  for j = 0 to ((Array.length kv_arr)-1) do 
    enqueue q (kv_arr.(j))
  done;
  let rec kv_dequeue i =
  if i >= (Array.length kv_arr) 
  then true
  else 
    begin
    let x = dequeue q in 
    x = Some kv_arr.(i) && kv_dequeue (i+1)
    end
  in kv_dequeue 0
   
let%test "Equeue when no free memory" = 
  let q = mk_queue 4 in
  enqueue q (1, "a");
  enqueue q (12, "ab");
  enqueue q (123, "abc");
  enqueue q (1234, "abcd");
  let extra = (12345, "abcde") in 
  try let _ = enqueue q extra in false
  with _ -> true

(**********************************************)
(*            Kelvin & Tristan                *)
(**********************************************)

(* Allocator *)

(* Positive test for strings *)
let%test "str ptr preservation" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 2 in
  assign_string hp ptr 0 "abc";
  assign_string hp ptr 1 "def";
  let res1 = deref_as_string hp ptr 0 in
  let res2 = deref_as_string hp ptr 1 in
  res1 = "abc" && res2 = "def"

(* Positive test for pointers *)
let%test "pointer ptr preservation" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 2 in
  let ptr_1 = alloc hp 2 in
  let ptr_2 = alloc hp 2 in
  assign_ptr hp ptr 0 ptr_1;
  assign_ptr hp ptr 1 ptr_2;
  let res1 = deref_as_ptr hp ptr 0 in
  let res2 = deref_as_ptr hp ptr 1 in
  res1 = ptr_1 && res2 = ptr_2

let%test "free more memory than available in heap" =
  let open AllocatorImpl in
  let hp = make_heap 50 in
  let ptr = alloc hp 50 in
  try let _ = free hp ptr 100 in false
  with _ -> true

(* Testing deref and assign to unallocated memory exceptions *)
let%test "deref unalloc ptr" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 5 in
  try let _ = deref_as_ptr hp ptr 8 in false
  with _ -> true

let%test "deref unalloc int" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 5 in
  try let _ = deref_as_int hp ptr 8 in false
  with _ -> true

let%test "deref unalloc string" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 5 in
  try let _ = deref_as_string hp ptr 8 in false
  with _ -> true

let%test "assign unalloc ptr" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 5 in
  try let _ = assign_ptr hp ptr 8 (null hp) in false
  with _ -> true

let%test "assign unalloc int" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 5 in
  try let _ = assign_int hp ptr 8 5 in false
  with _ -> true

let%test "assign unalloc string" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 5 in
  try let _ = assign_string hp ptr 8 "abc" in false
  with _ -> true

(* Testing out of bounds pointer deref *)
let%test "pointer out of bounds deref ptr" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 10 in
  try let _ = deref_as_ptr hp ptr 11 in false
  with _ -> true

let%test "pointer out of bounds deref int" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 10 in
  try let _ = deref_as_int hp ptr 11 in false
  with _ -> true

let%test "pointer out of bounds deref str" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 10 in
  try let _ = deref_as_string hp ptr 11 in false
  with _ -> true

(* Testing out of bounds pointer assign *)
let%test "pointer out of bounds assign ptr" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr_1 = alloc hp 5 in
  let ptr_2 = alloc hp 5 in
  try let _ = assign_ptr hp ptr_1 11 ptr_2 in false
  with _ -> true

let%test "pointer out of bounds assign int" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 10 in
  try let _ = assign_int hp ptr 11 5 in false
  with _ -> true

let%test "pointer out of bounds assign string" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 10 in
  try let _ = assign_string hp ptr 11 "abc" in false
  with _ -> true

(* Testing null pointer exception *)
let%test "null pointer deref ptr" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  try let _ = deref_as_ptr hp (null hp) 5 in false
  with _ -> true

let%test "null pointer deref int" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  try let _ = deref_as_int hp (null hp) 5 in false
  with _ -> true

let%test "null pointer deref str" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  try let _ = deref_as_string hp (null hp) 5 in false
  with _ -> true

let%test "null pointer assign ptr" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr_2 = alloc hp 5 in
  try let _ = assign_ptr hp (null hp) 5 ptr_2 in false
  with _ -> true

let%test "null pointer assign int" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  try let _ = assign_int hp (null hp) 5 0 in false
  with _ -> true

let%test "null pointer assign string" =
  let open AllocatorImpl in
  let hp = make_heap 10 in
  try let _ = assign_string hp (null hp) 5 "abc" in false
  with _ -> true

let %test "deref wrong type exception 1" = 
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 5 in
  assign_int hp ptr 0 33;
  try let _ = deref_as_string hp ptr 0 in false
  with _ -> true

let %test "deref wrong type exception 2" = 
  let open AllocatorImpl in
  let hp = make_heap 10 in
  let ptr = alloc hp 5 in
  assign_string hp ptr 0 "bar";
  try let _ = deref_as_int hp ptr 0 in false
  with _ -> true


(* DLL *)

let%test "remove when there are next and prev nodes" =
  let hp = AllocatorImpl.make_heap 20 in
  let n1 = mk_node hp 1 "a" in
  let n2 = mk_node hp 2 "b" in
  let n3 = mk_node hp 3 "c" in
  insert_after hp n1 n2;
  insert_after hp n2 n3;
  let prev_n2 = prev hp n2 in
  let next_n2 = next hp n2 in
  let i_prev = int_value hp prev_n2 in
  let s_prev = string_value hp prev_n2 in
  let i_next = int_value hp next_n2 in
  let s_next = string_value hp next_n2 in
  i_prev = 1 && s_prev = "a" && i_next = 3 && s_next = "c"


let%test "remove 1 node" =
  let hp = AllocatorImpl.make_heap 10 in
  let n1 = mk_node hp 1 "a" in
  remove hp n1;
  let n2 = mk_node hp 1 "a" in
  (* Pointer should be same place in memory *)
  n1 = n2

let%test "remove when no prev node" =
  let hp = AllocatorImpl.make_heap 10 in
  let n1 = mk_node hp 1 "a" in
  let n2 = mk_node hp 2 "b" in
  insert_after hp n1 n2;
  remove hp n1;
  let prev_n2 = prev hp n2 in
  (* Prev for n2 should point to null *)
  AllocatorImpl.is_null hp prev_n2

let%test "remove when no next node" =
  let hp = AllocatorImpl.make_heap 10 in
  let n1 = mk_node hp 1 "a" in
  let n2 = mk_node hp 2 "b" in
  insert_after hp n1 n2;
  remove hp n2;
  let next_n1 = next hp n1 in
  AllocatorImpl.is_null hp next_n1

let%test "remove when there are next and prev nodes" =
  let hp = AllocatorImpl.make_heap 20 in
  let n1 = mk_node hp 1 "a" in
  let n2 = mk_node hp 2 "b" in
  let n3 = mk_node hp 3 "c" in
  remove hp n2;
  let next_n1 = next hp n1 in
  let prev_n3 = prev hp n3 in
  next_n1 = prev_n3

let%test "check null when no prev and next node" =
  let heap = AllocatorImpl.make_heap 10 in
  let n1 = mk_node heap 1 "a" in
  let prev = prev heap n1 in
  let next = next heap n1 in
  AllocatorImpl.is_null heap prev && AllocatorImpl.is_null heap next

let%test "print from node" =
  let heap = AllocatorImpl.make_heap 10 in
  let n1 = mk_node heap 1 "a" in
  let i = int_value heap n1 in 
  let str = string_value heap n1 in
  i = 1 && str = "a"

let%test "deref int value when node removed" =
  let hp = AllocatorImpl.make_heap 10 in
  let n1 = mk_node hp 1 "a" in
  remove hp n1;
  try let _ = int_value hp n1 in false
  with _ -> true

let%test "deref str value when node removed" =
  let hp = AllocatorImpl.make_heap 10 in
  let n1 = mk_node hp 1 "a" in
  remove hp n1;
  try let _ = string_value hp n1 in false
  with _ -> true

(* Queue *)

let%test "empty queue" =
  let q = mk_queue 10 in
  is_empty q

let%test "full queue" =
  let q = mk_queue 2 in
  enqueue q (1, "a");
  enqueue q (2, "b");
  true

let%test "enqueue full queue exception" = 
  let q = mk_queue 2 in
  enqueue q (1, "a");
  enqueue q (1, "b");
  try let _ = enqueue q (2, "c") in false
  with _ -> true

let%test "dequeue empty queue exception" =
  let q = mk_queue 2 in
  let res = dequeue q in
  res = None

let%test "DLL queue to list" =
  let q = mk_queue 10 in
  let rand_kv_list = array_to_list (generate_key_value_array 10) in
  List.iter (enqueue q) rand_kv_list;
  let res = queue_to_list q in
  res = rand_kv_list 

let%test "FIFO characteristic of queues" =
  let q = mk_queue 10 in
  let rand_kv_list = array_to_list (generate_key_value_array 10) in
  List.iter (enqueue q) rand_kv_list;
  let rec dequeue_all n acc =
    if n = 0 then acc
    else 
      (let res = get_exn (dequeue q) in
       dequeue_all (n - 1) (res :: acc))
  in    
  let res = dequeue_all 10 [] in 
  rand_kv_list = List.rev res

(**********************************************)
(*       Kris & Jonas                         *)
(**********************************************)

(* Allocator *)

let%test "is null" =
  let open AllocatorImpl in 
  let hp = make_heap 100 in
  is_null hp (null hp)

let%test "dereference wrong type0" =
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let x0 = alloc hp 500 in
  assign_string hp x0 200 "foo";
  try let _ = deref_as_int hp x0 200 in false
  with _ -> true    

let%test "dereference wrong type1" =
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let x0 = alloc hp 500 in
  let x1 = alloc hp 500 in
  assign_ptr hp x0 200 x1;
  try let _ = deref_as_int hp x0 200 in false
  with _ -> true
                  
let%test "add blocks of 5" =
  let open AllocatorImpl in
  let hp = make_heap 20 in
  let x0 = alloc hp 5 in
  let x1 = alloc hp 5 in
  assign_int hp x0 0 12;
  assign_string hp x1 1 "foo";
  assign_string hp x1 3 "barz";
  let res1 = deref_as_int hp x0 0 in
  let res2 = deref_as_string hp x1 1 in
  let res3 = deref_as_string hp x1 3 in
  res1 = 12 && res2 = "foo" && res3 = "barz"

let%test "with non-contiguous free memory" =
  let open AllocatorImpl in
  let hp = make_heap 200 in
  let x0 = alloc hp 5 in
  let x1 = alloc hp 5 in
  let x2 = alloc hp 5 in
  let x3 = alloc hp 5 in
  assign_int hp x0 0 12;
  assign_int hp x1 1 42;
  free hp x0 5; free hp x2 5;
  let x5 = alloc hp 7 in
  assign_string hp x5 3 "foo";
  assign_string hp x5 6 "bar";
  free hp x3 5; 
  let res4 = deref_as_string hp x5 3 in
  let res5 = deref_as_string hp x5 6 in
  res4 = "foo" && res5 = "bar"

let%test "assigning beyond allocated memory" =
  let open AllocatorImpl in
  let hp = make_heap 5 in
  let x0 = alloc hp 3 in
  assign_int hp x0 0 12;
  assign_int hp x0 1 42;
  assign_int hp x0 2 45;
  try let _ = assign_int hp x0 3 52; in false
  with _ -> true

(* modified for generality *)
let%test "freeing beyond memory" =
  let open AllocatorImpl in
  let hp = make_heap 5 in
  let x0 = alloc hp 3 in
  try let _ = free hp x0 10; in false
  with _ -> true

(* modified for generality *)
let%test "freeing less than allocated memory" =
  let open AllocatorImpl in
  let hp = make_heap 5 in
  let x0 = alloc hp 3 in
  try let _ = free hp x0 (-1); in false
  with _ -> true

(* modified *)
let%test "cannot dereference freed memory" =
  let open AllocatorImpl in
  let hp = make_heap 5 in
  let x0 = alloc hp 3 in
  let x1 = alloc hp 2 in
  assign_ptr hp x0 0 x1;
  free hp x1 2; (* shouldn't be derefable once freed *)
  try let _ = deref_as_ptr hp x1 0; in false
  with _ -> true

(* DLL *)

let%test "test mk_node basic" = 
  let heap = AllocatorImpl.make_heap 10 in
  let n = mk_node heap 1 "a" in
  let i = int_value heap n in
  let s = string_value heap n in
  i = 1 && s = "a"

let%test "basic mk_node fail when run out of memory" = 
  let heap = AllocatorImpl.make_heap 10 in
  try
  (let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" 
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n2;
  insert_after heap n1 n3;
  false) with _ -> true

(* Basic node manipulation *)

let%test "basic node manipulation" = 
  let heap = AllocatorImpl.make_heap 10 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" in
  insert_after heap n1 n2;
  let n = next heap n1 in
  let i = int_value heap n in
  let s = string_value heap n in
  i = 2 && s = "b"

let%test "basic node manipulation: check other node" = 
  let heap = AllocatorImpl.make_heap 10 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" in
  insert_after heap n1 n2;
  let n = prev heap n2 in
  let i = int_value heap n in
  let s = string_value heap n in
  i = 1 && s = "a"


let%test "basic node manipulation - multiple nexts" = 
  let heap = AllocatorImpl.make_heap 20 in
  let n1 = mk_node heap 7 "ad" 
  and n2 = mk_node heap 5 "bc" 
  and n3 = mk_node heap 12 "thr" 
  and n4 = mk_node heap 3 "qwert" 
  and n5 = mk_node heap 100 "ploi" in
  insert_after heap n1 n2;
  insert_after heap n2 n3;
  insert_after heap n3 n4;
  insert_after heap n4 n5;
  let n = next heap n1 in
  let n' = next heap n in
  let n'' = next heap n' in
  let n''' = next heap n'' in
  let i = int_value heap n''' in
  let s = string_value heap n''' in
  i = 100 && s = "ploi"

let%test "basic node manipulation - multiple prevs" = 
  let heap = AllocatorImpl.make_heap 20 in
  let n1 = mk_node heap 7 "ad" 
  and n2 = mk_node heap 5 "bc" 
  and n3 = mk_node heap 12 "thr" 
  and n4 = mk_node heap 3 "qwert" 
  and n5 = mk_node heap 100 "ploi" in
  insert_after heap n1 n2;
  insert_after heap n2 n3;
  insert_after heap n3 n4;
  insert_after heap n4 n5;
  let n = prev heap n5 in
  let n' = prev heap n in
  let n'' = prev heap n' in
  let n''' = prev heap n'' in
  let i = int_value heap n''' in
  let s = string_value heap n''' in
  i = 7 && s = "ad"

(* Invariance of insert_after *)

(* Remove  *)

let%test "remove frees memory" = 
  let heap = AllocatorImpl.make_heap 8 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" in
  remove heap n1;
  let n3 = mk_node heap 3 "c"  in
  insert_after heap n3 n2;
  let n = next heap n3 in
  let i = int_value heap n in
  let s = string_value heap n in
  i = 2 && s = "b"

(* Queue *)

let%test "mk_queue can hold as much as its size 1" = 
  let q = mk_queue 5 in
  try (enqueue q (1, "a");
  enqueue q (2, "b");
  enqueue q (3, "c");
  enqueue q (4, "d");
  enqueue q (5, "e");
  true) with Assert_failure _ -> false

(* Modified *)
let%test "mk_queue can hold as much as its size 2" = 
  let q = mk_queue 10 in
  try (enqueue q (1, "a");
  enqueue q (2, "b");
  enqueue q (3, "c");
  enqueue q (4, "d");
  enqueue q (5, "e");
  enqueue q (6, "f");
  enqueue q (7, "g");
  enqueue q (8, "h");
  enqueue q (9, "i");
  enqueue q (10, "j");
  true) with _ -> false

(* Modified *)
let%test "mk_queue cannot hold more than its size 1" = 
  let q = mk_queue 5 in
  try (enqueue q (1, "a");
  enqueue q (2, "b");
  enqueue q (3, "c");
  enqueue q (4, "d");
  enqueue q (5, "e");
  enqueue q (6, "f");
  false) with _ -> true

(* empty and full tests*)

let%test "empty" = 
  let q = mk_queue 10 in
  is_empty q

let%test "not empty" = 
  let q = mk_queue 10 in
  enqueue q (1, "a");
  enqueue q (2, "b");
  not (is_empty q)

let%test "empty after dequeue" = 
  let q = mk_queue 10 in
  enqueue q (1, "a");
  enqueue q (2, "b");
  let e = dequeue q in
  let e' = dequeue q in
  (e = Some (1, "a")) && (e' = Some (2, "b")) && (is_empty q)

(* modified *)
let%test "is_full" = 
  let q = mk_queue 5 in
  enqueue q (1, "a");
  enqueue q (2, "b");
  enqueue q (3, "c");
  enqueue q (4, "d");
  enqueue q (5, "e");
  true

let%test "is_full" = 
  let q = mk_queue 7 in
  enqueue q (1, "a");
  enqueue q (2, "b");
  enqueue q (3, "c");
  enqueue q (4, "d");
  enqueue q (5, "e");
  not (is_full q)

(* enqueue and dequeue *)

let%test "dequeue correct element" = 
  let q = mk_queue 10 in
  enqueue q (42, "a");
  enqueue q (2, "b");
  let e = dequeue q in
  e = Some (42, "a")

let%test "dequeue correct element 2" = 
  let q = mk_queue 10 in
  enqueue q (42, "a");
  enqueue q (2, "b");
  enqueue q (100, "c");
  let e = dequeue q in
  let e' = dequeue q in
  (e = Some (42, "a")) && (e' = Some (2, "b"))

let%test "dequeue empty queue" = 
  let q = mk_queue 10 in
  let e = dequeue q in
  e = None

(* Queue to list *)

let%test "basic queue to list" = 
  let q = mk_queue 10 in
  enqueue q (1, "a");
  enqueue q (2, "b");
  enqueue q (3, "c");
  enqueue q (4, "d");
  enqueue q (5, "e");
  let e = queue_to_list q in
  e = [(1, "a"); (2, "b"); (3, "c"); (4, "d"); (5, "e")]

let%test "queue to list after dequeue" = 
  let q = mk_queue 10 in
  enqueue q (1, "a");
  enqueue q (2, "b");
  enqueue q (3, "c");
  enqueue q (4, "d");
  enqueue q (5, "e");
  let e = dequeue q in
  let e' = queue_to_list q in
  (e = Some (1, "a")) && (e' = [(2, "b"); (3, "c"); (4, "d"); (5, "e")])



(******************************************************)
(*         Testing heap reclamation                   *)
(******************************************************)

(*

Implement a test that creates a small heap, and then uses it to 
allocate and use a queue (by enqueueing and dequeueing), in a way 
that the number of nodes the queue has over its lifetime is *larger*
than the capacity of the heap. That is, make sure to use memory 
reclamation implemented for doubly-linked lists.

*)

let%test "heap reclamation: enqueue N > 2 items on size 2 queue" =
  let q = mk_queue 2 in
  enqueue q (42, "a");
  enqueue q (0, "b");
  let e = dequeue q in
  enqueue q (2, "d");
  e = Some (42, "a")

let%test "heap reclamation: enqueue N > 4 items on size 4 queue" =
  let q = mk_queue 4 in
  enqueue q (42, "a");
  enqueue q (0, "b");
  let e = dequeue q in
  enqueue q (2, "dqwe");
  enqueue q (3, "erty");
  enqueue q (4, "fzxc");
  let e' = dequeue q in
  let e'' = dequeue q in
  let e''' = dequeue q in
  enqueue q (5, "g");
  enqueue q (6, "h");
  enqueue q (7, "i");
  (e = Some (42, "a")) && (e' = Some (0, "b")) && (e'' = Some (2, "dqwe")) &&  (e''' = Some (3, "erty")) 


(**********************************************)
(*    Lana & Lukas                            *)
(**********************************************)

(* Allocator *)

let%test "string ptr preservation" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 2 in
  assign_string hp ptr 0 "a";
  assign_string hp ptr 1 "b";
  let res1 = deref_as_string hp ptr 0 in
  let res2 = deref_as_string hp ptr 1 in
  res1 = "a" && res2 = "b"                      

let%test "entire array occupied: full heap failure Jr." = 
  let open AllocatorImpl in
  let hp = make_heap 2 in
  let ptr = alloc hp 2 in 
  assign_string hp ptr 0 "a";
  assign_string hp ptr 1 "b";
  try let _ = alloc hp 1 in false
  with _ -> true                         
                      
let%test "bad deference" = 
  let open AllocatorImpl in
  let hp = make_heap 1 in
  let ptr = alloc hp 1 in 
  assign_string hp ptr 0 "a";
  free hp ptr 1;
  try let _ = deref_as_string hp ptr 0 in false
  with _ -> true                                                  

let%test "null pointer" = 
  let open AllocatorImpl in
  let hp = make_heap 1 in
  let ptr = alloc hp 1 in 
  assign_ptr hp ptr 0 (null hp);
  let res = deref_as_ptr hp ptr 0 in
  is_null hp res

let%test "memory reclamation" = 
  let open AllocatorImpl in
  let hp = make_heap 1 in
  let ptr = alloc hp 1 in 
  assign_string hp ptr 0 "hi";
  free hp ptr 1;
  let ptr2 = alloc hp 1 in
  assign_int hp ptr 0 3;
  let res = deref_as_int hp ptr2 0 in
  res = 3

(* DLL *)

let%test "remove" = 
  let heap = AllocatorImpl.make_heap 12 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b"
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n3;
  insert_after heap n1 n2;
  remove heap n2;
  let n3_prev = prev heap n3
  and n1_next = next heap n1
  in n1_next = n3 && n3_prev = n1
   
let%test "some_more_node_checking" = 
  let heap = AllocatorImpl.make_heap 12 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b"
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n2;
  insert_after heap n1 n3;
  remove heap n3;
  let n4 = mk_node heap 4 "d" in
  insert_after heap n2 n4;
  let n2' = prev heap n4
  and n2'' = next heap n1
  in n2'=n2''           

(* Queue *)

let%test "basic queue operations 1" = 
  let q = mk_queue 10 in
  enqueue q (42, "a");
  enqueue q (17, "b");
  let e = dequeue q in
  let a = dequeue q in
  a = Some (17, "b") && e = Some (42, "a") && is_empty q

let%test "basic queue operations 2" = 
  let q = mk_queue 10 in
  enqueue q (42, "a");
  let e = dequeue q in
  let a = dequeue q in
  e = Some (42, "a") && a = None
 
(******************************************************)
(*         Testing heap reclamation                   *)
(******************************************************)

let%test "heap reclamation: enqueue N > 2 items on size 2 queue" =
  let q = mk_queue 2 in
  enqueue q (42, "a");
  enqueue q (17, "b");
  let _ = dequeue q in
  enqueue q (40, "c");
  true

(**********************************************)
(*    Linda & Rui & Ziting                    *)
(**********************************************)

(* Allocator *)

(* Positive test *)
let%test "String ptr preservation" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 2 in
  assign_string hp ptr 0 "a";
  assign_string hp ptr 1 "b";
  let res1 = deref_as_string hp ptr 0 in
  let res2 = deref_as_string hp ptr 1 in
  res1 = "a" && res2 = "b"

let%test "int and string ptr preservation" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 3 in
  assign_string hp ptr 0 "a";
  assign_string hp ptr 1 "b";
  assign_int hp ptr 2 1;
  let res1 = deref_as_string hp ptr 0 in
  let res2 = deref_as_string hp ptr 1 in
  let res3 = deref_as_int hp ptr 2 in
  res1 = "a" && res2 = "b" && res3 = 1

let%test "alloc more space than there is" = 
  let open AllocatorImpl in 
  let hp = make_heap 1 in 
  try let _ = alloc hp 4 in false
  with _ -> true

(*negative test: assume the user doesn't know how the allocator works *)
let%test "free too much memory than there is in the heap" = 
  let open AllocatorImpl in
  let hp = make_heap 2 in
  let ptr = alloc hp 2 in
  assign_int hp ptr 0 42;
  assign_int hp ptr 1 12;
  try let _ = free hp ptr 3 in false
  with _ -> true 

(* DLL *)

let%test "basic node manipulation: prev and next when there are more nodes" = 
  let heap = AllocatorImpl.make_heap 20 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b"
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n2;
  insert_after heap n2 n3;
  let first = prev heap n2 
  and last = next heap n2 in
  let i_first = int_value heap first 
  and s_first = string_value heap first 
  and i_last = int_value heap last 
  and s_last = string_value heap last
  in i_first = 1 && s_first = "a" && i_last = 3 && s_last = "c"

let%test "basic node manipulation: prev and next when 
there is only one node in the list" = 
  let heap = AllocatorImpl.make_heap 10 in
  let n1 = mk_node heap 1 "a" in
  let is_null = AllocatorImpl.is_null in 
  is_null heap (next heap n1) && is_null heap (prev heap n1)

let%test "basic node manipulation: insert before when 
the list is out of memory" = 
  let heap = AllocatorImpl.make_heap 1 in
  try let _ = mk_node heap 1 "a" in false
  with _ -> true

(* Queue *)

let%test "queue is empty" =
  let q = mk_queue 10 in
  enqueue q (42, "a");
  let _ = dequeue q in ();
  is_empty q

let%test "basic queue operations alt" = 
  let q = mk_queue 10 in
  enqueue q (42, "a");
  let _ = dequeue q in ();
  enqueue q (42, "a");
  let e = dequeue q in
  e = Some (42, "a")

let%test "checking enqueue and dequeue many elements with queue_to_list" =
  let arr = generate_key_value_array 5 in
  let list = to_list arr in
  let q = mk_queue 5 in
  List.iter (fun kv -> enqueue q kv) list;
  list = queue_to_list q

let%test "heap reclamation: enqueue N > 2 items on size 2 queue" =
  let q = mk_queue 2 in
  enqueue q (42, "a");
  enqueue q (42, "a");
  let _ = dequeue q in ();
  enqueue q (42, "a");
  true

let%test "dequeue from empty queue" =
  let q = mk_queue 2 in
  enqueue q (42, "a");
  let _ = dequeue q in ();
  let res = dequeue q in
  res = None

(**********************************************)
(*  Lize & Woonha                             *)
(**********************************************)

(* Allocator *)

let%test "string ptr presentation" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 2 in
  assign_string hp ptr 0 "hello";
  assign_string hp ptr 1 "world";
  let res1 = deref_as_string hp ptr 0 in
  let res2 = deref_as_string hp ptr 1 in
  res1 = "hello" && res2 = "world"

let%test "mixed ptr presentation" = 
  let open AllocatorImpl in
  let hp = make_heap 4 in
  let ptr = alloc hp 4 in
  assign_int hp ptr 0 42;
  assign_string hp ptr 1 "hello";
  let res1 = deref_as_int hp ptr 0 in
  let res2 = deref_as_string hp ptr 1 in
  res1 = 42 && res2 = "hello"

let%test "free function test" = 
  let open AllocatorImpl in
  let hp = make_heap 1000 in
  let ptr = alloc hp 2 in
  assign_int hp ptr 0 42;
  assign_int hp ptr 1 12;
  free hp ptr 2;
  let ptr = alloc hp 2 in
  assign_int hp ptr 0 420;
  assign_int hp ptr 1 120;
  let res1 = deref_as_int hp ptr 0 in
  let res2 = deref_as_int hp ptr 1 in
  res1 = 420 && res2 = 120

let%test "free function negative test" = 
  let open AllocatorImpl in
  let hp = make_heap 2 in
  let ptr = alloc hp 2 in
  assign_int hp ptr 0 42;
  assign_int hp ptr 1 12;
  try let _ = free hp ptr 3 in false
  with _ -> true

let%test "deref function negative test when wrong type" = 
  let open AllocatorImpl in
  let hp = make_heap 2 in
  let ptr = alloc hp 2 in
  assign_int hp ptr 0 42;
  try let _ = deref_as_string hp ptr 0 in false
  with _ -> true

(* DLL *)

let%test "insert_after with 3 nodes" = 
  let heap = AllocatorImpl.make_heap 15 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" 
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n3;
  insert_after heap n1 n2;
  (let n = next heap n1 in
  let i = int_value heap n in
  let s = string_value heap n in
  i = 2 && s = "b") 
  &&
  (let n' = next heap n2 in
  let i' = int_value heap n' in
  let s' = string_value heap n' in
  i' = 3 && s' = "c")

let%test "remove node" = 
  let heap = AllocatorImpl.make_heap 15 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" 
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n2;
  insert_after heap n2 n3;
  (let n = next heap n1 in
  let i = int_value heap n in
  let s = string_value heap n in
  i = 2 && s = "b") &&
  (remove heap n2;
  let n' = next heap n1 in
  let i' = int_value heap n' in
  let s' = string_value heap n' in
  i' = 3 && s' = "c")

let%test "remove node with prev" = 
  let heap = AllocatorImpl.make_heap 15 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" 
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n2;
  insert_after heap n2 n3;
  (let n = prev heap n3 in
  let i = int_value heap n in
  let s = string_value heap n in
  i = 2 && s = "b") &&
  (remove heap n2;
  let n' = prev heap n3 in
  let i' = int_value heap n' in
  let s' = string_value heap n' in
  i' = 1 && s' = "a")

let%test "remove head node" = 
  let heap = AllocatorImpl.make_heap 15 in
  let n1 = mk_node heap 1 "a" 
  and n2 = mk_node heap 2 "b" 
  and n3 = mk_node heap 3 "c" in
  insert_after heap n1 n2;
  remove heap n1;
  insert_after heap n2 n3;
  (let n' = prev heap n3 in
  let i' = int_value heap n' in
  let s' = string_value heap n' in
  i' = 2 && s' = "b") &&
  (AllocatorImpl.is_null heap (prev heap n2))

(* Queue *)

let%test "dequeue order" = 
  let q = mk_queue 10 in
  enqueue q (42, "a");
  enqueue q (15, "b");
  let e1 = dequeue q in
  let e2 = dequeue q in
  e1 = Some (42, "a") && e2 = Some (15, "b") && is_empty q

let%test "is_empty function test" =
  let q = mk_queue 10 in
  let arr =   [|(2, "teaum"); (8, "ylxiy"); (6, "bpelh"); (6, "xonjr"); (9, "yghgg");
    (9, "bvyjr"); (1, "wzgsx"); (4, "dzvmf"); (8, "agajq"); (8, "obght")|] in
  for i = 0 to 9 do enqueue q arr.(i) done;
  for i = 0 to 9 do let _ = dequeue q in () done;
  is_empty q

let%test "dequeue corner case test" =
  let q = mk_queue 10 in
  let a = dequeue q in 
  a = None

let%test "enqueue corner case test" =
  let q = mk_queue 2 in
  enqueue q (1, "royal");
  enqueue q (2, "right");
  try let _ =  enqueue q (3, "roast") in false 
  with _ -> true;;

let%test "heap reclamation: enqueue N > 10 items on size 10 queue" =
  let q = mk_queue 10 in
  let arr =   [|(2, "teaum"); (8, "ylxiy"); (6, "bpelh"); (6, "xonjr"); (9, "yghgg");
    (9, "bvyjr"); (1, "wzgsx"); (4, "dzvmf"); (8, "agajq"); (8, "obght")|] in
  for i = 0 to 9 do enqueue q arr.(i) done;
  let _ = dequeue q in
  let _ = dequeue q in
  let _ = dequeue q in
  enqueue q (5, "toast");
  enqueue q (7, "first");
  let e3 = dequeue q in
  e3 = Some (6, "xonjr") 

