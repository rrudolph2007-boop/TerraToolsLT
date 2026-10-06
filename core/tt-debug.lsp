;;; Read-only diagnostics using AutoCAD system variables.
;;; getvar returns nil for an unavailable variable; TT:PrintValue reports it.

(defun C:TTDEBUG
  (/ *error* project association project-path preferences layers-exist
     master-catalog master-count palette palette-count planting-error)
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
  (TT:PrintValue "Resolved drawing unit" (TT:DrawingUnitName))
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
  (TT:PrintValue "Planting Module Loaded"
    (if *TT:PlantingModuleLoaded* "Yes" "No"))
  (TT:PrintValue "Plant Search Loaded"
    (if *TT:PlantSearchModuleLoaded* "Yes" "No"))
  (TT:PrintValue "Standards Module Loaded"
    (if *TT:StandardsModuleLoaded* "Yes" "No"))
  (TT:PrintValue "QA Module Loaded"
    (if *TT:QAModuleLoaded* "Yes" "No"))
  (TT:PrintValue "Schedule Engine Loaded"
    (if *TT:ScheduleModuleLoaded* "Yes" "No"))
  (TT:PrintValue "Site Module Loaded"
    (if *TT:SiteModuleLoaded* "Yes" "No"))
  (TT:PrintValue "Details Module Loaded"
    (if *TT:DetailsModuleLoaded* "Yes" "No"))
  (TT:PrintValue "Lighting Module Loaded"
    (if *TT:LightingModuleLoaded* "Yes" "No"))
  (TT:PrintValue "Hydraulic Engine Loaded"
    (if *TT:HydraulicsModuleLoaded* "Yes" "No"))
  (TT:PrintValue "Irrigation Module Loaded"
    (if *TT:IrrigationModuleLoaded* "Yes" "No"))
  (TT:PrintValue "User Interface Loaded"
    (if *TT:UIModuleLoaded* "Yes" "No"))
  (if *TT:PlantingModuleLoaded*
    (progn
      (setq master-catalog (TT:PlantMasterLoad))
      (if master-catalog
        (setq master-count
          (length (TT:PlantMasterCatalogValue master-catalog 'PLANTS)))
        (setq planting-error (TT:PlantLastError)))
      (if project
        (progn
          (setq palette (TT:PlantPaletteLoadFromProject project))
          (if palette
            (setq palette-count
              (length (TT:PlantPaletteGetAllFromPalette palette)))
            (setq planting-error (TT:PlantLastError)))))))
  (TT:PrintValue "Master Plant Count" master-count)
  (TT:PrintValue "Project Palette Count" palette-count)
  (if planting-error
    (TT:PrintValue "Planting error" planting-error))
  (princ)
)

T
