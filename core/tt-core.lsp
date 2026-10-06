;;; Core readiness and the initial public command.
;;; The loader owns *TT:Version*, *TT:Root*, and *TT:CoreLoaded*.

(defun C:TTHELLO (/ *error*)
  (defun *error* (message)
    (TT:ReportError "TTHELLO" message)
  )
  (if *TT:CoreLoaded*
    (princ "\nTerraTools LT loaded successfully.")
    (princ "\nTerraTools LT core is not loaded. Reload TerraTools.lsp.")
  )
  (princ)
)

T
