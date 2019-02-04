.. -*- mode: rst -*-

Complexity of Divide-and-Conquer Algorithms
===========================================

We have seen several examples of divide-and-conquer algorithms. As their main trait is dividing the input into several parts and solving the problem recursively, one should be able to analyse their complexity via the recurrence relations method (Section :ref:`sec-rr`). The only thing we need is a little twist:


Changing variable in recurrence relations
-----------------------------------------

Consider the binary search program::

 let rec binary_search arr k = 
   let rec rank lo hi = 
     if hi <= lo 
     then 
       (* Empty array *)
       None
     (* Converged on a single element *)
     else 
       let mid = lo + (hi - lo) / 2 in
       if fst arr.(mid) = k 
       then Some (arr.(mid))
       else if fst arr.(mid) < k
       then rank (mid + 1) hi 
       else rank lo mid  
   in
   rank 0 (Array.length arr)

Its complexity can be described by the following recurrence relation, depending on the size :math:`n` of the input array ``arr``:

.. math:: 

  \begin{align*}
  t(0) &= 0 \\
  t(n) &= t\left(\frac{n}{2}\right) + c
  \end{align*}

where the complexity of returning a value is taken to be negligible (and, hence, 0) and :math:`c` is a complexity of computing the middle and dereferencing elements of an array.

Let us notice that this is not a first-order recurrence relation that we've used to see, as the input size is *divided* by two rather than subtracted 1 as in previous examples. In order to reduce the problem to the one we already know how to solve, we make a *change of variable*, assuming, for the time being, that the size :math:`n` is a power of 2. Specifically, we take :math:`n = 2^k` for some :math:`k`. We can then rewrite the relations above as follows, for a function :math:`f(k) = t(2^k) = t(n)`:

.. math:: 

  \begin{align*}
  f(0) &= t(2^0) = t(1) = c \\
  f(k) &= t(2^k) = t\left(\frac{2^k}{2}\right) + c = f(k - 1) + c
  \end{align*}

Therefore, by changing the variable, we obtain:

.. math:: 

  \begin{align*}
  f(0) &= c \\
  f(k) &= f(k - 1) + c
  \end{align*}

This is a familiar form that can be solved by the method of differences obtaining :math:`f(k) = c \cdot (k + 1)`. An since :math:`f(k) = t(2^k)`, and also :math:`k = \log_2 n`, we get 

.. math::

  t(n) = t(2^k) = f(k) = f(\log_2 n) = c \cdot \log_2 n + c \in O(\log n).

Remember, however, that this has been done under assumptions that :math:`n = 2^k`, and this result is not guaranteed for other :math:`n`. The total asymptotic guarantee, in the big-O sense, can be however, obtained via the following theorem.

.. admonition:: Theorem
                
  If :math:`f(n) \in O(g(n))` for :math:`n` being a power of 2, then :math:`f(n) \in O(g(n))` for *any* :math:`n` if the following two conditions hold:
  1. :math:`g` is non-decreasing for all :math:`n > n_0` for some fixed :math:`n_0`, and
  2. `g(2\cdot n) \in O(g(n))`, i.e., :math:`g` is *smooth* (does not grow too fast).

The first condition of the theorem is true for most of the functions of interest and means that :math:`g` is "predictable" and will not suddenly start decreasing in between the "checkpoints" being the powers of two. The second condition states that in between those checkpoints the function does not grow to fast, so on the segment :math:`[2^k ... 2^{k+1}]` one can still use it for asymptotic approximation. Combinations of polynomials and algorithms are smooth, but it's not the case for exponents and factorial.

Getting back to our example with binary search and its complexity :math:`t(n) \in O(\log n)` for powers of 2, we can assert that

