.. -*- mode: rst -*-

Sums of Series and Complexities of Loops
========================================

So far we have seen the complexities of simple straight-line programs,
taking the maximum of their asymptotic time demand, using the property
of big-O with regard to the maximum. Unfortunately, this approach does
not work if the number of steps an algorithm makes depends on the size
of the input. In such cases, an algorithm typically features a loop,
and the demand of a loop intuitively should be obtained as a sum of
demands of its iterations. 

Consider, for instance, the following OCaml program that sums up
elements of an array::

 let sum = ref 0 in
 for i = 0 to n - 1 do 
     sum := !sum + arr.(i)
 done
 !sum

Each individual summation has complexity :math:`O(1)`. Why can't we
obtain the overall complexity to be :math:`O(1)` if we just sum them
using the rule of maximums (:math:`\max(O(1), \ldots, O(1)) = O(1)`)?

The problem is similar to summing up a series of numbers in math:

.. math::

  \underbrace{1 + 1 + \ldots + 1}_{k~\text{times}} = \sum_{i=1}^{k}1 = k

but also

.. math::
  \lim_{n \rightarrow \infty} \sum_{i=1}^{n}1 = \infty

What in fact we need to estimate is how fast does this sum grow, as a
function of its upper limit :math:`n`, which corresponds the number
of iterations:

.. math::

  \sum_{i=1}^{n}1 = \underbrace{1 + 1 + \ldots + 1}_{n~\text{times}} =
  n \in O(n)

By distributivity of the sums:

.. math::

  \sum_{i=1}^{n} k = \underbrace{k + k + \ldots + k}_{n~\text{times}} =
  n \times k \in O(n)

In general, such sums are referred as *series* in mathematics and have
the standard notation as follows:

.. math::

  \sum_{i= a}^{b} f(i)= f(a) + f(a + 1) + \ldots + f(b)

where :math:`a` is called the lower limit, and :math:`b` is the upper
limit. The whole sum is :math:`0` if :math:`a < b`.

Arithmetic series
-----------------

Arithmetic series are the series of the form :math:`\sum_{i=a}^{b}i`.
Following the example of Gauss, one can notice that

.. math::

 \begin{align*} 
  2 \times \sum_{i=1}^{n} i &= 1 + 2 + \ldots + (n - 1) + n = \\
  &= n + (n - 1) + \ldots + 2 + 1  \\
  &= n \cdot (n + 1)
 \end{align*} 

This gives us the formula for arithmetic series:

.. math::

  \sum_{i=1}^{n}i = \frac{n \cdot (n + 1)}{2} \in O(n^2)

Somewhat surprisingly, an arithmetic series starting at constant non-1
lower bound has the same complexity:

.. math::

  \sum_{i=j}^{n}i = \sum_{i=1}^{n}i - \sum_{i=1}^{j - 1}i 
  = \frac{n \cdot (n + 1)}{2} - \frac{j \cdot (j - 1)}{2} \in O(n^2) 

Geometric series
----------------

Geometric series are defined as series of exponents:

.. math::

  S(n) = a + a^2 + a^3 + \ldots + a^n = \sum_{i=1}^{n}a^i

Let us notice that

.. math::

  \begin{align*}
  a \cdot S(n) &= a^2 + a^3 + \ldots + a^{n + 1} \\
  &= S(n) - a + a^{n+1}
  \end{align*}

Therefore, for :math:`a \neq 1`

.. math::

  S(n) = \frac{a (1 - a^n)}{1 - 1}


Estimating a sum by an integral
-------------------------------

Sometimes it is difficult to write an explicit expression for a sum.
The following trick helps to estimate sums of values of monotonically
growing functions:

.. math::

  \sum_{i=1}^{n}f(i) \leq \int_{1}^{n+1} f(x) dx


.. image:: ../resources/integral.png
   :width: 600px
   :align: center



**Example**: What is the complexity class of :math:`\sum_{i=1}^{n}i^3`?

