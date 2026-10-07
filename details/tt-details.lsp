;;; TerraTools LT - Project detail library, placement, and callouts.

(setq *TT:DetailsModuleLoaded* T)

(defun TT:Details (project) (TT:ProjectValue project 'DETAIL_LIBRARY))
(defun TT:DetailLabel (record)
  (strcat (TT:DataValue record 'NUMBER) " | " (TT:DataValue record 'TITLE)))

(defun TT:DetailNumberExistsP (records number / record found)
  (foreach record records
    (if (equal (strcase number) (strcase (TT:DataValue record 'NUMBER))) (setq found T)))
  found)

(defun TT:DetailDependencyCount (detail-id / item count)
  (setq count 0)
  (foreach item (TT:SmartFilter (TT:SmartScan) "DETAILS" nil)
    (if (equal detail-id (cdr (assoc 'CATALOG_ID (cdr item)))) (setq count (1+ count))))
  count)

(defun TT:DetailsVerify (project / records numbers record number problems source)
  (setq records (TT:Details project) problems 0)
  (foreach record records
    (setq number (strcase (TT:DataValue record 'NUMBER))
          source (TT:ProjectResourcePath (TT:DataValue record 'SOURCE_FILE)))
    (if (member number numbers)
      (progn (setq problems (1+ problems))
             (princ (strcat "\n  Duplicate detail number: " number)))
      (setq numbers (cons number numbers)))
    (if (and (eq (type source) 'STR) (not (equal source ""))
             (not (TT:StorageFileExistsP source)))
      (progn (setq problems (1+ problems))
             (princ (strcat "\n  Missing source file: " source)))))
  (princ (strcat "\nDetail verification: "
                 (if (= problems 0) "PASS" (strcat "FAIL, " (itoa problems) " issue(s)"))))
  problems)

(defun C:TTDETAILSCLI (/ *error* project option number title notes category keywords source record records selected updated answer dependencies)
  (defun *error* (message) (TT:ReportError "TTDETAILS" message))
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (initget "List Add Edit Remove Verify")
      (setq option (getkword "\nDetails [List/Add/Edit/Remove/Verify] <List>: "))
      (if (null option) (setq option "List"))
      (cond
       ((equal option "Add")
        (progn
          (setq number (getstring T "\nDetail number: ") title (getstring T "\nDetail title: ")
                category (getstring T "\nCategory <blank>: ")
                keywords (getstring T "\nKeywords <blank>: ")
                notes (getstring T "\nDetail notes <blank>: ")
                source (getfiled "Optional detail source drawing <Cancel for none>" "" "dwg" 0))
          (cond
           ((or (equal number "") (equal title ""))
             (princ "\nDetail number and title are required."))
           ((TT:DetailNumberExistsP (TT:Details project) number)
             (princ "\nThat detail number is already in use."))
           (T
            (progn
              (setq record (list 'DETAIL (cons 'DETAIL_ID (TT:GenerateUUID))
                             (cons 'NUMBER number) (cons 'TITLE title)
                             (cons 'CATEGORY category) (cons 'KEYWORDS keywords)
                             (cons 'NOTES notes) (cons 'SOURCE_FILE (if source source ""))
                             (cons 'LIBRARY_SCOPE "PROJECT")
                             (cons 'TEMPLATE "TT_DETAIL_FRAME"))
                    records (append (TT:Details project) (list record)))
              (if (TT:ProjectSaveSection 'DETAIL_LIBRARY records)
                (princ "\nDetail added.")
                (princ "\nCould not save the detail record.")))))))
       ((equal option "Edit")
        (setq selected (TT:SelectDetail project))
        (if selected
          (progn
            (setq updated selected title (getstring T "\nNew title <keep>: "))
            (if (not (equal title "")) (setq updated (TT:DataPut updated 'TITLE title)))
            (setq category (getstring T "\nNew category <keep>: "))
            (if (not (equal category "")) (setq updated (TT:DataPut updated 'CATEGORY category)))
            (setq keywords (getstring T "\nNew keywords <keep>: "))
            (if (not (equal keywords "")) (setq updated (TT:DataPut updated 'KEYWORDS keywords)))
            (setq notes (getstring T "\nNew notes <keep>: "))
            (if (not (equal notes "")) (setq updated (TT:DataPut updated 'NOTES notes)))
            (if (TT:ProjectSaveSection 'DETAIL_LIBRARY
                  (subst updated selected (TT:Details project)))
              (princ "\nDetail updated.")
              (princ "\nCould not save the detail update.")))))
       ((equal option "Remove")
        (setq selected (TT:SelectDetail project))
        (if selected
          (progn
            (setq dependencies (TT:DetailDependencyCount (TT:DataValue selected 'DETAIL_ID)))
            (if (> dependencies 0)
              (princ (strcat "\nDetail cannot be removed; " (itoa dependencies)
                             " placed object(s) reference it."))
              (progn
                (initget "Yes No")
                (setq answer (getkword "\nRemove this detail record? [Yes/No] <No>: "))
                (if (equal answer "Yes")
                  (progn
                    (if (TT:ProjectSaveSection 'DETAIL_LIBRARY
                          (TT:DataRemoveByValue (TT:Details project) 'DETAIL_ID
                                                (TT:DataValue selected 'DETAIL_ID)))
                      (princ "\nDetail record removed.")
                      (princ "\nCould not remove the detail record.")))))))))
       ((equal option "Verify") (TT:DetailsVerify project))
       (T
        (progn
          (princ "\nProject details")
          (foreach record (TT:Details project)
            (princ (strcat "\n  " (TT:DetailLabel record)))))))))
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
      (if (and (not (equal number ""))
        (or (equal number (TT:DataValue record 'NUMBER))
            (not (TT:DetailNumberExistsP (TT:Details project) number))))
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
