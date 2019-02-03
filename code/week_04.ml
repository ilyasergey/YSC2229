(* Loading previous modules withour compiling them *)

open Week_02
open Week_03

(****** Quick-sort ***********)

(* Partitioning with respect to an element *)

let partition arr lo hi = 
  if hi <= lo then lo
  else
    let pivot = arr.(hi - 1) in
    let i = ref lo in 
    for j = lo to hi - 2 do
      if fst arr.(j) <= fst pivot 
      then
        (swap arr !i j;
         i := !i + 1)
    done;
    swap arr !i (hi - 1);
    !i


let a = generate_key_value_array 10


(* Printing elements *)

open Printf

let print_kv_array arr lo hi = 
  printf "[|";
  for i = lo to hi - 1 do
    printf "(%d, %s)" (fst arr.(i)) (snd arr.(i));
    if i < hi - 1 then printf "; "
  done;
  printf "|]"

(* Paritition with tracing: *)

let partition_print arr lo hi = 
  if hi <= lo then lo
  else
    let pivot = arr.(hi - 1) in
    let i = ref lo in 
    for j = lo to hi - 2 do

      printf "pivot = (%d, %s)\n" (fst pivot) (snd pivot);
      printf "lo = %d to  i = %d: " lo !i;
      print_kv_array arr lo !i; print_newline ();
      printf "i = %d  to j = %d: "!i j;
      print_kv_array arr !i j; print_newline ();
      printf "j = %d  to hi = %d: "!i hi;
      print_kv_array arr j (hi -1); print_newline ();
      print_newline ();

      if fst arr.(j) <= fst pivot 
      then
        (swap arr !i j;
         i := !i + 1)
    done;
    swap arr !i (hi - 1);
    !i

(* In other words, the troublemakers always go to the beginning *)

(*
Invariants:

in the for-loop:

for k, lo <= k <= i, fst arr.(k) <= fst pivot
for k, i < k <= j, fst arr.(k) > fst pivot
if  k = hi - 1, fst arr.(k) = fst pivot
*)


(* Invariants: all elements are on the right sides (less/ greater than) *)

let quick_sort arr = 
  let rec sort arr lo hi = 
    if hi - lo <= 1 then ()
    else 
      let mid = partition arr lo hi in
      sort arr lo mid;
      sort arr mid hi
  in
  sort arr 0 (Array.length arr)


let quick_sort_print arr = 
  let rec sort arr lo hi = 
    if hi - lo <= 1 then ()
    else 
      let mid = partition arr lo hi in

      printf "mid = %d\n" mid;
      print_kv_array arr lo mid; print_newline ();
      print_kv_array arr mid hi; print_newline ();
      print_newline ();

      sort arr lo mid;
      sort arr mid hi
  in
  sort arr 0 (Array.length arr)


(* Generalising sorting *)

(* By passing the comparator *)

let generic_quick_sort arr ~comp = 
  let partition arr lo hi = 
    if hi <= lo then lo
    else
      let pivot = arr.(hi - 1) in
      let i = ref lo in 
      for j = lo to hi - 2 do
        if comp arr.(j) pivot <= 0 
        then
          (swap arr !i j;
           i := !i + 1)
      done;
      swap arr !i (hi - 1);
    !i
  in
  let rec sort arr lo hi = 
    if hi - lo <= 1 then ()
    else 
      let mid = partition arr lo hi in
      sort arr lo mid;
      sort arr mid hi
  in
  sort arr 0 (Array.length arr)

let key_order_asc = 
  fun x y -> if
    fst x < fst y then -1
    else if fst x = fst y then 0
    else 1
      
let kv_quick_sort_asc =
  generic_quick_sort ~comp:key_order_asc

let key_order_desc x y = key_order_asc y x
  
let kv_quick_sort_desc =  
  generic_quick_sort ~comp:key_order_desc

(* By creating a functor *)

module type Comparable = sig
  type t
  val comp : t -> t -> int
end

module Sorting(Comp: Comparable) = struct
  include Comp

  let sort arr  = 
    let partition arr lo hi = 
      if hi <= lo then lo
      else
        let pivot = arr.(hi - 1) in
        let i = ref lo in 
        for j = lo to hi - 2 do
          if comp arr.(j) pivot <= 0 
        then
          (swap arr !i j;
           i := !i + 1)
      done;
      swap arr !i (hi - 1);
    !i
  in
  let rec sort_aux arr lo hi = 
    if hi - lo <= 1 then ()
    else 
      let mid = partition arr lo hi in
      sort_aux arr lo mid;
      sort_aux arr mid hi
  in
  sort_aux arr 0 (Array.length arr)
end


module KeyAsc (*: Comparable *) = struct
  type t = int * string
  let comp = key_order_asc
end

module KeyDesc = struct
  type t = int * string
  let comp = key_order_desc
end

module AscKVSorting = Sorting(KeyAsc)
module DescKVSorting = Sorting(KeyDesc)

let kv_sort_asc = AscKVSorting.sort
let kv_sort_desc = DescKVSorting.sort




