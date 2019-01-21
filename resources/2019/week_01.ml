(* Week 01: Correctness of Algorithms, Recursion, and Loops *)

(* 1. A function find_min that finds 
      the smallest element in the list *)

let find_min ls =
  let rec walk xs min = match xs with 
    | [] -> min 
    | h :: t ->
      let new_min = if h < min then h else min 
      in walk t new_min
  in 
  match ls with 
  | [] -> None
  | h :: t -> 
    let res = walk t h
    in Some res

(* 2. find_min specification: 
      is_min, find_min_spec  *)

let is_min ls min = 
  List.for_all (fun e -> min <= e) ls

let get_exn o = match o with
  | Some x -> x
  | None -> raise (Failure "No. Such. Element!")

(* 3. testing find_min   *)

let test_find_min ls = 
  let min = get_exn @@ find_min ls
  in is_min ls min

let test_list0 = []
let test_list1 = [3; 42; 1; 239]
let test_list2 = [6; 6; 5; 5; 5; 1; 2; 3]

(* 4. find_min: precondition and postcondition   *)

let walk_post ls xs min res = 
  is_min ls res

let rec remove_first ls n = 
  if n <= 0 then ls
  else match ls with 
    | [] -> []
    | h :: t -> remove_first t (n-1)

let is_suffix xs ls = 
  let n1 = List.length xs in
  let n2 = List.length ls in
  let diff = n2 - n1 in
  if diff < 0 then false
  else
    let ls_tail = remove_first ls diff in
    ls_tail = xs

let walk_pre ls xs min = 
  (is_min ls min ||
   List.exists (fun e -> e < min) xs) &&
  is_suffix xs ls  

(* 5. find_min with invariants, assert with message   *)

let find_min_with_inv ls =
  let rec walk xs min = 
    (* walk_pre ls xs min *)
    match xs with 
    | [] -> min 
    | h :: t ->
      (* is_min ls min  || *)
      (* exists (_ < min) (h :: t)  *)
      let new_min = if h > min then h else min 
      in 
      assert (walk_pre ls t new_min);      
      let res = walk t new_min in 
      assert (walk_post ls t new_min res);
      res
  in 
  match ls with 
  | [] -> None
  | h :: t -> 
    assert (walk_pre ls t h);
    let res = walk t h
    in 
    assert (walk_post ls t h res);
    Some res

(* 6. find_min with loops   *)

let find_min_loop ls =
  let loop xs min = 
    while !xs <> [] do
      let h = List.hd !xs in
      let t = List.tl !xs in
      let new_min = if h < !min then h else !min in
      min := new_min;
      xs := t;
    done;
    !min
  in 
  match ls with 
  | [] -> None
  | h :: t -> 
    let xs = ref t in
    let min = ref h in
    let res = loop xs min
    in Some res


(* 7. find_min with loops: invariant   *)

let walk_pre ls xs min = 
  (is_min ls !min ||
   List.exists (fun e -> e < !min) !xs) &&
  is_suffix !xs ls  

let find_min_loop_inv ls =
  let loop xs min = 
    while !xs <> [] do
      let h = List.hd !xs in
      let t = List.tl !xs in
      let new_min = if h < !min then h else !min in
      min := new_min;
      xs := t;
      assert (walk_pre ls xs min)
    done;
    !min
  in 
  match ls with 
  | [] -> None
  | h :: t -> 
    let xs = ref t in
    let min = ref h in
    assert (walk_pre ls xs min);
    let res = loop xs min
    in Some res

(* 8. insertion sort   *)

let print_list ls = 
  Printf.printf "[";
  List.fold_left 
    (fun z e -> Printf.printf "%d; " e) () ls;
  Printf.printf "]\n"
  

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
      let new_prefix = insert h sorted_prefix in
      print_list new_prefix;
      walk new_prefix t
  in 
  walk [] ls
    
(* 9. sorting specifications   *)


(* 10. annotating insert_sort   *)

