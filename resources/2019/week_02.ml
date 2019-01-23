(* ## Sorting the lists (continued) *)

(* TODO: installing merlin and company-mode *)

(* <copied from the last week> *)

let print_list ls = 
  Printf.printf "[ ";
  List.fold_left 
    (fun z e -> Printf.printf "%d; " e) () ls;
  Printf.printf "] "

let test_list1 = [3; 42; 1; 239]
let test_list2 = [6; 6; 5; 5; 5; 1; 2; 3]  

let insert_sort ls =
  let rec insert elem tail = match tail with
    | [] -> [elem]
    | h :: t ->
      if h < elem
      then h :: (insert elem t)
      else elem :: (h :: t)
  in
  let rec walk sorted_prefix xs = match xs with
    | [] -> sorted_prefix
    | h :: t ->
      print_list sorted_prefix;
      print_list xs;
      print_newline ();
      let new_prefix = insert h sorted_prefix in     
      walk new_prefix t
  in
  walk [] ls

(* </copied from the last week> *)

(* ## Sorting specifications   *)

let rec is_sorted ls = match ls with
  | [] -> true
  | h :: t -> 
    is_sorted t &&
    List.for_all (fun e -> h <= e) t

let have_same_elements ls1 ls2 = 
  List.for_all (fun e ->
      List.find_all (fun e' -> e = e') ls2 =
      List.find_all (fun e' -> e = e') ls1
    ) ls1 &&
  List.for_all (fun e ->
      List.find_all (fun e' -> e = e') ls2 =
      List.find_all (fun e' -> e = e') ls1
    ) ls2

let sorting_spec ls res = 
  is_sorted res &&
  have_same_elements ls res

let test_sort ls =
  sorting_spec ls (insert_sort ls)

(* ## Annotating insert_sort with invariants  *)

let insert_sort_walk_pre ls prefix xs = 
  is_sorted prefix &&
  have_same_elements (prefix @ xs) ls

let insert_sort_walk_post ls res = 
  sorting_spec ls res

let insert_pre elem tail =
  is_sorted tail

let insert_post elem tail res = 
  is_sorted res &&
  have_same_elements (tail @ [elem]) res

let rec insert elem tail = match tail with
  | [] -> [elem]
  | h :: t ->
    if h < elem
    then h :: (insert elem t)
    else elem :: (h :: t)

let insert_sort_inv ls =
  let rec walk sorted_prefix xs = match xs with
    | [] -> sorted_prefix
    | h :: t ->
      assert (insert_pre h sorted_prefix);
      let new_prefix = insert h sorted_prefix in     
      assert(insert_post h sorted_prefix new_prefix);
      (*
      have_same_elements (sorted_prefix @ [h] @ t) ls

      is_sorted new_prefix &&
      have_same_elements 
          (h :: sorted_prefix) new_prefix &&
      
      
      ==> ?

      is_sorted new_prefix &&
      have_same_elements (new_prefix @ t) ls
  
       *)
      assert (insert_sort_walk_pre ls new_prefix t);
      walk new_prefix t
  in
  assert (insert_sort_walk_pre ls [] ls);
  walk [] ls




(********************************************)

(* ## Operations with arrays: swapping, printing, sub-array, converting to list *)

let swap arr i j = 
  let len = Array.length arr in
  assert (i < len && i >= 0);
  assert (j < len && j >= 0);
  let tmp = arr.(i) in
  arr.(i) <- arr.(j);
  arr.(j) <- tmp

(* ## An example array *)


let a1 = [| 5; 2; 8; 3 |]
         
let sub_array_to_list l u arr = 
  let ls = ref [] in
  for i = u - 1 downto l do
    ls := arr.(i) :: !ls
  done;
  !ls

let array_to_list arr = 
  let len = Array.length arr in
  sub_array_to_list 0 len arr
  
let print_sub_array l u arr = 
  print_list (sub_array_to_list l u arr)

let print_array arr = 
  print_list (array_to_list arr)

(* ## Insertion sort *)

let insert_sort arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    let j = ref i in
    while !j > 0 && 
          arr.(!j) < arr.(!j - 1) do 
      swap arr !j (!j - 1);
      j := !j - 1
    done
  done

(* ## Termination of insertion *)

(* Done *)

(* ##  InsertSort invariants and annotated *)

let insert_sort_outer_inv i arr =
  let prefix = sub_array_to_list 0 i arr in
  is_sorted prefix &&
  have_same_elements (array_to_list arr)
    (prefix @
     (sub_array_to_list i (Array.length arr) arr))

let larger_than m ls = 
  List.for_all (fun e -> m <= e) ls

let insert_sort_inner_inv i j arr =
  is_sorted (sub_array_to_list 0 !j arr) &&
  is_sorted (sub_array_to_list (!j + 1) i arr) &&
  larger_than arr.(!j) 
    (sub_array_to_list (!j + 1) i arr)

let insert_sort_inv arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    assert (insert_sort_outer_inv i arr);
    let j = ref i in
    while !j > 0 && 
          arr.(!j) < arr.(!j - 1) do 
      assert (insert_sort_inner_inv i j arr);
      swap arr !j (!j - 1);
      j := !j - 1;
      assert (insert_sort_inner_inv i j arr);
    done;
    assert (insert_sort_outer_inv (i + 1) arr);
  done

(* ##  Select Sort *)

let select_sort arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    for j = i to len - 1 do
      if arr.(i) > arr.(j)
      then swap arr i j
      else ()
    done
  done


