(***********************************)
(* Searching and sorting in arrays *)
(***********************************)

(* Load *)
#load "week_02a_arrays.cmo";;
open Week_02a_arrays

(* Generating elements for an array *)

let generate_keys bound len = 
  let acc = ref [] in
  for i = 0 to len - 1 do
    acc := (Random.int bound) :: ! acc
  done;
  !acc

let generate_words length num =
  let random_ascii_char _ = 
    let rnd = (Random.int 26) + 97 in
    Char.chr rnd
  in
  let random_string _ = 
    let buf = Buffer.create length in
    for i = 0 to length - 1 do
      Buffer.add_char buf (random_ascii_char ())
    done;
    Buffer.contents buf
  in
  let acc = ref [] in
  for i = 0 to num - 1 do
    acc := (random_string ()) :: ! acc
  done;
  !acc

let iota n = 
  let rec walk acc m = 
    if m < 0 
    then acc
    else walk (m :: acc) (m - 1)
  in
  walk [] n

let list_zip ls1 ls2 = 
  let rec walk xs1 xs2 k = match xs1, xs2 with
    | h1 :: t1, h2 :: t2 -> 
      walk t1 t2 (fun acc -> k ((h1, h2) :: acc))
    | _ -> k []
  in
  walk ls1 ls2 (fun x -> x)    

let generate_key_value_array len = 
  let kvs = list_zip (generate_keys len len) (generate_words 5 len) in
  let almost_array = list_zip (iota (len - 1)) kvs in
  let arr = Array.make len (0, "") in
  List.iter (fun (i, kv) -> arr.(i) <- kv) almost_array;
  arr
  
(* TODO: test all these things *)

let time f x =
  let t = Sys.time () in
  let fx = f x in
  Printf.printf "Execution elapsed time: %f sec\n"
    (Sys.time () -. t);
  fx

(* Insertion sort on KV-arrays *)

let new_insert_sort arr = 
  let len = Array.length arr in
  for i = 0 to len - 1 do
    let j = ref i in
    while !j > 0 && (fst arr.(!j - 1)) > (fst arr.(!j)) do
      swap arr !j (!j - 1);
      j := !j - 1
    done
  done

(* Test this! *)

