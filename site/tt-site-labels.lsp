;;; Reference callouts resolve the same project note as their target geometry.
(defun C:TTREFNOTELABEL (/ *error* project item record point height entity)
  (defun *error* (message) (TT:ReportError "TTREFNOTELABEL" message))
  (setq project (TT:ProjectCurrent) item (if project (TT:SelectSmartEntity "\nSelect reference-note geometry: "))
    record (if (and item (equal (cdr (assoc 'PROJECT_UUID (cdr item))) (TT:ProjectValue project 'PROJECT_UUID)))
      (TT:DataFindByValue (TT:ReferenceNotes project) 'NOTE_ID (cdr (assoc 'CATALOG_ID (cdr item))))))
  (if (and record (setq point (getpoint "\nCallout point: ")))
    (progn
      (setq height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT)
        entity (TT:CreateText (trans point 1 0) height (TT:ReferenceNoteLabel record) (TT:EnsureLayer 'SITE_LABEL)))
      (if (and entity (not (TT:SmartAttach entity project "SITE" "REFNOTE_LABEL" (TT:DataValue record 'NOTE_ID)
        (cdr (assoc 'WORK_AREA_ID (cdr item)))))) (entdel entity))))
  (princ))

(defun C:TTUPDATEREFNOTELABELS (/ project items item record data count)
  (setq project (TT:ProjectCurrent) items (TT:ProjectItems (TT:SmartScan) project) count 0)
  (foreach item (TT:SmartFilter items "SITE" "REFNOTE_LABEL")
    (setq record (TT:DataFindByValue (TT:ReferenceNotes project) 'NOTE_ID (cdr (assoc 'CATALOG_ID (cdr item)))))
    (if record
      (progn (setq data (entget (car item)))
        (if (entmod (subst (cons 1 (TT:ReferenceNoteLabel record)) (assoc 1 data) data)) (setq count (1+ count))))))
  (TT:PrintValue "Reference callouts updated" count) (princ))
T
