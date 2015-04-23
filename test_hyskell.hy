(require hyskell)
(require hytest)

(defunion Node
  (Nint p ival)
  (Nstr p sval))

(test-set test-accfor
  (test = (list (accfor [x [1 2 3] y [4 5 6]] [x y]))
          [[1 4] [1 5] [1 6] [2 4] [2 5] [2 6] [3 4] [3 5] [3 6]]))

(test-set test-defunion
  (setv i (Nint 0 7))
  (setv s (Nstr 1 "s"))
  (test = i.ival 7)
  (test = s.sval "s")
  (test = i.p 0)
  (test = s.p 1)
  (test true (isinstance i Node))
  (test true (isinstance s Node))
  (test = i.-fields [0 7])
  (test = s.-fields [1 "s"]))

(test-set test-match
  (match [1 2 3]
    [[1 2 3] nil])
  (match [1 2 3]
    [[1 :b 3] (test = b 2)])
  (match [1 2 3]
    [:v (test = v [1 2 3])])
  (match [1 2 3]
    [_ nil])

  (match (, 1 2 3)
    [(, :a :b 3)
      (test = a 1)
      (test = b 2)])

  (match (Nint 0 2)
    [(Nint :p 2) (test = p 0)])

  (setv x 2)
  (match 2 [x nil])

  (match [1 2]
    [[1 _] nil])

  (match [1]
    [[1 _] (fail-test "")]
    [_ nil])

  (match (Nint 1 2)
    [(Nint) nil]
    [_ (fail-test "")]))
