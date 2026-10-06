;;; TerraTools LT - Smart planting areas and reusable multi-component mixes.

(defun TT:PlantSpacingNumber (record / value)
  (setq value (TT:PlantRecordValue record 'SPACING))
  (TT:DimensionToDrawingUnits value)
)

(defun TT:PlantQuantityFromArea (area spacing triangular)
  (if (and (numberp area) (>= area 0.0) (numberp spacing) (> spacing 0.0))
    (fix (+ 0.999999
            (/ area (* spacing spacing (if triangular 0.8660254038 1.0)))))
    nil))

(defun TT:PlantAreaQuantity (entity metadata / record spacing area factor)
  (setq record (TT:PlantFindProjectByID (cdr (assoc 'CATALOG_ID metadata)))
        spacing (if record (TT:PlantSpacingNumber record))
        area (TT:EntityArea entity)
        factor (if (equal (cdr (assoc 'OBJECT_TYPE metadata)) "PLANT_AREA_TRIANGULAR")
                 0.8660254 1.0))
  (TT:PlantQuantityFromArea area spacing (equal factor 0.8660254))
)

(defun C:TTGROUND (/ *error* project record selection entity method object-type layer)
  (defun *error* (message) (TT:ReportError "TTGROUND" message))
  (setq project (TT:ProjectCurrent) record (if project (TT:PlantSelectProjectRecord)))
  (if record
    (progn
      (setq selection (entsel "\nSelect closed planting boundary: "))
      (if (and selection (TT:PolylineClosedP (setq entity (car selection))))
        (progn
          (initget "Square Triangular")
          (setq method (getkword "\nSpacing layout [Square/Triangular] <Square>: "))
          (if (null method) (setq method "Square"))
          (setq object-type (if (equal method "Triangular")
                              "PLANT_AREA_TRIANGULAR" "PLANT_AREA_SQUARE")
                layer (TT:GetLayerForRole (TT:PlantLayerRole record)))
          (command-s "_.UNDO" "_Begin")
          (if layer (entmod (subst (cons 8 layer) (assoc 8 (entget entity)) (entget entity))))
          (if (TT:SmartAttach entity project "PLANTING" object-type
                (TT:PlantRecordValue record 'PROJECT_PLANT_ID) nil)
            (princ "\nSmart planting area created."))
          (command-s "_.UNDO" "_End"))
        (princ "\nA closed LWPOLYLINE is required."))))
  (princ)
)

(defun TT:GroundInfo (context / item metadata quantity record)
  (setq item (TT:SelectSmartEntity "\nSelect smart planting area: "))
  (if (and item
           (member (cdr (assoc 'OBJECT_TYPE (cdr item)))
                   '("PLANT_AREA_SQUARE" "PLANT_AREA_TRIANGULAR")))
    (progn
      (setq metadata (cdr item)
            record (TT:PlantFindProjectByID (cdr (assoc 'CATALOG_ID metadata)))
            quantity (TT:PlantAreaQuantity (car item) metadata))
      (TT:PrintValue "Plant code" (TT:PlantRecordValue record 'PLANT_CODE))
      (TT:PrintValue "Boundary area" (TT:EntityArea (car item)))
      (TT:PrintValue "Derived quantity" quantity))
    (princ "\nThe selected entity is not a smart planting area."))
  (princ)
)

(defun C:TTGROUNDINFO (/ *error*)
  (defun *error* (message) (TT:ReportError "TTGROUNDINFO" message))
  (TT:GroundInfo "TTGROUNDINFO"))

(defun C:TTUPDATEGROUND (/ *error*)
  (defun *error* (message) (TT:ReportError "TTUPDATEGROUND" message))
  (TT:GroundInfo "TTUPDATEGROUND"))

(defun TT:PlantMixes (project) (TT:ProjectValue project 'PLANT_MIXES))

(defun TT:PlantMixLabel (record) (TT:DataValue record 'NAME))

(defun TT:PlantMixPromptComponents (/ mode count index plant id ids value values total components item)
  (initget "Percent Ratio")
  (setq mode (getkword "\nComposition method [Percent/Ratio] <Percent>: "))
  (if (null mode) (setq mode "Percent"))
  (initget 6)
  (setq count (getint "\nNumber of mix components (2-20): "))
  (if (and count (>= count 2) (<= count 20))
    (progn
      (setq index 1 total 0.0)
      (while (and (<= index count) (null item))
        (princ (strcat "\nSelect mix plant " (itoa index) " of " (itoa count) ":"))
        (setq plant (TT:PlantSelectProjectRecord))
        (cond
          ((null plant) (setq item 'CANCELED))
          ((member (setq id (TT:PlantRecordValue plant 'PROJECT_PLANT_ID)) ids)
            (princ "\nEach project plant may appear only once in a mix.")
            (setq item 'CANCELED))
          (T
            (initget 7)
            (setq value (getreal (strcat "\n" mode " value for "
                              (TT:PlantRecordValue plant 'PLANT_CODE) ": ")))
            (if value
              (progn
                (setq values (append values (list (list plant value)))
                      ids (cons id ids) total (+ total value)
                      index (1+ index)))
              (setq item 'CANCELED)))))
      (cond
        (item nil)
        ((and (equal mode "Percent") (not (equal total 100.0 0.01)))
          (princ (strcat "\nPercentage total must equal 100. Current total: "
                         (rtos total 2 2)))
          nil)
        (T
          (foreach item values
            (setq plant (car item) value (cadr item)
                  components (append components
                    (list (list 'MIX_COMPONENT
                      (cons 'PROJECT_PLANT_ID
                        (TT:PlantRecordValue plant 'PROJECT_PLANT_ID))
                      (cons 'PERCENT (* 100.0 (/ value total))))))))
          (list mode components))))
    (progn (if count (princ "\nA mix must contain 2 through 20 components.")) nil)))

(defun C:TTMIX (/ *error* project composition name record mixes)
  (defun *error* (message) (TT:ReportError "TTMIX" message))
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (setq composition (TT:PlantMixPromptComponents)
            name (if composition (getstring T "\nMix name: ")))
      (if (and composition (not (equal name "")))
        (progn
          (setq record
            (list 'PLANT_MIX (cons 'MIX_ID (TT:GenerateUUID)) (cons 'NAME name)
              (cons 'COMPOSITION_MODE (car composition))
              (cons 'COMPONENTS (cadr composition)))
                mixes (append (TT:PlantMixes project) (list record)))
          (if (TT:ProjectSaveSection 'PLANT_MIXES mixes)
            (princ (strcat "\nPlant mix saved: " name)))))))
  (princ)
)

(defun C:TTMIXEDIT (/ *error* project old composition name updated mixes)
  (defun *error* (message) (TT:ReportError "TTMIXEDIT" message))
  (setq project (TT:ProjectCurrent) old (if project (TT:SelectPlantMix project)))
  (if old
    (progn
      (setq name (getstring T (strcat "\nMix name <" (TT:DataValue old 'NAME) ">: ")))
      (if (equal name "") (setq name (TT:DataValue old 'NAME)))
      (princ "\nDefine the complete replacement composition. Press Esc to cancel.")
      (setq composition (TT:PlantMixPromptComponents))
      (if composition
        (progn
          (setq updated (TT:DataPut old 'NAME name)
                updated (TT:DataPut updated 'COMPOSITION_MODE (car composition))
                updated (TT:DataPut updated 'COMPONENTS (cadr composition))
                mixes (subst updated old (TT:PlantMixes project)))
          (if (TT:ProjectSaveSection 'PLANT_MIXES mixes)
            (princ "\nPlant mix updated."))))))
  (princ))

(defun TT:SelectPlantMix (project)
  (if (TT:PlantMixes project)
    (TT:PromptNumberedRecord (TT:PlantMixes project) 'TT:PlantMixLabel "Select mix number")
    (princ "\nNo plant mixes are defined."))
)

(defun C:TTMIXAREA (/ *error* project mix selection entity)
  (defun *error* (message) (TT:ReportError "TTMIXAREA" message))
  (setq project (TT:ProjectCurrent) mix (if project (TT:SelectPlantMix project)))
  (if mix
    (progn
      (setq selection (entsel "\nSelect closed mix boundary: "))
      (if (and selection (TT:PolylineClosedP (setq entity (car selection))))
        (if (TT:SmartAttach entity project "PLANTING" "PLANT_MIX_AREA"
              (TT:DataValue mix 'MIX_ID) nil)
          (princ "\nSmart mixed planting area created."))
        (princ "\nA closed LWPOLYLINE is required."))))
  (princ)
)

(defun C:TTMIXINFO (/ *error* project item mix area component plant spacing quantity)
  (defun *error* (message) (TT:ReportError "TTMIXINFO" message))
  (setq project (TT:ProjectCurrent) item (TT:SelectSmartEntity "\nSelect mixed planting area: "))
  (if (and project item (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "PLANT_MIX_AREA"))
    (progn
      (setq mix (TT:DataFindByValue (TT:PlantMixes project) 'MIX_ID
                  (cdr (assoc 'CATALOG_ID (cdr item))))
            area (TT:EntityArea (car item)))
      (TT:PrintValue "Mix" (TT:DataValue mix 'NAME))
      (TT:PrintValue "Area" area)
      (foreach component (TT:DataValue mix 'COMPONENTS)
        (setq plant (TT:PlantFindProjectByID (TT:DataValue component 'PROJECT_PLANT_ID))
              spacing (TT:PlantSpacingNumber plant)
              quantity (if (and area spacing (> spacing 0.0))
                         (fix (+ 0.999999 (* (/ area (* spacing spacing))
                                              (/ (TT:DataValue component 'PERCENT) 100.0))))))
        (princ (strcat "\n  " (TT:PlantRecordValue plant 'PLANT_CODE)
                       ": " (if quantity (itoa quantity) "Unavailable")))))
    (princ "\nThe selected entity is not a mixed planting area."))
  (princ)
)

T
