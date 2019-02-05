.. -*- mode: rst -*-

Maintaining Binary Heaps
========================

Let us now fix the broken heap ``bad_heap`` by restoring an order in it. As we can see, the issue there is between the parent ``(10, "c")`` and a left child ``(11, "f")`` that are out of order. What we need to do is to swap them (assuming that both subtrees followed from the children obey the descrnding order),.
