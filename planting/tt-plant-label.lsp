;;; TerraTools LT - Derived plant labels and planting verification.

(defun TT:PlantLabels (project) (TT:ProjectValue project 'PLANT_LABELS))

(defun TT:PlantCodeForProjectID (id / record)
  (setq record (TT:PlantFindProjectByID id))
  (if record (TT:PlantRecordValue record 'PLANT_CODE) "UNKNOWN")
)

(defun TT:PlantLabelText (target-uuids)
  (TT:PlantLabelFromItems target-uuids (TT:SmartScan) (TT:ProjectCurrent)))

(defun TT:CreatePlantLabel (entities / project uuids item metadata point height text label-id label records entity catalog-id catalog-ids layer leader target)
  (setq project (TT:ProjectCurrent))
  (foreach item entities
    (setq metadata (cdr item))
    (if (and (equal (cdr (assoc 'OBJECT_TYPE metadata)) "PLANT_INSTANCE")
             (equal (cdr (assoc 'PROJECT_UUID metadata)) (TT:ProjectValue project 'PROJECT_UUID)))
      (progn
        (setq uuids (cons (cdr (assoc 'ENTITY_UUID metadata)) uuids)
              catalog-id (cdr (assoc 'CATALOG_ID metadata)))
        (if (not (member catalog-id catalog-ids))
          (setq catalog-ids (cons catalog-id catalog-ids))))))
  (setq uuids (reverse uuids))
  (if (> (length catalog-ids) 1)
    (princ "\nA group label must contain one Project Plant type.")
    (if (and project uuids (setq point (getpoint "\nLabel insertion point: ")))
    (progn
      (setq height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT))
      (if (not (numberp height)) (setq height 0.1))
      (setq layer (TT:EnsureLayer 'PLANT_LABEL))
      (setq text (TT:PlantLabelText uuids)
            label-id (TT:GenerateUUID)
            entity (if layer (TT:CreateText (trans point 1 0) height text layer))
            label (list 'PLANT_LABEL (cons 'LABEL_ID label-id)
                        (cons 'TARGET_UUIDS uuids))
            records (append (TT:PlantLabels project) (list label)))
      (if (and entity
               (TT:SmartAttach entity project "PLANTING" "PLANT_LABEL" label-id nil)
               (TT:ProjectSaveSection 'PLANT_LABELS records))
        (progn
          (if (= (strcase (TT:DataValue (TT:LabelStyle) 'LEADER)) "YES")
            (progn
              (setq target (cdr (assoc 10 (entget (caar entities))))
                    leader (if target (TT:CreateLine target (trans point 1 0) layer)))
              (if leader (TT:SmartAttach leader project "PLANTING" "PLANT_LABEL_LEADER" label-id nil))))
          (princ (strcat "\nPlant label created: " text)))
        (if entity (entdel entity))))))
)

(defun C:TTLABELPLANT (/ *error* item)
  (defun *error* (message) (TT:ReportError "TTLABELPLANT" message))
  (setq item (TT:SelectSmartEntity "\nSelect individual plant to label: "))
  (if item (TT:CreatePlantLabel (list item)) (princ "\nNo smart plant selected."))
  (princ)
)

(defun C:TTLABELGROUP (/ *error* selection index entity metadata items)
  (defun *error* (message) (TT:ReportError "TTLABELGROUP" message))
  (setq selection (ssget "_:L"))
  (if selection
    (progn
      (setq index 0)
      (while (< index (sslength selection))
        (setq entity (ssname selection index) metadata (TT:GetEntityXData entity))
        (if metadata (setq items (cons (cons entity metadata) items)))
        (setq index (1+ index)))
      (TT:CreatePlantLabel (reverse items))))
  (princ)
)

(defun TT:UpdatePlantLabelEntity (item project all-items / metadata label-id record text data)
  (setq metadata (cdr item) label-id (cdr (assoc 'CATALOG_ID metadata))
        record (TT:DataFindByValue (TT:PlantLabels project) 'LABEL_ID label-id))
  (if record
    (progn
      (setq text (TT:PlantLabelFromItems (TT:DataValue record 'TARGET_UUIDS) all-items project)
            data (entget (car item)))
      (if (assoc 1 data)
        (entmod (subst (cons 1 text) (assoc 1 data) data))
        nil))
    nil)
)

(defun C:TTUPDATEPLANTLABELS (/ *error* project items item updated invalid all-items)
  (defun *error* (message) (TT:ReportError "TTUPDATEPLANTLABELS" message))
  (setq project (TT:ProjectCurrent)
        all-items (TT:ProjectItems (TT:SmartScan) project)
        items (TT:SmartFilter all-items "PLANTING" "PLANT_LABEL")
        updated 0 invalid 0)
  (if project
    (progn
      (command-s "_.UNDO" "_Begin")
      (foreach item items
        (if (TT:UpdatePlantLabelEntity item project all-items)
          (setq updated (1+ updated))
          (setq invalid (1+ invalid))))
      (command-s "_.UNDO" "_End")
      (princ (strcat "\nUpdated " (itoa updated) " plant label(s); "
                     (itoa invalid) " invalid."))))
  (princ)
)

(defun TT:VerifyPlants (/ items palette project-ids record item metadata missing malformed labels invalid-labels
                        missing-symbols invalid-work-areas project reconcile block work-area-id
                        source-report)
  (setq project (TT:ProjectCurrent))
  (setq palette (TT:PlantPaletteLoad))
  (if palette
    (progn
      (setq source-report (TT:PlantPaletteSourceReport palette))
      (foreach record (TT:PlantPaletteGetAllFromPalette palette)
        (setq project-ids
          (cons (TT:PlantRecordValue record 'PROJECT_PLANT_ID) project-ids)))))
  (setq items (TT:SmartFilter (TT:SmartScan) "PLANTING" nil))
  (foreach item items
    (setq metadata (cdr item))
    (cond
      ((equal (cdr (assoc 'OBJECT_TYPE metadata)) "PLANT_INSTANCE")
        (if (not (member (cdr (assoc 'CATALOG_ID metadata)) project-ids))
          (setq missing (1+ (if missing missing 0))))
        (setq block (cdr (assoc 2 (entget (car item)))))
        (if (or (null block) (null (tblsearch "BLOCK" block)))
          (setq missing-symbols (1+ (if missing-symbols missing-symbols 0)))))
      ((equal (cdr (assoc 'OBJECT_TYPE metadata)) "PLANT_LABEL")
        (setq labels (1+ (if labels labels 0)))
        (if (null (TT:DataFindByValue (TT:PlantLabels project) 'LABEL_ID
                    (cdr (assoc 'CATALOG_ID metadata))))
          (setq invalid-labels (1+ (if invalid-labels invalid-labels 0))))))
    (setq work-area-id (cdr (assoc 'WORK_AREA_ID metadata)))
    (if (and work-area-id (null (TT:WorkAreaFind project work-area-id)))
      (setq invalid-work-areas (1+ (if invalid-work-areas invalid-work-areas 0)))))
  (setq reconcile (TT:ReconcileScan nil))
  (list (cons 'ENTITIES (length items)) (cons 'MISSING_REFERENCES (if missing missing 0))
        (cons 'LABELS (if labels labels 0))
        (cons 'INVALID_LABELS (if invalid-labels invalid-labels 0))
        (cons 'MISSING_SYMBOLS (if missing-symbols missing-symbols 0))
        (cons 'INVALID_WORK_AREAS (if invalid-work-areas invalid-work-areas 0))
        (cons 'SOURCE_AVAILABLE
              (if source-report (cdr (assoc 'SOURCE_AVAILABLE source-report)) 0))
        (cons 'SOURCE_UNAVAILABLE
              (if source-report (cdr (assoc 'SOURCE_UNAVAILABLE source-report)) 0))
        (cons 'SOURCE_CATEGORY_MISMATCH
              (if source-report
                (cdr (assoc 'SOURCE_CATEGORY_MISMATCH source-report)) 0))
        (cons 'DUPLICATE_UUIDS (cdr (assoc 'DUPLICATES reconcile))))
)

(defun C:TTVERIFYPLANTS (/ *error* report)
  (defun *error* (message) (TT:ReportError "TTVERIFYPLANTS" message))
  (setq report (TT:VerifyPlants))
  (princ "\nPlant verification")
  (TT:PrintValue "Planting smart entities" (cdr (assoc 'ENTITIES report)))
  (TT:PrintValue "Missing project plant references" (cdr (assoc 'MISSING_REFERENCES report)))
  (TT:PrintValue "Plant labels" (cdr (assoc 'LABELS report)))
  (TT:PrintValue "Invalid labels" (cdr (assoc 'INVALID_LABELS report)))
  (TT:PrintValue "Missing symbol definitions" (cdr (assoc 'MISSING_SYMBOLS report)))
  (TT:PrintValue "Invalid Work Area references" (cdr (assoc 'INVALID_WORK_AREAS report)))
  (TT:PrintValue "Source available" (cdr (assoc 'SOURCE_AVAILABLE report)))
  (TT:PrintValue "Source unavailable" (cdr (assoc 'SOURCE_UNAVAILABLE report)))
  (TT:PrintValue "Source category mismatch"
                 (cdr (assoc 'SOURCE_CATEGORY_MISMATCH report)))
  (TT:PrintValue "Duplicate UUIDs" (cdr (assoc 'DUPLICATE_UUIDS report)))
  (princ)
)

(defun C:TTFIXPLANTS (/ *error*)
  (defun *error* (message) (TT:ReportError "TTFIXPLANTS" message))
  (C:TTRECONCILE)
  (C:TTUPDATEPLANTLABELS)
  (C:TTVERIFYPLANTS)
)

T
