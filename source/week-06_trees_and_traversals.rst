.. -*- mode: rst -*-

Simple Trees and Their Traversals
=================================


A linked tree structure
-----------------------

The following signature describes some of the desired operations with
a binary tree::

 module type BinaryTree = functor(C: Comparable) -> sig

   type 'e tree_node

   val mk_root : 'e -> 'e tree_node

   val value : 'e tree_node -> 'e
   val left : 'e tree_node -> 'e tree_node option
   val right : 'e tree_node -> 'e tree_node option
   val parent : 'e tree_node -> 'e tree_node option

   val get_root : 'e tree_node -> 'e tree_node
   val update_value : 'e tree_node -> 'e -> unit
   val insert_element : C.t tree_node -> C.t -> unit
   val find_node : C.t tree_node -> C.t -> C.t tree_node option

   (* Traversals, with depth *)
   val depth_first_search_rec : 'e tree_node -> (int * 'e) list 
   val depth_first_search_loop : 'e tree_node -> (int * 'e) list 
   val breadth_first_search_loop : 'e tree_node -> (int * 'e) list 

 end

Of particular interest are the last three functions. [TODO]

The module describing a binary tree starts as follows::

 module BinaryTreeImpl : BinaryTree = 
   functor (C: Comparable) -> struct

   type 'e tree_node = {
     value : 'e ref;
     parent  : 'e tree_node option ref;
     left  : 'e tree_node option ref;
     right  : 'e tree_node option ref;
   }

   (* More functions coming here *)

   end

Let us define some convenience functions to work with nodes::

  let value n = !(n.value)
  let left n = !(n.left)
  let right n = !(n.right)
  let parent n = !(n.parent)
  let update_value n v = n.value := v

Since the root of the tree plays a very special role, the following
functions are aimed to facilitate the navigation towards it::

  let is_root n =  parent n = None

  let mk_root e = {value = ref e;
                   parent = ref None;
                   left = ref None;
                   right = ref None}
                   
  let rec get_root n = match parent n with
    | None -> n
    | Some m -> get_root m

Populating a tree
-----------------

Assuming that the three is ordered as a max-heap, we can insert the
node using the following function::

  let rec insert_element n e = 
    if C.comp e (value n) < 0
    then match left n with
      | Some m -> insert_element m e
      | None ->
        let m = {value = ref e;
                 parent = ref @@ Some n;
                 left = ref None;
                 right = ref None} in
        n.left := Some m;
    else match right n with
      | Some m -> insert_element m e
      | None ->
        let m = {value = ref e;
                 parent = ref @@ Some n;
                 left = ref None;
                 right = ref None} in
        n.right := Some m

With this property, it is also easy to find an element with the
necessary key in logarithmic time::

  let rec find_node n k = 
    let nk = value n in 
    if k = nk then Some n
    else if C.comp k nk < 0 
    then match left n with
      | None -> None
      | Some l -> find_node l k
    else match right n with
      | None -> None
      | Some r -> find_node r k

Recursive Depth-First Traversal
-------------------------------

Let us collect all elements of a tree into a queue. For this, we will need a particular queue implementation, e.g., based on double-linked lists::

  open DLLBasedQueue

The first attempt at enumerating all elements of a tree is done via the following recursive procedure::

  let depth_first_search_rec n = 
    let rec walk n q depth =
      enqueue q (depth, value n);
      (match left n with
       | Some l -> walk l q (depth + 1)
       | None -> ());
      (match right n with
       | Some r -> walk r q (depth + 1)
       | None -> ());
    in
    let acc = (mk_queue 0) in
    walk (get_root n) acc 0;
    queue_to_list acc

Non-recursive Depth-First Traversal
-----------------------------------

The same procedure, but with a loop instead of recursion, can be emulated via a stack::

  let depth_first_search_loop n = 
    let open ListBasedStack in
    let loop stack q _depth =
      while not (is_empty stack) do
        let (depth, n) = get_exn @@ pop stack in
        enqueue q (depth, value n);
        (match right n with
         | Some r -> push stack (depth + 1, r)
         | _ -> ());
        (match left n with
         | Some l -> push stack (depth + 1, l)
         | _ -> ());
      done
    in
    let acc = (mk_queue 0) in
    let stack = mk_stack () in
    push stack (0, get_root n);
    loop stack acc 0;
    queue_to_list acc


Breath-First Traversal
----------------------

An alternative way to traverse a tree would be to go by "levels" rather than "deep down". This is known as "breadth-first-search". It can be easily obtained from depth-firrst traversal outlined above by replacing the stack with a queue::

  let breadth_first_search_loop n = 
    let open DLLBasedQueue in
    let loop wlist q _depth =
      while not (is_empty wlist) do
        let (depth, n) = get_exn @@ dequeue wlist in
        enqueue q (depth, value n);
        (match left n with
         | Some l -> enqueue wlist (depth + 1, l)
         | _ -> ());
        (match right n with
         | Some r -> enqueue wlist (depth + 1, r)
         | _ -> ());
      done
    in
    let acc = (mk_queue 0) in
    let wlist = mk_queue 0 in
    enqueue wlist (0, get_root n);
    loop wlist acc 0;
    queue_to_list acc

Experimenting with Tree Traveersals
-----------------------------------

First, let us define a comparaator::

 module KVComp  = struct
   type t = int * string
   let comp (k1, _) (k2, _) = k1 - k2        
 end

We can now instantiate a tree module::

 module KVTree = BinaryTreeImpl(KVComp)
 open KVTree

For the experiments, let us first populate a tree from an array::

 # for i = 0 to 9 do KVTree.insert_element root a.(i) done;;
 - : unit = ()

The recursive depth-first traversal yields the following result::

 # depth_first_search_rec root;;
 - : (int * (int * string)) list =
 [(0, (5, "abcde")); (1, (0, "rartq")); (2, (1, "hpivx")); (3, (2, "lacrp"));
  (4, (2, "dkuet")); (1, (7, "tlzqm")); (2, (5, "bjamg")); (3, (6, "uvfbv"));
  (4, (6, "nsieb")); (2, (7, "kzfkk")); (3, (7, "qlziz"))]

Quite unsurprisingly, the loop-based implementation with an explicit stack results in exactly the same list::

 # depth_first_search_loop root;;
 - : (int * (int * string)) list =
 [(0, (5, "abcde")); (1, (0, "rartq")); (2, (1, "hpivx")); (3, (2, "lacrp"));
  (4, (2, "dkuet")); (1, (7, "tlzqm")); (2, (5, "bjamg")); (3, (6, "uvfbv"));
  (4, (6, "nsieb")); (2, (7, "kzfkk")); (3, (7, "qlziz"))]

Finally, the breadth-first search yields as somewhat different result, but with a different order::

 # breadth_first_search_loop root;;
 - : (int * (int * string)) list =
 [(0, (5, "abcde")); (1, (0, "rartq")); (1, (7, "tlzqm")); (2, (1, "hpivx"));
  (2, (5, "bjamg")); (2, (7, "kzfkk")); (3, (2, "lacrp")); (3, (6, "uvfbv"));
  (3, (7, "qlziz")); (4, (2, "dkuet")); (4, (6, "nsieb"))]





