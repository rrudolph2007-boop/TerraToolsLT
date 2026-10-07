;;; TerraTools LT 0.12.0-rc1 - application loader for AutoCAD LT 2024+ on Windows.
;;; Add the installation folder to the Support File Search Path, then APPLOAD
;;; this file. If it cannot be found there, select this file when prompted.
;;; The installation folder and loaded subfolders must be trusted by AutoCAD.

(defun TT:ClearReadiness ()
  (setq *TT:CoreLoaded* nil *TT:PlantingModuleLoaded* nil
    *TT:SiteModuleLoaded* nil *TT:DetailsModuleLoaded* nil
    *TT:LightingModuleLoaded* nil *TT:IrrigationModuleLoaded* nil
    *TT:HydraulicsModuleLoaded* nil *TT:ScheduleModuleLoaded* nil
    *TT:UIModuleLoaded* nil *TT:RecordUIModuleLoaded* nil
    *TT:MigrationModuleLoaded* nil *TT:PlantUIModuleLoaded* nil
    *TT:PlantDatabaseLoaded* nil *TT:NetworkModuleLoaded* nil
    *TT:RecoveryModuleLoaded* nil *TT:GeometryModuleLoaded* nil
    *TT:PlantSearchModuleLoaded* nil *TT:StandardsModuleLoaded* nil
    *TT:UnitsModuleLoaded* nil *TT:CSVModuleLoaded* nil
    *TT:QAModuleLoaded* nil *TT:HelpModuleLoaded* nil))

