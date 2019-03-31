.. -*- mode: rst -*-

.. _reachability:

Reachability and Graph Traversals
=================================

https://github.com/ilyasergey/ysc2229-part-two/blob/master/lib/week_12_Reachability.ml

Having the graphs defined, let us now do something interesting with them. In this chapter, we will be looking at the questions of *reachability* between nodes, as allowed by a given graph's topology. In all algorithms, we will be relying on the linked representation::

 open Week_12_Graphs
 open LinkedGraphs


Checking Reachability in a Graph
--------------------------------

Given a graph ``g`` and two its nodes ``init`` and ``final``, let us define a procedure that determines whether we can get from ``init`` to ``final`` by following the edges of ``g``, and if so, return the list of those edges::

 let reachable g init final = 
   let rec walk path visited n = 
     if n = final 
     then Some path
     else if List.mem n visited 
     then None
     else
       (* Try successors *)
       let node = get_node g n in
       let successors = get_next node in
       let visited' = n :: visited in
       let rec iter = function
         | [] -> None
         | h :: t -> 
           let path' = (n, h) :: path in
           match walk path' visited' h with
           | Some p -> Some p
           | None -> iter t
       in
       iter successors
   in
   match walk [] [] init with
   | Some p -> Some (List.rev p)
   | _ -> None

The implementation of ``reachable`` employs the backtracking technique (see the Chapter :ref:`week-10-backtracking`), which is implemented by means of an interplay of the two functions: ``walk`` and ``iter``. The former also checks that we do not hit a *cycle* in a graph, hence it contains the list of ``visited`` nodes. Finally, the ``path`` accumulates the edges (in a reversed) on the way to destination, and is returned at the end, if the path is found.

**Question:** What is the complexity of ``reachable`` in terms of sizes of ``g.V`` and ``g.E``. What would it be if we don't take the complexity of ``List.mem n visited`` into the account?

We can define the reachability predicate as follows::

 let is_reachable g init final = 
   reachable g init final <> None

Testing Reachability
--------------------

The following are the tests for the specific two graphs we have seen, designed with a human intuition in mind::

 open Week_12_Reachability

 let%test _ =  
   let g = LinkedGraphs.parse_linked_int_graph small_graph_shape in
   (* True statements *)
   assert (is_reachable g 0 5);
   assert (is_reachable g 5 1);
   assert (is_reachable g 5 5);

   (* False statements *)
   assert (not (is_reachable g 4 5));
   true

 let%test _ =  
   let g = LinkedGraphs.parse_linked_int_graph medium_graph_shape in
   (* True statements *)
   assert (is_reachable g 2 4);
   assert (is_reachable g 8 12);
   assert (is_reachable g 0 10);

   (* False statements *)
   assert (not (is_reachable g 5 9));
   assert (not (is_reachable g 11 7));
   true


Rendering Paths in a Graph
--------------------------

We can use the same machinery for interactive with GraphViz to highlight the reachable paths in a graph::

 let bold_edge = "[color=red,penwidth=3.0]"

 let graphviz_with_path g init final out = 
   let r = reachable g init final in 
   let attrib (s, d) = match r with
     | None -> ""
     | Some p -> 
       if List.mem (s, d) p 
       then bold_edge
       else ""
   in
   let open Week_10_ReadingFiles in
   let ag = LinkedGraphs.to_adjacency_graph g in
   let s = graphviz_string_of_graph "digraph" " -> " 
       string_of_int attrib ag in
   write_string_to_file out s

For instance, taking the ``g`` to be the medium-size graph from the end of the previous chapter, we can render the result of ``graphviz_with_path g 2 12 "filename.out"`` to the following picture:

.. image:: ../resources/path1.png
   :width: 500px
   :align: center





Depth-First Traversal
---------------------

TODO


Topological Sort
----------------

TODO: Say what a DAG is
