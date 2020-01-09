.. -*- mode: rst -*-

Checking your setup
===================

To ensure that you've got all software installed correctly, let us retrieve, compile and run a small self-contained OCaml project. First, open this GitHub project:

* https://github.com/ysc2229/ocaml-graphics-demo

Click "Clone or Download" button and choose "Use SSH" as a cloning option:

.. image:: ../resources/howto/git.png
   :width: 820px
   :align: center

Next, copy the url ``git@github.com:ysc2229/ocaml-graphics-demo.git`` to your buffer.

Switch to terminal in your WSL Linux or Mac OS system, and create a folder where you'll be storing your OCaml projects. It might be ``~/projects`` or ``~/home/projects`` or whatever you prefer. You can do it as follows::

  cd ~
  mkdir projects
  cd projects

Now run this command from the folder ``projects``::

  git clone git@github.com:ysc2229/ocaml-graphics-demo.git
  cd ocaml-graphics-demo

If prompted to answer a question, simply answer ``y``. We have just created a local copy of the simple repository. Now let's compile it and run the executables. Execute the following commands::

  make
  bin/demo

After a few seconds (longer on Mac OS X), you should get a window with a funny face. Feel free to play with it and close when done. You can also browse the sources of the project with Emacs.

.. image:: ../resources/howto/face.png
   :width: 820px
   :align: center

Well done! Now you're ready to take the class.

