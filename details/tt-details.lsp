;;; TerraTools LT - Project detail library, placement, and callouts.

(setq *TT:DetailsModuleLoaded* T)

(defun TT:Details (project) (TT:ProjectValue project 'DETAIL_LIBRARY))
(defun TT:DetailLabel (record)
  (strcat (TT:DataValue record 'NUMBER) " | " (TT:DataValue record 'TITLE)))

(defun C:TTDETAILS (/ *error* project option number title notes record records)
  (defun *error* (message) (TT:ReportError "TTDETAILS" message))
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (initget "List Add") (setq option (getkword "\nDetails [List/Add] <List>: "))
      (if (null option) (setq option "List"))
      (if (equal option "Add")
        (progn
          (setq number (getstring T "\nDetail number: ") title (getstring T "\nDetail title: ")
                notes (getstring T "\nDetail notes <blank>: "))
          (if (and (not (equal number "")) (not (equal title "")))
            (progn
              (setq record (list 'DETAIL (cons 'DETAIL_ID (TT:GenerateUUID))
                             (cons 'NUMBER number) (cons 'TITLE title)
                             (cons 'NOTES notes) (cons 'TEMPLATE "TT_DETAIL_FRAME"))
                    records (append (TT:Details project) (list record)))
              (TT:ProjectSaveSection 'DETAIL_LIBRARY records)
              (princ "\nDetail added."))))
        (progn
          (princ "\nProject details")
          (foreach record (TT:Details project)
            (princ (strcat "\n  " (TT:DetailLabel record))))))))
  (princ)
)

(defun TT:SelectDetail (project)
  (if (TT:Details project)
    (TT:PromptNumberedRecord (TT:Details project) 'TT:DetailLabel "Select detail number")
    (princ "\nThe project detail library is empty."))
)

(defun C:TTPLACEDETAIL (/ *error* project record point block entity)
  (defun *error* (message) (TT:ReportError "TTPLACEDETAIL" message))
  (setq project (TT:ProjectCurrent) record (if project (TT:SelectDetail project)))
  (if (and record (setq point (getpoint "\nDetail insertion point: ")))
    (progn
      (setq block (TT:DataValue record 'TEMPLATE))
      (if (or (null block) (equal block "")) (setq block "TT_DETAIL_FRAME"))
      (setq block (TT:EnsureSymbolBlock block 'SQUARE)
            entity (TT:CreateInsert block point "0" 10.0))
      (TT:SmartAttach entity project "DETAILS" "DETAIL_INSTANCE" (TT:DataValue record 'DETAIL_ID) nil)
      (princ (strcat "\nDetail placed: " (TT:DetailLabel record)))))
  (princ)
)

(defun C:TTCALLOUT (/ *error* project record point height entity)
  (defun *error* (message) (TT:ReportError "TTCALLOUT" message))
  (setq project (TT:ProjectCurrent) record (if project (TT:SelectDetail project))
        point (if record (getpoint "\nCallout insertion point: ")) height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT))
  (if point
    (progn
      (setq entity (TT:CreateText point (if (numberp height) height 0.1)
                     (TT:DetailLabel record) "0"))
      (TT:SmartAttach entity project "DETAILS" "DETAIL_CALLOUT" (TT:DataValue record 'DETAIL_ID) nil)))
  (princ)
)

(defun C:TTDETAILRENUMBER (/ *error* project record number updated records item data entity-data count)
  (defun *error* (message) (TT:ReportError "TTDETAILRENUMBER" message))
  (setq project (TT:ProjectCurrent) record (if project (TT:SelectDetail project)))
  (if record
    (progn
      (setq number (getstring T "\nNew detail number: "))
      (if (not (equal number ""))
        (progn
          (setq updated (TT:DataPut record 'NUMBER number)
                records (subst updated record (TT:Details project)))
          (if (TT:ProjectSaveSection 'DETAIL_LIBRARY records)
            (progn
              (setq count 0)
              (foreach item (TT:SmartFilter (TT:SmartScan) "DETAILS" "DETAIL_CALLOUT")
                (setq data (cdr item))
                (if (equal (cdr (assoc 'CATALOG_ID data)) (TT:DataValue record 'DETAIL_ID))
                  (progn
                    (setq entity-data (entget (car item)))
                    (if (and (assoc 1 entity-data)
                             (entmod (subst (cons 1 (TT:DetailLabel updated))
                                            (assoc 1 entity-data) entity-data)))
                      (setq count (1+ count))))))
              (princ (strcat "\nDetail renumbered. Updated " (itoa count) " callout(s)."))))))))
  (princ)
)

(defun C:TTDETAILINFO (/ *error* item project record)
  (defun *error* (message) (TT:ReportError "TTDETAILINFO" message))
  (setq item (TT:SelectSmartEntity "\nSelect detail or callout: ") project (TT:ProjectCurrent))
  (if (and item project
           (setq record (TT:DataFindByValue (TT:Details project) 'DETAIL_ID
                          (cdr (assoc 'CATALOG_ID (cdr item))))))
    (progn (TT:PrintValue "Detail number" (TT:DataValue record 'NUMBER))
           (TT:PrintValue "Title" (TT:DataValue record 'TITLE))
           (TT:PrintValue "Notes" (TT:DataValue record 'NOTES))
           (TT:PrintValue "Template" (TT:DataValue record 'TEMPLATE)))
    (princ "\nNo valid detail record is referenced."))
  (princ)
)

(defun C:TTDETAILINDEX (/ *error* project point height text record)
  (defun *error* (message) (TT:ReportError "TTDETAILINDEX" message))
  (setq project (TT:ProjectCurrent) point (if project (getpoint "\nDetail index insertion point: ")))
  (if point
    (progn
      (setq text "DETAIL INDEX")
      (foreach record (TT:Details project)
        (setq text (strcat text "\\P" (TT:DetailLabel record))))
      (setq height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT))
      (TT:CreateMText point (if (numberp height) height 0.1) 30.0 text "0")))
  (princ)
)

T
