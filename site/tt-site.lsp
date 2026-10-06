;;; TerraTools LT - Reference notes, measurements, and basic site graphics.

(setq *TT:SiteModuleLoaded* T)

(defun TT:SiteTypeName (value)
  (cond ((eq value 'NOTATION) "NOTATION") ((eq value 'COUNT) "COUNT")
        ((eq value 'LENGTH) "LENGTH") ((eq value 'AREA) "AREA")
        ((eq value 'VOLUME) "VOLUME") ((eq value 'AMENITY) "AMENITY")
        ((eq value 'MATERIAL) "MATERIAL") ((eq value 'HARDSCAPE) "HARDSCAPE")
        (T "UNKNOWN")))

(defun TT:ReferenceNotes (project) (TT:ProjectValue project 'REFERENCE_NOTES))
(defun TT:ReferenceNoteLabel (record)
  (strcat (TT:DataValue record 'CODE) " | " (TT:DataValue record 'DESCRIPTION)))

(defun TT:ReferenceNoteQuantityForArea (record work-area-id / id type item metadata entity value)
  (setq id (TT:DataValue record 'NOTE_ID) type (TT:DataValue record 'TYPE) value 0.0)
  (foreach item (TT:SmartFilter (TT:SmartScan) "SITE" nil)
    (setq metadata (cdr item) entity (car item))
    (if (and (equal id (cdr (assoc 'CATALOG_ID metadata)))
             (or (null work-area-id)
                 (equal work-area-id (cdr (assoc 'WORK_AREA_ID metadata)))))
      (cond ((eq type 'COUNT) (setq value (1+ value)))
            ((eq type 'LENGTH) (setq value (+ value (TT:SafeNumber (TT:EntityLength entity) 0.0))))
            ((eq type 'AREA) (setq value (+ value (TT:SafeNumber (TT:EntityArea entity) 0.0))))
            ((eq type 'VOLUME)
              (setq value (+ value (* (TT:SafeNumber (TT:EntityArea entity) 0.0)
                                      (TT:SafeNumber (TT:DataValue record 'DEPTH) 0.0)))))
            (T (setq value (1+ value))))))
  value
)

(defun TT:ReferenceNoteQuantity (record)
  (TT:ReferenceNoteQuantityForArea record nil))

(defun C:TTREFNOTE (/ *error* project type code description depth unit-cost record records selection entity)
  (defun *error* (message) (TT:ReportError "TTREFNOTE" message))
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (initget "Notation Count Length Area Volume Amenity Material Hardscape")
      (setq type (getkword "\nReference note type [Notation/Count/Length/Area/Volume/Amenity/Material/Hardscape] <Notation>: "))
      (if (null type) (setq type "Notation"))
      (setq code (getstring T "\nReference note code: ")
            description (getstring T "\nDescription: "))
      (if (equal type "Volume") (setq depth (getreal "\nDepth in drawing units: ")))
      (setq unit-cost (getreal "\nUnit cost <0>: "))
      (if (null unit-cost) (setq unit-cost 0.0))
      (setq selection (entsel "\nSelect geometry for this reference note: "))
      (if (and selection (not (equal code "")) (not (equal description "")))
        (progn
          (setq entity (car selection)
                record (list 'REFERENCE_NOTE (cons 'NOTE_ID (TT:GenerateUUID))
                         (cons 'TYPE (read (strcase type))) (cons 'CODE code)
                         (cons 'DESCRIPTION description)
                         (cons 'DEPTH (TT:SafeNumber depth 0.0))
                         (cons 'UNIT_COST (max 0.0 unit-cost)))
                records (append (TT:ReferenceNotes project) (list record)))
          (if (and (TT:SmartAttach entity project "SITE"
                     (strcat "REFNOTE_" (strcase type)) (TT:DataValue record 'NOTE_ID) nil)
                   (TT:ProjectSaveSection 'REFERENCE_NOTES records))
            (princ "\nReference note created."))))))
  (princ)
)

(defun C:TTREFNOTEEDIT (/ *error* project item record text value records updated)
  (defun *error* (message) (TT:ReportError "TTREFNOTEEDIT" message))
  (setq project (TT:ProjectCurrent) item (TT:SelectSmartEntity "\nSelect reference-note object: "))
  (if (and project item
           (setq record (TT:DataFindByValue (TT:ReferenceNotes project) 'NOTE_ID
                          (cdr (assoc 'CATALOG_ID (cdr item))))))
    (progn
      (setq updated record
            text (getstring T "\nNew code <keep>: "))
      (if (not (equal text "")) (setq updated (TT:DataPut updated 'CODE text)))
      (setq text (getstring T "\nNew description <keep>: "))
      (if (not (equal text "")) (setq updated (TT:DataPut updated 'DESCRIPTION text)))
      (setq value (getreal "\nNew unit cost <keep>: "))
      (if (and value (>= value 0.0)) (setq updated (TT:DataPut updated 'UNIT_COST value)))
      (if (not (equal updated record))
        (progn
          (setq records (subst updated record (TT:ReferenceNotes project)))
          (if (TT:ProjectSaveSection 'REFERENCE_NOTES records)
            (princ "\nReference note updated.")))))
    (princ "\nThe selected object has no valid reference-note record."))
  (princ)
)

(defun TT:ReferenceScheduleText (project work-area-id / text record quantity unit-cost subtotal)
  (setq text "REFERENCE NOTES\\PCODE | TYPE | QUANTITY | DESCRIPTION | UNIT COST | SUBTOTAL")
  (foreach record (TT:ReferenceNotes project)
    (setq quantity (TT:ReferenceNoteQuantityForArea record work-area-id)
          unit-cost (TT:SafeNumber (TT:DataValue record 'UNIT_COST) 0.0)
          subtotal (* quantity unit-cost)
          text (strcat text "\\P" (TT:DataValue record 'CODE) " | "
                       (TT:SiteTypeName (TT:DataValue record 'TYPE)) " | "
                       (rtos quantity 2 2) " | " (TT:DataValue record 'DESCRIPTION) " | "
                       (rtos unit-cost 2 2) " | " (rtos subtotal 2 2))))
  text
)

(defun C:TTREFNOTESCHEDULE (/ *error* project point height entity id scope work-area work-area-id)
  (defun *error* (message) (TT:ReportError "TTREFNOTESCHEDULE" message))
  (setq project (TT:ProjectCurrent))
  (if (and project (TT:WorkAreas project))
    (progn
      (initget "All WorkArea")
      (setq scope (getkword "\nReference schedule scope [All/WorkArea] <All>: "))
      (if (equal scope "WorkArea")
        (setq work-area (TT:SelectWorkAreaRecord project)
              work-area-id (if work-area (TT:DataValue work-area 'WORK_AREA_ID))))))
  (setq point (if (and project
                       (or (not (equal scope "WorkArea")) work-area))
                (getpoint "\nSchedule insertion point: ")))
  (if point
    (progn
      (setq height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT))
      (if (not (numberp height)) (setq height 0.1))
      (setq entity (TT:CreateMText point height (* height 70.0)
                     (TT:ReferenceScheduleText project work-area-id) "0") id (TT:GenerateUUID))
      (TT:SmartAttach entity project "SCHEDULES" "REFNOTE_SCHEDULE" id work-area-id)
      (princ "\nReference-note schedule created.")))
  (princ)
)

(defun C:TTUPDATEREFNOTES (/ *error* project item data)
  (defun *error* (message) (TT:ReportError "TTUPDATEREFNOTES" message))
  (setq project (TT:ProjectCurrent) item (TT:SelectSmartEntity "\nSelect reference-note schedule: "))
  (if (and project item (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "REFNOTE_SCHEDULE"))
    (progn
      (setq data (entget (car item)))
      (entmod (subst (cons 1 (TT:ReferenceScheduleText project
                            (cdr (assoc 'WORK_AREA_ID (cdr item))))) (assoc 1 data) data))
      (princ "\nReference-note schedule updated.")))
  (princ)
)

(defun C:TTAREA (/ *error* selection value)
  (defun *error* (message) (TT:ReportError "TTAREA" message))
  (setq selection (entsel "\nSelect closed LWPOLYLINE: "))
  (if (and selection (setq value (TT:EntityArea (car selection))))
    (TT:PrintValue "Area" value) (princ "\nA closed LWPOLYLINE is required."))
  (princ)
)

(defun C:TTLENGTH (/ *error* selection value)
  (defun *error* (message) (TT:ReportError "TTLENGTH" message))
  (setq selection (entsel "\nSelect LINE or LWPOLYLINE: "))
  (if (and selection (setq value (TT:EntityLength (car selection))))
    (TT:PrintValue "Length" value) (princ "\nUnsupported geometry."))
  (princ)
)

(defun C:TTVOLUME (/ *error* selection area depth)
  (defun *error* (message) (TT:ReportError "TTVOLUME" message))
  (setq selection (entsel "\nSelect closed LWPOLYLINE: ")
        area (if selection (TT:EntityArea (car selection)))
        depth (if area (getreal "\nDepth: ")))
  (if (and area depth) (TT:PrintValue "Volume" (* area depth)))
  (princ)
)

(defun C:TTSLOPE (/ *error* p1 p2 z1 z2 run rise)
  (defun *error* (message) (TT:ReportError "TTSLOPE" message))
  (setq p1 (getpoint "\nFirst point: ") p2 (if p1 (getpoint p1 "\nSecond point: "))
        z1 (if p2 (getreal "\nFirst elevation: ")) z2 (if z1 (getreal "\nSecond elevation: ")))
  (if (and p1 p2 z1 z2 (> (setq run (distance p1 p2)) 0.0))
    (progn (setq rise (- z2 z1))
      (TT:PrintValue "Slope percent" (* 100.0 (/ rise run)))
      (TT:PrintValue "Slope ratio (horizontal:vertical)"
        (if (equal rise 0.0 1e-12) "Level"
          (strcat "1:" (rtos (/ run (abs rise)) 2 2))))
      (TT:PrintValue "Rise" rise) (TT:PrintValue "Run" run)))
  (princ)
)

(defun C:TTCOORDLABEL (/ *error* point height text)
  (defun *error* (message) (TT:ReportError "TTCOORDLABEL" message))
  (setq point (getpoint "\nCoordinate point: ") height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT))
  (if point
    (progn
      (if (not (numberp height)) (setq height 0.1))
      (setq text (strcat "N " (rtos (cadr point) 2 2) "  E " (rtos (car point) 2 2)))
      (TT:CreateText point height text "0")))
  (princ)
)

(defun C:TTSPOTELEVATION (/ *error* point elevation height)
  (defun *error* (message) (TT:ReportError "TTSPOTELEVATION" message))
  (setq point (getpoint "\nSpot location: ") elevation (if point (getreal "\nElevation: "))
        height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT))
  (if elevation (TT:CreateText point (if (numberp height) height 0.1)
                  (strcat "EL " (rtos elevation 2 2)) "0"))
  (princ)
)

(defun C:TTCONCEPT (/ *error* project selection entity name)
  (defun *error* (message) (TT:ReportError "TTCONCEPT" message))
  (setq project (TT:ProjectCurrent) selection (if project (entsel "\nSelect closed concept polygon: ")))
  (if (and selection (TT:PolylineClosedP (setq entity (car selection))))
    (progn
      (setq name (getstring T "\nConcept zone name: "))
      (TT:SmartAttach entity project "SITE" "CONCEPT_ZONE" name nil)
      (princ "\nConcept zone created.")))
  (princ)
)

(defun TT:SiteUnitSymbol (unit)
  (TT:UnitName unit))

(defun TT:MetersToLength (value unit)
  (TT:ConvertLength value 'METERS (TT:SiteUnitSymbol unit)))

(defun TT:LengthToMeters (value unit)
  (TT:ConvertLength value (TT:SiteUnitSymbol unit) 'METERS))

(defun C:TTUNITCONVERT (/ value from to result)
  (setq value (getreal "\nLength value: "))
  (if value
    (progn
      (initget "Feet Inches Meters Centimeters Millimeters")
      (setq from (getkword "\nFrom [Feet/Inches/Meters/Centimeters/Millimeters]: "))
      (initget "Feet Inches Meters Centimeters Millimeters")
      (setq to (if from (getkword "\nTo [Feet/Inches/Meters/Centimeters/Millimeters]: ")))
      (if to
        (progn
          (setq result (TT:MetersToLength (TT:LengthToMeters value from) to))
          (princ (strcat "\n" (rtos value 2 4) " " from " = "
                         (rtos result 2 4) " " to))))))
  (princ))

(defun C:TTBEARINGDIST (/ p1 p2 distance azimuth degrees)
  (setq p1 (getpoint "\nBearing start point: ")
        p2 (if p1 (getpoint p1 "\nBearing end point: ")))
  (if p2
    (progn
      (setq distance (distance p1 p2)
            azimuth (- (/ pi 2.0) (angle p1 p2)))
      (while (< azimuth 0.0) (setq azimuth (+ azimuth (* 2.0 pi))))
      (while (>= azimuth (* 2.0 pi)) (setq azimuth (- azimuth (* 2.0 pi))))
      (setq degrees (* 180.0 (/ azimuth pi)))
      (TT:PrintValue "Distance" distance)
      (princ (strcat "\nAzimuth clockwise from north: " (rtos degrees 2 4) " degrees"))))
  (princ))

T