We can obtain it as follows:

.. math::

   \sum_{i=1}^{n}i^3 \leq \int_{1}^{n+1} x^3 dx =
   \left[\frac{x^4}{4}\right]_{1}^{n+1} = \frac{(n + 1)^4 - 1}{4} \in
   O(n^4)

Big O and function composition
------------------------------

Let us take :math:`f_1(n) \in O(g_1(n))` and :math:`f_2(n) \in
O(g_2(n))`. Assuming :math:`g_2(n)` grows monotonically, what would be
the tight enough complexity class for :math:`f_2(f_1(n))`? 

It's tempting to say that it should be :math:`g_2(g_2(n))`. However,
recalls that by the definition of big O, :math:`f_1(n) \leq c_1\cdot
g_2(n)` and :math:`f_2(n) \leq c_2\cdot g_2(n)` for :math:`n \geq n_0`
and some constants :math:`c_1, c_2` and :math:`n_0`.

By monotonicity of :math:`g_2` we get 

.. math::

  f_2(f_1(n)) \leq c_2 \cdot g_2(f_1(n)) \leq c_2 \cdot g_2(c_1 \cdot
  g_1(n)).

Therefore

.. math::

  f_2(f_1(n)) \in O(g_2(c_1 \cdot g_1(n)))

The implication of this is one should thread function composition with
some care. Specifically, it is okay to drop :math:`c_1` if :math:`g_2`
is a polynomial, logarithmic, or their composition, since:

.. math::

  \begin{align*}
  (c\cdot f(n))^k &= c^k \cdot f(n)^k \in O(f(n)^k) \\
  \log(c\cdot f(n)) &= \log c + \log(f(n)) \in O(\log(f(n)) 
  \end{align*}

However, this does not work more fast-growing functions :math:`g_2(n)`,
such as an exponent and factorial:

.. math::

  \begin{align*}
  k^{c\cdot f(n)} &= (k^c)^{f(n)} \notin O(k^{f(n)}) \\
  (c \cdot f(n))! &= (c\cdot f(n)) \cdot (c\cdot f(n) - 1) \cdot
  \ldots \cdot (f(n))! \notin O((f(n))!)
  \end{align*}

Complexity of algorithms with loops
-----------------------------------

Let us get back to our program that sums up elements of an array::

 let sum = ref 0 in
 for i = 0 to n - 1 do 
     sum := !sum + arr.(i)
 done;
 !sum

The first assignment is an atomic command, and so it the last
references, hence they both take :math:`O(1)`. The bounded
``for``-iteration executes :math:`n` times, each time with a constant
demand of its body, hence it's complexity is :math:`O(n)`. To
summarise, the overall complexity of the procedure is :math:`O(n)`.


Let us now take a look at one of the sorting algorithms that we've
studies, namely, Insertion Sort::

 let insert_sort arr = 
   let len = Array.length arr in
   for i = 0 to len - 1 do
     let j = ref i in 
     while !j > 0 && arr.(!j) < arr.(!j - 1) do
       swap arr !j (!j - 1);
       j := !j - 1
     done
   done

Assuming that the size of the array is :math:`n`, the outer loop makes
:math:`n` iterations. The inner loop, however, goes in an opposite
direction and starts from :math:`j` such that :math:`0 \leq j < n`
and, in the worst case, terminates with :math:`j = 0`. The complexity
of the body of the inner loop is linear (as ``swap`` performs three
atomic operations, and the assignment is atomic). Therefore, we can
estimate the complexity of this sorting by the following sum (assuming
:math:`c` is a constant accounting for the complexity of the inner
loop body):

.. math::

  \sum_{i=0}^{n-1}\sum_{j=0}^{i}c = c \sum_{i=0}^{n - 1}i = c\frac{n (n -
  1)}{2} \in O(n^2).

With this, we conclude that the complexity of the insertion sort is
*quadratic* in the size of its input, i.e., the length of the array.
