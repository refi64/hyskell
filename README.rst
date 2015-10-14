Hyskell
=======

This brings two functional-ish things to Hy: accumulating for loops and unions/pattern matching. Just prefix your files with this:

.. code-block:: hy
   
   (require hyskell)

accfor
******

`accfor` is a `for` loop that is actually an iterator. It's basically `genexpr` with a nicer syntax that can take anything; not just a single expression.

.. code-block:: hy
   
   (print (list (accfor [x [1 2 3]] x))) ; prints [1 2 3]

defunion
********

Defines a union type:

.. code-block:: hy
   
   (defunion Node
     (Nint val)
     (Nstr val))

This example defines three types: `Node` (a base class), `Nint` (a class with one attribute: val), and `Nstr` (same as `Nint`).

You can use the types like any other type:

.. code-block:: hy
   
   (setv i (Nint 7))
   (setv s (Nstr "abc"))

match
*****

True ML-style pattern matching:

.. code-block:: hy
   
   (match value
     [[1 2 3] (print "Got list [1 2 3]")] ; against a list
     [[:a 2 3] (print "Got list with a =" a)] ; grab values with :
     [(, 1 2) (print "Got tuple (1, 2)")] ; against a tuple
     [1 (print "Got 1")] ; against an int or string
     [(Nint :v) (print "Got Nint with v =" v)] ; against a union branch
     [(Nstr (:val "abc")) (print "Got Nstr with val of abc")] ; use : at the beginning of an expression to test attributes
     [(Nstr _) (print "Got Nstr")] ; use _ to ignore values
     [[1 2 ...] (print "Got list that starts with 1 and 2")] ; use ... to allow extra items at the end
     [[_ _ ...] (print "Got list with >= 2 elements")] ; use ... with _ to do cool stuff
     [_ (print "Got something weird!")]) ; you can also use _ for a fallthrough statement

If none of the branches match, a `hyskell.MatchFailure` exception is thrown.

Examples
********

See `test_hyskell.hy` for the unit tests, written using [HyTest](https://github.com/kirbyfan64/hytest).
