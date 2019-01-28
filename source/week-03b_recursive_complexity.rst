.. -*- mode: rst -*-

Complexity of Simple Recursive Algorithms
=========================================

In this chapter we will study complexity of the programs that combine
both loops and recursion.


Complexity of computing the factorial
-------------------------------------

Typically, any terminating recursive algorithm works by calling itself
on progressively smaller instances of some data structures. For
instance, consider the "Hello, World!" of all recursive programs ---
the ``factorial`` function::

 let rec factorial n = 
   if n <= 0 then 1
   else n * (factorial (n - 1))

Assume its complexity is the number of multiplications (taken as the
most expensive operations) it performs for a number ``n`` (so ``n``
will also serve as the "size" of the problem). We can write the
relation on factorial's complexity :math:`F(n)` using the following
relation:

.. math:: 

  \begin{align*}
  F(0) &= 0 \\
  F(n) &= F (n - 1) + 1
  \end{align*}

That is, the value of :math:`F(n)` is defined recursively (shouldn't be that much of a surprise, huh?) thourgh the value of :math:`F(n - 1)`.

Method of differences
---------------------

We can now exploit this pattern by constructing a number of equations of the following shape, following the definition of :math:`F(n)` of the factorial complexity, and sum them up together:

.. math::

  \begin{align*}
  && F(n) &- F (n - 1) &= 1 \\
  &+& F(n - 1) &- F (n - 2) &= 1 \\
  &+& F(n - 2) &- F (n - 3) &= 1 \\
  &+& \ldots \\
  &+& F(1) &- F(0) &= 1 \\
  \hline 
  && F(n) &- F(0) &= n
  \end{align*}

As the result, we obtain :math:`F(n) = n` (since :math:`F(0) = 0`), therefore we can conclude that :math:`F(n) \in O(n)`.

Recurrence relations
--------------------

What we've seen as an example of the factorial complexity can be generalised to the following definition of a *recurrence relation*.

.. admonition:: Definition 
  
  Recurrence relation for a function :math:`f` is an equation that expresses the value :math:`f(n)` through the values :math:`f(n-1), \ldots, f(0)`.

Naturally, recurrence relations are a method to express complexities of recursive algorithms depending on input sizes of the recursive call, and we've just seen an example of such for the factorial, namely :math:`F(n) = F(n - 1) + 1`. Similarly to well-founded recursion and induction, recurrence relations require initial values to "bootstrap" the computation (for instance, :math:`F(0) = 0`).  

The main challenge that comes with recurrence relations is to find explicit (non-recurrent) expression of :math:`f` (aka *closed form*) as a function of its argument :math:`n` (e.g., :math:`F(n) = n`).  This is similar to finding an explicit value for a sum in the case of loops.

First-order recurrence relations
--------------------------------

Most of the time we will be considering the following special case of recurrence relations.


.. admonition:: Definition 
  
  *First-order recurrence relation* for a function :math:`f` is an equation that expresses the value :math:`f(n)` recursively only via the value of :math:`f(n-1)`, when :math:`n > a` for some :math:`a`.

.. admonition:: Example

  For some :math:`c > 0`:

  .. math::  
    \begin{align*}
    f(0) &= 1 \\
    f(n) &= c \cdot f (n - 1)
    \end{align*}                 
  
  By inspection and unfolding the definition of :math:`f(n)`, we get the solution :math:`f(n) = c^n`.

.. admonition:: Definition

  **Homogeneous recurrence relations** take the following form for some constants :math:`a`, :math:`f(n)` and a coefficient :math:`b_n`, which might be a function of :math:`n`:

  .. math:: 

    \begin{align*}
    f(n) &= b_n \cdot f(n - 1) ~\text{if}~ n > a \\
    f(a) &= d
    \end{align*}

By unfolding the definition recursively, we can obtain the following formula to solve it:

.. math::

  \begin{align*}
  f(n) &= b_n \cdot f(n - 1) \\
  &= b_n \cdot b_{n-1} \cdot f(n - 2) \\
  & \ldots \\
  &= b_n \cdot b_{n - 1} \cdot \ldots \cdot b_{a + 1} \cdot f(a) \\
  &= b_n \cdot b_{n - 1} \cdot \ldots \cdot b_{a + 1} \cdot d
  \end{align*}

Therefore:

.. math:: 

  f(n) = \left( \prod_{i = a + 1}^{n}b_i \right) \cdot f(a)

You can try to remember that formula, but it's easier to remember how it is obtained. 

Inhomogeneous recurrence relations
----------------------------------

.. admonition:: Definition

  **Inhomogeneous recurrence relations** take the following form for some constants :math:`a`, :math:`f(n)` and a coefficient :math:`b_n` and :math:`c_n`, which might be functions of :math:`n`:

  .. math:: 

    \begin{align*}
    f(n) &= b_n \cdot f(n - 1) + c_n ~\text{if}~ n > a \\
    f(a) &= d
    \end{align*}

The trick to solve an inhomogeneous relation is to "pretend" that we are solving a homogeneous recurrence relation by changing the function :math:`f(n)` to :math:`g(n)`, such that 

.. math::

  \begin{align*}
  f(n) &= b_{a+1}\cdot \ldots \cdot b_n \cdot g(n) ~\text{if}~ n > a \\
  f(a) &= g(a) = d
  \end{align*}

Intuitively, this "change of function" allows us to reduce a general recurrence relation to the one where :math:`b_n = 1`. In other words, :math:`g(n)` is a "calibrated" version of :math:`f(n)` that behaves "like" :math:`f(n)` module the appended product of coefficients.

Let us see how this trick helps us to solve the initial relation. We start by expanding the definition of :math:`f(n)` for :math:`n > 0` as follows:

.. math::

   f(n) = b_n \cdot f(n - 1) + c_n

We then recall that :math:`f(n)` can be expressed via :math:`g(n)`, and rewrite both parts of this equation as follows:

.. math::

  \underbrace{b_{a+1}\cdot \ldots \cdot b_n}_{X} \cdot g(n) = \underbrace{b_n \cdot b_{a+1}\cdot \ldots \cdot b_{n-1}}_{X} \cdot g(n) + c_n

Notice that the parts marked via :math:`X` are, in fact the same, so we can divide both parts of the expression by it, so we can get

.. math::

  g(n) = g(n - 1) + d_n ~\text{where}~ d_n = \frac{c_n}{\prod_{i = a + 1}^{n}b_i}.

We can now solve the recurrence on :math:`g(n)` via the method of difference, obtaining

.. math::

  g(n) = g(a) + \sum_{j = a + 1}^{n}d_j ~\text{where}~ d_j = \frac{c_j}{\prod_{k = a + 1}^{j}b_k}

The final step is to obtain :math:`f(n)` by multiplying :math:`g(n)` by the corresponding product. This way we obtain:

.. math::

  f(n) = \prod_{i = a + 1}^{n} b_i \cdot \left(g(a) + \sum_{j = a + 1}^{n}d_j\right) ~\text{where}~ d_j = \frac{c_j}{\prod_{k = a + 1}^{j}b_k}

As in the previous case, it is much easier to remember the "trick" with introducing :math:`g(n)` and reproduce it every time you solve a relation, than to remember that formula above!  In the examples we'll, the initial index :math:`a` will be normally be 0 or 1.  The techniques for series summation and approximation will come useful when dealing with coefficients :math:`d_j`.

.. admonition:: Example

 Consider the following recurrence relation:        

 .. math::

   \begin{align*}
   f(n) &= 3 \cdot f(n - 1) + 1 ~\text{if}~ n > 0 \\
   f(0) &= 0
   \end{align*}

 We start by changing the function so :math:`f(n) = 3^n \cdot g(n)` for an unknown :math:`g(n)`, since :math:`b_i = 3` for any :math:`i`. Substityting for :math:`f(n)` gives us 

 .. math::

    g(n) = g(n - 1) + \frac{1}{3^n}

 By method of differences, we obtain

 .. math::

    g(n) = \sum_{i = 1}^{n}\frac{1}{3^i} = \left[\sum_{i = 1}^{n}\frac{1}{a^i}\right]_{a = \frac{1}{3}} = \left[\frac{a (1 - a^n)}{1-a}\right]_{a = \frac{1}{3}} = \frac{1}{2}\left(1 - \frac{1}{3^n}\right)

 Finally, restoring :math:`f(n)`, we get

 .. math::

   f(n) = 3^n \cdot g(n) = \frac{3^n}{2}\left(1 - \frac{1}{3^n}\right) = \frac{1}{2} \left(3^n - 1\right) \in O(3^n)

.. _exercise-recur: 

Exercise 1
----------

Find closed forms (explicit expressions) for the following recurrence relations on :math:`f(n)`.

a. :math:`f(0) = 4` and for :math:`n \geq 1`, :math:`f(n) = f(n -1) + 5`

a. :math:`f(0) = 3` and for :math:`n \geq 1`, :math:`f(n) = 5 f(n -1) - 2`

c. :math:`f(1) = 1` and for :math:`n \geq 2`, :math:`f(n) = n^2 f(n -1) + n \cdot (n!)^2`

Complexity of recursive matrix determinant
------------------------------------------

Recall the definition of a matrix determinant by Laplace expansion

.. math::

  |M| = \sum_{i = 0}^{n - 1}(-1)^{i} M_{0, i} \cdot |M^{0, i}|

where :math:`M^{0, i}` is the corresponding `minor of the matrix <https://en.wikipedia.org/wiki/Minor_(linear_algebra)>`_ :math:`M` of size :math:`n`, with indexing starting from :math:`0`.

This definition can be translated to OCaml as follows::

 let rec detLaplace m n = 
   if n = 1 then m.(0).(0)
   else
     let det = ref 0 in
     for i = 0 to n - 1 do
       let min = minor m 0 i in
       let detMin =  detLaplace min (n - 1) in
       det := !det + (power (-1) i) * m.(0).(i) * detMin
     done;
     !det

A matrix is encoded as a 2-dimensional array ``m``, whose rank (both dimensions) is ``n``. Here, ``minor`` returns the minor of the matrix ``m``, and ``power a b`` returns the natural power of ``b`` of an integer value ``a``.

.. _exercise-determ: 

Exercise 2
----------

Out of the explanations and the code above, estimate (in terms of big-O notation) the time complexity :math:`t(n)` of the recursive determinant computation. Start by writing down a recurrence relation on :math:`t(n)`. Consider the complexity of returning an element of an array to be 0 (i.e., :math:`t(1) = 0`). For :math:`n > 1`, consider the time cost of computing the ``minor`` of a matrix, ``power``, addition, multiplication and other primitive operations to be constant,s and approximate all of them by a single constant :math:`c`.

.. _exercise-determ2: 

Exercise 3
-----------

Now, assume that the complexity of ``minor`` is :math:`c \dot n^2` for some constant :math:`c`. How does this change the asymptotic complexity of ``detLaplace``?
