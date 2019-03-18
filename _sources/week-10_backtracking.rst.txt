.. -*- mode: rst -*-

.. _week-10-backtracking:

Constraint Solving via Backtracking
===================================

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_09_week_10_Backtracking.ml

*Constraint solving* problems are extremely common in Computer Science. In the most abstract form a constraint problem deals with a finite set of variables ``x1``, ``x2``, ... ``xn`` that can be assigned multiple values, in the most common cases those values being ``0`` and ``1``. In addition to the set of variables, each problem comes with a number of **constraints** in a for of predicates (boolean functions) that render certain assignment schemes to the variables as undesirable. Therefore, you can think of constraint systems as of systems of equations and inequalities on ``x1``, ``x2``, ... ``xn``, and their solutions to be the values of ``x1``, ``x2``, ... ``xn`` that satisfy all the constraints.

Another example of a constraint problem is allocating ``N`` students into groups, such that each group would hame between ``m`` and ``k`` members. The problem could be solved by a simple division, but in the presence of constraints (a student ``A`` does not want to be in the same group with a student ``B``), the finding solution becomes less trivial. While humans are good in solving constraint-satisfaction problems for small number of variables (e.g., 20 or less), it becomes quite tedious and should be implemented as a computer program. 


Constraint Solving by Backtracking
----------------------------------

In practice, most of constraint satisfaction problems (CSPs) do not have an efficient solution, and fall into the category of **intractable**, having complexity :math:`O(2^n)` or :math:`O(n!)` in the number of involved variables. Nevertheless, they still arise very often in practice and hence we need to know how to tackle them algorithmically.

The stated complexities :math:`O(2^n)` and :math:`O(n!)` hint that in order to solve a CSP we often need to enumerate all **subsets** or even all **permutations** of the set of variables. This is due to the fact that for a set of :math:`n` distinct elements, the number its subsets would be :math:`2^n` and the number of permutations would be :math:`n!`. 

When enumerating subsets or permutations, we should take constraints into the account. Instead of trying all permutations/subsets randomly, we can do slightly better by constructing the solution incrementally, while checking the constraints at each intermediate step. However, it might also be the case that, while taking a certain route when assigning values to ``x1``, ``x2``, ... ``xn``, we have went in a "wrong way". In this case, the algorithm for gradually constructing the solution, the algorithm needs to **back-track** to the partial solution, which did not (yet) violate the constraints, and try a different path. Eventually, either the full solution satisfying all constraints is discovered, or no solution is found (in which case CSP is unsolvable). As a graphical analogy, you can think of CSPs as walking by the trees towards possible solutions, back-tracking when a certain branch does not work. This is somewhat reminiscent to the tree of sorting possibilities discussed in Section :ref:`best_worst`.

Computing Solutions with Backtracking
-------------------------------------

In the light of the tree-analogy described above, let us remark that each algorithm implementing a CSP solution by search via back-tracking combines two computational patterns:

* Iteration (e.g., via ``for``-loop) --- for enumerating possible alternatives (branches) to consider at a given stage.
* Recursion --- for going deeper into a certain branch, in a hope that it will bring us closer to a solution.

Examples of CSP solved by Backtracking
--------------------------------------

The tree-based analogy and back-tracking is widely applicable for solving NP-complete problems, such as

* `Boolean satisfiability problem (SAT) <https://en.wikipedia.org/wiki/Boolean_satisfiability_problem>`_
* `Hamiltonian path problem <https://en.wikipedia.org/wiki/Hamiltonian_path_problem>`_
* `Travelling salesman problem <https://en.wikipedia.org/wiki/Travelling_salesman_problem>`_
* `Graph coloring <https://en.wikipedia.org/wiki/Graph_coloring>`_

We will consider some of these problems later in this class, but in this section focus on a simpler (and less practically useful problem) solved by backtracking, namely *N-Queens problem*.

N-Queens problem
----------------

Assume you are given an ``n`` by ``n`` chessboard so that no two queens threaten each other; thus, a solution requires that no two queens share the same row, column, or diagonal. We are going to discover this solution iteratively, via back-tracking, by considering it a CSP.

