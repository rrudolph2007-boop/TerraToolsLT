;;; TerraTools LT - Smart individual plant placement and editing.

(defun TT:PlantFindProjectByID (project-plant-id / palette)
  (setq palette (TT:PlantPaletteLoad))
  (if palette
    (TT:DataFindByValue (TT:PlantPaletteGetAllFromPalette palette)
                        'PROJECT_PLANT_ID project-plant-id)
    nil)
)

(defun TT:PlantSelectProjectRecord (/ palette plants)
  (setq palette (TT:PlantPaletteLoad))
  (if palette
    (progn
      (setq plants (TT:PlantPaletteGetAllFromPalette palette))
      (if plants
        (progn
          (princ "\nSelect a Project Plant:")
          (TT:PlantPromptProjectSelection plants "Select plant number"))
        (princ "\nThe Project Plant Palette is empty.")))
    (TT:PlantPrintError))
)

(defun TT:PlantLayerRole (record)
  (TT:PlantRecordValue record 'CATEGORY)
)

(defun TT:PlantSymbolStyle (record / category)
  (setq category (TT:PlantRecordValue record 'CATEGORY))
  (cond ((eq category 'TREE) 'CIRCLE)
        ((eq category 'SHRUB) 'SQUARE)
        (T 'TRIANGLE))
)

(defun TT:PlantEnsureSymbol (record / name)
  (setq name (TT:PlantRecordValue record 'SYMBOL_BLOCK))
  (if (equal name "")
    (setq name (strcat "TT_PLANT_" (TT:PlantRecordValue record 'PLANT_CODE))))
  (TT:EnsureSymbolBlock name (TT:PlantSymbolStyle record))
)

(defun TT:PlantCreateInstance (project record point work-area-id / layer block entity)
  (setq layer (TT:EnsureLayer (TT:PlantLayerRole record)))
  (if (null layer) (setq layer "0"))
  (setq block (TT:PlantEnsureSymbol record))
  (if block
    (progn
      (setq entity (TT:CreateInsert block point layer 1.0))
      (if (and entity
               (TT:SmartAttach entity project "PLANTING" "PLANT_INSTANCE"
                 (TT:PlantRecordValue record 'PROJECT_PLANT_ID) work-area-id))
        entity
        (progn (if entity (entdel entity)) nil)))
    nil)
)

(defun C:TTPLACEPLANT (/ *error* undo-open project record point count)
  (defun *error* (message)
    (if undo-open (command-s "_.UNDO" "_End"))
    (TT:ReportError "TTPLACEPLANT" message))
  (setq project (TT:ProjectCurrent))
  (if (null project)
    (princ "\nNo TerraTools project is associated with this drawing.")
    (if (setq record (TT:PlantSelectProjectRecord))
      (progn
        (command-s "_.UNDO" "_Begin")
        (setq undo-open T count 0)
        (while (setq point (getpoint "\nPlant insertion point <finish>: "))
          (if (TT:PlantCreateInstance project record point nil)
            (setq count (1+ count))))
        (command-s "_.UNDO" "_End")
        (setq undo-open nil)
        (princ (strcat "\nPlaced " (itoa count) " plant instance(s).")))))
  (princ)
)

(defun C:TTPLANTINFO (/ *error* item metadata record source)
  (defun *error* (message) (TT:ReportError "TTPLANTINFO" message))
  (setq item (TT:SelectSmartEntity "\nSelect smart plant: "))
  (if (and item (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "PLANT_INSTANCE"))
    (progn
      (setq metadata (cdr item)
            record (TT:PlantFindProjectByID (cdr (assoc 'CATALOG_ID metadata))))
      (if record
        (progn
          (TT:PlantPrintProjectRecord record)
          (setq source (TT:PlantProjectSourceRecord record))
          (TT:PrintValue "Source status"
            (if source "SOURCE AVAILABLE" "SOURCE UNAVAILABLE"))
          (if (and source (TT:PlantRecordValue source 'CATEGORY)
                   (not (eq (TT:PlantRecordValue record 'CATEGORY)
                            (TT:PlantRecordValue source 'CATEGORY))))
            (TT:PrintValue "Source warning" "CATEGORY MISMATCH")))
        (princ "\nThe plant references a missing Project Plant record."))
      (TT:PrintValue "Entity UUID" (cdr (assoc 'ENTITY_UUID metadata)))
      (TT:PrintValue "Work Area ID" (cdr (assoc 'WORK_AREA_ID metadata))))
    (princ "\nThe selected entity is not an individual TerraTools plant."))
  (princ)
)

(defun TT:PlantInstanceItems ()
  (TT:SmartFilter (TT:SmartScan) "PLANTING" "PLANT_INSTANCE")
)

(defun TT:PlantCountByProjectID (project-id work-area-id / count item metadata)
  (setq count 0)
  (foreach item (TT:PlantInstanceItems)
    (setq metadata (cdr item))
    (if (and (equal project-id (cdr (assoc 'CATALOG_ID metadata)))
             (or (null work-area-id)
                 (equal work-area-id (cdr (assoc 'WORK_AREA_ID metadata)))))
      (setq count (1+ count))))
  count
)

(defun C:TTCOUNTPLANTS (/ *error* palette record count)
  (defun *error* (message) (TT:ReportError "TTCOUNTPLANTS" message))
  (setq palette (TT:PlantPaletteLoad))
  (if palette
    (progn
      (princ "\nTerraTools individual plant counts")
      (foreach record (TT:PlantPaletteGetAllFromPalette palette)
        (setq count (TT:PlantCountByProjectID
                      (TT:PlantRecordValue record 'PROJECT_PLANT_ID) nil))
        (princ (strcat "\n  " (TT:PlantRecordValue record 'PLANT_CODE)
                       ": " (itoa count))))))
  (princ)
)

(defun TT:PlantReplaceEntity (entity record / data block metadata)
  (setq data (entget entity) block (TT:PlantEnsureSymbol record)
        metadata (TT:GetEntityXData entity))
  (if (and block metadata (equal (cdr (assoc 0 data)) "INSERT"))
    (progn
      (setq data (subst (cons 2 block) (assoc 2 data) data)
            metadata (TT:SmartMetadataPut metadata 'CATALOG_ID
                       (TT:PlantRecordValue record 'PROJECT_PLANT_ID)))
      (and (entmod data) (TT:SetEntityXData entity metadata)))
    nil)
)

(defun TT:PlantReplaceCommand (context / item record)
  (setq item (TT:SelectSmartEntity "\nSelect individual plant: "))
  (if (and item (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "PLANT_INSTANCE"))
    (if (setq record (TT:PlantSelectProjectRecord))
      (progn
        (command-s "_.UNDO" "_Begin")
        (if (TT:PlantReplaceEntity (car item) record)
          (princ "\nPlant updated.")
          (princ "\nPlant could not be updated."))
        (command-s "_.UNDO" "_End")))
    (princ "\nThe selected entity is not an individual TerraTools plant."))
  (princ)
)

(defun C:TTEDITPLANT (/ *error*)
  (defun *error* (message) (TT:ReportError "TTEDITPLANT" message))
  (TT:PlantReplaceCommand "TTEDITPLANT"))

(defun C:TTREPLACEPLANT (/ *error*)
  (defun *error* (message) (TT:ReportError "TTREPLACEPLANT" message))
  (TT:PlantReplaceCommand "TTREPLACEPLANT"))

(defun C:TTMATCHPLANT (/ *error* source metadata record selection index entity count)
  (defun *error* (message) (TT:ReportError "TTMATCHPLANT" message))
  (setq source (TT:SelectSmartEntity "\nSelect source plant: "))
  (if (and source (equal (cdr (assoc 'OBJECT_TYPE (cdr source))) "PLANT_INSTANCE"))
    (progn
      (setq metadata (cdr source)
            record (TT:PlantFindProjectByID (cdr (assoc 'CATALOG_ID metadata)))
            selection (ssget "_:L") index 0 count 0)
      (if (and record selection)
        (progn
          (command-s "_.UNDO" "_Begin")
          (while (< index (sslength selection))
            (setq entity (ssname selection index))
            (if (TT:PlantReplaceEntity entity record) (setq count (1+ count)))
            (setq index (1+ index)))
          (command-s "_.UNDO" "_End")
          (princ (strcat "\nMatched " (itoa count) " plant(s).")))))
    (princ "\nThe source is not an individual TerraTools plant."))
  (princ)
)

(defun C:TTHIGHLIGHTPLANT (/ *error* record item count)
  (defun *error* (message) (TT:ReportError "TTHIGHLIGHTPLANT" message))
  (setq record (TT:PlantSelectProjectRecord) count 0)
  (if record
    (foreach item (TT:PlantInstanceItems)
      (if (equal (TT:PlantRecordValue record 'PROJECT_PLANT_ID)
                 (cdr (assoc 'CATALOG_ID (cdr item))))
        (progn (redraw (car item) 3) (setq count (1+ count))))))
  (princ (strcat "\nHighlighted " (itoa count) " plant(s)."))
  (princ)
)

(defun C:TTLOCATEPLANT (/ *error* item)
  (defun *error* (message) (TT:ReportError "TTLOCATEPLANT" message))
  (setq item (TT:SelectSmartEntity "\nSelect plant to locate: "))
  (if item (command-s "_.ZOOM" "_Object" (car item) ""))
  (princ)
)

(defun C:TTPLANTLINE (/ *error* project record start end spacing length count index point)
  (defun *error* (message) (TT:ReportError "TTPLANTLINE" message))
  (setq project (TT:ProjectCurrent) record (if project (TT:PlantSelectProjectRecord)))
  (if record
    (progn
      (setq start (getpoint "\nStart point: ") end (if start (getpoint start "\nEnd point: "))
            spacing (if end (getdist "\nPlant spacing: ")))
      (if (and start end spacing (> spacing 0.0))
        (progn
          (setq length (distance start end) count (1+ (fix (/ length spacing))) index 0)
          (command-s "_.UNDO" "_Begin")
          (repeat count
            (setq point (polar start (angle start end) (min length (* index spacing))))
            (TT:PlantCreateInstance project record point nil)
            (setq index (1+ index)))
          (command-s "_.UNDO" "_End")
          (princ (strcat "\nPlaced " (itoa count) " plants along the line.")))))
  (princ)
)
)

(defun C:TTPLANTPATH (/ *error* undo-open project record selection entity type length closed mode spacing count index point made)
  (defun *error* (message)
    (if undo-open (command-s "_.UNDO" "_End"))
    (TT:ReportError "TTPLANTPATH" message))
  (setq project (TT:ProjectCurrent) record (if project (TT:PlantSelectProjectRecord)))
  (if record
    (progn
      (setq selection (entsel "\nSelect LINE, ARC, or LWPOLYLINE path: ")
            entity (if selection (car selection))
            type (if entity (cdr (assoc 0 (entget entity))))
            length (if (member type '("LINE" "ARC" "LWPOLYLINE")) (TT:EntityLength entity))
            closed (and entity (equal type "LWPOLYLINE") (TT:PolylineClosedP entity)))
      (if (and length (> length 0.0))
        (progn
          (initget "Fixed Equal")
          (setq mode (getkword "\nPath spacing [Fixed/Equal] <Fixed>: "))
          (if (null mode) (setq mode "Fixed"))
          (if (equal mode "Fixed")
            (progn
              (setq spacing (getdist "\nFixed plant spacing: "))
              (if (and spacing (> spacing 0.0))
                (setq count (if closed (max 1 (fix (/ length spacing)))
                              (1+ (fix (/ length spacing)))))))
            (progn
              (initget 6)
              (setq count (getint "\nNumber of plants (2 or more): "))
              (if (and count (>= count 2))
                (setq spacing (/ length (if closed count (1- count)))))))
          (if (and count spacing)
            (progn
              (command-s "_.UNDO" "_Begin") (setq undo-open T index 0 made 0)
              (repeat count
                (setq point (TT:EntityPointAtDistance entity (* index spacing)))
                (if (and point (TT:PlantCreateInstance project record point nil))
                  (setq made (1+ made)))
                (setq index (1+ index)))
              (command-s "_.UNDO" "_End") (setq undo-open nil)
              (princ (strcat "\nPlaced " (itoa made) " plants along the path.")))))
        (if selection (princ "\nThe selected entity is not a supported path.")))))
  (princ))

(defun C:TTPLANTARRAY (/ *error* project record origin rows columns row-spacing column-spacing r c point count)
  (defun *error* (message) (TT:ReportError "TTPLANTARRAY" message))
  (setq project (TT:ProjectCurrent) record (if project (TT:PlantSelectProjectRecord)))
  (if record
    (progn
      (setq origin (getpoint "\nArray origin: ") rows (if origin (getint "\nRows: "))
            columns (if rows (getint "\nColumns: "))
            row-spacing (if columns (getdist "\nRow spacing: "))
            column-spacing (if row-spacing (getdist "\nColumn spacing: ")))
      (if (and origin rows columns row-spacing column-spacing
               (> rows 0) (> columns 0) (> row-spacing 0.0) (> column-spacing 0.0))
        (progn
          (command-s "_.UNDO" "_Begin")
          (setq r 0 count 0)
          (repeat rows
            (setq c 0)
            (repeat columns
              (setq point (list (+ (car origin) (* c column-spacing))
                                (+ (cadr origin) (* r row-spacing))
                                (if (caddr origin) (caddr origin) 0.0)))
              (if (TT:PlantCreateInstance project record point nil) (setq count (1+ count)))
              (setq c (1+ c)))
            (setq r (1+ r)))
          (command-s "_.UNDO" "_End")
          (princ (strcat "\nPlaced " (itoa count) " plants in the array."))))))
  (princ))

(defun TT:RandomUnit (/ value)
  (if (not (and (boundp '*TT:RandomSeed*) (numberp *TT:RandomSeed*)))
    (setq *TT:RandomSeed* (fix (* (getvar "DATE") 1000000.0))))
  (setq *TT:RandomSeed* (rem (+ (* 1103515245 *TT:RandomSeed*) 12345) 2147483647))
  (/ (float *TT:RandomSeed*) 2147483647.0))

(defun TT:PlantApplyTransform (entity scale rotation / data)
  (setq data (entget entity))
  (if (and data (equal (cdr (assoc 0 data)) "INSERT"))
    (progn
      (setq data (subst (cons 41 scale) (assoc 41 data) data)
            data (subst (cons 42 scale) (assoc 42 data) data)
            data (subst (cons 43 scale) (assoc 43 data) data)
            data (subst (cons 50 rotation) (assoc 50 data) data))
      (entmod data))
    nil))

(defun C:TTPLANTRANDOM (/ *error* undo-open project record first second count index x y point made min-scale max-scale rotation-range entity scale rotation)
  (defun *error* (message)
    (if undo-open (command-s "_.UNDO" "_End"))
    (TT:ReportError "TTPLANTRANDOM" message))
  (setq project (TT:ProjectCurrent) record (if project (TT:PlantSelectProjectRecord)))
  (if record
    (progn
      (setq first (getpoint "\nFirst corner of placement rectangle: ")
            second (if first (getcorner first "\nOpposite corner: "))
            count (if second (getint "\nNumber of plants: "))
            min-scale (if count (getreal "\nMinimum symbol scale <1.0>: ")))
      (if (and count (null min-scale)) (setq min-scale 1.0))
      (setq max-scale (if min-scale (getreal "\nMaximum symbol scale <minimum>: ")))
      (if (and min-scale (null max-scale)) (setq max-scale min-scale))
      (setq rotation-range (if max-scale (getreal "\nRandom rotation range in degrees <360>: ")))
      (if (and max-scale (null rotation-range)) (setq rotation-range 360.0))
      (if (and count (> count 0) min-scale (> min-scale 0.0)
               max-scale (>= max-scale min-scale)
               rotation-range (>= rotation-range 0.0))
        (progn
          (command-s "_.UNDO" "_Begin")
          (setq undo-open T)
          (setq index 0 made 0)
          (repeat count
            (setq x (+ (min (car first) (car second))
                       (* (abs (- (car second) (car first))) (TT:RandomUnit)))
                  y (+ (min (cadr first) (cadr second))
                       (* (abs (- (cadr second) (cadr first))) (TT:RandomUnit)))
                  point (list x y 0.0)
                  scale (+ min-scale (* (- max-scale min-scale) (TT:RandomUnit)))
                  rotation (* (/ pi 180.0) rotation-range (TT:RandomUnit))
                  entity (TT:PlantCreateInstance project record point nil))
            (if entity
              (progn (TT:PlantApplyTransform entity scale rotation) (setq made (1+ made))))
            (setq index (1+ index)))
          (command-s "_.UNDO" "_End")
          (setq undo-open nil)
          (princ (strcat "\nPlaced " (itoa made) " randomly distributed plants.")))
        (if count (princ "\nCount and transform ranges must be valid positive values.")))))
  (princ))

T
