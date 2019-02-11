.. -*- mode: rst -*-

.. _sec-repl-modules:

OCaml REPL and Multiple Files
=============================

On the previous week we have learned how to compile an OCaml file into a separate module and then use it in other files via the REPL directives ``#load`` and ``open`` (see Section :ref:`sec-loading_modules`).  Unfortunately, when our project grows, the REPL directives (such as ``#load``) prevent regular compilation via OCaml Compiler (``ocamlc``) from the terminal --- the compiler simply complains about bad syntax. Therefore, we need to commented out the REPL-related lines. For instance, in the past week's file, ``week_03.ml`` we have to comment out the following line, in order to compile it::

  (* #load "week_02.cmo";;  *)
  open Week_02

Notice that the module ``Week_02`` is still recognised by Merlin highlighting in Emacs/Aquamacs, as it is a compiled module and is in the same folder. The now commented directive has only served the purpose of informing REPL where to load the the contents of the module ``Week_02``.

To inform REPL of this dependency more elegantly and in a reusable way, let us execute the following commands from the terminal first (assuming ``week_02.ml`` and ``week_03.ml`` are the files from the past weeks, that do not contain REPL directives, such as ``#load``)::

  ocamlc week_02.ml week_03.ml 
  ocamlmktop -o mytoplevel week_02.cmo week_03.cmo

The first line compiles the sources from the past two weeks into two separate modules (whose binary representation is stored in files ``week_02.cmo`` and ``week_03.cmo``); the second line creates a specialised binary ``mytoplevel`` for a REPL, which already has the two past weeks as loaded libraries.

In order to take advantage of this set up, let us create the new file, ``week_04.ml``, which makes use of the past two weeks::

  open Week_02
  open Week_03

Now, when running the REPL from Tuareg (``C-c C-b``), once prompted to choose the executable to interpret OCaml definitions (the default one is ``ocaml``), type instead::

  ./mytoplevel

As the result, the contents of the two past weeks (linked via the ``ocamlmktop`` command as shown above) will be loaded. You can repeat this operation for the next weeks, simply adding what you need loaded modules to REPL, as following the same pattern.
