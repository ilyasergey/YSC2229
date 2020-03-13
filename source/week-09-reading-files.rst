.. -*- mode: rst -*-

.. _week-09-file-io:

File Input and Output in OCaml
==============================

File: ``ReadingFiles.ml``

Any realistic program interacts with an outside world by either getting an input from the user via textual or graphical interface, or reading/writing from/to files. 

Input/Output (IO) with files in OCaml can be implemented in multiple ways, and we will employ some of the state-of-the art libraries that provide convenient mechanisms to do so. In order to compile and run the rest of this lecture, please make sure that your have packages ``core`` and ``batteries`` installed via ``opam``::

  opam install core batteries

Amongst other things, ``core`` redefines and enhances some of the familiar modules, which we used before, such as ``List`` and ``Array``. Specifically, it heavily uses *named* arguments for functions. Such arguments require a specific ``name`` to be provided before the value passed (in a form ``~name:value``). With such, they can be placed at any position in the parameter list. As an example, the following expression::

  List.filter (fun x -> x > 1) [1; 2; 3];;

can be written, using a version of ``List`` by ``core`` as follows::

 List.filter ~f:(fun x -> x > 1) [1; 2; 3];;

or::

  List.filter [1; 2; 3] ~f:(fun x -> x > 1);;

Since the parameter ``f`` is named, it can be located at any position.

Reading and Writing with Channels
---------------------------------

In an operational system, files can be concurrently accessed for reading/writing by multiple applications. Because of this, the access to then needs to be controlled. OCaml enables this via *channels* --- an abstraction that guarantees that no one is modifying the file, from which reading is done, and no one is reading from a file, to which we write.

A channel for reading can be used as in the following example that reads all lines from a file with the path ``filename``:: 

 let read_file_to_strings filename = 
   let file = In_channel.create filename in
   let strings = In_channel.input_lines file in
   In_channel.close file;
   strings

Notice that before the function returns its result, it has to close the channel, thus giving up the read-acces to it, so other applications could use it. If it is not done, no other program (including the same one) will be able to get an access to this file (an attempt of doing so will result in a runtime error).

In OCaml, the pattern of reading from a file and closing the channel after completing the optation can be done using the ``with_file`` function which takes a file name an a function that tells ``f`` how to obtain a result from the input channel ``input`` of the file::

 let read_file_to_single_string filename = 
   In_channel.with_file filename ~f:(fun input ->
       In_channel.input_all input)
 

Writing from the files is done similarly, although the corresponding functions for manipulating with write-channels take some additional parameters::

 let write_string_to_file filename text = 
   let outc = Out_channel.create ~append:false filename in
   Out_channel.output_string outc text;
   Out_channel.close outc

 let write_strings_to_file filename lines = 
   Out_channel.with_file ~append:false ~fail_if_exists:false
     filename ~f:(fun out -> List.iter lines ~f:(fun s -> Out_channel.fprintf out "%s\r\n" s))


For instance, both ``Out_channel.create`` and ``Out_channel.with_file`` take optional parameters (that come with default values) ``~append`` and ``~fail_if_exists`` that determine the corresponding behaviour in the case if the file already exists. For instance, by passing ``~append:false`` we indicate that the contents of the file needs to be rewritten, rather than appended to.

Copying Files
-------------

We can use the functions above to copy files::

 let copy_file old_file new_file = 
   let contents = read_file_to_single_string old_file in
   write_string_to_file new_file contents
 
Any Unix-like system comes with hash utilities to ensure that the contents of a file are intact by computing its checksum or hash. This can be done for a file ``filename`` using either::

 cksum filename

or::

 md5 filename

Representing Strings
--------------------

One can think of files as of sequences of 0 and 1 stored in a computer's memory. How can one tell that a file stores "text" or it is "binary"? 

The text files are identified (usually empirically) according to the *encoding* used to represent text in them. One of the most common encoding `ASCII <https://en.wikipedia.org/wiki/ASCII>`_, uses 8-bit sequences (known as bytes or OCaml type ``char``) to encode 256 characters, including upper/lowercase letters of the latin alphabet, numbers and some punctuation marks. Another encoding UTF-16 uses 16-bit sequence, which allows it to encode 65536 symbols, so it includes all of ASCII plus the letters of most of existing alphabets. OCaml strings are treated as sequences of bytes (represented by the data type ``char``). Therefore, the characters from ASCII are represented by ``char`` accurately, while ``UTF-16`` characters are broken into two bytes, when considering them as string components. The difference can be observed via the following example::

 utop # let ascii_string = "ATR";;
 val ascii_string : string = "ATR"
 utop # String.length ascii_string;;
 - : int = 3
 utop # ascii_string.[2];;
 - : char = 'R'

Let us try a string that has a Cyrillic character from UTF-16 encoding::

 utop # let utf16_string = "ATЯ";;
 val utf16_string : string = "ATЯ"
 utop # String.length utf16_string;;
 - : int = 4
 utop # utf16_string.[2];;
 - : char = '\208'

When working with strings the following functions implemented via ``core`` machinery will come useful::

 let trimmer = String.strip 
     ~drop:(fun c -> List.mem ['\n'; ' '; '\r'] 
               c ~equal:(fun a b -> a = b))

 let splitter s = 
   String.split_on_chars ~on:['\n'; ' '; '\r'] s |>
   List.filter ~f:(fun s -> not @@ String.is_empty s)



