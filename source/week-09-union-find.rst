.. -*- mode: rst -*-

.. _union-find:

Equivalence Classes and Union-Find
==================================

* File: ``UnionFind.ml``

An equivalence class is a set of elements related by a relation :math:`R`, such that :math:`R` is 

(a) reflexive (any element is related to itself)
(b) symmetric (if :math:`p` is related to :math:`q`, then :math:`q` is related to :math:`p`), and
(c) transitice (if :math:`p` is related to :math:`q` and :math:`q` is related to :math:`r`, then :math:`p` is related to :math:`r`).

Reasoning about inclusion of an element into a certain equivalence class within a set is a common problem in computing. For instance, it appears in the following domains:

* Checking if a computer node is in a certain network segment
* Checking whether two variables in the same program are equivalent (aliases)
* Reasoning about mathematical sets.

We are going to refer to equivalent elements (according to a certain equivalence relation) as to *connected* ones.


Union-Find Structure
--------------------

*Union-Find* is a data structure that allows to efficiently represent a finite set of ``n`` elements (encoded by a segment of integers ``0 ... n``) with a possibility to answer the following questions:

* Are elements ``i`` and ``j`` connected?
* What is an equivalence class of an element ``i``?
* How many equivalence classes are there in the given relation?

In addition to that it allows to modify the current equivalence relation by taking a union of two classes, corresponding by elements ``i`` and ``j``, therefore, possibly affecting the answers to the questions above.

The definition of the Union-Find structure is very simple::

 module UnionFind = struct

   type t = {
     count : int ref;
     id : int array
   }

   (* More definitions come here *)

 end

That is, it only stores a count of equivalence classes and an array, representing the elements. We can create a union-find for ``n`` elements by relying to the previously defined machinery from past lectures::

  let mk_UF n = 
    let ints = 
      ArrayUtil.list_to_array (Week_03.iota (n - 1)) in
    { count = ref n;
      id = ints }

  let get_count uf = !(uf.count)

Working with Sets via Union-Find
--------------------------------

The Union-Find structure is going to rely on an old trick --- encoding
certain information about elements in an array via their locations. In
this particular case, once created, each location in a UF "carrier"
array determines an equivalence class, represented by an element
itself. That is, for instance creating a UF structure via ``mk_UF 10``
we create an equivalence relation with 10 classes, where each element
is only connected to itself.

However, in the future the class of an element might change, which
will be reflected by changing the value in the corresponding array
cell. More specifically, the dependencies in the arrays will be
forming *chains* ending with a *root* --- an element that is in its
own position. Keeping this fact in mind --- that all element-position
chains eventually reach a fixed point (root), we can implement a
procedure by determining the equivalence class of an element, as a
fixed point in the corresponding chain::

  let find uf p = 
    let r = ref p in 
    while (!r <> uf.id.(!r)) do
      r := uf.id.(!r)
    done;
    !r

  let connected uf p q =
    find uf p = find uf q

That is, to determine the class of an element ``p``, the function ``find`` follows the chain that starts from it, via array indices, until it reaches a root, which corresponds to the "canonical element" of ``p``'s equivalence class.

The intuition behind ``find`` becomes more clear once we see how ``union`` is implemented::

  let union uf p q = 
    let i = find uf p in
    let j = find uf q in
    if i = j then ()
    else begin
      uf.id.(i) <- j;
      uf.count := !(uf.count) - 1
    end

If two elements belong to different classes (their canonical elements are different), then one's canonical element is "attached" to another. So now all chain for elements that used to lead to ``i``, will be extended to go to ``j``, hence they will end up in the same equivalence class! To emphasise, recall that initially every element's canonical representation is itself, but this is what changes via ``union``.

Testing Union-Find
------------------

We can observe the evolution of equivalence classes in Union-Find by implementing the following printing machinery::

  let print_uf uf = 
    let n = Array.length uf.id in
    let ids = ArrayUtil.iota (n - 1) in
    for i = 0 to n - 1 do
      let connected = List.find_all (fun e -> find uf e = i) ids in
      if connected <> [] then begin
        Printf.printf "Class %d: [" i;
        List.iter (fun j -> Printf.printf "%d; " j) connected;
        print_endline "]"
      end      
    done                      

Let us run some experiments using ``utop``::

 utop # open UnionFind;;
 utop # let uf = UnionFind.mk_UF 10;;
 val uf : t = {count = {contents = 10}; id = [|0; 1; 2; 3; 4; 5; 6; 7; 8; 9|]}
 utop # UnionFind.print_uf uf;;
 Class 0: [0; ]
 Class 1: [1; ]
 Class 2: [2; ]
 Class 3: [3; ]
 Class 4: [4; ]
 Class 5: [5; ]
 Class 6: [6; ]
 Class 7: [7; ]
 Class 8: [8; ]
 Class 9: [9; ]
 - : unit = ()

Now let us merge some equivalence classes::

 utop #   union uf 0 1; union uf 2 3; union uf 4 5; union uf 6 7; union uf 8 9; union uf 1 8;;
 - : unit = ()
 utop # UnionFind.connected uf 0 9;;
 - : bool = true
 utop # print_uf uf;;
 Class 3: [2; 3; ]
 Class 5: [4; 5; ]
 Class 7: [6; 7; ]
 Class 9: [0; 1; 8; 9; ]
 - : unit = ()

We will make active use of the Union-Find structure in the future lectures.























