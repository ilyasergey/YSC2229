.. -*- mode: rst -*-

Installing GraphViz
===================

For the next two lectures we will be using the `GraphViz
<https://www.graphviz.org/>`_ tool suite for visualising graph-like
data structures. GraphViz is available on all modern operating
systems and is easy to install. Below, I provide brief instructions on
how to obtain it. As its input, GraphViz accepts a text file in a
special format, which it can then convert to an image of a graph,
taking care of positioning the nodes and rendering the edges between
them. Some examples for using GraphViz can be found by `this link <https://graphs.grevian.org/example>`_.

Microsoft Windows 10
--------------------

Assuming that you have WSL and Ubuntu Linux installed, execute the following commands from the terminal::

  sudo apt install -y graphviz evince

This will install GraphViz as well as the Evince viewer for PDF documents.

Once complete, download `this file <resources/graph.dot>`_. You can do it from the command line as follows::

  wget https://ilyasergey.net/YSC2229/resources/graph.dot  

And execute the following command from the command line::

  dot -Tpdf graph.dot -o graph.pdf

This should produce the file ``graph.pdf``, which you should be view by calling::

  evince graph.pdf

If it looks like a graph with four nodes, you're all set for the next
lecture. Don't worry if your WSL window turns black after that (it
happened to me once after performing this operation). Just restart
your X Server asa usual and it should work fine.

You may also open ``graph.pdf`` with your Windows PDF viewer (e.g.,
Adobe Acrobat) by opening the current folder in Windows Explorer. Just
type in the terminal::

  explorer.exe .

Linux
-----

Follow the same steps as for MS Windows 10 above, using the corresponding package manager.

Mac OS X
--------

Install GraphViz by executing the following command in the terminal::

  brew install graphviz wget

The second utility, ``wget`` allows download files from the command line.

For convenience of viewing the files, add the following line into your configuration file ``~/.profile``::

  alias preview='open -a Preview'

After that, open a new terminal window or tab and download `this file <resources/graph.dot>`_. You can do it from the command line as follows::

  wget https://ilyasergey.net/YSC2229/resources/graph.dot  

And execute the following command from the command line::

  dot -Tpdf graph.dot -o graph.pdf

This should produce the file ``graph.pdf``, which you should be view by calling::

  preview graph.pdf

If it looks like a graph with four nodes, you're all set for the next lecture.
