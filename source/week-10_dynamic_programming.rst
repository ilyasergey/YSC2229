.. -*- mode: rst -*-

.. _week-10-dp:

Optimisation Problems and Dynamic Programming
=============================================

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_10_DynamicProgramming.ml

*Dynamic programming* is a method for optimising the expensive algorithms by *memoising* the intermediate results of repetitive computations. Such repetitive computations most often appear in the context of applications that requires back-tracking (when one back-tracks, they might re-compute a result already obtained, which is undesirable). The essense of dynamic programming is to store (or, occasionally *tabulate*) the results of the recursive algorithm obtained for "smaller" inputs, so they could be used when computing the result for larger inputs. 

The term `"dynamic programming" <https://en.wikipedia.org/wiki/Dynamic_programming>`_ was originally used in the 1940s by Richard Bellman to describe the process of solving problems where one needs to find the best decisions one after another.

A similar idea has been already demonstrated in the implementation of :ref:`section_kmp`.

Implementing Fibonacci numbers
------------------------------

Let us demonstrate the main idea of dynamic programming on a toy example: efficiently computing `Fibonacci numbers <https://en.wikipedia.org/wiki/Fibonacci_number>`_.

One can implement the definition of Fibonacci numbers is implemented as a program naively as follows::

 let rec naive_fib n = 
   if n <= 1 then 1 
   else naive_fib (n - 1) + naive_fib (n - 2)

This implementation is horribly inefficient: notice that for ``n = 4`` the value ``naive_fib 2`` will be (recursively) computed twice, while ``naive_fib 1`` will be computed 4 times. This is exactly the repeating computations that dynamic programming can help to get rid of.

A somewhat non-obvious trick when applying the DP technique is to restructure the problem, so it would be solved bottom-up, rather than top-down (as in the example above). Typically, it means replacing top-down recursion with bottom-up iteration, and requires some ingenuity. In the case of Fibonacci numbers, let us notice that the result for ``n`` number can be computed from the results for ``n - 1`` and ``n - 2``, hence we only need to store them and use for each iteration. This results in the following efficient implementation::

 let rec memo_fib n = 
   if n <= 1 then 1 
   else begin
     let fib = ref  1 in
     let fib_prev = ref 1 in
     for i = 2 to n do
       let tmp = !fib_prev in 
       fib_prev := !fib;
       fib := tmp + !fib;
     done; 
     !fib
   end

We can now test that our implementation is equivalent to the naive one::

 let test_fib fib_fun n = 
   for i = 0 to n do
     assert (fib_fun n = naive_fib n)
   done;
   true

Let us compare the performance of the two implementation on medium-size inputs::

 utop # open Week_03;;
 utop # time naive_fib 38;;
 Execution elapsed time: 1.433646 sec
 - : int = 63245986
 utop # time memo_fib 38;;
 Execution elapsed time: 0.000008 sec
 - : int = 63245986

As it is easy to show, the complexity of ``naive_fib`` is :math:`O(2^n)`, while the complexity of ``memo_fib`` is :math:`O(n)`.

Knapsack Problem
----------------

*Knapsack Problem* (KP) is a very famous instance of a CSP, combined with an *optimisation problem*. This means that not only we need to find a solution that satisfies the given constraints, but also such that it maximises certain target function. 

The classical formulation of KP is as follows. Given a set of items, each with a weight and a value, determine the number of each item to include in a collection so that the total weight is less than or equal to a given limit and the total value is as large as possible. It derives its name from the problem faced by someone who is constrained by a fixed-size knapsack and must fill it with the most valuable items.

For instance, we can encode our items (each available in a singe instance) in a form of an array, coupling their descriptions with their weight and price::

 (* name * weight * price *)
 let fruit_sack = [|
   ("apple",  1, 1);
   ("melon",  2, 2);
   ("kiwi",   1, 2);
   ("durian", 2, 3);
 |]

 (* Utility functions *)
 let weight items i = 
   let (_, w, _) = items.(i) in w

 let price items i = 
   let (_, _, p) = items.(i) in p

That is, we have a selection of 4 fruit, of different weight and price. For instance, the weight of kiwi is 1 while its cost is 2. Two additional functions are defined to retrieve the corresponding item characteristics.

Determining the Maximal Weight
------------------------------

