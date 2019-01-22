.. -*- mode: rst -*-

Selection Sort
==============


.. _exercise-selection-max: 

Exercise 2
----------

Rewrite selection sort, so it would walk the array right-to-left,
looking for a maximum rather than a minimum for a currently
unprocessed sub-array, while sorting the overall array in an ascending
order. Write the invariants for this version.

.. _exercise-generalised-sort: 

Exercise 3
----------

Generalise either insertion or selection sort to take an array of
arbitrary type ``'a array`` and comparator ``less_than`` of type ``'a
-> 'a -> bool``, and return an array sorted in an ascending order
according to this comparator. Test your implementation by sorting an
array of lists by length.

.. _exercise-bubble-sort: 

Exercise 4
----------

Bubble Sort
