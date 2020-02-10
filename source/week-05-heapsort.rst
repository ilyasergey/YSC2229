.. -*- mode: rst -*-

Heapsort
========

* File: ``Heaps.ml`` (continued)

Let us now exploit the ability of a max-heap to always keep the
element with the largest key at the beginning, as well as being able
to restore a heap from an "almost-heap" (i.e., the one that only has
one offending triple) in :math:`\Theta(n \log n)`, for construct a
very efficient sorting algorithm --- Heapsort.

Heapsort starts by turning an arbitrary array into a max-heap (by
means of `build_max_heap`). It then repeatedly takes the first element
and swaps it with the "working" element in the tail, building a sorted
array backwards. After each swap, it shifts the "front" of what is
considered to be a heap (i.e., the mentioned above ``heap_size``), and
what is an already sorted array suffix, and restores the heap
structure up to this front. The following code the final addition to
the ``Heaps`` functor::

  let heapsort arr = 
    let len = Array.length arr in
    let heap_size = ref len in
    build_max_heap arr;
    for i = len - 1 downto 1 do
      swap arr 0 i;
      heap_size := !heap_size - 1;
      max_heapify !heap_size arr 0;
    done

Heapsort Complexity
-------------------

The main bulk of complexity is taken by ``build_max_heap arr`` (which
results in :math:`O(n \log n)`) and in running the loop. Since the
loop runs :math:`n/2` iteration, and each reconstruction of the tree
takes :math:`O(\log n)` swaps, the overall complexity of Heapsort is
:math:`O(n \log n)`.


Evaluating Heapsort
-------------------

We can now use our checked to make sure that it indeed delivers sorted arrays::

 module Checker = SortChecker(KV)

 let c = generate_key_value_array 1000
 let d = Array.copy c

The following are the results of the experiment::

 # heapsort d;;
 - : unit = ()
 # Checker.sorted_spec c d;;
 - : bool = true

Which sorting algorithm to choose?
----------------------------------

By now we have seen three linearithmic sorting algorithms: merge sort,
Quicksort and Heapsort. The first two achieve efficiency via
divide-and-conquer strategy (structuring the computations in a tree).
The last one exploits the properties of a maintained data structures
(i.e., a heap), which also coincidentally turns out to be a tree.

It would be interesting to compare the relative performance of the three implementations we have, by running them on three copies of the same array::

 let x = generate_key_value_array 100000
 let y = Array.copy x
 let z = Array.copy x

 let quicksort = kv_sort_asc

Let us now time the executions::

 # time heapsort x;;
 Execution elapsed time: 0.511102 sec
 - : unit = ()
 # time quicksort y;;
 Execution elapsed time: 0.145787 sec
 - : unit = ()
 # time merge_sort z;;
 Execution elapsed time: 0.148201 sec
 - : unit = ()

We can repeat an experiment on a larger array (e.g., :math:`10^6`
elements)::

 # time heapsort x;;
 Execution elapsed time: 6.943117 sec
 - : unit = ()
 # time quicksort y;;
 Execution elapsed time: 2.049979 sec
 - : unit = ()
 # time merge_sort z;;
 Execution elapsed time: 2.192766 sec
 - : unit = ()

As we can see, the relative performance of the three algorithms
remains the same, with our implementation of ``heapsort`` being about
3.5 slower than both ``quicksort`` and ``merge_sort``.

The reason why ``quicksort`` beats ``heapsort`` by a constant factor
is because is almost doesn't perform "unnecessary" element swapping,
which is time consuming. In contrast, even if all of the array is
already ordered, ``heapsort`` is going to swap all of them in order to
make a heap structure.

However, on an almost-sorted array, ``heapsort`` will perform
significantly better than ``quicksort`` and, unlike ``merge_sort``, it
will not require extra memory::

 # let x = generate_key_value_array 10000;;
 ...
 # time quicksort x;;
 Execution elapsed time: 0.014825 sec
 - : unit = ()
 # time quicksort x;;
 Execution elapsed time: 3.650797 sec
 - : unit = ()
 # time heapsort x;;
 Execution elapsed time: 0.044624 sec
 - : unit = ()
