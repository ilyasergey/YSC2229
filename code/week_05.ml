(* Compiling the previous weeks modules:

 ocamlc week_01.ml week_02.ml week_03.ml week_04.ml 

Creating the new REPL:

 ocamlmktop -o mytoplevel week_01.ml week_02.cmo week_03.cmo week_04.cmo

Then just load ./mytoplevel as your REPL command (instead of ocaml).

*)

open Week_01
open Week_02
open Week_03
open Week_04

(* A functor for printing arrays *)
module ArrayPrinter = functor (P : sig
    type t
    val pp : t -> string
  end) -> struct

    (* Printing machinery *)
    let print_sub_array l u arr =
      assert (l <= u);
      assert (u <= Array.length arr);
      Printf.printf "[| ";
      for i = l to u - 1 do
        Printf.printf "%s" (P.pp arr.(i));
        if i < u - 1
        then Printf.printf "; "
        else ()      
      done;
      Printf.printf " |] "
        
    let print_array arr = 
      let len = Array.length arr in
      print_sub_array 0 len arr              
  end
  
module SortChecker =  functor 
  (C : sig type t val comp : t -> t -> int end) -> struct
  
  let rec sorted ls = 
    match ls with 
    | [] -> true
    | h :: t -> 
      List.for_all (fun e -> C.comp e h >= 0) t && sorted t

  let to_list arr = 
    array_to_list 0 (Array.length arr) arr
      
  let sub_array_sorted l u arr = 
    let ls = array_to_list l u arr in 
    sorted ls
      
  let array_sorted arr = 
    sub_array_sorted 0 (Array.length  arr) arr

  let same_elems ls1 ls2 =
    List.for_all (fun e ->
        List.find_all (fun e' -> e = e') ls2 =
        List.find_all (fun e' -> e = e') ls1
      ) ls1 &&
    List.for_all (fun e ->
        List.find_all (fun e' -> e = e') ls2 =
        List.find_all (fun e' -> e = e') ls1
      ) ls2

  let sorted_spec arr1 arr2 = 
    array_sorted arr2 &&
    same_elems (to_list arr1) (to_list arr2)
      
end

module type CompareAndPrint = sig
  type t
  val comp : t -> t -> int
  (* For pretty-printing *)
  val pp : t -> string
end

