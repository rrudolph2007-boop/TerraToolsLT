;;; Derived equipment schedules retain their scope for later regeneration.
(defun TT:EquipmentScheduleText (project module station work-area / items rows item metadata record key previous row text length-value)
  (setq items (TT:ProjectItems (TT:SmartScan) project) text (strcat module " SCHEDULE\\PCODE | DESCRIPTION | QTY | FLOW/LOAD | COST"))
  (foreach item (TT:SmartFilter items module nil)
    (setq metadata (cdr item))
    (if (and (or (null station) (equal station (cdr (assoc 'STATION metadata))))
             (or (null work-area) (equal work-area (cdr (assoc 'WORK_AREA_ID metadata)))))
      (progn
        (setq key (cdr (assoc 'CATALOG_ID metadata))
          record (if (= module "LIGHTING")
            (if (equal (cdr (assoc 'OBJECT_TYPE metadata)) "FIXTURE") (TT:LightingFind (TT:LightingPalette project) key))
            (TT:IrrigationFind (TT:IrrigationPalette project) key)))
        (if record
          (progn
            (setq previous (assoc key rows))
            (if previous (setq rows (subst (list key record (1+ (nth 2 previous))) previous rows))
              (setq rows (cons (list key record 1) rows)))))
        (if (and (= module "IRRIGATION") (TT:IrrigationPipeP metadata))
          (progn
            (setq length-value (TT:DrawingLengthToFeet (TT:EntityLength (car item))))
            (setq text (strcat text "\\PPIPE | " (cdr (assoc 'OBJECT_TYPE metadata)) " | "
              (if length-value (strcat (rtos length-value 2 2) " ft") "UNRESOLVED UNITS") " | nominal "
              (TT:UIValue (cdr (assoc 'DIAMETER_IN metadata))) " in | ID " (TT:UIValue (TT:PipeInsideDiameter metadata)) " in")))))))
  (foreach row (reverse rows)
    (setq record (cadr row) text (strcat text "\\P" (TT:DataValue record 'CODE) " | " (TT:DataValue record 'DESCRIPTION)
      " | " (itoa (nth 2 row)) " | " (rtos (* (nth 2 row) (TT:SafeNumber (TT:DataValue record (if (= module "LIGHTING") 'WATTAGE 'FLOW_GPM)) 0.0)) 2 2)
      (if (= module "LIGHTING") " W | " " gpm | ") (rtos (* (nth 2 row) (TT:SafeNumber (TT:DataValue record 'UNIT_COST) 0.0)) 2 2))))
  text)

(defun TT:CreateEquipmentSchedule (module / project scope station work-area record point entity height id)
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (initget "All WorkArea Station") (setq scope (getkword "\nScope [All/WorkArea/Station] <All>: "))
      (if (= scope "WorkArea") (setq work-area (TT:SelectWorkAreaRecord project)))
      (if (= scope "Station") (setq station (getstring T "\nStation name: ")))
      (if (and (or (/= scope "WorkArea") work-area) (or (/= scope "Station") (and station (/= station "")))
          (setq point (getpoint "\nSchedule insertion point: ")))
        (progn
          (setq height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT) id (TT:GenerateUUID)
            record (list 'EQUIPMENT_SCHEDULE (cons 'SCHEDULE_ID id) (cons 'MODULE module) (cons 'STATION station)
              (cons 'WORK_AREA_ID (TT:DataValue work-area 'WORK_AREA_ID)))
            entity (TT:CreateMText (trans point 1 0) height (* height 85.0)
              (TT:EquipmentScheduleText project module station (TT:DataValue work-area 'WORK_AREA_ID))
              (TT:EnsureLayer (if (= module "LIGHTING") 'LIGHT_SCHEDULE 'IRR_SCHEDULE))))
          (if (not (and entity (TT:SmartAttach entity project "SCHEDULES" "EQUIPMENT_SCHEDULE" id (TT:DataValue work-area 'WORK_AREA_ID))
            (TT:ProjectSaveSection 'EQUIPMENT_SCHEDULES (append (TT:ProjectValue project 'EQUIPMENT_SCHEDULES) (list record)))))
            (if entity (entdel entity)))))))
  (princ))

(defun C:TTLIGHTINGSCHEDULE () (TT:CreateEquipmentSchedule "LIGHTING"))
(defun C:TTIRRIGATIONSCHEDULE () (TT:CreateEquipmentSchedule "IRRIGATION"))
(defun C:TTUPDATEEQUIPMENTSCHEDULE (/ project item record data)
  (setq project (TT:ProjectCurrent) item (if project (TT:SelectSmartEntity "\nSelect equipment schedule: ")))
  (if (and item (equal (cdr (assoc 'PROJECT_UUID (cdr item))) (TT:ProjectValue project 'PROJECT_UUID))
    (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "EQUIPMENT_SCHEDULE")
    (setq record (TT:DataFindByValue (TT:ProjectValue project 'EQUIPMENT_SCHEDULES) 'SCHEDULE_ID (cdr (assoc 'CATALOG_ID (cdr item))))))
    (progn
      (setq data (entget (car item)))
      (entmod (subst (cons 1 (TT:EquipmentScheduleText project (TT:DataValue record 'MODULE)
        (TT:DataValue record 'STATION) (TT:DataValue record 'WORK_AREA_ID))) (assoc 1 data) data)))
    (princ "\nSelect a current-project equipment schedule created by this release."))
  (princ))
T
