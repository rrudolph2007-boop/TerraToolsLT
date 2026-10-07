;;; Pipe classes keep nominal and hydraulic inside diameters distinct, in inches.
(defun TT:PipeClassSizes (record / text words token split nominal inside sizes valid diameter)
  (setq text (TT:DataValue record 'SIZES_TEXT) valid T)
  (if (and (eq (type text) 'STR) (/= text ""))
    (progn
      (setq words (TT:StringWords (vl-string-translate "," " " text)))
      (foreach token words
        (setq split (vl-string-search ":" token))
        (if (and split (> split 0)
          (setq nominal (TT:StrictDecimal (substr token 1 split)))
          (setq inside (TT:StrictDecimal (substr token (+ split 2)))) (> nominal 0) (> inside 0))
          (setq sizes (cons (list nominal inside) sizes)) (setq valid nil))))
    (foreach diameter (TT:DataValue record 'DIAMETERS) (setq sizes (cons (list diameter diameter) sizes))))
  (if (and valid sizes) (vl-sort sizes '(lambda (a b) (< (cadr a) (cadr b))))))

(defun TT:PipeClasses (/ project master records record result)
  (setq project (TT:ProjectCurrent) master (TT:IrrigationMasterLoad))
  (setq records (append (TT:ProjectValue project 'PIPE_CLASSES) (TT:DataValue master 'PIPE_CLASSES)))
  (foreach record records
    (if (null (TT:DataValue record 'CLASS_ID))
      (setq record (TT:DataPut record 'CLASS_ID (TT:DataValue record 'PIPE_CLASS_ID))))
    (if (null (TT:DataValue record 'MATERIAL))
      (setq record (TT:DataPut record 'MATERIAL (TT:DataValue record 'DESCRIPTION))))
    (setq result (cons record result)))
  (reverse result))

(defun TT:PipeClassLabel (record)
  (strcat (TT:UIValue (TT:DataValue record 'CLASS_ID)) " | " (TT:UIValue (TT:DataValue record 'MATERIAL))
    (if (TT:DataValue record 'SIZES_TEXT) " | actual IDs supplied" " | legacy nominal diameter assumption")))

(defun TT:PipeChooseClass ()
  (TT:PromptNumberedRecord (TT:PipeClasses) 'TT:PipeClassLabel "Select pipe class"))

(defun C:TTPIPECLASSES (/ project record updated classes selected option)
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (initget "List Add Edit") (setq option (getkword "\nPipe classes [List/Add/Edit] <List>: "))
      (cond
        ((= option "Add")
          (setq record '(PIPE_CLASS (CLASS_ID . "") (MATERIAL . "") (C_FACTOR . 150.0) (SIZES_TEXT . ""))))
        ((= option "Edit")
          (setq record (TT:PipeChooseClass)))
        (T (foreach record (TT:PipeClasses) (princ (strcat "\n" (TT:PipeClassLabel record)))) (setq record nil)))
      (if record
        (progn
          (setq updated (TT:UIEditRecord record
            '((CLASS_ID "Class name" REQUIRED) (MATERIAL "Material/class description" REQUIRED)
              (C_FACTOR "Hazen-Williams C" POSITIVE) (SIZES_TEXT "Nominal:inside pairs, inches" REQUIRED)) "TerraTools LT | Pipe Class"))
          (if updated
            (if (TT:PipeClassSizes updated)
              (progn
                (setq classes (TT:ProjectValue project 'PIPE_CLASSES)
                  selected (TT:DataFindByValue classes 'CLASS_ID (TT:DataValue updated 'CLASS_ID)))
                (if (and selected (not (equal selected record))) (princ "\nThat class name already exists.")
                  (TT:ProjectSaveSection 'PIPE_CLASSES (if (member record classes) (subst updated record classes) (append classes (list updated))))))
              (princ "\nUse positive nominal:inside pairs, for example 1:1.049 1.25:1.380. Verify dimensions against your pipe data.")))))))
  (princ))

(defun TT:PipeSizeLabel (size)
  (strcat "Nominal " (rtos (car size) 2 3) " in | inside " (rtos (cadr size) 2 3) " in"))

(defun C:TTPIPE (/ *error* project type class size a b station entity metadata layer)
  (defun *error* (message) (TT:ReportError "TTPIPE" message))
  (setq project (TT:ProjectCurrent) class (if project (TT:PipeChooseClass)))
  (if class
    (progn
      (setq size (TT:PromptNumberedRecord (TT:PipeClassSizes class) 'TT:PipeSizeLabel "Select size"))
      (if size
        (progn
          (initget "Mainline Lateral") (setq type (getkword "\nPipe type [Mainline/Lateral] <Lateral>: "))
          (setq station (getstring T "\nStation <unassigned>: ") a (getpoint "\nPipe start: ") b (if a (getpoint a "\nPipe end: ")))
          (if (and a b (> (distance a b) 1e-9))
            (progn
              (setq layer (TT:EnsureLayer (if (= type "Mainline") 'IRR_MAINLINE 'IRR_LATERAL))
                entity (if layer (TT:CreateLine (trans a 1 0) (trans b 1 0) layer))
                metadata (TT:SmartMetadata project "IRRIGATION" (if (= type "Mainline") "MAINLINE_PIPE" "LATERAL_PIPE")
                  (TT:DataValue class 'CLASS_ID) (TT:ActiveWorkArea project))
                metadata (append metadata (list (cons 'PIPE_CLASS (TT:DataValue class 'CLASS_ID))
                  (cons 'DIAMETER_IN (car size)) (cons 'INSIDE_DIAMETER (cadr size))
                  (cons 'C_FACTOR (TT:DataValue class 'C_FACTOR)) '(MANUAL_SIZE . 1.0))))
              (if (/= station "") (setq metadata (append metadata (list (cons 'STATION station)))))
              (if (and entity (not (TT:SetEntityXData entity metadata))) (entdel entity))
              (princ "\nPipe created with a manual size. Use TTPIPEAUTO before automatic sizing.")))))))
  (princ))

(defun TT:PipeRecommendSize (edge graph class maxv maxloss / flow size result selected)
  (setq flow (cdr (assoc (TT:DataValue edge 'TO) (TT:DataValue graph 'FLOWS))))
  (foreach size (TT:PipeClassSizes class)
    (if (null selected)
      (progn
        (setq result (TT:HydraulicPipeResult (TT:DataValue edge 'LENGTH_FT) flow (cadr size) (TT:DataValue class 'C_FACTOR) 0.0 0.0))
        (if (and result (<= (TT:DataValue result 'VELOCITY_FPS) maxv)
          (<= (TT:DataValue result 'FRICTION_LOSS_PSI) maxloss)) (setq selected size)))))
  selected)

(defun C:TTPIPEAUTO (/ item data option)
  (setq item (TT:SelectSmartEntity "\nSelect pipe: "))
  (if (and item (TT:IrrigationPipeP (cdr item)))
    (progn
      (initget "Automatic Manual") (setq option (getkword "\nSize control [Automatic/Manual] <Manual>: "))
      (TT:SetEntityXData (car item) (TT:SmartMetadataPut (cdr item) 'MANUAL_SIZE (if (= option "Automatic") 0.0 1.0)))))
  (princ))

(defun C:TTIRRIGATIONSIZE (/ *error* undo-open scope item selection stations station data graph edge class size maxv maxloss updated apply-size count)
  (defun *error* (message)
    (if undo-open (command-s "_.UNDO" "_End")) (TT:ReportError "TTIRRIGATIONSIZE" message))
  (initget "Recommend Single Selection Station Network")
  (setq scope (getkword "\nSizing scope [Recommend/Single/Selection/Station/Network] <Recommend>: ") count 0)
  (if (null scope) (setq scope "Recommend"))
  (if (member scope '("Single" "Recommend"))
    (progn (setq item (TT:SelectSmartEntity "\nSelect pipe: "))
      (if (and item (TT:IrrigationPipeP (cdr item))) (setq selection (ssadd (car item)) stations (list (cdr (assoc 'STATION (cdr item)))))))
    (if (= scope "Selection")
      (progn (setq selection (ssget "_:L"))
        (foreach item (TT:SmartFilter (TT:SmartScan) "IRRIGATION" nil)
          (if (and selection (ssmemb (car item) selection) (TT:IrrigationPipeP (cdr item)))
            (if (not (member (cdr (assoc 'STATION (cdr item))) stations)) (setq stations (cons (cdr (assoc 'STATION (cdr item))) stations))))))
      (if (= scope "Station") (setq stations (list (getstring T "\nStation: ")))
        (foreach item (TT:SmartFilter (TT:SmartScan) "IRRIGATION" nil)
          (if (and (TT:IrrigationPipeP (cdr item)) (not (member (cdr (assoc 'STATION (cdr item))) stations)))
            (setq stations (cons (cdr (assoc 'STATION (cdr item))) stations)))))))
  (if stations
    (progn
      (initget 6) (setq maxv (getreal "\nMaximum velocity, ft/s <5>: ")) (if (null maxv) (setq maxv 5.0))
      (initget 6) (setq maxloss (getreal "\nMaximum friction per pipe, psi <5>: ")) (if (null maxloss) (setq maxloss 5.0))
      (command-s "_.UNDO" "_Begin") (setq undo-open T)
      (foreach station stations
        (setq graph (TT:NetworkFromDrawing station))
        (if (TT:DataValue graph 'ERRORS)
          (foreach item (TT:DataValue graph 'ERRORS) (princ (strcat "\nSizing refused: " item)))
          (foreach edge (TT:DataValue graph 'EDGES)
            (setq data (TT:DataValue edge 'DATA) class (TT:DataFindByValue (TT:PipeClasses) 'CLASS_ID (cdr (assoc 'CATALOG_ID data))))
            (if (and class (or (null selection) (ssmemb (TT:DataValue edge 'ENTITY) selection)))
              (progn
                (setq size (TT:PipeRecommendSize edge graph class maxv maxloss))
                (if size
                  (progn
                    (princ (strcat "\nRecommended: " (TT:PipeSizeLabel size)))
                    (if (and (/= scope "Recommend") (equal (cdr (assoc 'MANUAL_SIZE data)) 0.0))
                      (progn
                        (setq updated (TT:SmartMetadataPut data 'DIAMETER_IN (car size))
                              updated (TT:SmartMetadataPut updated 'INSIDE_DIAMETER (cadr size)))
                        (if (TT:SetEntityXData (TT:DataValue edge 'ENTITY) updated) (setq count (1+ count))))))
                  (princ "\nNo available class size passes."))
                (if (or (null size) (< (TT:PipeInsideDiameter data) (cadr size))) (redraw (TT:DataValue edge 'ENTITY) 3)))))))
      (command-s "_.UNDO" "_End") (setq undo-open nil)))
  (TT:PrintValue "Pipes resized (manual sizes retained)" count) (princ))
T

(defun C:TTSIZEPIPE (/ class length flow maxv maxloss size result selected)
  (setq class (TT:PipeChooseClass))
  (if class
    (progn
      (initget 6) (setq length (getreal "\nPipe length, feet: "))
      (if length (progn (initget 4) (setq flow (getreal "\nDesign flow, gpm: "))))
      (if flow
        (progn
          (initget 6) (setq maxv (getreal "\nMaximum velocity, ft/s <5>: ")) (if (null maxv) (setq maxv 5.0))
          (initget 6) (setq maxloss (getreal "\nMaximum friction per pipe, psi <5>: ")) (if (null maxloss) (setq maxloss 5.0))
          (foreach size (TT:PipeClassSizes class)
            (setq result (TT:HydraulicPipeResult length flow (cadr size) (TT:DataValue class 'C_FACTOR) 0.0 0.0))
            (if (and (null selected) result (<= (TT:DataValue result 'VELOCITY_FPS) maxv)
              (<= (TT:DataValue result 'FRICTION_LOSS_PSI) maxloss)) (setq selected size)))
          (princ (strcat "\n" (if selected (TT:PipeSizeLabel selected) "No available size passes.")))))))
  (princ))
T
