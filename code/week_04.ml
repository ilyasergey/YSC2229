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
      printf "i = %d  to j = %d: " !i j;
      print_kv_array arr !i j; print_newline ();
      printf "j = %d  to hi = %d: " j hi;
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
      sort arr (mid + 1) hi
  in
  sort arr 0 (Array.length arr)


let quick_sort_print arr = 
  let rec sort arr lo hi = 
    if hi - lo <= 1 then ()
    else 
      let mid = partition arr lo hi in
      printf "lo = %d, hi = %d\n" lo hi;
      print_kv_array arr lo hi; print_newline ();
      printf "mid = %d\n" mid; print_newline ();
      sort arr lo mid;
      sort arr (mid + 1) hi
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

(*****************************************************)
(*              Linear-time sorting                  *)
(*****************************************************)

let generate_array_small_keys len = 
  let kvs = list_zip (generate_keys 10 len) (generate_words 5 len) in
  let almost_array = list_zip (iota (len - 1)) kvs in
  let arr = Array.make len (0, "") in
  List.iter (fun (i, kv) -> arr.(i) <- kv) almost_array;
  arr

let list_to_array ls = match ls with
  | [] -> [||]
  | h :: t ->
    let len = List.length ls in
    let arr = Array.make len h in
    let almost_array = list_zip (iota (len - 1)) ls in
    List.iter (fun (i, e) -> arr.(i) <- e) almost_array;
    arr

(* bucket sort for a fixed number of buckets *)
  
let simple_bucket_sort bnum arr = 
  let buckets = Array.make bnum [] in
  let len = Array.length arr in 
  for i = 0 to len - 1 do
    let key = fst arr.(i) in
    let bindex = key mod bnum in
    let b = buckets.(bindex) in
    buckets.(bindex) <- arr.(i) :: b
  done;
  let res = ref [] in
  for i = bnum - 1 downto 0 do
    res := List.append (List.rev (buckets.(i))) !res
  done;
  list_to_array !res
  
(* Explain stability of sorting! *)    


(* Enhanced bucket_sort *)

let kv_insert_sort ls = 
  let rec walk xs acc =
    match xs with
    | [] -> acc
    | h :: t -> 
      let rec insert elem remaining = 
        match remaining with
        | [] -> [elem]
        | h :: t as l ->
          if fst h < fst elem 
          then h :: (insert elem t) else (elem :: l)
      in
      let acc' = insert h acc in
      walk t acc'
  in 
  walk ls []

(* The idea to divide into buckets is not so bad *)

let bucket_sort max ?(bnum = 1000) arr = 
  let buckets = Array.make bnum [] in
  let len = Array.length arr in 
  for i = 0 to len - 1 do
    let key = fst arr.(i) in
    let bind = (key / max) * bnum in
    let b = buckets.(bind) in
    buckets.(bind) <- arr.(i) :: b
  done;
  let res = ref [] in
  for i = bnum - 1 downto 0 do
    let bucket_contents = List.rev (buckets.(i)) in 
    let sorted_bucket = kv_insert_sort bucket_contents in
    res := List.append sorted_bucket !res
  done;
  list_to_array !res

let e = generate_key_value_array 1000

(* Radix sort *)

(* Reuse simple_bucket_sort *)

let radix_sort arr = 
  let len = Array.length arr in
  let max_key = 
    let res = ref 0 in
    for i = 0 to len - 1 do
      if fst arr.(i) > !res 
      then res := fst arr.(i)
    done; !res
  in
  if len = 0 then arr
  else
    let radix = ref max_key in
    let ls = array_to_list 0 len arr in
    let keys = List.map fst ls in
    let combined = list_to_array (list_zip keys ls) in
    let res = ref combined in
    while !radix > 0 do
      res := simple_bucket_sort 10 !res;
      for i = 0 to len - 1 do
        let (k, v) = !res.(i) in
        !res.(i) <- (k / 10, v)
      done;
      radix := !radix / 10
    done;
    let result_list = array_to_list 0 len !res in
    list_to_array @@ List.map snd result_list

      
let test_radix_sort arr = 
  let len = (Array.length arr) in
  same_elems (array_to_list 0 len arr) (array_to_list 0 len (radix_sort arr))

