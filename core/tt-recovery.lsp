;;; Deliberate project recovery. Never overwrite the known-good backup.
(setq *TT:RecoveryModuleLoaded* T)

(defun TT:ProjectRecover (path expected-uuid / backup data archive staged moved result)
  (setq backup (strcat path ".bak") data (TT:ProjectLoad backup))
  (cond
    ((null data) (TT:ProjectSetError "The backup is missing or invalid. Neither file was changed."))
    ((and expected-uuid (not (equal expected-uuid (TT:ProjectValue data 'PROJECT_UUID))))
      (TT:ProjectSetError "Backup UUID does not match the drawing. Neither file was changed."))
    (T
      (setq archive (strcat path ".unrecovered-" (TT:GenerateUUID)) staged (strcat archive ".staged"))
      (cond
        ((not (TT:StorageWriteRaw staged data)) (TT:ProjectSetError "Could not stage recovery. Check directory permissions."))
        ((not (equal (TT:ProjectLoad staged) data))
          (TT:StorageDeleteIfExists staged) (TT:ProjectSetError "Recovery staging failed validation."))
        (T
          (if (TT:StorageFileExistsP path)
            (setq moved (vl-catch-all-apply 'vl-file-rename (list path archive)))
            (setq moved T))
          (if (or (vl-catch-all-error-p moved) (null moved))
            (progn (TT:StorageDeleteIfExists staged) (TT:ProjectSetError "Could not preserve the current file. Recovery stopped."))
            (progn
              (setq result (vl-catch-all-apply 'vl-file-rename (list staged path)))
              (if (or (vl-catch-all-error-p result) (null result))
                (progn
                  (if (TT:StorageFileExistsP archive) (vl-file-rename archive path))
                  (TT:ProjectSetError (strcat "Recovery finalization failed. Check preserved files beside " path)))
                (progn (TT:ProjectRefresh) T)))))))))

(defun C:TTRECOVERPROJECT (/ *error* association path backup answer)
  (defun *error* (message) (TT:ReportError "TTRECOVERPROJECT" message))
  (setq association (TT:ProjectGetAssociation)
        path (if association (cdr (assoc 'PROJECT_PATH association))))
  (if (null path) (setq path (getfiled "Select project file to inspect for recovery" "" "dat" 0)))
  (if path
    (progn
      (setq backup (TT:ProjectLoad (strcat path ".bak")))
      (if backup
        (progn
          (TT:PrintValue "Backup project" (TT:ProjectValue backup 'PROJECT_NAME))
          (TT:PrintValue "Backup UUID" (TT:ProjectValue backup 'PROJECT_UUID))
          (TT:PrintValue "Restore destination" path)
          (initget "Restore Cancel")
          (setq answer (getkword "\nPreserve current file and restore this backup? [Restore/Cancel] <Cancel>: "))
          (if (= answer "Restore")
            (if (TT:ProjectRecover path (if association (cdr (assoc 'PROJECT_UUID association))))
              (princ "\nProject restored. Backup retained; previous file preserved beside the project.")
              (TT:ProjectPrintError))))
        (princ "\nNo valid backup is available. Current project and backup were left unchanged."))))
  (princ))

T
