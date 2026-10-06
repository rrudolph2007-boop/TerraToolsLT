;;; TerraTools LT - Explicit project Work Areas.

(defun TT:WorkAreas (project)
  (TT:ProjectValue project 'WORK_AREAS)
)

(defun TT:WorkAreaLabel (record)
  (TT:DataValue record 'NAME)
)

(defun TT:WorkAreaFind (project id)
  (TT:DataFindByValue (TT:WorkAreas project) 'WORK_AREA_ID id)
)

(defun TT:SelectWorkAreaRecord (project)
  (if (TT:WorkAreas project)
    (TT:PromptNumberedRecord (TT:WorkAreas project) 'TT:WorkAreaLabel
                             "Select Work Area number")
    nil)
)

(defun TT:WorkAreaEntity (work-area-id / item found)
  (foreach item (TT:SmartFilter (TT:SmartScan) "CORE" "WORK_AREA")
    (if (equal work-area-id (cdr (assoc 'CATALOG_ID (cdr item))))
      (setq found (car item))))
  found)

(defun TT:WorkAreaAssignedItems (work-area-id / item result)
  (foreach item (TT:SmartScan)
    (if (and (equal work-area-id (cdr (assoc 'WORK_AREA_ID (cdr item))))
             (not (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "WORK_AREA")))
      (setq result (cons item result))))
  (reverse result))

(defun TT:WorkAreaCountInItems (work-area-id items / item count)
  (setq count 0)
  (foreach item items
    (if (and (equal work-area-id (cdr (assoc 'WORK_AREA_ID (cdr item))))
             (not (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "WORK_AREA")))
      (setq count (1+ count))))
  count)

(defun TT:WorkAreaPrintList (project / record count items)
  (setq count 0)
  (setq items (TT:SmartScan))
  (princ "\nTerraTools Work Areas")
  (foreach record (TT:WorkAreas project)
    (setq count (1+ count))
    (princ (strcat "\n  " (itoa count) ". " (TT:DataValue record 'NAME)
                   " | assigned objects: "
                   (itoa (TT:WorkAreaCountInItems
                           (TT:DataValue record 'WORK_AREA_ID) items)))))
  (if (= count 0) (princ "\n  No Work Areas are defined."))
  (princ))

(defun TT:WorkAreaRenameCommand (/ project record id name areas)
  (setq project (TT:ProjectCurrent)
        record (if project (TT:SelectWorkAreaRecord project)))
  (if record
    (progn
      (setq name (getstring T "\nNew Work Area name <cancel>: "))
      (if (not (equal name ""))
        (progn
          (setq id (TT:DataValue record 'WORK_AREA_ID)
                areas (subst (TT:DataPut record 'NAME name) record
                             (TT:WorkAreas project)))
          (if (TT:ProjectSaveSection 'WORK_AREAS areas)
            (princ (strcat "\nWork Area renamed: " name))
            (princ "\nCould not save the Work Area name."))))))
  (princ))

(defun TT:WorkAreaDeleteCommand (/ project record id assigned boundary answer areas deleted)
  (setq project (TT:ProjectCurrent)
        record (if project (TT:SelectWorkAreaRecord project)))
  (if record
    (progn
      (setq id (TT:DataValue record 'WORK_AREA_ID)
            assigned (TT:WorkAreaAssignedItems id)
            boundary (TT:WorkAreaEntity id))
      (if assigned
        (princ (strcat "\nWork Area cannot be deleted. It has "
                       (itoa (length assigned)) " assigned smart object(s)."))
        (progn
          (initget "Yes No")
          (setq answer (getkword
            (strcat "\nDelete Work Area " (TT:DataValue record 'NAME)
                    " and its boundary? [Yes/No] <No>: ")))
          (if (equal answer "Yes")
            (progn
              (command-s "_.UNDO" "_Begin")
              (if boundary (setq deleted (entdel boundary)))
              (setq areas (TT:DataRemoveByValue (TT:WorkAreas project)
                                                'WORK_AREA_ID id))
              (if (TT:ProjectSaveSection 'WORK_AREAS areas)
                (princ "\nWork Area deleted.")
                (progn
                  (if deleted (entdel boundary))
                  (princ "\nWork Area deletion failed; the boundary was restored.")))
              (command-s "_.UNDO" "_End")))))))
  (princ))

(defun TT:WorkAreaHighlightCommand (/ project record id item count)
  (setq project (TT:ProjectCurrent)
        record (if project (TT:SelectWorkAreaRecord project))
        count 0)
  (if record
    (progn
      (setq id (TT:DataValue record 'WORK_AREA_ID))
      (foreach item (TT:SmartScan)
        (if (or (equal id (cdr (assoc 'WORK_AREA_ID (cdr item))))
                (and (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "WORK_AREA")
                     (equal id (cdr (assoc 'CATALOG_ID (cdr item))))))
          (progn (redraw (car item) 3) (setq count (1+ count)))))
      (princ (strcat "\nHighlighted " (itoa count)
                     " object(s). REGEN clears highlighting."))))
  (princ))

(defun C:TTWORKAREAS (/ *error* project option)
  (defun *error* (message) (TT:ReportError "TTWORKAREAS" message))
  (setq project (TT:ProjectCurrent))
  (if (null project)
    (princ "\nNo TerraTools project is associated with this drawing.")
    (progn
      (initget "List Create Assign Rename Delete Highlight Count")
      (setq option (getkword
        "\nWork Areas [List/Create/Assign/Rename/Delete/Highlight/Count] <List>: "))
      (if (null option) (setq option "List"))
      (cond
        ((or (equal option "List") (equal option "Count"))
          (TT:WorkAreaPrintList project))
        ((equal option "Create") (C:TTWORKAREA))
        ((equal option "Assign") (C:TTASSIGNWORKAREA))
        ((equal option "Rename") (TT:WorkAreaRenameCommand))
        ((equal option "Delete") (TT:WorkAreaDeleteCommand))
        ((equal option "Highlight") (TT:WorkAreaHighlightCommand)))))
  (princ))

(defun C:TTWORKAREA (/ *error* project selection entity name id record areas layer)
  (defun *error* (message) (TT:ReportError "TTWORKAREA" message))
  (setq project (TT:ProjectCurrent))
  (if (null project)
    (princ "\nNo TerraTools project is associated with this drawing.")
    (progn
      (setq selection (entsel "\nSelect a closed polyline for the Work Area: "))
      (cond
        ((null selection) (princ "\nWork Area creation canceled."))
        ((not (TT:PolylineClosedP (setq entity (car selection))))
          (princ "\nA closed LWPOLYLINE is required."))
        ((equal (setq name (getstring T "\nWork Area name: ")) "")
          (princ "\nA Work Area name is required."))
        (T
          (setq id (TT:GenerateUUID)
                record (list 'WORK_AREA (cons 'WORK_AREA_ID id) (cons 'NAME name))
                areas (append (TT:WorkAreas project) (list record))
                layer (TT:GetLayerForRole 'HELPER_NPLT))
          (command-s "_.UNDO" "_Begin")
          (if layer (entmod (subst (cons 8 layer) (assoc 8 (entget entity)) (entget entity))))
          (if (and (TT:SmartAttach entity project "CORE" "WORK_AREA" id nil)
                   (TT:ProjectSaveSection 'WORK_AREAS areas))
            (princ (strcat "\nWork Area created: " name))
            (princ "\nCould not create the Work Area."))
          (command-s "_.UNDO" "_End")))))
  (princ)
)

(defun C:TTWORKAREAINFO (/ *error* item metadata project record)
  (defun *error* (message) (TT:ReportError "TTWORKAREAINFO" message))
  (setq item (TT:SelectSmartEntity "\nSelect Work Area boundary: "))
  (if (and item (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "WORK_AREA"))
    (progn
      (setq metadata (cdr item) project (TT:ProjectCurrent)
            record (TT:WorkAreaFind project (cdr (assoc 'CATALOG_ID metadata))))
      (TT:PrintValue "Work Area" (TT:DataValue record 'NAME))
      (TT:PrintValue "Area" (TT:EntityArea (car item))))
    (princ "\nThe selected entity is not a TerraTools Work Area."))
  (princ)
)

(defun C:TTASSIGNWORKAREA (/ *error* project record id selection index entity metadata count)
  (defun *error* (message) (TT:ReportError "TTASSIGNWORKAREA" message))
  (setq project (TT:ProjectCurrent))
  (if (null project)
    (princ "\nNo TerraTools project is associated with this drawing.")
    (if (null (setq record (TT:SelectWorkAreaRecord project)))
      (princ "\nNo Work Area selected.")
      (progn
        (setq id (TT:DataValue record 'WORK_AREA_ID)
              selection (ssget "_:L"))
        (if selection
          (progn
            (command-s "_.UNDO" "_Begin")
            (setq index 0 count 0)
            (while (< index (sslength selection))
              (setq entity (ssname selection index)
                    metadata (TT:GetEntityXData entity))
              (if (and metadata
                       (not (equal (cdr (assoc 'OBJECT_TYPE metadata)) "WORK_AREA")))
                (progn
                  (setq metadata (TT:SmartMetadataPut metadata 'WORK_AREA_ID id))
                  (if (TT:SetEntityXData entity metadata) (setq count (1+ count)))))
              (setq index (1+ index)))
            (command-s "_.UNDO" "_End")
            (princ (strcat "\nAssigned " (itoa count) " smart objects to "
                           (TT:DataValue record 'NAME) ".")))))))
  (princ)
)

T