Now assume that we want to first solve a simpler problem: what is the maximal cumulative price of the items we can carry in the knapsack, without exceeding the weight limit. The following program provides such a solution::

 let knapsack_max_price max_weight items = 
   let num_items = Array.length items in 
   (* n - currently observed item
      w - remaining weight        *)
   let rec solver n w = 
     if n < 0 || w == 0 then 0
     else 
       let wn = weight items n in
       if wn > w 
       then solver (n - 1) w
       else
         let option1 = solver (n - 1) w in
         let pn = price items n in    
         let option2 = pn + solver (n - 1) (w - wn) in
         max option1 option2
   in
   solver (num_items - 1) max_weight

The main bulk of work is done by the function ``solver`` that computes an optimal price for by using only a subset of *first* ``n`` items from the list, while not exceeding the weight ``w``. It does so via back-tracking by computing, at each recursive step (the last ``else``-clause) the maximum of the maximal price with the first ``(n - 1)`` items excluding the last one (``solver (n - 1) w``) or by including the last one and thus increasing the price while reducing the maximal allotted weight (``pn + solver (n - 1) (w - wn)``).

**Question:** What is going to be the result of ``knapsack_max_price 4 fruit_sack``?

Solving Knapsack Problem via Dynamic Programming
------------------------------------------------

The implementation ``knapsack_max_price`` has the same problems as the naive implementation of Fibonacci numbers. For instance, it's not difficult to see that ``solver (n - 1) w`` is going to be called multiple times for the same ``n``. This is a good candidate for using DP memoisation technique. 

We are going to implement the said memoisation by computing, bottom-up, the table ``m`` as a two-dimensional array, where ``m.(i).(w)`` stores the maximal price achievable by taking only ``i`` first items while not exceeding the weight ``w``. Having the maximal weight specified, we can populate our table by iterating through all prefixes of the item list, and all weights from 0 to the maximal given one, thus tabulating all the results. The implementation is as follows::


 let knapsack_max_price_dynamic max_weight items = 
   let num_items = Array.length items in 

   (* Make array of maximal prices 
      m.(i).(w) = max price when taking up to i items 
                  with max weight w *)

   let m = Array.make (num_items + 1) [||] in
   for i = 0 to num_items do
     m.(i) <- Array.make (max_weight + 1) 0
   done;

   (* Main operation *)
   for i = 1 to num_items do
       for w = 1 to max_weight do
         if weight items (i - 1) <= w 
         then
           let p = price items (i - 1) in
           m.(i).(w) <- max 
               (m.(i - 1).(w))
               (m.(i - 1).(w - weight items (i - 1)) + p)
         else m.(i).(w) <- m.(i - 1).(w)
       done
   done;

   (m.(num_items).(max_weight), m)

The implementation of ``knapsack_max_price_dynamic``, in its two nested loops, fills the table ``m`` bottom-up. As the result, it returns the maximal possible weight ``m.(num_items).(max_weight)``, as well as the table ``m`` itself. We can render them to observe the results::

 n  item    w  p |  
 --------------------------------
 0  apple   1  1 |  0  1  1  1  1  
 1  melon   2  2 |  0  1  2  3  3  
 2  kiwi    1  2 |  0  2  3  4  5  
 3  durian  2  3 |  0  2  3  5  6 

**Question:** what is the complexity of ``knapsack_max_price_dynamic`` in terms of ``n`` and ``max_weight``? How come that it does not contradict the NP-completeness of the Knapsack Problem?

Restoring the Optimal List of Items
-----------------------------------

As the final step, let us obtain the actual items that deliver the optimal price. This can be done by walking the resulting memoisation table from the bottom-right cornet up and left. Specifically, if the price is not reduced by going, bottom-up in the same column, from an element ``n`` of the list, then the element ``n`` has not been taken. However, if the price is reduced, this means that means that wee need to include element number ``n`` to the list of taken items, subtract its weight, obtaining the new column to consult and repeat the process. The following program implement this logic::

 let knapsack_obtain_items max_weight items =
   let num_items = Array.length items in 
   let (_, m) = knapsack_max_price_dynamic max_weight items in
   let res = ref [] in
   let w = ref max_weight in 
   for i = num_items downto 1 do
     if m.(i).(!w) = m.(i - 1).(!w) then ()
     else begin
       w := !w - weight items (i - 1);
       res :=  (i - 1) :: !res
     end
   done;
   !res

As an example, in the table above we start from ``max_weight = 4`` and ``n = 3``, thus obtaining ``6``. We then notice that the third item (i.e., durian has been taken). We subtract its weight (``2``) and go to the column (``2 = 4 - 2``), repeating the process. In the same way we realise that kiwi was included, but not melon. Finally, apple was also included. As the result, we get the following list of included fruit::

 utop # knapsack_obtain_items 4 fruit_sack;;
 - : int list = [0; 2; 3]

