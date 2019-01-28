(***********************************)
(* Searching and sorting in arrays *)
(***********************************)

(* Loading last week *)
#load "week_02.cmo";;
open Week_02;;

(* Generating keys via Random.int *)

let generate_numbers bound len = 
  let acc = ref [] in
  for i = 0 to len - 1 do
    let rnum = Random.int bound in
    acc := rnum :: !acc
  done;
  !acc

let random_ascii_char _ =
  let almost_letter = Random.int 26 in
  Char.chr (almost_letter + 97)

let generate_words length num =
  let gen_word _ = 
    let buf = Buffer.create length in
    for i = 0 to length - 1 do
      Buffer.add_char buf (random_ascii_char ())
    done;
    Buffer.contents buf
  in
  let acc = ref [] in
  for i = 0 to num - 1 do
    let word = gen_word () in
    acc := word :: !acc
  done;
  !acc

let iota n = 
  let rec walk acc m = 
    if m < 0 
    then acc
    else walk (m :: acc) (m - 1)
  in
  walk [] (n - 1)

let list_zip ls1 ls2 = 
  let rec walk xs1 xs2 k = match xs1, xs2 with
    | h1 :: t1, h2 :: t2 ->
      walk t1 t2 (fun acc -> k ((h1, h2) :: acc))
    | _ -> k []
  in
  walk ls1 ls2 (fun acc -> acc)

let generate_kv_array len = 
  let keys = generate_numbers len len in
  let values = generate_words 5 len in
  let arr = Array.make len (0, "") in
  let almost_array = 
    list_zip (iota len) (list_zip keys values) in
  List.iter (fun (i, kv) -> arr.(i) <- kv) almost_array;
  arr

let time f x = 
  let t = Sys.time () in
  let fx = f x in
  let t' = Sys.time () in
  Printf.printf "Time elapsed: %f sec.\n" (t' -. t);
  fx

let insert_sort arr = 
  let len = Array.length arr in 
  for i = 0 to len - 1 do
    let j = ref i in
    while !j > 0 && (fst arr.(!j - 1) > fst arr.(!j)) do
      swap arr !j (!j - 1);
      j := !j - 1
    done
  done

let binary_search arr k = 
  let rec rank lo hi =
    if hi <= lo then None
    else
      let mid = (hi - lo) / 2 + lo in
      if fst arr.(mid) = k 
      then Some (mid, arr.(mid))
      else if fst arr.(mid) < k
      then rank (mid + 1) hi
      else rank lo mid
  in
  rank 0 (Array.length arr)
      
(* Mergin two arrays into a sub-array of a larger one *)

let merge from1 from2 dest lo hi = 
  let len1 = Array.length from1 in
  let len2 = Array.length from2 in
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

let copy_array arr lo hi = 
  let len = hi - lo in
  if len = 0 then [||]
  else
    let dest = Array.make len arr.(lo) in
    for i = 0 to len - 1 do
      dest.(i) <- arr.(lo + i)
    done;
    dest

let merge_sort arr = 
  let rec sort a = 
    let lo = 0 in
    let hi = Array.length a in
    if hi - lo <= 1 then ()
    else 
      let mid = lo + (hi - lo) / 2 in
      let from1 = copy_array a lo mid in
      let from2 = copy_array a mid hi in
      sort from1; sort from2;
      merge from1 from2 a lo hi
  in
  sort arr
      


(* copying an array *)


(*  merge-sort *)


(*  merge-sort invariants *)






