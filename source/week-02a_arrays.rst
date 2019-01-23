.. -*- mode: rst -*-

Arrays and Operations on Them
=============================

So far the main data structure we've been looking and and using as a
container is an algebraic list. While simple to work with and grow by
adding new elements to the beginning, algebraic lists have a
significant shortcoming: they do not allow an instant access to their
elements. For instance, in a list ``6; 8; 5; 2; 3; 7; 0``, in order
to obtain its fourth element, one needs to "peel off" for previous
elements by means of deconstructing the list, as implemented by the
function ``nth`` from the standard OCaml library::

  let nth l n =
    if n < 0 then invalid_arg "List.nth" else
    let rec walk l n =
      match l with
      | [] -> failwith "nth"
      | a::l -> if n = 0 then a else walk l (n-1)
    in walk l n
 
Arrays are similar and complementary to lists. They also encode data
structured in a sequence, but allow immediate access to their
elements, referred to by an *index* (i.e., position in an array). At
the low-level, arrays are implemented by means of *fixed offsets*, and
take ful advantage of the random-access memory (RAM), implemented by
the modern compute architectures, allowing one to access a location
with a known address almost immediately.

The price to pay for that is the inability to change the size of an
array dynamically. In essence, once array is created, it "reserves" a
fixed sequence of memory locations in RAM. Indeed, since more data can
be allocated after the array, it is not easy to allow for its future
growth. Therefore, the only way to extend (or shrink) and array is to
allocate a new array of the necessary size.

In OCaml, arrays with all known elements can be created sugin the
following syntax::
  
  let a1 = [|6; 8; 5; 2; 3; 7; 0|]

creates an array with 7 numbers and assigns its reference to ``a1``.
It is also possible to create an array of a fixed size, filled with
some "default" element. For instance,::

  let a2 = Array.make 10 0

Creates an array of size 10, filled with zeroes. 

Elements of an array are accessed using their indices::

  # a1.(2);;
  - : int = 5
  # a1.(0);;
  - : int = 6

Notice that the indices start from 0 (not from 1), and end with the
number equal to an array's length - 1. This is often confusing and
might lead to an infamous `Off-by-one error
<https://en.wikipedia.org/wiki/Off-by-one_error>`_. An attempt to
address the elements outside of this range lead to an exception::

  # a1.(7);;
  Exception: Invalid_argument "index out of bounds".  

One can determine the range of indices as the length of an array as
follows::

  # Array.length a1;;
  - : int = 7
  # a1.((Array.length a1) - 1);;
  - : int = 0   

The elements of an array can be altered using the following syntax.
Notice, that upon changing an array's element, no new array is created
(hence the update's type is ``unit``), and it's the initial array that
is modified. In this sense, arrays are similar to references, that are
modified in-place::

  # a1;;
  - : int array = [|6; 8; 5; 2; 3; 7; 0|]
  # a1.(0) <- 12;;
  - : unit = ()
  # a1;;
  - : int array = [|12; 8; 5; 2; 3; 7; 0|]

The following functions swaps two elements of an array indexed via
``i`` and ``j`` (assuming they are within the array indexing bounds)::

  let swap arr i j = 
    let tmp = arr.(i) in
    arr.(i) <- arr.(j);
    arr.(j) <- tmp

It is useful to be able to print a sub-array ``arr.(l) .. arr.(u - 1)`` of
a given array ``arr`` for debugging purposes. Here, for the sake of
simplicity we assume the array to be filled with integers::

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
    print_int_sub_array 0 (len - 1) arr

Notice that the procedure ``print_int_sub_array`` employs the special
bounded iteration loop of a general form::

  for variable = start_value to end_value do
    expression
  done
  
  for variable = start_value downto end_value do
    expression
  done

In both cases ``start_value`` and ``end_value`` must be of type
``int``, and ``expression`` is of type ``unit``. There is no way to
"break" from the iteration in OCaml, interrupting it, hence sometimes
it is more preferable to use a more general ``while``-loop.
