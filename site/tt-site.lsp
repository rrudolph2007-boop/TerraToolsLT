;;; TerraTools LT - Reference notes, measurements, and basic site graphics.

(setq *TT:SiteModuleLoaded* T)

(defun TT:SiteTypeName (value)
  (cond ((eq value 'NOTATION) "NOTATION") ((eq value 'COUNT) "COUNT")
        ((eq value 'LENGTH) "LENGTH") ((eq value 'AREA) "AREA")
        ((eq value 'VOLUME) "VOLUME") ((eq value 'AMENITY) "AMENITY")
        (T "UNKNOWN")))

(defun TT:ReferenceNotes (project) (TT:ProjectValue project 'REFERENCE_NOTES))
(defun TT:ReferenceNoteLabel (record)
  (strcat (TT:DataValue record 'CODE) " | " (TT:DataValue record 'DESCRIPTION)))

(defun TT:ReferenceNoteQuantity (record / id type item metadata entity value)
  (setq id (TT:DataValue record 'NOTE_ID) type (TT:DataValue record 'TYPE) value 0.0)
  (foreach item (TT:SmartFilter (TT:SmartScan) "SITE" nil)
    (setq metadata (cdr item) entity (car item))
    (if (equal id (cdr (assoc 'CATALOG_ID metadata)))
      (cond ((eq type 'COUNT) (setq value (1+ value)))
            ((eq type 'LENGTH) (setq value (+ value (TT:SafeNumber (TT:EntityLength entity) 0.0))))
            ((eq type 'AREA) (setq value (+ value (TT:SafeNumber (TT:EntityArea entity) 0.0))))
            ((eq type 'VOLUME)
              (setq value (+ value (* (TT:SafeNumber (TT:EntityArea entity) 0.0)
                                      (TT:SafeNumber (TT:DataValue record 'DEPTH) 0.0)))))
            (T (setq value (1+ value))))))
  value
)

(defun C:TTREFNOTE (/ *error* project type code description depth record records selection entity)
  (defun *error* (message) (TT:ReportError "TTREFNOTE" message))
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (initget "Notation Count Length Area Volume Amenity")
      (setq type (getkword "\nReference note type [Notation/Count/Length/Area/Volume/Amenity] <Notation>: "))
      (if (null type) (setq type "Notation"))
      (setq code (getstring T "\nReference note code: ")
            description (getstring T "\nDescription: "))
      (if (equal type "Volume") (setq depth (getreal "\nDepth in drawing units: ")))
      (setq selection (entsel "\nSelect geometry for this reference note: "))
      (if (and selection (not (equal code "")) (not (equal description "")))
        (progn
          (setq entity (car selection)
                record (list 'REFERENCE_NOTE (cons 'NOTE_ID (TT:GenerateUUID))
                         (cons 'TYPE (read (strcase type))) (cons 'CODE code)
                         (cons 'DESCRIPTION description)
                         (cons 'DEPTH (TT:SafeNumber depth 0.0)))
                records (append (TT:ReferenceNotes project) (list record)))
          (if (and (TT:SmartAttach entity project "SITE"
                     (strcat "REFNOTE_" (strcase type)) (TT:DataValue record 'NOTE_ID) nil)
                   (TT:ProjectSaveSection 'REFERENCE_NOTES records))
            (princ "\nReference note created."))))))
  (princ)
)

(defun C:TTREFNOTEEDIT (/ *error* project item record text records updated)
  (defun *error* (message) (TT:ReportError "TTREFNOTEEDIT" message))
  (setq project (TT:ProjectCurrent) item (TT:SelectSmartEntity "\nSelect reference-note object: "))
  (if (and project item
           (setq record (TT:DataFindByValue (TT:ReferenceNotes project) 'NOTE_ID
                          (cdr (assoc 'CATALOG_ID (cdr item))))))
    (progn
      (setq text (getstring T "\nNew description <keep>: "))
      (if (not (equal text ""))
        (progn
          (setq updated (TT:DataPut record 'DESCRIPTION text)
                records (subst updated record (TT:ReferenceNotes project)))
          (if (TT:ProjectSaveSection 'REFERENCE_NOTES records)
            (princ "\nReference note updated.")))))
    (princ "\nThe selected object has no valid reference-note record."))
  (princ)
)

(defun TT:ReferenceScheduleText (project / text record quantity)
  (setq text "REFERENCE NOTES\\PCODE | TYPE | QUANTITY | DESCRIPTION")
  (foreach record (TT:ReferenceNotes project)
    (setq quantity (TT:ReferenceNoteQuantity record)
          text (strcat text "\\P" (TT:DataValue record 'CODE) " | "
                       (TT:SiteTypeName (TT:DataValue record 'TYPE)) " | "
                       (rtos quantity 2 2) " | " (TT:DataValue record 'DESCRIPTION))))
  text
)

(defun C:TTREFNOTESCHEDULE (/ *error* project point height entity id)
  (defun *error* (message) (TT:ReportError "TTREFNOTESCHEDULE" message))
  (setq project (TT:ProjectCurrent) point (if project (getpoint "\nSchedule insertion point: ")))
  (if point
    (progn
      (setq height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT))
      (if (not (numberp height)) (setq height 0.1))
      (setq entity (TT:CreateMText point height (* height 70.0)
                     (TT:ReferenceScheduleText project) "0") id (TT:GenerateUUID))
      (TT:SmartAttach entity project "SCHEDULES" "REFNOTE_SCHEDULE" id nil)
      (princ "\nReference-note schedule created.")))
  (princ)
)

(defun C:TTUPDATEREFNOTES (/ *error* project item data)
  (defun *error* (message) (TT:ReportError "TTUPDATEREFNOTES" message))
  (setq project (TT:ProjectCurrent) item (TT:SelectSmartEntity "\nSelect reference-note schedule: "))
  (if (and project item (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "REFNOTE_SCHEDULE"))
    (progn
      (setq data (entget (car item)))
      (entmod (subst (cons 1 (TT:ReferenceScheduleText project)) (assoc 1 data) data))
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

(defun TT:LengthToMeters (value unit)
  (* value (cond ((equal unit "Feet") 0.3048) ((equal unit "Inches") 0.0254)
                 ((equal unit "Millimeters") 0.001) (T 1.0))))

(defun TT:MetersToLength (value unit)
  (/ value (cond ((equal unit "Feet") 0.3048) ((equal unit "Inches") 0.0254)
                 ((equal unit "Millimeters") 0.001) (T 1.0))))

(defun C:TTUNITCONVERT (/ value from to result)
  (setq value (getreal "\nLength value: "))
  (if value
    (progn
      (initget "Feet Inches Meters Millimeters")
      (setq from (getkword "\nFrom [Feet/Inches/Meters/Millimeters]: "))
      (initget "Feet Inches Meters Millimeters")
      (setq to (if from (getkword "\nTo [Feet/Inches/Meters/Millimeters]: ")))
      (if to
        (progn
          (setq result (TT:MetersToLength (TT:LengthToMeters value from) to))
          (princ (strcat "\n" (rtos value 2 4) " " from " = "
                         (rtos result 2 4) " " to))))))
  (princ))

T
