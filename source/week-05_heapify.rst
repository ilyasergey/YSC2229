.. -*- mode: rst -*-

Maintaining Binary Heaps
========================

Let us now fix the broken heap ``bad_heap`` by restoring an order in it. As we can see, the issue there is between the parent ``(10, "c")`` and a left child ``(11, "f")`` that are out of order. 

"Heapifying" elements of an array
---------------------------------

What we need to do is to swap them (assuming that both subtrees reachable from the children obey the descending order), and also make sure that the swapped element ``(10, "c")`` "sinks down", finding its correct position in a rechable subtree. This procedure of "sinking" is what is implemented by the most important heap-manipulating function shown below::

  (* 3. Restoring the heap property for an element i *)
  let rec max_heapify heap_size arr i = 
    let len = Array.length arr in
    assert (heap_size <= Array.length arr);
    if i > (len - 1) / 2 then ()
    else
      let ai = arr.(i) in
      let largest = ref (i, arr.(i)) in
      let l = left arr i in 

      (* Shall we swap with the left child?.. *)
      if l <> None && 
         (fst (get_exn l)) < heap_size &&
         comp (snd (get_exn l)) (snd !largest) > 0 
      then largest := get_exn l;


      (* May be the right child is even bigger? *)
      let r = right arr i in 
      if r <> None && 
         (fst (get_exn r)) < heap_size &&
         comp (snd (get_exn r)) (snd !largest) > 0
      then largest := get_exn r;


      if !largest <> (i, ai) 
      (* Okay, there is a necessity to progress further... *)
      then 
         (swap arr i (fst !largest); 
          max_heapify heap_size arr (fst !largest))

The implementation of ``max_heapify`` deserves som attention. It takes three arguments, an integer ``heap_size`` (whose role will be explained shortly), and array ``arr`` representing the heap, and an index ``i`` of a parent element of an offending triple. 

The ``heap_size`` serves the purpose of "limiting the scope" of a heap in an array and is always assumed to be less or equal than the array size. The reason why one might need it is because in some applications (as we will soon see), it is convenient to consider only a certain prefix of an array as a heap (and, thus obeying the heap definition), while the remaining suffix does not to be a part of it. One can, therefore, think of  ``heap_size`` as of a "separator" between the heap-y and a non-heapy parts of an array.

The body of ``max_heapify`` is rather straightforward. It first assumes that the element at the position ``arr.(i)`` is the largest one. It then triese to retrieve its both children (if those are within the array size and heap size ranges), and determine the largest of them. If such one is present, it becomes the new parent, swapping with previous one. However, such a swap might have broken the heap-property in one of the subtrees, so the procedure needs to be repeated. Hence, the operation happens recursively for the new child (which used to be a parent, and now, after the swap, resides at the position ``!larger``).

**Question:** Why does ``max_heapify`` terminate?

Let us now restore the heap using the ``max_heapify`` procedure::

 let bad_heap =
   [|(16, "a"); (14, "b"); (10, "c"); (8, "d"); (7, "e"); (11, "f"); (3, "g");
     (2, "h"); (4, "i"); (1, "j")|]

 # is_heap bad_heap;;
 - : bool = false

 # is_heap_print ~print:true bad_heap;;
 Out-of-order elements:
 Parent: (2, (10, c))
 Left: (5, (11, f))
 Right: (6, (3, g))
 - : bool = false

 # max_heapify 10 bad_heap 2;;
 - : unit = ()

 # is_heap_print ~print:true bad_heap;;
 - : bool = true

 # bad_heap;;
 - : (int * string) array =
 [|(16, "a"); (14, "b"); (11, "f"); (8, "d"); (7, "e"); (10, "c"); (3, "g");
   (2, "h"); (4, "i"); (1, "j")|] 

As we can observe the two elements have now been correctly swapped.

Building a heap from an array
-----------------------------
