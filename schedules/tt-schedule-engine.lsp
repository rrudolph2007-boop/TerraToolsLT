;;; TerraTools LT - Derived text schedules, CSV export, and planting costs.

(setq *TT:ScheduleModuleLoaded* T)

(defun TT:PlantAreaItems ()
  (append
    (TT:SmartFilter (TT:SmartScan) "PLANTING" "PLANT_AREA_SQUARE")
    (TT:SmartFilter (TT:SmartScan) "PLANTING" "PLANT_AREA_TRIANGULAR"))
)

(defun TT:PlantDerivedQuantityFromItems
  (project-id plant-record work-area-id items project
   / quantity item metadata object-type area-quantity mix component spacing area)
  (setq quantity 0 spacing (TT:PlantSpacingNumber plant-record))
  (foreach item items
    (setq metadata (cdr item) object-type (cdr (assoc 'OBJECT_TYPE metadata)))
    (if (or (null work-area-id)
            (equal work-area-id (cdr (assoc 'WORK_AREA_ID metadata))))
      (cond
        ((and (equal object-type "PLANT_INSTANCE")
              (equal project-id (cdr (assoc 'CATALOG_ID metadata))))
          (setq quantity (1+ quantity)))
        ((and (member object-type '("PLANT_AREA_SQUARE" "PLANT_AREA_TRIANGULAR" "PLANT_AREA_DENSITY"))
              (equal project-id (cdr (assoc 'CATALOG_ID metadata))))
          (setq area-quantity (TT:PlantAreaQuantity (car item) metadata))
          (if area-quantity (setq quantity (+ quantity area-quantity))))
        ((equal object-type "PLANT_MIX_AREA")
          (setq mix (TT:DataFindByValue (TT:PlantMixes project) 'MIX_ID
                                        (cdr (assoc 'CATALOG_ID metadata)))
                area (TT:EntityArea (car item)))
          (foreach component (if mix (TT:DataValue mix 'COMPONENTS))
            (if (and (equal project-id (TT:DataValue component 'PROJECT_PLANT_ID))
                     area spacing (> spacing 0.0))
              (setq quantity (+ quantity
                (fix (+ 0.999999
                  (* (/ area (* spacing spacing))
                     (/ (TT:DataValue component 'PERCENT) 100.0))))))))))))
  quantity)

(defun TT:PlantDerivedQuantity (project-id work-area-id / project palette plant items)
  (setq project (TT:ProjectCurrent) palette (if project (TT:PlantPaletteLoadFromProject project))
        plant (if palette (TT:DataFindByValue (TT:PlantPaletteGetAllFromPalette palette)
                                               'PROJECT_PLANT_ID project-id))
        items (TT:SmartFilter (TT:ProjectItems (TT:SmartScan) project) "PLANTING" nil))
  (if plant (TT:PlantDerivedQuantityFromItems project-id plant work-area-id items project) 0))

(defun TT:PlantScheduleRows (work-area-id / project palette rows record quantity items)
  (setq project (TT:ProjectCurrent)
        palette (if project (TT:PlantPaletteLoadFromProject project))
        items (TT:SmartFilter (TT:SmartScan) "PLANTING" nil))
  (if palette
    (foreach record (TT:PlantPaletteGetAllFromPalette palette)
      (setq quantity (TT:PlantDerivedQuantityFromItems
                       (TT:PlantRecordValue record 'PROJECT_PLANT_ID)
                       record work-area-id items project))
      (if (> quantity 0)
        (setq rows
          (cons
            (list 'SCHEDULE_ROW
              (cons 'CODE (TT:PlantRecordValue record 'PLANT_CODE))
              (cons 'CATEGORY (TT:PlantRecordValue record 'CATEGORY))
              (cons 'BOTANICAL_NAME (TT:PlantRecordValue record 'BOTANICAL_NAME))
              (cons 'COMMON_NAME (TT:PlantRecordValue record 'COMMON_NAME))
              (cons 'SIZE (TT:PlantRecordValue record 'SIZE))
              (cons 'SPACING (TT:PlantRecordValue record 'SPACING))
              (cons 'UNIT_COST (TT:PlantRecordValue record 'UNIT_COST))
              (cons 'QUANTITY quantity)) rows)))))
  (reverse rows)
)

(defun TT:PlantScheduleText (rows) (TT:StyledScheduleText rows (TT:ScheduleStyle)))

(defun TT:CreateMText (point height width text layer)
  (entmakex
    (list '(0 . "MTEXT") (cons 8 layer) (cons 10 point) (cons 40 height)
          (cons 41 width) (cons 1 text) '(71 . 1) '(7 . "STANDARD")))
)

(defun C:TTPLANTSCHEDULE (/ *error* project rows point height entity id scope work-area work-area-id)
  (defun *error* (message) (TT:ReportError "TTPLANTSCHEDULE" message))
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (initget "All WorkArea")
      (setq scope (getkword "\nPlant schedule scope [All/WorkArea] <All>: "))
      (if (equal scope "WorkArea")
        (progn (setq work-area (TT:SelectWorkAreaRecord project))
               (if work-area (setq work-area-id (TT:DataValue work-area 'WORK_AREA_ID)))))))
  (setq rows (if (and project (or (not (equal scope "WorkArea")) work-area)) (TT:PlantScheduleRows work-area-id)))
  (if (and project rows (setq point (getpoint "\nPlant schedule insertion point: ")))
    (progn
      (setq height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT))
      (if (not (numberp height)) (setq height 0.1))
      (setq entity (TT:CreateMText point height (* height (TT:DataValue (TT:ScheduleStyle) 'WIDTH))
                     (TT:PlantScheduleText rows) (TT:GetLayerForRole 'PLANT_SCHEDULE))
            id (TT:GenerateUUID))
      (if (and entity (TT:SmartAttach entity project "SCHEDULES" "PLANT_SCHEDULE" id work-area-id))
        (princ "\nPlant schedule created."))))
  (princ)
)

(defun C:TTUPDATEPLANTSCHEDULE (/ *error* item data rows project)
  (defun *error* (message) (TT:ReportError "TTUPDATEPLANTSCHEDULE" message))
  (setq project (TT:ProjectCurrent) item (if project (TT:SelectSmartEntity "\nSelect TerraTools plant schedule: ")))
  (if (and item (equal (cdr (assoc 'PROJECT_UUID (cdr item))) (TT:ProjectValue project 'PROJECT_UUID))
           (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "PLANT_SCHEDULE"))
    (progn
      (setq rows (TT:PlantScheduleRows (cdr (assoc 'WORK_AREA_ID (cdr item))))
            data (entget (car item)))
      (if (and (assoc 1 data)
               (entmod (subst (cons 1 (TT:PlantScheduleText rows)) (assoc 1 data) data)))
        (princ "\nPlant schedule updated.")))
    (princ "\nThe selected entity is not a TerraTools plant schedule."))
  (princ)
)

(defun C:TTEXPORTPLANTCSV (/ *error* rows path stream row)
  (defun *error* (message) (if stream (close stream)) (TT:ReportError "TTEXPORTPLANTCSV" message))
  (setq rows (TT:PlantScheduleRows nil)
        path (getfiled "Export TerraTools Plant Schedule" "plant-schedule.csv" "csv" 1))
  (if path
    (progn
      (setq stream (open path "w"))
      (if stream
        (progn
          (write-line "Code,Category,Botanical Name,Common Name,Size,Spacing,Quantity,Unit Cost,Subtotal" stream)
          (foreach row rows
            (write-line
              (strcat (TT:CSVQuote (TT:DataValue row 'CODE)) ","
                      (TT:CSVQuote (TT:PlantCategoryName (TT:DataValue row 'CATEGORY))) ","
                      (TT:CSVQuote (TT:DataValue row 'BOTANICAL_NAME)) ","
                      (TT:CSVQuote (TT:DataValue row 'COMMON_NAME)) ","
                      (TT:CSVQuote (TT:DataValue row 'SIZE)) ","
                      (TT:CSVQuote (TT:DataValue row 'SPACING)) ","
                      (TT:CSVQuote (TT:DataValue row 'QUANTITY)) ","
                      (TT:CSVQuote (TT:DataValue row 'UNIT_COST)) ","
                      (TT:CSVQuote (* (TT:DataValue row 'QUANTITY)
                                      (TT:SafeNumber (TT:DataValue row 'UNIT_COST) 0.0)))) stream))
          (close stream) (setq stream nil)
          (princ (strcat "\nPlant schedule exported: " path)))
        (princ "\nCould not open the CSV file for writing."))))
  (princ)
)

(defun C:TTPLANTCOST (/ *error* project scope work-area work-area-id rows total row subtotal category old category-totals)
  (defun *error* (message) (TT:ReportError "TTPLANTCOST" message))
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (initget "All WorkArea")
      (setq scope (getkword "\nPlant cost scope [All/WorkArea] <All>: "))
      (if (equal scope "WorkArea")
        (progn (setq work-area (TT:SelectWorkAreaRecord project))
               (if work-area (setq work-area-id (TT:DataValue work-area 'WORK_AREA_ID)))))))
  (setq rows (TT:PlantScheduleRows work-area-id) total 0.0)
  (princ "\nPlanting cost summary")
  (foreach row rows
    (setq subtotal (* (TT:DataValue row 'QUANTITY)
                      (TT:SafeNumber (TT:DataValue row 'UNIT_COST) 0.0))
          total (+ total subtotal)
          category (TT:PlantCategoryName (TT:DataValue row 'CATEGORY))
          old (assoc category category-totals))
    (if old
      (setq category-totals (subst (cons category (+ (cdr old) subtotal)) old category-totals))
      (setq category-totals (cons (cons category subtotal) category-totals)))
    (princ (strcat "\n  " (TT:DataValue row 'CODE) ": " (rtos subtotal 2 2))))
  (foreach old (reverse category-totals)
    (princ (strcat "\n  " (car old) " subtotal: " (rtos (cdr old) 2 2))))
  (princ (strcat "\nTotal: " (rtos total 2 2)))
  (princ)
)

(defun TT:CSVFirstField (line / index result character next done)
  (if (and line (> (strlen line) 0) (equal (substr line 1 1) "\""))
    (progn
      (setq index 2 result "")
      (while (and (<= index (strlen line)) (not done))
        (setq character (substr line index 1))
        (cond
          ((equal character "\"")
            (setq next (if (< index (strlen line)) (substr line (1+ index) 1) ""))
            (if (equal next "\"")
              (progn (setq result (strcat result "\"") index (1+ index)))
              (setq done T)))
          (T (setq result (strcat result character))))
        (setq index (1+ index)))
      result)
    (if line
      (substr line 1 (if (vl-string-search "," line) (vl-string-search "," line) (strlen line)))
      nil)))

(defun TT:PlantMasterFindByCode (code / record found)
  (foreach record (TT:PlantMasterGetAll)
    (if (equal (strcase code) (strcase (TT:PlantRecordValue record 'PLANT_CODE)))
      (setq found record)))
  found)

(defun C:TTIMPORTPLANTCSV (/ path rows headers row code master palette plants added skipped new-record)
  (setq path (getfiled "Import TerraTools Plant Codes" "" "csv" 0))
  (if path
    (progn
      (setq rows (TT:CSVReadFile path) palette (TT:PlantPaletteLoad) added 0 skipped 0)
      (if (and rows palette)
        (progn
          (setq headers (TT:CSVHeaderMap (car rows))
                plants (TT:PlantPaletteGetAllFromPalette palette))
          (foreach row (cdr rows)
            (setq code (TT:CSVField row headers "Code"))
            (if (null code) (setq code (car row)))
            (setq master (if code (TT:PlantMasterFindByCode code)))
            (if (and master
                     (not (TT:PlantPaletteFindByMasterID plants
                            (TT:PlantRecordValue master 'PLANT_ID))))
              (progn
                (setq new-record (TT:PlantProjectRecordFromMaster master)
                      plants (append plants (list new-record)) added (1+ added)))
               (setq skipped (1+ skipped))))
          (setq palette (TT:PlantPaletteWithPlants palette plants))
          (if (TT:PlantPaletteSave palette)
            (princ (strcat "\nImported " (itoa added) " plant(s); skipped "
                           (itoa skipped) " duplicate or unknown code(s)."))))
        (princ "\nThe CSV or active Project Plant Palette could not be read."))))
  (princ))

T
