;;; TerraTools LT - Small development reload and read-only smoke-test tools.

(defun TT:DevSmokeLine (status label detail)
  (princ (strcat "\n" status "  " label))
  (if (and (eq (type detail) 'STR) (not (equal detail "")))
    (princ (strcat " - " detail)))
  (princ)
)

(defun TT:DevSmokeCheck (condition label detail)
  (if condition
    (progn
      (TT:DevSmokeLine "PASS" label nil)
      T)
    (progn
      (TT:DevSmokeLine "FAIL" label detail)
      nil))
)

(defun TT:DevSmokeSkip (label detail)
  (TT:DevSmokeLine "SKIP" label detail)
  T
)

(defun TT:DevErrorMessage (result fallback)
  (cond
    ((vl-catch-all-error-p result) (vl-catch-all-error-message result))
    ((and (eq (type fallback) 'STR) (not (equal fallback ""))) fallback)
    (T "Check failed."))
)

(defun C:TTRELOAD (/ *error* root loader-path result)
  (defun *error* (message)
    (setq *TT:LoaderPathOverride* nil)
    (TT:ReportError "TTRELOAD" message))
  (setq root (if (boundp '*TT:Root*) *TT:Root* nil))
  (cond
    ((or (not (eq (type root) 'STR)) (equal root ""))
      (princ "\nTerraTools reload failed: the current installation root is unavailable."))
    (T
      (setq loader-path (TT:StorageJoinPath root "TerraTools.lsp"))
      (if (not (findfile loader-path))
        (princ
          (strcat "\nTerraTools reload failed: loader file was not found: "
                  loader-path))
        (progn
          (setq *TT:LoaderPathOverride* loader-path
                result (vl-catch-all-apply 'load (list loader-path)))
          (setq *TT:LoaderPathOverride* nil)
          (cond
            ((vl-catch-all-error-p result)
              (princ
                (strcat "\nTerraTools reload failed: "
                        (vl-catch-all-error-message result))))
            ((and *TT:CoreLoaded*
                  (eq (type *TT:Root*) 'STR)
                  (equal
                    (strcase (TT:StorageNormalizePath root))
                    (strcase (TT:StorageNormalizePath *TT:Root*))))
              (princ (strcat "\nTerraTools reload successful: " loader-path)))
            (T
              (princ
                "\nTerraTools reload failed. Review the preceding load messages.")))))))
  (princ)
)

(defun C:TTDEVSMOKE
  (/ *error* passed result uuid association association-error project
     project-path preferences scale planting-loaded catalog master-plants
     master-count palette palette-valid palette-count module-check fixture-master
     irrigation-master work-areas work-area-count)
  (defun *error* (message)
    (TT:ReportError "TTDEVSMOKE" message))

  (setq passed T)
  (princ "\nTerraTools development smoke test")

  (if (not
        (TT:DevSmokeCheck
          (and (boundp '*TT:CoreLoaded*) *TT:CoreLoaded*)
          "Core loaded"
          "TerraTools core is not marked as loaded."))
    (setq passed nil))

  (setq result (vl-catch-all-apply 'TT:XDataAppRegisteredP nil))
  (if (not
        (TT:DevSmokeCheck
          (and (not (vl-catch-all-error-p result)) result)
          "XData framework"
          (TT:DevErrorMessage result
            "The TERRATOOLS registered application is unavailable.")))
    (setq passed nil))

  (setq result (vl-catch-all-apply 'TT:GenerateUUID nil))
  (if (vl-catch-all-error-p result)
    (setq uuid nil)
    (setq uuid result))
  (if (not
        (TT:DevSmokeCheck
          (and (eq (type uuid) 'STR) (not (equal uuid "")))
          "UUID generation"
          (TT:DevErrorMessage result "UUID generation returned no value.")))
    (setq passed nil))

  (setq result (vl-catch-all-apply 'TT:ProjectGetAssociation nil))
  (if (vl-catch-all-error-p result)
    (setq association nil
          association-error (vl-catch-all-error-message result))
    (setq association result
          association-error *TT:ProjectAssociationError*))

  (cond
    (association
      (setq result (vl-catch-all-apply 'TT:ProjectCurrent nil))
      (if (vl-catch-all-error-p result)
        (setq project nil)
        (setq project result))
      (if (not
            (TT:DevSmokeCheck
              project
              "Project load"
              (TT:DevErrorMessage result (TT:ProjectLastError))))
        (setq passed nil))
      (if project
        (setq project-path *TT:CurrentProjectPath*)
        (setq project-path (cdr (assoc 'PROJECT_PATH association))))
      (if (not
            (TT:DevSmokeCheck
              (and project-path (TT:StorageReadableP project-path))
              "Project file readable"
              "The associated project file cannot be read."))
        (setq passed nil))
      (if project
        (progn
          (setq result (vl-catch-all-apply 'TT:LoadPreferences nil))
          (if (vl-catch-all-error-p result)
            (setq preferences nil)
            (setq preferences result))
          (if (not
                (TT:DevSmokeCheck
                  preferences
                  "Preferences"
                  (TT:DevErrorMessage result (TT:PreferencesLastError))))
            (setq passed nil))

          (setq result (vl-catch-all-apply 'TT:GetDrawingScale nil))
          (if (vl-catch-all-error-p result)
            (setq scale nil)
            (setq scale result))
          (if (not
                (TT:DevSmokeCheck
                  (and (numberp scale) (> scale 0.0))
                  "Drawing scale"
                  (TT:DevErrorMessage result (TT:ScaleLastError))))
            (setq passed nil)))
        (progn
          (TT:DevSmokeSkip "Preferences" "Project could not be loaded.")
          (TT:DevSmokeSkip "Drawing scale" "Project could not be loaded."))))
    (association-error
      (TT:DevSmokeLine "FAIL" "Project load" association-error)
      (setq passed nil)
      (TT:DevSmokeSkip "Project file readable" "Project association is invalid.")
      (TT:DevSmokeSkip "Preferences" "Project could not be loaded.")
      (TT:DevSmokeSkip "Drawing scale" "Project could not be loaded."))
    (T
      (TT:DevSmokeSkip "Project load" "No project is associated.")
      (TT:DevSmokeSkip "Project file readable" "No project is associated.")
      (TT:DevSmokeSkip "Preferences" "No project is associated.")
      (TT:DevSmokeSkip "Drawing scale" "No project is associated.")))

  (setq planting-loaded
    (and (boundp '*TT:PlantingModuleLoaded*) *TT:PlantingModuleLoaded*))
  (if (not
        (TT:DevSmokeCheck
          planting-loaded
          "Planting module"
          "The planting modules are not marked as loaded."))
    (setq passed nil))

  (if planting-loaded
    (progn
      (setq result (vl-catch-all-apply 'TT:PlantMasterLoad nil))
      (if (vl-catch-all-error-p result)
        (setq catalog nil)
        (setq catalog result))
      (if (not
            (TT:DevSmokeCheck
              catalog
              "Master catalog validation"
              (TT:DevErrorMessage result (TT:PlantLastError))))
        (setq passed nil))
      (if catalog
        (progn
          (setq master-plants
                  (TT:PlantMasterCatalogValue catalog 'PLANTS)
                master-count (length master-plants))
          (if (not
                (TT:DevSmokeCheck
                  (= master-count 15)
                  (strcat "Master catalog (" (itoa master-count) " records)")
                  "The current sample catalog must contain 15 records."))
            (setq passed nil)))
        (progn
          (TT:DevSmokeLine "FAIL" "Master catalog count" "Catalog unavailable.")
          (setq passed nil)))

      (if project
        (progn
          (setq result
            (vl-catch-all-apply
              'TT:PlantPaletteLoadFromProject (list project)))
          (if (vl-catch-all-error-p result)
            (setq palette nil)
            (setq palette result))
          (if palette
            (setq palette-valid (TT:PlantPaletteValidate palette)))
          (if palette-valid
            (progn
              (setq palette-count
                (length (TT:PlantPaletteGetAllFromPalette palette)))
              (TT:DevSmokeLine
                "PASS"
                (strcat "Project palette (" (itoa palette-count) " records)")
                nil))
            (progn
              (TT:DevSmokeLine
                "FAIL"
                "Project palette"
                (TT:DevErrorMessage result (TT:PlantLastError)))
              (setq passed nil))))
        (TT:DevSmokeSkip "Project palette" "No readable project is active.")))
    (progn
      (TT:DevSmokeSkip "Master catalog validation" "Planting module unavailable.")
      (TT:DevSmokeSkip "Master catalog count" "Planting module unavailable.")
      (TT:DevSmokeSkip "Project palette" "Planting module unavailable.")))

  (foreach module-check
    '((*TT:UnitsModuleLoaded* . "Unit engine")
      (*TT:CSVModuleLoaded* . "CSV engine")
      (*TT:StandardsModuleLoaded* . "Standards")
      (*TT:PlantSearchModuleLoaded* . "Plant search")
      (*TT:PlantDatabaseLoaded* . "Open plant database reader")
      (*TT:PlantUIModuleLoaded* . "Plant manager")
      (*TT:GeometryModuleLoaded* . "Containment geometry")
      (*TT:NetworkModuleLoaded* . "Network graph")
      (*TT:RecoveryModuleLoaded* . "Project recovery")
      (*TT:QAModuleLoaded* . "QA module")
      (*TT:HelpModuleLoaded* . "Help module")
      (*TT:ScheduleModuleLoaded* . "Schedule engine")
      (*TT:SiteModuleLoaded* . "Site module")
      (*TT:DetailsModuleLoaded* . "Details module")
      (*TT:LightingModuleLoaded* . "Lighting module")
      (*TT:HydraulicsModuleLoaded* . "Hydraulic engine")
      (*TT:IrrigationModuleLoaded* . "Irrigation module")
      (*TT:UIModuleLoaded* . "User interface"))
    (if (not
          (TT:DevSmokeCheck
            (and (boundp (car module-check)) (eval (car module-check)))
            (cdr module-check) "Module is not loaded."))
      (setq passed nil)))

  (setq fixture-master (vl-catch-all-apply 'TT:LightingMasterLoad nil))
  (if (not (TT:DevSmokeCheck
             (and (not (vl-catch-all-error-p fixture-master)) fixture-master)
             "Master fixture catalog" "Catalog is missing or malformed."))
    (setq passed nil))
  (setq irrigation-master (vl-catch-all-apply 'TT:IrrigationMasterLoad nil))
  (if (not (TT:DevSmokeCheck
             (and (not (vl-catch-all-error-p irrigation-master)) irrigation-master)
             "Irrigation equipment catalog" "Catalog is missing or malformed."))
    (setq passed nil))
  (if project
    (progn
      (setq work-areas (TT:WorkAreas project))
      (setq work-area-count (if (eq (type work-areas) 'LIST) (length work-areas) 0))
      (if (not (TT:DevSmokeCheck
                 (or (null work-areas) (eq (type work-areas) 'LIST))
                 (strcat "Work Areas (" (itoa work-area-count) " records)")
                 "Project Work Area data is malformed."))
        (setq passed nil)))
    (TT:DevSmokeSkip "Work Areas" "No readable project is active."))

  (foreach module-check '("dialogs/terratools-main.dcl" "dialogs/terratools-plants.dcl")
    (if (not (TT:DevSmokeCheck (findfile (TT:StorageJoinPath *TT:Root* module-check))
                              module-check "DCL file is missing.")) (setq passed nil)))
  (if (findfile (TT:StorageJoinPath (TT:PlantDatabaseRoot) "manifest.dat"))
    (if (not (TT:DevSmokeCheck (TT:PlantDatabaseManifest) "Open database manifest" "Manifest is invalid."))
      (setq passed nil))
    (TT:DevSmokeSkip "Open database" "Optional database package is not installed."))
  (princ (strcat "\nOptional Production Plant Database: "
    (if (TT:PlantDatabaseManifest) "INSTALLED (manifest checked)" "NOT INSTALLED")))
  (princ (strcat "\n\nCore Smoke: " (if passed "PASS" "FAIL")))
  (princ)
)

T
