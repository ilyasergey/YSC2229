


(* Swapping two elements in an array *)

let swap arr i j = 
  let tmp = arr.(i) in
  arr.(i) <- arr.(j);
  arr.(j) <- tmp

let print_int_array arr = 
  let len = Array.length arr in
  Printf.printf "[| ";
  for i = 0 to len - 1 do
    Printf.printf "%d" arr.(i);
    if i < len - 1 
    then Printf.printf "; "
    else ()      
  done;
  Printf.printf " |]\n"

let a1 = [|6; 239; 5; 2; 3; 42; 0|]

(* Tell about index out of bounds *)

let a2 = Array.make 10 0

(**********************************************)
(*  Essence of the simple sorting             *)
(*

* Grow up the sorted array path
* Adjust it as the new elements come by

*)
(**********************************************)



(* Insert_sort: loop-based implementation *)
let insert_sort arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    let j = ref i in 
    while !j > 0 && arr.(!j) < arr.(!j - 1) do
      swap arr !j (!j -1);
      j := !j - 1
    done
  done

(* TODO: invariant *)

(* Exercise:

Rewrite insertion sort, so it would be starting not from the
   beginning, but from the end of an array

*)

(* Print out partial arrays and try the loop invariant *)

let select_sort arr = 
  print_int_array arr;
  let len = Array.length arr in
  for i = 0 to len - 1 do
    Printf.printf "Sorted prefix: "; 
    print_int_array (Array.sub arr 0 i);
    (* Invariant: a[i] holds the minimun wrt a[i ... j] *)
    for j = i to len - 1 do
      if arr.(j) < arr.(i)
      then 
        (swap arr i j;
         print_int_array arr)        
      else ()
    done
  done


(* Exercise:

Rewrite selection sort, so it would be looking for a maximum rather
   than a minimum.

*)

(* Exercise: bubble sort invariant *)

let bubble_sort arr = 
  let len = Array.length arr in
  print_int_array arr;
  (* Invariant: a[0 .. i] is sorted. *)
  for i = 0 to len - 1 do
    let j = ref (len - 1) in
    (* Invariant: a[j] is the smallest in a[j ... len - 1] *)
    while !j > i do
      if arr.(!j) < arr.(!j - 1) 
      then swap arr !j (!j - 1)
      else ();
      j := !j - 1
    done;
    print_int_array arr;
  done
