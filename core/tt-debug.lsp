;;; Read-only diagnostics using AutoCAD system variables.
;;; getvar returns nil for an unavailable variable; TT:PrintValue reports it.

(defun C:TTDEBUG
  (/ *error* project association project-path preferences layers-exist)
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
  (setq project (TT:ProjectCurrent)
        association (TT:ProjectGetAssociation))
  (if project
    (setq project-path *TT:CurrentProjectPath*)
    (if association
      (setq project-path (cdr (assoc 'PROJECT_PATH association)))
      (setq project-path nil)))
  (TT:PrintValue "Project active" (if project "Yes" "No"))
  (if project
    (progn
      (TT:PrintValue "Project UUID"
                     (TT:ProjectValue project 'PROJECT_UUID))
      (TT:PrintValue "Project name"
                     (TT:ProjectValue project 'PROJECT_NAME))))
  (if project-path
    (TT:PrintValue "Project data path" project-path))
  (TT:PrintValue "Project file readable"
                 (if (and project-path
                          (TT:StorageReadableP project-path))
                   "Yes"
                   "No"))
  (if (and (null project) (TT:ProjectLastError))
    (TT:PrintValue "Project error" (TT:ProjectLastError)))
  (if project
    (progn
      (setq preferences (TT:LoadPreferences))
      (if preferences
        (setq layers-exist (TT:StandardLayersExistP)))))
  (TT:PrintValue "Active preference set"
    (if preferences
      (TT:PreferencesValue preferences 'PREFERENCE_SET_NAME)
      nil))
  (TT:PrintValue "Project units"
    (if project (TT:ProjectValue project 'UNITS) nil))
  (TT:PrintValue "Annotation text height"
    (if preferences
      (TT:PreferencesValue preferences 'ANNOTATION_TEXT_HEIGHT)
      nil))
  (TT:PrintValue "Numeric precision"
    (if preferences
      (TT:PreferencesValue preferences 'NUMERIC_PRECISION)
      nil))
  (TT:PrintValue "Drawing scale"
    (if project (TT:ProjectValue project 'DRAWING_SCALE) nil))
  (TT:PrintValue "Standard TerraTools layers exist"
    (if preferences (if layers-exist "Yes" "No") nil))
  (if (and project (null preferences) (TT:PreferencesLastError))
    (TT:PrintValue "Preferences error" (TT:PreferencesLastError)))
  (princ)
)

T