1. :math:`\log n` is growing monotonically, that is, it's non-decreasing.
2. :math:`\log (2n) = :math:`\log 2 + \log n \in O(\log n)`, therefore the function is smooth.

As the result we can conclude that time demand of binary search is within :math:`O(\log n)` unconditionally.

Complexity of Merge Sort
------------------------

Recall the code of merge sort::

 let rec merge_sort arr = 
   let rec sort a = 
     let lo = 0 in
     let hi = Array.length a in
     if hi - lo <= 1 then ()
     else
       let mid = lo + (hi - lo) / 2 in
       let from1 = copy_array a lo mid in
       let from2 = copy_array a mid hi in
       sort from1; sort from2;
       merge from1 from2 a lo hi
   in
   sort arr

Notice that the complexity :math:`t(n)` of the internal ``sort`` is combined from the following components:

* Computing the middle of the array (constant :math:`d`),
* Copying the array into two sub-arrays (:math:`c_1 \cdot n`), and 
* Merging two sub-arrays of the half-size (:math:`c_2 \cdot n`), and 
* Running two recursive sorting calls (:math:`2 \cdot t(n/2)`).

Therefore, merging come constants, we can write its recurrence relation as:

.. math::

  \begin{align*}
  t(0) &= t(1) = 0 \\
  t(n) &= 2 \cdot t\left(\frac{n}{2}\right) + cn + d
  \end{align*}

We can now solve it by means of changing the variable :math:`n = 2^k`, :math:`t(n) = f(2^k)`:

.. math::

  \begin{align*}
  f(0) &= t(1) = 0 \\
  f(k) &= 2 \cdot t\left(\frac{n}{2}\right) + cn + d = 2 f(k - 1) + c \cdot 2^k + d
  \end{align*}

Therefore

.. math::

  \begin{align*}
  f(0) &= 0 \\
  f(k) &= 2 f(k - 1) + c \cdot 2^k + d
  \end{align*}

We can solve this first-order inhomogeneous recurrence relation by changing the function 

.. math::
   
   \begin{align*}
   f(k) &= 2^{k - 1}\cdot g(k) \\
   g(1) &= f(1) = 0
   \end{align*}

Repeating the steps from the previous lectures, we obtain:

.. math::

  f(k) = 2^{k - 1}\cdot g(k) = 2(2^{k - 2}\cdot g(k - 1)) + c \cdot 2^k + d

and by dividing both parts of the equation by :math:`2^{k - 1}`, we obtain:

.. math::

  g(k) = g(k - 1) + 2c + \frac{d}{2^k-1}

By the method of differences, we obtain

.. math::

  g(k) \leq 2c(k - 1) + d

The last sum of series is less than :math:`d`, hence it was approximated by :math:`d`.

We can now substitute back, obtaining

.. math::

  f(k) = 2^{k-1} \cdot g(k) \leq 2^k\cdot c \cdot k + d

Recalling that :math:`t(n) = f(\log_2 n)`, we obtain:

.. math::

  t(n) = c \cdot 2^{\log_2 n}\cdot (\log_2 n) + d = c\cdot n \cdot \log_2 n + d \in O(n \log n)

As we have obtained :math:`t(n) \in O(n \log n)` for the powers of two, we need to check the conditions of the theorem, Indeed, :math:`n \log n` is a monotonically growing function. It is also not difficult to check that it is smooth, hence the worst-case complexity of merge sort is in :math:`O(n \log n)`.

Complexity of Quicksort
-----------------------

Recall the code of Quicksort::

 let quick_sort arr = 
   let rec sort arr lo hi = 
     if hi - lo <= 1 then ()
     else 
       let mid = partition arr lo hi in
       sort arr lo mid;
       sort arr mid hi
   in
   sort arr 0 (Array.length arr)

The complexity of:math:`t(n)` of the internal ``sort`` is combined from the following components:

* Partitioning the array into two sub-arrays (:math:`c \cdot n`), and 
* Running two recursive sorting calls (:math:`2 \cdot t(n/2)`).

Therefore, one can obtain a complexity in the class :math:`O(n \log n)` for quick sort by solving the following recurrence relation, similar to the one we have already solved for merge sort:

.. math::

  \begin{align*}
  t(0) &= t(1) = 0 \\
  t(n) &= 2 \cdot t\left(\frac{n}{2}\right) + n
  \end{align*}

The second component is, however, a bit subtle as the fact that the input is divided by two *is not guaranteed* (unlike in merge sort). The partitioning into two equal halves is only the case if the pivot for partitioning has been chosen so putting it at its "right place" would partition the array precisely in the middle. And, as we've seen from the examples before, this is not always true.

However, remember that we have assumed that all keys in the array are randomly distributed. Therefore, it is highly unlikely that at each recursive call we will partition the array badly (e.g., to :math:`n - 1` and `1` element). Proving that the *average* sorting time of quick sort is still within :math:`O(n \log n)` is beyond the scope of this lecture.
 
As the final remark, when asked about the *worst*-case complexity of Quicksort, one should be careful and tell :math:`O(n \log n)` only specifying that it is an *average*-case complexity on uniformly distributed inputs. For the truly worst-case complexity the recurrence relations will be somewhat different (see :ref:`exercise-quicksort-worst`):

.. math::

  \begin{align*}
  t(0) &= t(1) = 0 \\
  t(n) &= t(n - 1) + n + c
  \end{align*}

What do you think the complexity will be in this case?

The Master Theorem
------------------

Divide-and-conquer algorithms come in many shapes, and so far we have seen only a class of very specific (albeit, arguably, most common) one --- such that divide their input into two parts. For a general case of analysing the recursive algorithms, there is a widely used theorem, known and Master Theorem or a Master Method for solving recurrence relations, which covers a larger class of algorithms. Here we provide necessary definitions to formulate the theorem and give its statement.

.. admonition:: Definition (Theta-notation)

  The positive-valued function :math:`f(x) \in \Theta(g(x))` if and only if there is a value :math:`x_0` and constants :math:`c_1, c_2 > 0`, such that for all :math:`x \geq x_0`, :math:`c_1 \cdot g(x) \leq f(x) \leq c_2 \cdot g(x)`.


.. admonition:: Definition (Omega-notation)

  The positive-valued function :math:`f(x) \in \Omega(g(x))` if and only if there is a value :math:`x_0` and constants :math:`c > 0`, such that for all :math:`x \geq x_0`, :math:`c \cdot g(x) \leq f(x)`.

As a mnemonics, one can think of

* :math:`f(n) \in O(g(n))` as ":math:`f \leq g`"
* :math:`f(n) \in \Omega(g(n))` as ":math:`f \geq g`", and
* :math:`f(n) \in \Theta(g(n))` as ":math:`f = g`"

The following theorem serves a "Swiss-army knife" for recurrence relations of the form :math:`T(n) = aT(n/b) + f(n)`, where :math:`a \geq 1` and `b > 1` are constants, and :math:`f(n)` is eventually non-decreasing.

.. admonition:: Theorem (The Master Method for Solving Recurrences)

  Let :math:`T(n) = aT(n/b) + f(n)`, then :math:`T(n)` has the following asymptotic behaviour:               

  * If :math:`f(n) \in O(n^{\log_b a - \varepsilon})` for some :math:`\varepsilon > 0`, then :math:`T(n) \in \Theta(n^{\log_b a})`;
  * If :math:`f(n) \in \Theta(n^{\log_b a})` for some then :math:`T(n) \in \Theta(n^{\log_b a} \log n)`
  * If :math:`f(n) \in \Omega(n^{\log_b a + \varepsilon})` for some :math:`\varepsilon > 0`, and it :math:`a f(n/b) \leq c f(n)` for some constant :math:`c < 1` and sufficiently large :math:`n`, then :math:`T(n) \in \Theta(f(n))`.

The proof of the Master Theorem as well as its advanced applications are beyond the scope of this course, and you are welcome to refer to the book **Introduction to Algorithms** by Cormen et al. for the details and examples.

