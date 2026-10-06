;;; Command-line output helpers. No drawing or system-variable changes.

(defun TT:PrintValue (label value)
  (princ (strcat "\n" label ": "))
  (cond
    ((null value) (princ "Unavailable"))
    ((equal value "") (princ "(empty)"))
    (T (princ value))
  )
  (princ)
)

;; The loader uses this return value to confirm module loading completed.
T
