;;; TerraTools LT - Reusable user standards and project preference exchange.

(setq *TT:StandardsSchemaVersion* 1
      *TT:StandardsModuleLoaded* T)

(defun TT:StandardsEnvelope (preferences)
  (list 'TT_OFFICE_STANDARD
        (cons 'SCHEMA_VERSION *TT:StandardsSchemaVersion*)
        (cons 'PREFERENCES preferences)))

(defun TT:StandardsValidate (standard / preferences)
  (and (eq (type standard) 'LIST)
       (eq (car standard) 'TT_OFFICE_STANDARD)
       (equal (TT:DataValue standard 'SCHEMA_VERSION) *TT:StandardsSchemaVersion*)
       (setq preferences (TT:DataValue standard 'PREFERENCES))
       (TT:ValidatePreferences preferences)))

(defun TT:StandardsUserDirectory (/ base directory made)
  (setq base (getenv "APPDATA"))
  (if (and base (not (equal base "")))
    (progn
      (setq directory (TT:StorageJoinPath base "TerraToolsLT"))
      (if (not (TT:StorageDirectoryExistsP directory))
        (setq made (vl-catch-all-apply 'vl-mkdir (list directory))))
      (if (TT:StorageDirectoryExistsP directory) directory nil))
    nil))

(defun TT:StandardsUserPath (/ directory)
  (setq directory (TT:StandardsUserDirectory))
  (if directory (TT:StorageJoinPath directory "user-standard.dat") nil))

(defun TT:StandardsRead (path / value)
  (setq value (TT:StorageRead path))
  (if (and value (TT:StandardsValidate value)) value nil))

(defun TT:StandardsWrite (path preferences)
  (and path (TT:ValidatePreferences preferences)
       (TT:StorageWrite path (TT:StandardsEnvelope preferences))))

(defun TT:StandardsApply (standard)
  (if (TT:StandardsValidate standard)
    (TT:SavePreferences (TT:DataValue standard 'PREFERENCES))
    nil))

(defun TT:StandardsPrintStatus (/ path standard)
  (setq path (TT:StandardsUserPath)
        standard (if (and path (TT:StorageFileExistsP path)) (TT:StandardsRead path)))
  (princ "\nTerraTools office standards")
  (TT:PrintValue "TerraTools default" "Built in")
  (TT:PrintValue "User standard path" path)
  (TT:PrintValue "User standard readable" (if standard "Yes" "No"))
  (TT:PrintValue "Project override" (if (TT:ProjectCurrent) "Active" "Unavailable"))
  (princ))

(defun C:TTSTANDARDS (/ *error* option preferences path standard answer)
  (defun *error* (message) (TT:ReportError "TTSTANDARDS" message))
  (initget "Info SaveUser ApplyUser Export Import")
  (setq option (getkword
    "\nOffice standards [Info/SaveUser/ApplyUser/Export/Import] <Info>: "))
  (if (null option) (setq option "Info"))
  (cond
    ((equal option "Info") (TT:StandardsPrintStatus))
    ((equal option "SaveUser")
      (setq preferences (TT:LoadPreferences) path (TT:StandardsUserPath))
      (if (and preferences path (TT:StandardsWrite path preferences))
        (princ (strcat "\nUser standard saved: " path))
        (princ "\nCould not save the user standard.")))
    ((equal option "ApplyUser")
      (setq path (TT:StandardsUserPath)
            standard (if path (TT:StandardsRead path)))
      (if (and standard (TT:StandardsApply standard))
        (princ "\nUser standard applied as this project's preferences.")
        (princ "\nNo valid user standard could be applied.")))
    ((equal option "Export")
      (setq preferences (TT:LoadPreferences)
            path (if preferences (getfiled "Export TerraTools standard" "terratools-standard.dat" "dat" 1)))
      (if path
        (if (TT:StandardsWrite path preferences)
          (princ (strcat "\nOffice standard exported: " path))
          (princ "\nOffice standard export failed."))))
    ((equal option "Import")
      (setq path (getfiled "Import TerraTools standard" "" "dat" 0)
            standard (if path (TT:StandardsRead path)))
      (cond
        ((null path) nil)
        ((null standard) (princ "\nThe selected office standard is invalid or unreadable."))
        (T
          (initget "Yes No")
          (setq answer (getkword "\nApply this standard to the active project? [Yes/No] <No>: "))
          (if (equal answer "Yes")
            (if (TT:StandardsApply standard)
              (princ "\nImported standard applied to the project.")
              (princ "\nThe imported standard could not be applied.")))))))
  (princ))

T
