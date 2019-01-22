(* Arrays and sorting of them *)

(* Swapping two elements in an array *)

let swap arr i j = 
  let tmp = arr.(i) in
  arr.(i) <- arr.(j);
  arr.(j) <- tmp

let print_int_sub_array l u arr =
  assert (l <= u);
  assert (u <= Array.length arr);
  Printf.printf "[| ";
  for i = l to u - 1 do
    Printf.printf "%d" arr.(i);
    if i < u - 1
    then Printf.printf "; "
    else ()      
  done;
  Printf.printf " |] "

let print_int_array arr = 
  let len = Array.length arr in
  print_int_sub_array 0 (len - 1) arr

let a1 = [|6; 8; 5; 2; 3; 7; 0|]


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
      swap arr !j (!j - 1);
      j := !j - 1
    done
  done

(* Auxiliary functions for invariants *)

let rec sorted ls = 
  match ls with 
  | [] -> true
  | h :: t -> 
    List.for_all (fun e -> e >= h) t && sorted t

let array_to_list l u arr = 
  assert (l <= u);
  let res = ref [] in
  let i = ref (u - 1) in
  while l < !i do
    res := arr.(!i) :: !res;
    i := !i - 1             
  done;
  !res
  
let sub_array_sorted l u arr = 
  let ls = array_to_list l u arr in 
  sorted ls

let array_sorted arr = 
  sub_array_sorted 0 (Array.length  arr) arr

let is_min ls min = 
  List.for_all (fun e -> min <= e) ls

let is_min_sub_array l u arr min = 
  let ls = array_to_list l u arr in 
  is_min ls min

let print_offset _ = 
  Printf.printf "  "

(* reconstructing the invariant *)

let insert_sort_print arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    print_int_sub_array 0 i arr; 
    print_int_sub_array i len arr;
    print_newline ();
    let j = ref i in 
    while !j > 0 && arr.(!j) < arr.(!j - 1) do
      print_offset ();
      print_int_sub_array 0 (i + 1) arr;
      print_int_sub_array (i + 1) len arr;
      print_newline ();
      swap arr !j (!j - 1);
      j := !j - 1;
    done;
    print_int_sub_array 0 (i + 1) arr; 
    print_newline (); print_newline ()
  done

let insert_sort_inner_loop_inv j i arr = 
  is_min_sub_array !j i arr arr.(!j) &&
  sub_array_sorted 0 !j arr && 
  sub_array_sorted (!j + 1) (i + 1) arr

let insert_sort_outer_loop_inv i arr = 
  sub_array_sorted 0 i arr

let insert_sort_inv arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    assert (insert_sort_outer_loop_inv i arr);    
    let j = ref i in 
    while !j > 0 && arr.(!j) < arr.(!j - 1) do
      assert (insert_sort_inner_loop_inv j i arr);
      swap arr !j (!j - 1);
      j := !j - 1;
      assert (insert_sort_inner_loop_inv j i arr);
    done;
    assert (insert_sort_outer_loop_inv (i + 1) arr)
  done


(* Exercise:

Rewrite insertion sort, so it would be starting not from the
   beginning, but from the end of an array

*)

(* Print out partial arrays and try the loop invariant *)

let select_sort arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    for j = i to len - 1 do
      if arr.(j) < arr.(i)
      then swap arr i j
      else ()
    done
  done

let select_sort_print arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    print_int_sub_array 0 i arr; 
    print_int_sub_array i len arr;
    print_newline ();

    for j = i to len - 1 do
      print_offset ();
      Printf.printf "j = %d, a[j] = %d, a[i] = %d: " j arr.(j) arr.(i);
      print_int_sub_array 0 i arr;
      print_int_sub_array i len arr;
      print_newline ();

      if arr.(j) < arr.(i)
      then swap arr i j
      else ()
    done;

    print_int_sub_array 0 (i + 1) arr; 
    print_int_sub_array (i + 1) len arr;
    print_newline (); print_newline ();
  done

let select_sort_outer_inv i arr =
  sub_array_sorted 0 i arr

let select_sort_inner_inv j i arr = 
  is_min_sub_array i j arr arr.(i) &&
  sub_array_sorted 0 i arr

let select_sort_inv arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    assert (select_sort_outer_inv i arr);
    for j = i to len - 1 do
      assert (select_sort_inner_inv j i arr);
      if arr.(j) < arr.(i)
      then swap arr i j
      else ();
      assert (select_sort_inner_inv (j + 1) i arr);
    done;
    assert (select_sort_outer_inv i arr);
  done


(* Invariant: a[i] holds the minimun wrt a[i ... j] *)


let select_sort_general arr = 
  print_int_array arr; print_newline ();
  let len = Array.length arr in
  for i = 0 to len - 1 do
    Printf.printf "Sorted prefix: "; 
    print_int_array (Array.sub arr 0 i); print_newline ();
    (* Invariant: a[i] holds the minimun wrt a[i ... j] *)
    for j = i to len - 1 do
      if arr.(j) < arr.(i)
      then 
        (swap arr i j;
         print_int_array arr; print_newline ())        
      else ()
    done
  done

(* Exercise:

Rewrite selection sort, so it would be looking for a maximum rather
   than a minimum.

Generalise to take an arbitrary comparator. Sort an array of lists.

*)

(* Exercise: bubble sort invariant *)

let bubble_sort arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    print_int_sub_array 0 i arr; 
    print_int_sub_array i len arr;
    print_newline ();

    let j = ref (len - 1) in
    while !j > i do
      if arr.(!j) < arr.(!j - 1) 
      then swap arr !j (!j - 1)
      else ();
      j := !j - 1;
    done;

    print_int_sub_array 0 i arr; 
    print_int_sub_array i len arr;
    print_newline (); print_newline ();
  done

let bubble_sort_print arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    print_int_sub_array 0 i arr; 
    print_int_sub_array i len arr;
    print_newline ();

    let j = ref (len - 1) in
    while !j > i do
      print_offset ();
      print_int_sub_array 0 i arr; 
      print_int_sub_array i (!j) arr; 
      print_int_sub_array (!j) len arr;
      print_newline ();


      if arr.(!j) < arr.(!j - 1) 
      then swap arr !j (!j - 1)
      else ();
      j := !j - 1;
    done;

    print_int_sub_array 0 (i + 1) arr; 
    print_int_sub_array (i + 1) len arr;
    print_newline (); print_newline ();
  done

let bubble_sort_inv arr = 
  let len = Array.length arr in
  print_int_array arr;
  (* Invariant: a[0 .. i] is sorted. *)  
  for i = 0 to len - 1 do
    assert (sub_array_sorted 0 i arr);
    let j = ref (len - 1) in
    (* Invariant: a[j] is the smallest in a[j ... len - 1] *)
    while !j > i do
      assert (is_min_sub_array !j (len - 1) arr arr.(!j));
      if arr.(!j) < arr.(!j - 1) 
      then swap arr !j (!j - 1)
      else ();
      j := !j - 1;
      assert (is_min_sub_array !j (len - 1) arr arr.(!j))
    done;
    print_int_array arr;
    assert (sub_array_sorted 0 i arr);
  done
