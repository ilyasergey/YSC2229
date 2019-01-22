
(* A function that finds the smallest element in the list *)

let find_min ls = 
  let rec walk xs min = 
    match xs with
    | [] -> min
    | h :: t ->
      let min' = if h < min then h else min in
      walk t min'
  in match ls with
  | h :: t -> 
    let min = walk t h in
    Some min
  | _ -> None

(*  Let's start from some test *)

(* This is a precise specification of the algorithm,
   implemented by `find_min` *)

(* Some testing *)
let is_min ls m = 
  List.for_all (fun e -> e >= m) ls &&
  List.mem m ls
                  

let get_exn o = match o with
  | Some e -> e
  | _ -> raise (Failure "Empty option!") 

let find_min_spec find_min_fun ls = 
  let result = find_min_fun ls in
  ls = [] && result = None ||
  is_min ls (get_exn result) 


let generic_test_find_min find_min = 
  find_min_spec find_min [] &&
  find_min_spec find_min [1; 2; 3] &&
  find_min_spec find_min [31; 42; 239; 5; 100]


let test_find_min = 
  generic_test_find_min find_min

(* Now let's write an invariant for `find_min`'s `walk` *)
(* Remember what an invariant is for:
  * It constrains the parameters of the function
  * It holds before every recursive  call the function 
  * It holds at the end of every function invocation
  * When we return from the function at the top level, 
    it should give us the desired correctness property, i.e., 
   `find_min_spec`
 *)

let find_min_walk_pre ls xs min = 
  is_min ls min ||
  List.exists (fun e -> e < min) xs

let find_min_walk_post ls xs min res = 
  is_min ls res


(* Let us instrument walk_with invariant *) 

let find_min_with_invariant ls = 
  let rec walk xs min = 
    match xs with
    | [] -> 
      assert (find_min_walk_pre ls [] min);
      let res = min in
      assert (find_min_walk_post ls xs min res);
      res
    | h :: t ->
      let min' = if h < min then h else min in
      assert (find_min_walk_pre ls t min');
      let res = walk t min' in
      assert (find_min_walk_post ls xs min res);
      res

  in match ls with
  | h :: t -> 
    assert (find_min_walk_pre ls t h);
    let res = walk t h in
    assert (find_min_walk_post ls t h res);
    Some res
  | _ -> None

(* let test_find_min2_with_inv = 
 *   generic_test_find_min find_min_with_inv *)

(* 

   What happens if we change the `h < min` to `h >= min` above? The
   invariant will no longer hold, as we might have excluded the actual
   minimum from the tail!

 *)

(* TODO: say about tail-recursive functions how to deal with
   invariants for them. *)

(* 

Exercise 1.
-----------

 * Implement find_min2, which finds the second-to-min 
 * Write tests for it
 * Implement an invariant for it and check that it holds.

Hint: Use the following definition:
```
let is_min2 ls m1 m2 = 
  m1 <= m2 &&
  List.for_all (fun e -> e == m1 || m2 <= e )ls
```

The invariant should inform you how to change m1 and m2.

 *)          

(* Solution to the exercise 1 *)

let is_min2 ls m1 m2 = 
  m1 < m2 &&
  List.for_all (fun e -> e == m1 || m2 <= e ) ls &&
  List.mem m2 ls
  

let find_min2_walk_inv ls xs m1 m2 = 
  is_min2 ls m1 m2 ||
  List.exists (fun e -> e < m1 || m1 <= e && e < m2 && e <> m1) xs

let find_min2 ls = 
  let rec walk xs m1 m2 = 
    match xs with
    | [] -> m2
    | h :: t ->
      let m1' = min h m1 in
      let m2' = if h < m1 then m1 else if h < m2 && h <> m1 then h else m2  in
      Printf.printf "m1' = %d, m2' = %d, Inv: %b\n" 
        m1' m2' (find_min2_walk_inv ls t m1' m2') ;
      assert (find_min2_walk_inv ls t m1' m2');
      walk t m1' m2'

  in match ls with
  | h1 :: h2 :: t ->
    let m1 = min h1 h2 in
    let m2 = max h1 h2 in
    Printf.printf "Inv_init: %b\n" (find_min2_walk_inv ls t m1 m2);
    assert (find_min2_walk_inv ls t m1 m2);
    let r = walk t m1 m2 in
    Some r
  | _ -> None

(* Going imperative *)

let find_min_loop ls = 
  
  let loop cur_tail cur_min = 
    while !cur_tail <> [] do
      let xs = !cur_tail in
      let h = List.hd xs in
      let min = !cur_min in
      cur_min := if h < min then h else min;
      cur_tail := List.tl xs
    done;
    !cur_min

  in match ls with
  | h :: t -> 
    let cur_tail = ref t in
    let cur_min = ref h in
    let min = loop cur_tail cur_min in
    Some min
  | _ -> None

(*  Now we need to assign the loop invariant  *)

let find_min_loop_inv ls = 
  
  let loop cur_tail cur_min = 
    assert (find_min_walk_pre ls !cur_tail !cur_min);
    while !cur_tail <> [] do
      let xs = !cur_tail in
      let h = List.hd xs in
      let min = !cur_min in
      cur_min := if h < min then h else min;
      cur_tail := List.tl xs;
      assert (find_min_walk_pre ls !cur_tail !cur_min);
    done;
    !cur_min

  in match ls with
  | h :: t -> 
    let cur_tail = ref t in
    let cur_min = ref h in
    assert (find_min_walk_pre ls !cur_tail !cur_min);
    let min = loop cur_tail cur_min in
    assert (find_min_walk_post ls !cur_tail !cur_min min);
    Some min
  | _ -> None

(* Now how about sorting? *)

let insert_sort ls = 
  let rec walk xs acc =
    match xs with
    | [] -> acc
    | h :: t -> 
      let rec insert elem remaining = 
        match remaining with
        | [] -> [elem]
        | h :: t as l ->
          if h < elem 
          then h :: (insert elem t) else (elem :: l)
      in
      let acc' = insert h acc in
      walk t acc'
  in 
  walk ls []


let rec sorted ls = 
  match ls with 
  | [] -> true
  | h :: t -> 
    List.for_all (fun e -> e >= h) t && sorted t
    
let same_elems ls1 ls2 =
   List.for_all (fun e -> 
      List.find_all (fun e' -> e' = e) ls2 = 
      List.find_all (fun e' -> e' = e) ls1) 
     ls1

let sorted_spec ls res = 
  same_elems ls res && sorted res
     
let sort_test sorter ls = 
  let res = sorter ls in
  sorted_spec ls res

(* Invariant for the outer loop *)
let insert_sort_walk_inv ls xs acc = 
  sorted acc &&
  same_elems (acc @ xs) ls

(* Tell about pre-postconditions and how they generalise invariants

 *)
  
let insert_sort_insert_pre elem prefix  =  sorted prefix

let insert_sort_insert_post res elem prefix  = 
  sorted res &&
  same_elems res (elem :: prefix)

  let insert_sort_with_inv ls = 
    let rec walk xs acc =
      match xs with
      | [] -> 
        let res = acc in
        (* walk's postcondition *)
        assert (sorted_spec ls res); 
        res
      | h :: t -> 

        let rec insert elem remaining = 
          match remaining with
          | [] -> 
            (* insert's postcondition *)
            assert (insert_sort_insert_post [elem] elem remaining);
            [elem]
          | h :: t as l ->
            if h < elem 
            then (
              (* insert's precondition *)
              assert (insert_sort_insert_pre elem t);
              let res = insert elem t in
              (* insert's postcondition *)
              (assert (insert_sort_insert_post (h :: res) elem remaining);
              h :: res))
            else 
              let res = elem :: l in
              (* insert's postcondition *)
              (assert (insert_sort_insert_post res elem remaining);
               res)
        in

        let acc' = (
           (* insert's precondition *)
           assert (insert_sort_insert_pre h acc);
           insert h acc) in
        (* walk's precondition *) 
        assert (insert_sort_walk_inv ls t acc');
        walk t acc'
    in 
    assert (insert_sort_walk_inv ls ls []);
    walk ls []
    
(* 
Exercise 2.
-----------

Parametrise `insert_sort` by a comparison function, and use it to sort both in an asecnding and a descending order.

Exercise 3.
-----------

Implement `insert_sort` without recursion, but using loops. 

Hint: When implementing `insert`, you will need to "break" out of the loop in some case. Consider adding an additional boolean flag `over` to implement it.

Start from the following version:

```
let insert_sort_tail ls = 
  let rec insert elem processed prefix  = 
    match prefix with
    | [] -> processed @ [elem]
    | h :: t as l ->
      if h < elem 
      then 
        let processed' = processed @ [h] in
        insert elem processed' t
      else (elem :: l)
  in
  let rec walk xs acc =
    match xs with
    | [] -> acc
    | h :: t -> 
      let acc' = insert h [] acc in
      walk t acc'
  in 
  walk ls []
```


Check the invariants at the beginning and the end of the loop.

Exercise 4. 
-----------
Use `insert_sort` to implement find_min2.

*)                                     

let insert_inv prefix elem acc remaining run  = 
  sorted acc &&
  (if run
   then same_elems (acc @ elem :: remaining) (elem :: prefix)
   else same_elems acc (elem :: prefix))


let insert_sort_tail_walk_inv ls xs acc = 
  sorted acc &&
  same_elems (acc @ xs) ls

let insert_sort_tail ls = 
  let rec walk xs prefix =
    match xs with
    | [] -> prefix
    | h :: t -> 
        let rec insert elem acc remaining run = 
          if not run then acc
          else match remaining with
            | [] -> acc @ [elem]
            | h :: t as l ->
              if h < elem 
              then 
                let run' = true in
                let acc' = acc @ [h] in
                (* assert (insert_inv prefix elem acc' t run'); *)
                insert elem acc' t run'
              else 
                let run' = false in
                let acc' = acc @ (elem :: l) in
                (* assert (insert_inv prefix elem acc' t run'); *)
                insert elem acc' t run'
        in

        (* assert (insert_inv prefix h [] prefix true); *)
        let acc' = insert h [] prefix true in
        (* assert (insert_sort_tail_walk_inv ls t acc'); *)
        walk t acc'
  in 
  walk ls []