(defun TT:Load
  (/ *error* requested-loader-path loader-path module-path modules module-name ok)
  ;; A local handler also covers failures before tt-errors.lsp is available.
  ;; Localizing *error* restores the caller's handler when this function exits.
  (defun *error* (message)
    (TT:ClearReadiness)
    (if module-name
      (princ (strcat "\nTerraTools load failed in: " module-name))
      (princ "\nTerraTools LT loader failed."))
    (if message (princ (strcat "\nError: " message)))
    (princ)
  )

  ;; TTRELOAD supplies an exact loader path so another support-path copy cannot
  ;; take precedence. Consume the override once and clear it immediately.
  (if (and (boundp '*TT:LoaderPathOverride*)
           (eq (type *TT:LoaderPathOverride*) 'STR))
    (setq requested-loader-path (findfile *TT:LoaderPathOverride*)))
  (setq *TT:LoaderPathOverride* nil)

  ;; Clear readiness on every attempt, including a failed reload.
  (setq *TT:Version* "0.12.0-rc1"
        *TT:CoreLoaded* nil
        *TT:PlantingModuleLoaded* nil
        *TT:SiteModuleLoaded* nil
        *TT:DetailsModuleLoaded* nil
        *TT:LightingModuleLoaded* nil
        *TT:IrrigationModuleLoaded* nil
        *TT:HydraulicsModuleLoaded* nil
        *TT:ScheduleModuleLoaded* nil
        *TT:UIModuleLoaded* nil
        *TT:RecordUIModuleLoaded* nil
        *TT:MigrationModuleLoaded* nil
        *TT:PlantUIModuleLoaded* nil
        *TT:PlantDatabaseLoaded* nil
        *TT:NetworkModuleLoaded* nil
        *TT:RecoveryModuleLoaded* nil
        *TT:GeometryModuleLoaded* nil
        *TT:PlantSearchModuleLoaded* nil
        *TT:StandardsModuleLoaded* nil
        *TT:UnitsModuleLoaded* nil
        *TT:CSVModuleLoaded* nil
        *TT:QAModuleLoaded* nil
        *TT:HelpModuleLoaded* nil
        *TT:Root* nil
        loader-path requested-loader-path)

  (if (not loader-path)
    (setq loader-path (findfile "TerraTools.lsp")))

  (if (not loader-path)
    (setq loader-path
      (getfiled "Locate the TerraTools.lsp you are loading" "" "lsp" 0))
  )

  (cond
    ((not loader-path)
      (princ "\nTerraTools LT load cancelled. Core is not loaded."))
    ((not (and (= (strcase (vl-filename-base loader-path)) "TERRATOOLS")
               (vl-filename-extension loader-path)
               (= (strcase (vl-filename-extension loader-path)) ".LSP")))
      (princ "\nTerraTools LT load failed: select TerraTools.lsp."))
    (T
      (setq *TT:Root* (vl-filename-directory loader-path)
            modules '("core/tt-errors.lsp"
                      "core/tt-utils.lsp"
                      "core/tt-core.lsp"
                      "core/tt-uuid.lsp"
                      "core/tt-xdata.lsp"
                      "core/tt-storage.lsp"
                      "core/tt-project.lsp"
                      "core/tt-recovery.lsp"
                      "core/tt-preferences.lsp"
                      "core/tt-layer-roles.lsp"
                      "core/tt-scale.lsp"
                      "core/tt-units.lsp"
                      "core/tt-data.lsp"
                      "core/tt-migration.lsp"
                      "core/tt-csv.lsp"
                      "core/tt-standards.lsp"
                      "core/tt-smart.lsp"
                      "core/tt-geometry.lsp"
                      "planting/tt-plant-db.lsp"
                      "planting/tt-plant-manager.lsp"
                      "planting/tt-plant-search.lsp"
                      "planting/tt-plant-library.lsp"
                      "core/tt-reconcile.lsp"
                      "core/tt-workarea.lsp"
                      "planting/tt-plant-place.lsp"
                      "planting/tt-plant-tools.lsp"
                      "planting/tt-plant-area.lsp"
                      "planting/tt-plant-label.lsp"
                      "schedules/tt-schedule-engine.lsp"
                      "site/tt-site.lsp"
                      "details/tt-details.lsp"
                      "lighting/tt-lighting.lsp"
                      "irrigation/tt-hydraulics.lsp"
                      "irrigation/tt-irrigation.lsp"
                      "irrigation/tt-network.lsp"
                      "core/tt-debug.lsp"
                      "core/tt-dev.lsp"
                      "core/tt-qa.lsp"
                      "core/tt-qa-network.lsp"
                      "core/tt-help.lsp"
                      "planting/tt-plant-ui.lsp"
                      "core/tt-ui.lsp"
                      "core/tt-record-ui.lsp"
                      "core/tt-manager-actions.lsp"
                      "core/tt-library.lsp"
                      "core/tt-managers.lsp"
                      "schedules/tt-styles.lsp"
                      "planting/tt-plant-production.lsp"
                      "core/tt-package.lsp"
                      "irrigation/tt-pipe-classes.lsp"
                      "irrigation/tt-irrigation-tools.lsp"
                      "site/tt-site-labels.lsp"
                      "lighting/tt-lighting-tools.lsp"
                      "schedules/tt-equipment-schedules.lsp")
            ok T)
      ;; Always use explicit paths under one installation, never bare module
      ;; names that could resolve to files in another support directory.
      (while (and ok modules)
        (setq module-name (car modules)
              module-path (strcat *TT:Root* "/" module-name))
        (princ (strcat "\nTerraTools loading: " module-name))
        (cond
          ((not (findfile module-path))
            (setq ok nil)
            (princ (strcat "\nTerraTools load failed in: " module-name
                           "\nError: module file was not found.")))
          ((not (load module-path nil))
            (setq ok nil)
            (princ (strcat "\nTerraTools load failed in: " module-name)))
        )
        (setq modules (cdr modules))
      )
      (if ok
        (progn
          (setq *TT:CoreLoaded* T)
          (princ (strcat "\nTerraTools LT " *TT:Version*
                         " ready. Type TT to open TerraTools."))
        )
        (TT:ClearReadiness)
      )
    )
  )
  (princ)
)

(TT:Load)
(princ)
