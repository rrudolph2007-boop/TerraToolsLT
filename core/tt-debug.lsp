;;; Read-only diagnostics using AutoCAD system variables.
;;; getvar returns nil for an unavailable variable; TT:PrintValue reports it.

(defun C:TTDEBUG (/ *error*)
  (defun *error* (message)
    (TT:ReportError "TTDEBUG" message)
  )
  (princ "\nTerraTools LT diagnostics")
  (TT:PrintValue "TerraTools version" *TT:Version*)
  (TT:PrintValue "AutoCAD product" (getvar "PRODUCT"))
  (TT:PrintValue "AutoCAD version" (getvar "ACADVER"))
  (TT:PrintValue "Drawing filename" (getvar "DWGNAME"))
  (TT:PrintValue "Drawing directory" (getvar "DWGPREFIX"))
  (TT:PrintValue "Current layer" (getvar "CLAYER"))
  (TT:PrintValue "INSUNITS" (getvar "INSUNITS"))
  (TT:PrintValue "Core loaded successfully" (if *TT:CoreLoaded* "Yes" "No"))
  (TT:PrintValue "TERRATOOLS XData application registered"
                 (if (TT:XDataAppRegisteredP) "Yes" "No"))
  (princ)
)

T
