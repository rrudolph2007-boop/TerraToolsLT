;;; TerraTools LT - Persistent project drawing scale.
;;; DRAWING_SCALE is the positive denominator N in a dimensionless 1:N ratio.

(setq *TT:ScaleLastError* nil)

(defun TT:ScaleSetError (message)
  (setq *TT:ScaleLastError* message)
  nil
)

(defun TT:ScaleLastError ()
  *TT:ScaleLastError*
)

(defun TT:GetDrawingScale (/ project scale)
  (setq *TT:ScaleLastError* nil
        project (TT:ProjectCurrent))
  (cond
    ((null project)
      (if (TT:ProjectLastError)
        (TT:ScaleSetError (TT:ProjectLastError))
        (TT:ScaleSetError "An active TerraTools project is required.")))
    (T
      (setq scale (TT:ProjectValue project 'DRAWING_SCALE))
      (if (and (numberp scale) (> scale 0.0))
        scale
        (TT:ScaleSetError "The stored drawing scale is invalid."))))
)

(defun TT:SetDrawingScale (scale / project updated)
  (setq *TT:ScaleLastError* nil)
  (cond
    ((or (not (numberp scale)) (<= scale 0.0))
      (TT:ScaleSetError "Drawing scale must be greater than zero."))
    ((null (setq project (TT:ProjectCurrent)))
      (if (TT:ProjectLastError)
        (TT:ScaleSetError (TT:ProjectLastError))
        (TT:ScaleSetError "An active TerraTools project is required.")))
    (T
      (setq updated (TT:ProjectWithValue project 'DRAWING_SCALE scale))
      (if (TT:ProjectSave updated *TT:CurrentProjectPath*)
        (progn
          (setq *TT:CurrentProject* updated)
          T)
        (TT:ScaleSetError (TT:ProjectLastError)))))
)

(defun TT:GetAnnotationScaleFactor ()
  ;; The stored scale is dimensionless. Future placement tools can combine
  ;; this factor with project units and the configured paper text height.
  (TT:GetDrawingScale)
)

(defun TT:ScalePrintError ()
  (if *TT:ScaleLastError*
    (princ (strcat "\nTerraTools: " *TT:ScaleLastError*)))
  (princ)
)

(defun C:TTSCALE (/ *error* current-scale new-scale)
  (defun *error* (message)
    (TT:ReportError "TTSCALE" message))
  (setq current-scale (TT:GetDrawingScale))
  (if current-scale
    (progn
      (princ "\nCurrent TerraTools drawing scale: 1:")
      (princ current-scale)
      (setq new-scale
        (getreal "\nNew scale denominator N for 1:N <keep current>: "))
      (if new-scale
        (if (TT:SetDrawingScale new-scale)
          (progn
            (princ "\nTerraTools drawing scale saved: 1:")
            (princ new-scale))
          (TT:ScalePrintError))
        (princ "\nDrawing scale was not changed.")))
    (TT:ScalePrintError))
  (princ)
)

T
