;;; Reusable project-owned label and schedule styles. Text is never evaluated.
(defun TT:StyleFields (text allowed / tokens token field fields valid candidate)
  (setq tokens (TT:StringWords (vl-string-translate "," " " (strcase text))) valid T)
  (foreach token tokens
    (setq field nil)
    (foreach candidate allowed (if (= token (vl-symbol-name candidate)) (setq field candidate)))
    (if (or (null field) (member field fields)) (setq valid nil) (setq fields (append fields (list field)))))
  (if valid fields))

(defun TT:DefaultScheduleStyle ()
  '(SCHEDULE_STYLE (NAME . "Plant schedule")
    (COLUMNS . "CODE QUANTITY BOTANICAL_NAME COMMON_NAME SIZE SPACING")
    (SORT . "CODE") (GROUP . "None") (WIDTH . 80.0)))

(defun TT:ScheduleStyle (/ value)
  (setq value (TT:GetPreference 'PLANT_SCHEDULE_STYLE))
  (if (and value (TT:StyleFields (TT:DataValue value 'COLUMNS)
      '(CODE QUANTITY CATEGORY BOTANICAL_NAME COMMON_NAME SIZE SPACING UNIT_COST SUBTOTAL)))
    value (TT:DefaultScheduleStyle)))

(defun C:TTSCHEDULESTYLE (/ value fields)
  (princ "\nColumns: CODE QUANTITY CATEGORY BOTANICAL_NAME COMMON_NAME SIZE SPACING UNIT_COST SUBTOTAL")
  (setq value (TT:UIEditRecord (TT:ScheduleStyle)
    '((NAME "Style name" REQUIRED) (COLUMNS "Columns in display order" REQUIRED)
      (SORT "Sort column" REQUIRED) (GROUP "Group: None or Category" REQUIRED) (WIDTH "Width in text heights" POSITIVE))
    "TerraTools LT | Plant Schedule Style"))
  (if value
    (if (and (TT:StyleFields (TT:DataValue value 'COLUMNS) '(CODE QUANTITY CATEGORY BOTANICAL_NAME COMMON_NAME SIZE SPACING UNIT_COST SUBTOTAL))
      (= (length (TT:StyleFields (TT:DataValue value 'SORT) '(CODE QUANTITY CATEGORY BOTANICAL_NAME COMMON_NAME SIZE SPACING UNIT_COST SUBTOTAL))) 1)
      (member (strcase (TT:DataValue value 'GROUP)) '("NONE" "CATEGORY")))
      (TT:SetPreference 'PLANT_SCHEDULE_STYLE value)
      (princ "\nStyle was not saved. Use the listed column names and None or Category grouping.")))
  (princ))

(defun TT:ScheduleValue (row key)
  (if (eq key 'SUBTOTAL) (* (TT:SafeNumber (TT:DataValue row 'QUANTITY) 0.0) (TT:SafeNumber (TT:DataValue row 'UNIT_COST) 0.0))
    (TT:DataValue row key)))

(defun TT:ScheduleRowsSorted (rows style / schedule-sort group-sort)
  (setq schedule-sort (car (TT:StyleFields (TT:DataValue style 'SORT) '(CODE QUANTITY CATEGORY BOTANICAL_NAME COMMON_NAME SIZE SPACING UNIT_COST SUBTOTAL)))
        group-sort (= (strcase (TT:DataValue style 'GROUP)) "CATEGORY"))
  ;; vl-sort can drop equal items; sort indices instead so no records disappear.
  (mapcar '(lambda (index) (nth index rows))
    (vl-sort-i rows '(lambda (a b / av bv ag bg)
      (setq av (TT:ScheduleValue a schedule-sort) bv (TT:ScheduleValue b schedule-sort)
            ag (TT:UIValue (TT:DataValue a 'CATEGORY)) bg (TT:UIValue (TT:DataValue b 'CATEGORY)))
      (if (and group-sort (/= ag bg)) (< ag bg)
        (if (and (numberp av) (numberp bv)) (< av bv) (< (strcase (TT:UIValue av)) (strcase (TT:UIValue bv)))))))))

(defun TT:StyledScheduleText (rows style / fields text row field group last-group)
  (setq fields (TT:StyleFields (TT:DataValue style 'COLUMNS) '(CODE QUANTITY CATEGORY BOTANICAL_NAME COMMON_NAME SIZE SPACING UNIT_COST SUBTOTAL))
        text (TT:DataValue style 'NAME))
  (foreach field fields (setq text (strcat text (if (eq field (car fields)) "\\P" " | ") (vl-symbol-name field))))
  (foreach row (TT:ScheduleRowsSorted rows style)
    (setq group (TT:UIValue (TT:DataValue row 'CATEGORY)))
    (if (and (= (strcase (TT:DataValue style 'GROUP)) "CATEGORY") (not (equal group last-group)))
      (setq text (strcat text "\\P[" group "]") last-group group))
    (foreach field fields (setq text (strcat text (if (eq field (car fields)) "\\P" " | ") (TT:UIValue (TT:ScheduleValue row field))))))
  text)

(defun TT:LabelStyle (/ value)
  (setq value (TT:GetPreference 'PLANT_LABEL_STYLE))
  (if value value '(LABEL_STYLE (NAME . "Plant label") (FIELDS . "QUANTITY CODE") (LEADER . "No"))))

(defun C:TTLABELSTYLE (/ value)
  (setq value (TT:UIEditRecord (TT:LabelStyle)
    '((NAME "Style name" REQUIRED) (FIELDS "Fields in display order" REQUIRED) (LEADER "Leader: Yes or No" REQUIRED))
    "TerraTools LT | Plant Label Style"))
  (if value
    (if (and (TT:StyleFields (TT:DataValue value 'FIELDS) '(QUANTITY CODE BOTANICAL_NAME COMMON_NAME SIZE SPACING))
             (member (strcase (TT:DataValue value 'LEADER)) '("YES" "NO")))
      (TT:SetPreference 'PLANT_LABEL_STYLE value)
      (princ "\nUse QUANTITY CODE BOTANICAL_NAME COMMON_NAME SIZE SPACING, and Yes or No for Leader.")))
  (princ))

(defun TT:PlantLabelFromItems (target-uuids items project / count item id record palette fields field text value)
  (setq count 0 palette (TT:PlantPaletteLoadFromProject project))
  (foreach item items
    (if (and (member (cdr (assoc 'ENTITY_UUID (cdr item))) target-uuids)
             (equal (cdr (assoc 'PROJECT_UUID (cdr item))) (TT:ProjectValue project 'PROJECT_UUID))
             (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "PLANT_INSTANCE"))
      (setq count (1+ count) id (cdr (assoc 'CATALOG_ID (cdr item))))))
  (setq record (TT:DataFindByValue (TT:PlantPaletteGetAllFromPalette palette) 'PROJECT_PLANT_ID id)
        fields (TT:StyleFields (TT:DataValue (TT:LabelStyle) 'FIELDS) '(QUANTITY CODE BOTANICAL_NAME COMMON_NAME SIZE SPACING)) text "")
  (if (null fields) (setq fields '(QUANTITY CODE)))
  (if (null record) "0 ORPHANED"
    (progn
      (foreach field fields
        (setq value (cond ((eq field 'QUANTITY) (itoa count))
          ((eq field 'CODE) (TT:DataValue record 'PLANT_CODE)) (T (TT:DataValue record field)))
          text (strcat text (if (= text "") "" " ") (TT:UIValue value)))) text)))
T