**Question**: does the solution exist fo any ``n``?

The board is encoded as 2-dimensional array ``board`` of integers (0 or 1). We are going to put queens, iteratively, in each column, starting from the left, and moving right. To check the safety of a partial solution, before placing a new queen in a row ``row`` and a column ``col``, we define the constraints, that check that no other queen on the left part of the board threatens it::

 let is_safe board row col = 
   let n = Array.length board in

   (* Check this row on the left *)
   let rec check_row_left i = 
     if i < 0 then true
     else if board.(row).(i) = 1 then false
     else check_row_left (i - 1) 
   in

   let rec check_left_up_diag i j = 
     if i < 0 || j < 0 then true
     else if board.(i).(j) = 1 then false
     else check_left_up_diag (i - 1) (j - 1)
   in

   let rec check_left_down_diag i j = 
     if i >= n || j < 0 then true
     else if board.(i).(j) = 1 then false
     else check_left_down_diag (i + 1) (j - 1)

   in

   check_row_left col &&
   check_left_up_diag row col &&
   check_left_down_diag row col

The following procedure demonstrates back-tracking by combining the iteration and recursion. It rakes a ``board`` and its size ``n`` and solves the problem (or discovers that it is unsolvable) starting from the column ``col``, assuming the columns on the left are already taken care of::

 let rec solver board n col = 
   let rec loop i = 
     if i = n then false
     else if is_safe board i col
     then begin
       board.(i).(col) <- 1;
       if solver board n (col + 1) 
       then true
       (* Back-tracking *)
       else begin
         board.(i).(col) <- 0;
         loop (i + 1)
       end
     end 
     else loop (i + 1)
   in
   if col >= n 
   then true
   else loop 0

The main work is done by the recursive function ``loop i``, implementing the iteration through **rows** for a fixed column ``col``. Whenever ``loop`` reaches the bottom (row ``i = n``) it stops and returns ``true``, indicating that the solution is found. Alternatively, it tries to install a queen to a position ``board.(i).(col)`` and solve the remainin problem by moving to the next column (``solver board n (col + 1)``). In case if this has failed, it back-tracks (by un-installing the queen) and tries a different row. 

The top-level program simply calls ``solver`` from the leftmost column::

 let solve_n_queens board = 
   let n = Array.length board in
   let _ = solver board n 0 in
   board

**Question:** what is the complexity of ``solve_n_queens`` in terms of the size of the board?

We can check the result via the following functions::

 let mk_board n = 
   let board = Array.make n (Array.make n 0) in
   for i = 0 to n - 1 do
     board.(i) <- Array.make n 0
   done;
   board

 let print_board board = 
   let n = Array.length board in
   for i = 0 to n - 1 do
     for j = 0 to n - 1 do
       Printf.printf "%d  " board.(i).(j);
     done;
     print_endline ""
   done

For instance, for ``n = 8`` the outcome is as follows::

 utop # let b = mk_board 8;;
 val b : int array array =
   [|[|0; 0; 0; 0; 0; 0; 0; 0|]; [|0; 0; 0; 0; 0; 0; 0; 0|];
     [|0; 0; 0; 0; 0; 0; 0; 0|]; [|0; 0; 0; 0; 0; 0; 0; 0|];
     [|0; 0; 0; 0; 0; 0; 0; 0|]; [|0; 0; 0; 0; 0; 0; 0; 0|];
     [|0; 0; 0; 0; 0; 0; 0; 0|]; [|0; 0; 0; 0; 0; 0; 0; 0|]|]
 utop # solve_n_queens b;;
 - : bool * int array array = ...
 utop # print_board b;;

 1  0  0  0  0  0  0  0  
 0  0  0  0  0  0  1  0  
 0  0  0  0  1  0  0  0  
 0  0  0  0  0  0  0  1  
 0  1  0  0  0  0  0  0  
 0  0  0  1  0  0  0  0  
 0  0  0  0  0  1  0  0  
 0  0  1  0  0  0  0  0  

 - : unit = ()

