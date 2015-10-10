(import [hy.models.string [HyString]]
        [hy.models.symbol [HySymbol]]
        [hy.models.list [HyList]]
        [hy.models.keyword [HyKeyword]]
        [hy.models.expression [HyExpression]])

(defclass MatchFailure [Exception] [])

(defn match-failed []
  (raise (MatchFailure "match failed")))

(defn try-func [f]
  (try
    (do (f) true)
    (except [] false)))

(defmacro accfor [args &rest body]
  (setv names (cut args 0 nil 2))
  `(genexpr ((fn [~@names] ~@body) ~@names) [~@args]))

(defmacro defunion [name &rest types]
  (setv base `(defclass ~name [object] []))
  (setv classes (accfor [t types]
    (setv fields (HyList (cdr t)))
    (setv field-slist (HyList (map HyString fields)))
    (setv field-mlist (list (accfor [f fields] `(. self ~f))))
    (defn mk-fmstr [s]
      (HyString (.join ", " (accfor [f fields] (% "%s=%%%s" (, f s))))))
    (setv field-sfmstr (mk-fmstr "s"))
    (setv field-rfmstr (mk-fmstr "r"))
    (setv sname (HyString (car t)))
    (defn mk-fmfn [v]
      `(% "%s(%s)" (, ~sname (% ~v (, ~@field-mlist)))))
    `(defclass ~(get t 0) [~name]
      [--init-- (fn [self ~@fields]
                  (for [x (zip ~field-slist ~fields)]
                    (setattr self (get x 0) (get x 1)))
                  (setv self.-fields ~field-slist)
                  nil
                 )]
       [--str-- (fn [self] ~(mk-fmfn field-sfmstr))]
       [--repr-- (fn [self] ~(mk-fmfn field-rfmstr))])))
  (setv result (list (+ [base] (list classes))))
  `(do ~@result nil))

(defmacro match [x &rest branches]
  (defn get-tp [p]
    (cond
      [(isinstance p HyExpression)
        (if (= (get p 0) `,) "tupl-match" "data-match")]
      [(isinstance p HySymbol)
        (if (= p `_) "fallthough" "test-value")]
      [(isinstance p HyList) "list-match"]
      [(isinstance p HyKeyword) "grap-value"]
      [true "test-value"]))

  (defn map-fields [func var p f]
    (setv res [])
    (for [[i x] (enumerate p)]
      (if (= x (HySymbol "..."))
        (break))
      (res.append (func (f (HyInteger i)) x)))
    (and res (reduce + res)))

  (defn match-base [func var p fields no-slc]
    (unless no-slc (setv p (cut p 1)))
    (map-fields func var p (fn [i] (if fields `(getattr ~var (get (. ~var -fields) ~i))
                                              `(get ~var ~i)))))

  (defn cond-match-base [var p &optional t no-slc fields]
    (setv p2 (if no-slc p (cut p 1)))
    (+ [`(isinstance ~var ~(or t (get p 0))) ]
       (match-base recurse-cond var p fields no-slc)))

  (defn body-match-base [var p &optional fields no-slc]
    (match-base recurse-body var p fields no-slc))

  (defn recurse-cond [var p]
    (setv tp (get-tp p))
    (cond
      [(= tp "data-match") (cond-match-base var p :fields true)]
      [(= tp "tupl-match") (cond-match-base var p :t `tuple)]
      [(= tp "list-match") (cond-match-base var p :t `list :no-slc true)]
      [(= tp "test-value") [`(and (.try-func (--import-- "hyskell")
                                  (fn [] ~var)) (= ~var ~p))]]
      [(= tp "fallthough") [`(.try-func (--import-- "hyskell") (fn [] ~var))]]
      [true                []]))

  (defn recurse-body [var p]
    (setv tp (get-tp p))
    (cond
      [(= tp "data-match") (body-match-base var p :fields true)]
      [(= tp "tupl-match") (body-match-base var p)]
      [(= tp "list-match") (body-match-base var p :no-slc true)]
      [(= tp "grap-value") [`(setv ~(HySymbol (cut p 2)) ~var)]]
      [true                []]))

  (setv var (.replace (gensym) x))

  (.replace `(do
    (setv ~var ~x)
    (cond ~@(accfor [branch branches]
      (if (< (len branch) 2)
        (macro-error branch "branch requires >= two items"))
      (setv tag (get branch 0))
      (setv cond `(and true true ~@(recurse-cond var tag)))
      (setv code `(do ~@(recurse-body var tag) ~@(cut branch 1)))
      (cond.replace tag)
      (code.replace (get branch 1))
      (.replace `[~cond ~code] tag))
      [true (.match-failed (--import-- "hyskell"))])) x))
