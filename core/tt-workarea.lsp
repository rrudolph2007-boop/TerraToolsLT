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
