;;; Error reporting for read-only scaffold commands.
;;; These commands change no system variables or drawing state to restore.

(defun TT:ReportError (context message)
  (if (member message '("Function cancelled" "quit / exit abort" "console break"))
    (princ (strcat "\n" context " cancelled."))
    (princ (strcat "\n" context " error: " message))
  )
  (princ)
)

T
