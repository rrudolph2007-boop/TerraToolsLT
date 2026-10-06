;;; TerraTools LT - Smart planting areas and two-component mixes.

(defun TT:PlantSpacingNumber (record / value parsed)
  (setq value (TT:PlantRecordValue record 'SPACING))
  (cond ((numberp value) value)
        ((and (eq (type value) 'STR) (not (equal value "")))
          (setq parsed (distof value 2))
          (if parsed parsed (atof value)))
        (T nil))
)

(defun TT:PlantAreaQuantity (entity metadata / record spacing area factor)
  (setq record (TT:PlantFindProjectByID (cdr (assoc 'CATALOG_ID metadata)))
        spacing (if record (TT:PlantSpacingNumber record))
        area (TT:EntityArea entity)
        factor (if (equal (cdr (assoc 'OBJECT_TYPE metadata)) "PLANT_AREA_TRIANGULAR")
                 0.8660254 1.0))
  (if (and spacing (> spacing 0.0) area)
    (fix (+ 0.999999 (/ area (* spacing spacing factor))))
    nil)
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

(defun C:TTMIX (/ *error* project first second percent name record mixes)
  (defun *error* (message) (TT:ReportError "TTMIX" message))
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (princ "\nSelect first mix plant:") (setq first (TT:PlantSelectProjectRecord))
      (princ "\nSelect second mix plant:") (setq second (if first (TT:PlantSelectProjectRecord)))
      (setq percent (if second (getreal "\nFirst plant percentage <50>: ")))
      (if (null percent) (setq percent 50.0))
      (setq name (if second (getstring T "\nMix name: ")))
      (if (and first second (> percent 0.0) (< percent 100.0) (not (equal name "")))
        (progn
          (setq record
            (list 'PLANT_MIX (cons 'MIX_ID (TT:GenerateUUID)) (cons 'NAME name)
              (cons 'COMPONENTS
                (list
                  (list 'MIX_COMPONENT
                    (cons 'PROJECT_PLANT_ID (TT:PlantRecordValue first 'PROJECT_PLANT_ID))
                    (cons 'PERCENT percent))
                  (list 'MIX_COMPONENT
                    (cons 'PROJECT_PLANT_ID (TT:PlantRecordValue second 'PROJECT_PLANT_ID))
                    (cons 'PERCENT (- 100.0 percent))))))
                mixes (append (TT:PlantMixes project) (list record)))
          (if (TT:ProjectSaveSection 'PLANT_MIXES mixes)
            (princ (strcat "\nPlant mix saved: " name)))))))
  (princ)
)

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
