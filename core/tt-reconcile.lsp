;;; TerraTools LT - Cross-module inspection, verification, and UUID repair.

(defun TT:KnownModuleP (module)
  (if (and (eq (type module) 'STR) (member (strcase module) *TT:KnownModules*)) T nil)
)

(setq *TT:KnownObjectTypes*
  '("PLANT_INSTANCE" "PLANT_AREA_SQUARE" "PLANT_AREA_TRIANGULAR"
    "PLANT_MIX_AREA" "PLANT_LABEL" "PLANT_SCHEDULE" "WORK_AREA"
    "REFNOTE_NOTATION" "REFNOTE_COUNT" "REFNOTE_LENGTH" "REFNOTE_AREA"
    "REFNOTE_VOLUME" "REFNOTE_AMENITY" "REFNOTE_MATERIAL" "REFNOTE_HARDSCAPE"
    "REFNOTE_SCHEDULE" "CONCEPT_ZONE"
    "DETAIL_INSTANCE" "DETAIL_CALLOUT" "FIXTURE" "WIRE" "TRANSFORMER"
    "SPRAY_HEAD" "ROTOR" "DRIP" "VALVE" "CONTROLLER" "POC"
    "FILTER_REGULATOR" "SLEEVE" "COVERAGE" "MAINLINE_PIPE" "LATERAL_PIPE"
    "DRIP_LINE" "IRRIGATION_LABEL"))

(defun TT:ReconcileScan (repair / items selection total seen item entity metadata uuid project-uuid
                                active-project-uuid module object-type duplicates malformed missing-project foreign-project unknown unknown-object repaired)
  (setq items (TT:SmartScan)
        selection (ssget "_X" (list (list -3 (list *TT:XDataApp*))))
        total (if selection (sslength selection) 0)
        malformed (- total (length items))
        active-project-uuid (if (TT:ProjectCurrent)
                              (TT:ProjectValue *TT:CurrentProject* 'PROJECT_UUID)))
  (foreach item items
    (setq entity (car item) metadata (cdr item)
          uuid (cdr (assoc 'ENTITY_UUID metadata))
          project-uuid (cdr (assoc 'PROJECT_UUID metadata))
          module (cdr (assoc 'MODULE metadata)))
    (setq object-type (cdr (assoc 'OBJECT_TYPE metadata)))
    (cond
      ((or (null uuid) (equal uuid "")) (setq malformed (1+ malformed)))
      ((member uuid seen)
        (setq duplicates (1+ (if duplicates duplicates 0)))
        (if repair
          (progn
            (setq metadata (TT:SmartMetadataPut metadata 'ENTITY_UUID (TT:GenerateUUID)))
            (if (TT:SetEntityXData entity metadata)
              (setq repaired (1+ (if repaired repaired 0)))))))
      (T (setq seen (cons uuid seen))))
    (if (or (null project-uuid) (equal project-uuid ""))
      (setq missing-project (1+ (if missing-project missing-project 0))))
    (if (and active-project-uuid project-uuid
             (not (equal active-project-uuid project-uuid)))
      (setq foreign-project (1+ (if foreign-project foreign-project 0))))
    (if (or (null module) (not (TT:KnownModuleP module)))
      (setq unknown (1+ (if unknown unknown 0))))
    (if (or (null object-type) (not (member object-type *TT:KnownObjectTypes*)))
      (setq unknown-object (1+ (if unknown-object unknown-object 0)))))
  (list (cons 'TOTAL total)
        (cons 'DUPLICATES (if duplicates duplicates 0))
        (cons 'MALFORMED (if malformed malformed 0))
        (cons 'MISSING_PROJECT (if missing-project missing-project 0))
        (cons 'FOREIGN_PROJECT (if foreign-project foreign-project 0))
        (cons 'UNKNOWN_MODULE (if unknown unknown 0))
        (cons 'UNKNOWN_OBJECT_TYPE (if unknown-object unknown-object 0))
        (cons 'REPAIRED (if repaired repaired 0)))
)

(defun TT:PrintReconcileReport (report)
  (TT:PrintValue "Smart entities" (cdr (assoc 'TOTAL report)))
  (TT:PrintValue "Duplicate UUIDs" (cdr (assoc 'DUPLICATES report)))
  (TT:PrintValue "Malformed metadata" (cdr (assoc 'MALFORMED report)))
  (TT:PrintValue "Missing project UUID" (cdr (assoc 'MISSING_PROJECT report)))
  (TT:PrintValue "Foreign project UUID" (cdr (assoc 'FOREIGN_PROJECT report)))
  (TT:PrintValue "Unknown modules" (cdr (assoc 'UNKNOWN_MODULE report)))
  (TT:PrintValue "Unknown object types" (cdr (assoc 'UNKNOWN_OBJECT_TYPE report)))
  (TT:PrintValue "UUIDs repaired" (cdr (assoc 'REPAIRED report)))
)

(defun C:TTRECONCILE (/ *error* report undo-open)
  (defun *error* (message)
    (if undo-open (command-s "_.UNDO" "_End"))
    (TT:ReportError "TTRECONCILE" message))
  (command-s "_.UNDO" "_Begin")
  (setq undo-open T)
  (setq report (TT:ReconcileScan T))
  (command-s "_.UNDO" "_End")
  (setq undo-open nil)
  (princ "\nTerraTools reconciliation")
  (TT:PrintReconcileReport report)
  (princ)
)

(defun C:TTVERIFY (/ *error* report)
  (defun *error* (message) (TT:ReportError "TTVERIFY" message))
  (setq report (TT:ReconcileScan nil))
  (princ "\nTerraTools verification")
  (TT:PrintReconcileReport report)
  (princ)
)

(defun C:TTFIX (/ *error*)
  (defun *error* (message) (TT:ReportError "TTFIX" message))
  (C:TTRECONCILE)
)

(defun C:TTINFO (/ *error* item)
  (defun *error* (message) (TT:ReportError "TTINFO" message))
  (setq item (TT:SelectSmartEntity "\nSelect TerraTools object: "))
  (if item
    (progn
      (princ "\nTerraTools smart object")
      (TT:PrintEntityMetadata (cdr item)))
    (princ "\nThe selected entity is not TerraTools-aware."))
  (princ)
)

(defun C:TTHIGHLIGHT (/ *error* item)
  (defun *error* (message) (TT:ReportError "TTHIGHLIGHT" message))
  (setq item (TT:SelectSmartEntity "\nSelect TerraTools object to highlight: "))
  (if item (redraw (car item) 3) (princ "\nNo smart object selected."))
  (princ)
)

(defun TT:MimicMetadata (/ source targets index entity metadata)
  (setq source (TT:SelectSmartEntity "\nSelect source TerraTools object: "))
  (if source
    (progn
      (setq targets (ssget "_:L"))
      (if targets
        (progn
          (command-s "_.UNDO" "_Begin")
          (setq index 0)
          (while (< index (sslength targets))
            (setq entity (ssname targets index)
                  metadata (cdr source)
                  metadata (TT:SmartMetadataPut metadata 'ENTITY_UUID (TT:GenerateUUID)))
            (TT:SetEntityXData entity metadata)
            (setq index (1+ index)))
          (command-s "_.UNDO" "_End")))))
  (princ)
)

(defun C:TTMIMIC (/ *error*)
  (defun *error* (message) (TT:ReportError "TTMIMIC" message))
  (TT:MimicMetadata))

(defun C:TTSUBSTITUTE (/ *error*)
  (defun *error* (message) (TT:ReportError "TTSUBSTITUTE" message))
  (TT:MimicMetadata))

T
