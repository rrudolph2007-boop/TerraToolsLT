;;; Folder packages use safe generated resource names; no archive extraction.
(defun TT:PackageRelativePathP (path / parts part valid)
  (setq valid (and (eq (type path) 'STR) (> (strlen path) 0)
    (not (vl-string-search ":" path)) (not (member (substr path 1 1) '("/" "\\")))))
  (if valid
    (progn
      (setq parts (TT:StringWords (vl-string-translate "/\\" "  " path)))
      (foreach part parts (if (member part '("." "..")) (setq valid nil)))))
  valid)

(defun TT:ProjectResourcePath (path / directory)
  (if (and path (/= path ""))
    (if (TT:StorageAbsolutePathP path) path
      (if (and (TT:PackageRelativePathP path) *TT:CurrentProjectPath*)
        (TT:StorageJoinPath (vl-filename-directory *TT:CurrentProjectPath*) path)))))

(defun TT:PackageCreate (destination resources / project copied source name relative target entries mapping updated records record pair path valid)
  (setq project (TT:ProjectCurrent) valid (and project (TT:StorageAbsolutePathP destination)
    (not (TT:StorageDirectoryExistsP destination))))
  (if (not valid) (TT:ProjectSetError "Choose a new, absolute package folder. Existing folders are never overwritten.")
    (if (and (vl-mkdir destination) (vl-mkdir (TT:StorageJoinPath destination "resources")))
      (progn
        (foreach source resources
          (setq source (TT:ProjectResourcePath source))
          (if (not (and source (TT:StorageReadableP source))) (setq valid nil)
            (progn
              (setq name (strcat (TT:GenerateUUID) (if (vl-filename-extension source) (vl-filename-extension source) ".dat"))
                    relative (strcat "resources/" name) target (TT:StorageJoinPath destination relative))
              (if (vl-file-copy source target)
                (setq mapping (cons (cons source relative) mapping)
                      entries (cons (list 'RESOURCE (cons 'PATH relative) (cons 'ORIGINAL_NAME (vl-filename-base source))) entries))
                (setq valid nil)))))
        (if valid
          (progn
            (foreach record (TT:Details project)
              (setq path (TT:ProjectResourcePath (TT:DataValue record 'SOURCE_FILE)) pair (assoc path mapping))
              (setq records (cons (if pair (TT:DataPut record 'SOURCE_FILE (cdr pair)) record) records)))
            (setq updated (TT:ProjectWithValue project 'DETAIL_LIBRARY (reverse records)))
            (and (TT:ProjectValidate updated)
              (TT:StorageWrite (TT:StorageJoinPath destination "terratools-project.dat") updated)
              (TT:StorageWrite (TT:StorageJoinPath destination "terratools-package.dat")
                (list 'TT_PROJECT_PACKAGE '(SCHEMA_VERSION . 1) (cons 'PROJECT_UUID (TT:ProjectValue project 'PROJECT_UUID))
                  '(PROJECT_FILE . "terratools-project.dat") (cons 'RESOURCES (reverse entries))))))
          (TT:ProjectSetError "Package copy failed. The original project is unchanged; incomplete output remains in the new folder for inspection.")))
      (TT:ProjectSetError "Could not create the package folder. Check access and the parent directory."))))

(defun TT:PackageOpen (manifest-path / manifest root relative record valid path project)
  (setq manifest (TT:StorageRead manifest-path) root (vl-filename-directory manifest-path)
        relative (TT:DataValue manifest 'PROJECT_FILE)
        valid (and (eq (car manifest) 'TT_PROJECT_PACKAGE) (equal (TT:DataValue manifest 'SCHEMA_VERSION) 1)
          (TT:PackageRelativePathP relative)))
  (foreach record (TT:DataValue manifest 'RESOURCES)
    (if (not (and (TT:PackageRelativePathP (TT:DataValue record 'PATH))
      (TT:StorageReadableP (TT:StorageJoinPath root (TT:DataValue record 'PATH))))) (setq valid nil)))
  (if valid
    (progn
      (setq path (TT:StorageJoinPath root relative) project (TT:ProjectLoad path))
      (if (and project (equal (TT:ProjectValue project 'PROJECT_UUID) (TT:DataValue manifest 'PROJECT_UUID))) (TT:ProjectOpen path)))
    (TT:ProjectSetError "Package manifest is invalid or a listed resource is missing. No drawing association was changed.")))

(defun C:TTPACKAGE (/ *error* option path destination resources source)
  (defun *error* (message) (TT:ReportError "TTPACKAGE" message))
  (initget "Create Open") (setq option (getkword "\nProject package [Create/Open] <Create>: "))
  (if (= option "Open")
    (progn
      (setq path (getfiled "Open TerraTools package manifest" "" "dat" 0))
      (if (and path (not (TT:PackageOpen path))) (TT:ProjectPrintError)))
    (if (TT:ProjectCurrent)
      (progn
        (setq destination (getstring T "\nNew absolute package folder <cancel>: "))
        (if (/= destination "")
          (progn
            (princ "\nSelect only resources you want to copy. Cancel finishes resource selection. The DWG is not copied.")
            (while (setq source (getfiled "Add resource to package (Cancel finishes)" "" "*" 0))
              (if (not (member source resources)) (setq resources (append resources (list source)))))
            (if (TT:PackageCreate (TT:StorageNormalizePath destination) resources)
              (princ "\nPackage created. Original project remains active. Unselected external resources retain their original paths.")
              (TT:ProjectPrintError)))))))
  (princ))

(defun C:TTADOPT (/ *error* project selection index entity data module type id resolved updated count skipped)
  (defun *error* (message) (TT:ReportError "TTADOPT" message))
  (setq project (TT:ProjectCurrent) count 0 skipped 0)
  (if project
    (progn
      (princ "\nSelect foreign objects to adopt. Only existing project record IDs can resolve; unresolved Work Area links are cleared.")
      (setq selection (ssget "_:L") index 0)
      (if selection
        (while (< index (sslength selection))
          (setq entity (ssname selection index) data (TT:GetEntityXData entity) index (1+ index)
            module (cdr (assoc 'MODULE data)) type (cdr (assoc 'OBJECT_TYPE data)) id (cdr (assoc 'CATALOG_ID data))
            resolved (cond
              ((and (equal module "PLANTING") (member type '("PLANT_INSTANCE" "PLANT_AREA_SQUARE" "PLANT_AREA_TRIANGULAR" "PLANT_AREA_DENSITY"))) (TT:PlantFindProjectByID id))
              ((and (equal module "LIGHTING") (equal type "FIXTURE")) (TT:LightingFind (TT:LightingPalette project) id))
              ((and (equal module "IRRIGATION") (not (TT:IrrigationPipeP data))) (TT:IrrigationFind (TT:IrrigationPalette project) id))))
          (if (and data resolved (not (equal (cdr (assoc 'PROJECT_UUID data)) (TT:ProjectValue project 'PROJECT_UUID))))
            (progn
              (setq updated (TT:SmartMetadataPut data 'PROJECT_UUID (TT:ProjectValue project 'PROJECT_UUID))
                    updated (TT:SmartMetadataPut updated 'ENTITY_UUID (TT:GenerateUUID)))
              (if (not (TT:WorkAreaFind project (cdr (assoc 'WORK_AREA_ID data)))) (setq updated (vl-remove (assoc 'WORK_AREA_ID updated) updated)))
              (if (TT:SetEntityXData entity updated) (setq count (1+ count)) (setq skipped (1+ skipped))))
            (setq skipped (1+ skipped)))))))
  (TT:PrintValue "Adopted" count) (TT:PrintValue "Unchanged" skipped) (princ))
T
