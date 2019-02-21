
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
  print_int_sub_array 0 len arr

let perms a m = 
  let n = Array.length a in 
  if m <= 0 then ();
  let count = ref m in
  let rec walk a k =     
    for i = k to n - 1 do
      swap a k i;
      walk a (k + 1);
      swap a i k;
    done;
    if k = n - 1 
    then (if !count = 0 then
            print_int_array a;
          count := !count - 1)
    else ()         
  in
  walk a 0

let a = [|1; 2; 3|]