(* Now let's search an element in it *)

let linear_search arr k = 
  let len = Array.length arr in
  let res = ref None in
  let i = ref 0 in 
  while !i < len && !res = None do
    (if fst arr.(!i) = k 
    then res := Some ((!i, arr.(!i))));
    i := !i + 1
  done;
  !res

(* EXERCISE: find elements in a given range of the keys in an unsorted array. 
   Estimate the complexity.
*)

let rec binary_search arr k = 
  let rec rank lo hi = 
    if hi <= lo 
    then 
      (* Empty array *)
      None
    (* Converged on a single element *)
    else 
      let mid = lo + (hi - lo) / 2 in
      if fst arr.(mid) = k 
      then Some (arr.(mid))
      else if fst arr.(mid) < k
      then rank (mid + 1) hi 
      else rank lo mid  
  in
  rank 0 (Array.length arr)

(* Test it! *)

(* Let's annotate it with printing  *)

let rec binary_search_print arr k = 
  let rec rank lo hi = 
    Printf.printf "Subarray: [";
    let ls = array_to_list lo hi arr in
    List.iter (fun (k, v) -> Printf.printf "(%d, %s); " k v) ls;
    Printf.printf "]\n\n";
    if hi <= lo 
    then 
      (* Empty array *)
      None
    (* Converged on a single element *)
    else 
      let mid = lo + (hi - lo) / 2 in
      if fst arr.(mid) = k 
      then Some (arr.(mid))
      else if fst arr.(mid) < k
      then rank (mid + 1) hi 
      else rank lo mid  
  in
  rank 0 (Array.length arr)

let a1 = [|(0, "vzxtx"); (1, "hjqxi"); (3, "wzgsx"); (4, "hkuiu"); (4, "bvyjr");
  (5, "hdgrv"); (5, "sobff"); (5, "bpelh"); (5, "xonjr"); (6, "qjzui");
  (6, "syhze"); (8, "xyzxu"); (9, "gaixr"); (10, "obght"); (11, "wmiwb");
  (11, "dzvmf"); (12, "teaum"); (13, "gazaf"); (14, "svemi"); (15, "rxpus");
  (15, "agajq"); (21, "vztoj"); (21, "oszgf"); (21, "ylxiy"); (23, "itosu");
  (26, "nondm"); (27, "yazoj"); (28, "nqzcl"); (29, "lfevj"); (31, "hfcds");
  (31, "pgrym"); (32, "yghgg")|];;


new_insert_sort a1;;

(* What is the precondition? *)

let binary_search_rank_pre arr lo hi k = 
  let len = Array.length arr in 
  let ls = array_to_list 0 len arr in
  let ls' = array_to_list lo hi arr in
  if List.exists (fun e -> fst e = k) ls
  then List.exists (fun e -> fst e = k) ls'
  else not (List.exists (fun e -> fst e = k) ls')

(* Annotating with an invariant *)

let binary_search_inv arr k = 
  let rec rank lo hi = 
    Printf.printf "lo = %d, hi = %d\n" lo hi;
    Printf.printf "Subarray: [";
    let ls = array_to_list lo hi arr in
    List.iter (fun (k, v) -> Printf.printf "(%d, %s); " k v) ls;
    Printf.printf "]\n";
    if hi <= lo 
    then 
      (* Empty array *)
      None
    (* Converged on a single element *)
    else 
      let mid = lo + (hi - lo) / 2 in
      Printf.printf "mid = %d\n" mid;
      if fst arr.(mid) = k 
      then Some (arr.(mid))
      else if fst arr.(mid) < k
      then
        (Printf.printf "THEN: lo = %d, hi = %d\n\n" (mid + 1) hi;
        assert (binary_search_rank_pre arr (mid + 1) hi k);
        rank (mid + 1) hi) 
      else 
        (Printf.printf "ELSE: lo = %d, hi = %d\n\n" lo mid;
        assert (binary_search_rank_pre arr lo mid k);
         rank lo mid)
  in
  let len = Array.length arr in 
  assert (binary_search_rank_pre arr 0 len k);
  rank 0 len



(* EXERCISE: exponential search *)
    
let rec rank arr k lo hi = 
  if hi <= lo 
  then 
    (* Empty array *)
    None
    (* Converged on a single element *)
  else 
    let mid = lo + (hi - lo) / 2 in
    if fst arr.(mid) = k 
    then Some (arr.(mid))
    else if fst arr.(mid) < k
    then rank arr k (mid + 1) hi 
    else rank arr k lo mid  
        

let exponential_search arr k = 
  let len = Array.length arr in
  let rec inflate bound = 
    Printf.printf "Bound = %d\n" bound;
    if bound < len && fst arr.(bound) < k 
    then inflate (bound * 2)
    else if bound < len then bound else len
  in
  if len = 0 then None
  else
    let bound = inflate 1 in
    rank arr k 0 bound

(* Merge-sort *)      

(* Merging two arrays *)
let merge from1 from2 dest lo hi =
  let len1 = Array.length from1 in 
  let len2 = Array.length from2 in 
  assert (len1 + len2 = hi - lo);
  let i = ref 0 in
  let j = ref 0 in
  for k = lo to hi - 1 do
    if !i >= len1 
    then (dest.(k) <- from2.(!j); j := !j + 1)
    else if !j >= len2
    then (dest.(k) <- from1.(!i); i := !i + 1)
    else if fst from1.(!i) <= fst from2.(!j)
    then (dest.(k) <- from1.(!i); i := !i + 1)
    else (dest.(k) <- from2.(!j); j := !j + 1)
  done

let from1 = generate_key_value_array 10;;
new_insert_sort from1;;

let from2 = generate_key_value_array 10;;
new_insert_sort from2;;

let dest = Array.make 20 (0, "")


(* Now the merge-sort *)

let copy_array arr lo hi =
  let len = hi - lo in
  assert (len >= 0);
  if len = 0 then [||]
  else 
    let res = Array.make len arr.(lo) in
    for i = 0 to len - 1 do
      res.(i) <- arr.(i + lo)
    done;
    res
    
let rec merge_sort arr = 
  let rec sort a = 
    let hi = Array.length a in
    let lo = 0 in
    if hi - lo <= 1 then ()
    else
      let mid = lo + (hi - lo) / 2 in
      let from1 = copy_array a lo mid in
      let from2 = copy_array a mid hi in
      sort from1; sort from2;
      merge from1 from2 a lo hi
  in
  sort arr

(* Invariants *)

let rec sorted ls = 
  match ls with 
  | [] -> true
  | h :: t -> 
    List.for_all (fun e -> fst e >= fst h) t && sorted t

let array_to_list l u arr = 
  assert (l <= u);
  let res = ref [] in
  let i = ref (u - 1) in
  while l <= !i do
    res := arr.(!i) :: !res;
    i := !i - 1             
  done;
  !res
  
let sub_array_sorted l u arr = 
  let ls = array_to_list l u arr in 
  sorted ls

let array_sorted arr = 
  sub_array_sorted 0 (Array.length  arr) arr

let merge_pre from1 from2 = 
  array_sorted from1 && array_sorted from2

let same_elems ls1 ls2 =
  List.for_all (fun e ->
      List.find_all (fun e' -> e = e') ls2 =
      List.find_all (fun e' -> e = e') ls1
    ) ls1 &&
  List.for_all (fun e ->
      List.find_all (fun e' -> e = e') ls2 =
      List.find_all (fun e' -> e = e') ls1
    ) ls2

let merge_post from1 from2 arr lo hi = 
  array_sorted arr &&
  (let l1 = array_to_list 0 (Array.length from1) from1 in
  let l2 = array_to_list 0 (Array.length from2) from2 in
  let l = array_to_list lo hi arr in
  same_elems (l1 @ l2) l)
  
let rec merge_sort_inv arr = 
  let rec sort a = 
    let hi = Array.length a in
    let lo = 0 in
    if hi - lo <= 1 then ()
    else
      let mid = lo + (hi - lo) / 2 in
      let from1 = copy_array a lo mid in
      let from2 = copy_array a mid hi in
      sort from1; sort from2;
      assert (merge_pre from1 from2);
      merge from1 from2 a lo hi;
      assert (merge_post from1 from2 a lo hi)
  in
  sort arr


(* TODO: Write tests on this! *)

(* EXERCISE: Fast merge-sort *)

let better_merge aux lo mid hi dest =
  let i = ref lo in
  let j = ref mid in
  for k = lo to hi - 1 do
    aux.(k) <- dest.(k)
  done;
  for k = lo to hi - 1 do
    if !i >= mid
    then (dest.(k) <- aux.(!j); j := !j + 1)
    else if !j >= hi
    then (dest.(k) <- aux.(!i); i := !i + 1)
    else if fst aux.(!i) <= fst aux.(!j)
    then (dest.(k) <- aux.(!i); i := !i + 1)
    else (dest.(k) <- aux.(!j); j := !j + 1)
  done

let rec fast_merge_sort arr = 
  let len = Array.length arr in
  let aux = copy_array arr 0 len in

  let rec sort lo hi = 
    if hi - lo <= 1 then ()
    else
      let mid = lo + (hi - lo) / 2 in
      sort lo mid; sort mid hi;
      better_merge aux lo mid hi arr

  in
  sort 0 len


(* Exercise: index-sort *)
