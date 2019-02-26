.. -*- mode: rst -*-

Abstract Data Types
===================

*Data structures* provide an efficient way to represent information, facilitating access to it and its manipulation. However, it is not always desirable to let the client of a data structure know *how exactly* it is implemented. The mechanism for hiding the implementation details (or, alternatively *information hiding*) is typically referred to as *abstraction*, and different programming languages provide various mechanisms to define abstractions.

A data structure, once it implementation details are hidden, becomes an `*abstract data type* <https://en.wikipedia.org/wiki/Abstract_data_type>`_ --- a representation of information, which only allows to manipulate with it by means of a well-defined interface, without exposing the details of how the information is structured.

Most of abstract data types (ADTs) in computer science are targeted to represent, in a certain way, a set of elements, providing different interfaces (i.e., sets of functions/methods) to access elements of a set, add and remove them. A choice of a particular ADT is usually dictated by the needs of a client program and the semantics of the ADT. For instnance, some ADTs are deisgned to facilitate search of a particular element in a set (e.g., search trees), while the others provide a more efficient way to retrieve and element added most recently (e.g., stacks), and different applications might rely on either of those characteristic properties.

In this chapter, we will study several basic abstract data types, learn their properties and applications and see how they can be implemented differently by means of data structures at hand.