(* Binary heaps as arrays *)
module Heaps (C : CompareAndPrint)  = struct
  include C
  include ArrayPrinter(C)


  (* 1. Main heap operations *)
  let parent arr i = 
    if i = 0 
    then (0, arr.(i)) 
    else 
      let j = (i + 1) / 2 - 1 in
      (j, arr.(j))

  let left arr i = 
    let len = Array.length arr in 
    let j = 2 * (i + 1) - 1 in
    if j < len 
    then Some (j, arr.(j))
    else None

  let right arr i = 
    let len = Array.length arr in 
    let j = 2 * (i + 1) in 
    if j < len 
    then Some (j, arr.(j))
    else None

  open Printf

  (* 2. Testing whether something is a heap *)
  let is_heap arr = 
    let len = Array.length arr - 1 in 
    let res = ref true in
    let i = ref 0 in
    while !i <= len / 2 - 1 && !res do
      let this = arr.(!i) in 
      let l = left arr !i in 
      let r = right arr !i in 
      let is_left = l = None || 
                    comp this (snd (get_exn l)) >= 0 in
      let is_right = l = None || 
                     comp this (snd (get_exn r)) >= 0 in
      res := !res && is_left && is_right;
      i := !i + 1
    done;
    !res

  (* The same with printing *)
  let is_heap_print ?(print = false) arr = 
    let len = Array.length arr - 1 in 
    let res = ref true in
    let i = ref 0 in
    while !i <= len / 2 - 1 && !res do
      let this = arr.(!i) in 
      let l = left arr !i in 
      let r = right arr !i in 
      let is_left = l = None || 
                    comp this (snd (get_exn l)) >= 0 in
      let is_right = l = None || 
                     comp this (snd (get_exn r)) >= 0 in
      res := !res && is_left && is_right;
      (if (not !res && print) then (
         let Some(li, ll) = l in
         let Some(ri, rr) = r in
         printf "Out-of-order elements:\n";
         printf "Parent: (%d, %s)\n" !i (pp this);
         printf "Left: (%d, %s)\n" li (pp ll);
         printf "Right: (%d, %s)\n" ri (pp rr)
      ));
      i := !i + 1
    done;
    !res


  let is_heap_prefix arr ?(heap_size = Array.length arr) = 
    let len = Array.length arr - 1 in 
    let res = ref true in
    let i = ref 0 in
    while !i <= len / 2 - 1 && !res do
      let this = arr.(!i) in 
      let l = left arr !i in 
      let r = right arr !i in 
      let is_left = l = None || 
                    comp this (snd (get_exn l)) >= 0 in
      let is_right = l = None || 
                     comp this (snd (get_exn r)) >= 0 in
      res := !res && is_left && is_right;
      i := !i + 1
    done;
    !res

  (* 3. Restoring the heap property: see heapify *)
  let rec max_heapify heap_size arr i = 
    let len = Array.length arr in
    assert (heap_size <= Array.length arr);
    if i > (len - 1) / 2 then ()
    else
      let ai = arr.(i) in
      let largest = ref (i, arr.(i)) in
      let l = left arr i in 

      (* Shall we swap with the left child? *)
      if l <> None && 
         (fst (get_exn l)) < heap_size &&
         comp (snd (get_exn l)) (snd !largest) > 0 
      then largest := get_exn l;


      (* Or with the right child? *)
      let r = right arr i in 
      if r <> None && 
         (fst (get_exn r)) < heap_size &&
         comp (snd (get_exn r)) (snd !largest) > 0
      then largest := get_exn r;

      if !largest <> (i, ai) 
      then 
         (swap arr i (fst !largest); 
          max_heapify heap_size arr (fst !largest))

  (* 4: building a heap from an array *)
  let build_max_heap arr = 
    let len = Array.length arr in
    for i = (len - 1) / 2 downto 0 do
      max_heapify len arr i
    done
        
  (* 5. Heapsort *)
  let heapsort arr = 
    let len = Array.length arr in
    let heap_size = ref len in
    build_max_heap arr;
    for i = len - 1 downto 1 do
      swap arr 0 i;
      heap_size := !heap_size - 1;
      max_heapify !heap_size arr 0;
    done
end

module KV = struct
  type t = int * string
  let comp = key_order_asc
  let pp (k, v) = Printf.sprintf "(%d, %s)" k v
end

module KVHeaps = Heaps(KV)

open KVHeaps

(* 1. Main heap operations *)
    
let test_heap = 
  [|(16, "a");
    (14, "b");
    (10, "c");
    (8, "d");
    (7, "e");
    (9, "f");
    (3, "g");
    (2, "h");
    (4, "i");
    (1, "j");|]

(*
# right test_heap 0;;
- : (int * (int * string)) option = Some (2, (10, "c"))
# left test_heap 1;;
- : (int * (int * string)) option = Some (3, (8, "d"))
# right test_heap 1;;
- : (int * (int * string)) option = Some (4, (7, "e"))
# left test_heap 2;;
- : (int * (int * string)) option = Some (5, (9, "f"))
# right test_heap 2;;
- : (int * (int * string)) option = Some (6, (3, "g"))
# parent test_heap 9;;
- : int * (int * string) = (4, (7, "e"))
# parent test_heap 4;;
- : int * (int * string) = (1, (14, "b"))
# parent test_heap 1;;
- : int * (int * string) = (0, (16, "a"))
*)

(* 2. Testing whether something is a heap *)

(*
# is_heap test_heap;;
- : bool = true
*)

let bad_heap = 
  [|(16, "a");
    (14, "b");
    (10, "c");
    (8, "d");
    (7, "e");
    (11, "f");
    (3, "g");
    (2, "h");
    (4, "i");
    (1, "j");|]

(*

# is_heap_print ~print:true bad_heap;;
Out-of-order elements:
Parent: (2, (10, c))
Left: (5, (11, f))
Right: (6, (3, g))
- : bool = false
*)

