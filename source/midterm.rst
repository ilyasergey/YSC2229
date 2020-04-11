.. -*- mode: rst -*-

Midterm Project: Memory Allocation and Reclamation
==================================================

This midterm project will consist of two parts: team-based coding
assignments and individual implementation reports. 

Coding Assignment 
-----------------

How do we implement references and pointers in languages that do not
provide them? In this project you will be developing a solution for
implementing linked data structures (such as lists and queues) without
relying to OCaml's explicit ``ref`` type, by means of implementing a
custom `C-style memory allocator
<https://en.wikipedia.org/wiki/C_dynamic_memory_allocation>`_.

In order to encode the necessary machinery for dynamically creating
references, we notice that one can represent a collection of similar
values (e.g., of type ``int`` or ``string``) by packaging them into
arrays, so such arrays will play the role of random-access memory. For
instance, two consecutive nodes with the payloads ``(15, "a")`` and
``(42, "b")`` of a doubly-linked list containing pairs of integers can
be encoded by sub-segments of following three arrays: one for pointer
"addresses", one for integers, and one for strings:

.. image:: ../resources/alloc.png
   :width: 800px
   :align: center

A list "node" (``dll_node``) is simply a segment of four consecutive
entries in a pointer array, with the corresponding links to an integer
and a string part of the payload. Therefore, in order to work with a
doubly-linked list represented via three arrays, one should manipulate
with the encoding of references in by means of changing the contents
of those arrays.

The template code for the project can be obtained via the link
available on Canvas, In this project, you are expected to deliver the
following artefacts:

* An implementation of an array-based memory allocator that can
  provide storage (of a *fixed limited* capacity) for dynamically
  "allocated" pointers, integers, and strings, with a possibility of
  updating them. Similarly to languages without automatic memory
  management, such as C, it should be possible to both allocate and
  "free" consecutive pointer segments, making it possible to reuse the
  memory (i.e., "reclaim" it be the allocator).

* An implementation of a doubly-linked list, built on top of the
  allocator interface via the abstract "heap" it provides and the
  operations for manipulating with the pointers. Crucially, the list
  should free the memory occupied by its nodes, when the nodes are
  explicitly removed.

* An implementation of a queue data type (taking ``int * string``
  pairs), following the module signature from Section :ref:`sec_queues`
  and tests for checking that it indeed behaves like a queue. As your
  queue will not be polymorphic only be able to accept elements of a
  specific type, it needs to implement a specialised signature::

   module type Queue = 
   sig
     type t
     val mk_queue : int -> t
     val is_empty : t -> bool
     val is_full :  t -> bool
     val enqueue :  t -> (int * string) -> unit
     val dequeue :  t -> (int * string) option
     val queue_to_list : t -> (int * string) list
   end

The nature of the task imposes some restrictions and hints some
observations:

* You may **not** use OCaml's references (i.e., values of type
  ``ref``) in your implementation.

* As you remember, pointers and arrays are somewhat similar.
  Specifically, most of the pointer operations expect not just the
  pointer ``p`` value but also a non-negative integer "offset" ``o``,
  so that the considered value is located by the "address" ``p + o``.

* The allocator only has to provide storage and the machinery to
  manipulate references storing (a) integers, (b) strings, and (c)
  pointers which can point to either of the three kinds of values. You
  are not expected to support references to any other composite data
  types (such as, e.g., pairs). However, you might need to encode those
  data types using consecutive pointers with offsets.

More hints on the implementation are provided in the ``README.md``
file of the repository template. 

This part of the assignment is to be completed in groups of two.
Please, follow the instruction on Canvas to create a team on GitHub
Classroom and make a submission of your code on Canvas. For this part
of the assignment, both participants will be awarded the same grade,
depending on how well their code implements the tasks and also on the
quality of the provided tests. Feel free to think on how to split the
implementation workload within your team.

Report
------

The reports are written and submitted on Canvas individually. They
should focus on the following aspects of your experience with the
project:

* High-level overview of your design of the allocator implementation.
  How did you define its basic data structures, what were the algorithmic decisions
  you've taken for more efficient memory management? Please, don't
  quote the code verbatim at length (you may provide 3-4 line code
  snippets, if necessary). Pictures and drawings are welcome, but are
  not strictly required.

* What you considered to be the essential properties of your
  allocator implementation of the data structures that rely on it?
  How did you test those properties?

* How the design and implementation effort has been split between the
  team members, and what were your contributions?

* Any discoveries, anecdotes, and gotchas, elaborating on your
  experience with this project.

You individual report should not be very long; please, try to make it
succinct and to the point. 2-3 pages should be enough.
