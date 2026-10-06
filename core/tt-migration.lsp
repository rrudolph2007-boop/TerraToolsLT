;;; Explicit migration boundary. Schema 1 is the only published project schema.
;;; Never manufacture a schema-0 conversion or accept a future schema silently.
(setq *TT:MigrationModuleLoaded* T)

(defun TT:ProjectCanMigrate (project target)
  (and (= target *TT:ProjectDataSchemaVersion*)
       (equal (TT:ProjectValue project 'DATA_SCHEMA_VERSION) target)
       (TT:ProjectValidate project)))

(defun TT:ProjectMigrate (project target)
  ;; Pure identity transformation for the current schema, including unknown keys.
  ;; Future steps must validate both ends before joining this dispatch.
  (if (TT:ProjectCanMigrate project target) project
    (TT:ProjectSetError "No supported migration exists for this project schema. Keep the original file and use a compatible TerraTools release.")))

(defun C:TTPROJECTMIGRATE (/ project result)
  (setq project (TT:ProjectCurrent))
  (if project
    (if (setq result (TT:ProjectMigrate project *TT:ProjectDataSchemaVersion*))
      (princ "\nProject schema is current. No file was changed.")
      (TT:ProjectPrintError))
    (TT:ProjectPrintError))
  (princ))
T