(* 3. Restoring the heap property: see heapify *)

(* val bad_heap : (int * string) array =
 *   [|(16, "a"); (14, "b"); (10, "c"); (8, "d"); (7, "e"); (11, "f"); (3, "g");
 *     (2, "h"); (4, "i"); (1, "j")|]
 * # is_heap bad_heap;;
 * - : bool = false
 * # is_heap_print ~print:true bad_heap;;
 * Out-of-order elements:
 * Parent: (2, (10, c))
 * Left: (5, (11, f))
 * Right: (6, (3, g))
 * - : bool = false
 * # max_heapify 10 bad_heap 2;;
 * - : unit = ()
 * # is_heap_print ~print:true bad_heap;;
 * - : bool = true
 * # bad_heap;;
 * - : (int * string) array =
 * [|(16, "a"); (14, "b"); (11, "f"); (8, "d"); (7, "e"); (10, "c"); (3, "g");
 *   (2, "h"); (4, "i"); (1, "j")|] 
 *)

(* 4: building a heap from an array *)

(* Random array *)
(* let a = generate_key_value_array 10 *)
let a = 
[|(7, "sapwd"); (3, "bsxoq"); (0, "lfckx"); (7, "nwztj"); (5, "voeed");
  (9, "jtwrn"); (8, "zovuq"); (4, "hgiki"); (8, "yqnvq"); (3, "gjmfh")|]

let b = 
[| (7, ""); (3, ""); (0, ""); (8, ""); (5, ""); (9, ""); (8, ""); (4, ""); (7, ""); (3, "") |]

(*

val a : (int * string) array =
  [|(3, "maqzi"); (3, "axuop"); (9, "xczgb"); (7, "udzpo"); (8, "ijxsr");
    (7, "idrie"); (7, "zgqrb"); (1, "prioo"); (3, "kwfye"); (5, "flidv")|]
# build_max_heap a;;
- : unit = ()
# a;;
- : (int * string) array =
[|(9, "xczgb"); (8, "ijxsr"); (7, "zgqrb"); (7, "udzpo"); (5, "flidv");
  (7, "idrie"); (3, "maqzi"); (1, "prioo"); (3, "kwfye"); (3, "axuop")|]
# is_heap a;;
- : bool = true

*)

(* 5. Heapsort *)

module Checker = SortChecker(KV)

let c = generate_key_value_array 1000
let d = Array.copy c

(*
# heapsort d;;
- : unit = ()
# Checker.sorted_spec c d;;
- : bool = true

*)

(* 6. Comparing heapsort, quicksort, and merge sort *)

(* let x = generate_key_value_array 1000000
 * let y = Array.copy x
 * let z = Array.copy x *)

let quicksort = kv_sort_asc

(*

# time heapsort x;;
Execution elapsed time: 6.951060 sec
- : unit = ()
# time merge_sort y;;
Execution elapsed time: 2.052311 sec
- : unit = ()
# time quicksort z;;
Execution elapsed time: 2.380267 sec
- : unit = ()

*)

(* 8. Priority queues *)

module PriorityQueue(C: CompareAndPrint) = struct 
  module H = Heaps(C)
  (* Do no inline, just include *)
  open H

  type heap = {
    heap_size : int ref;
    arr : H.t array
  }

  (* Make a priority queue *)
  let mk_queue a = 
    let a' = Array.copy a in
    build_max_heap a';
    {heap_size = ref (Array.length a);
     arr = a'}

  let print_heap h = 
    print_array h.arr

  (* Dereferencing the record *)
  let heap_maxinum h = (h.arr).(0)
                         
  let heap_extract_max h = 
    if !(h.heap_size) < 1 then None
    else
      let a = h.arr in
      let max = a.(0) in
      a.(0) <- a.(!(h.heap_size) - 1);
      h.heap_size := !(h.heap_size) - 1;
      max_heapify !(h.heap_size) h.arr 0;
      Some max

end

module PQ = PriorityQueue(KV)
open PQ

let q = mk_queue (generate_key_value_array 10)

(* Test that the prefix is still a heap *)


(* Inserting elements *)

