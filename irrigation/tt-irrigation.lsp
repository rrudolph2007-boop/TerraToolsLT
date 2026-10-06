;;; TerraTools LT - Irrigation equipment, graphics, zones, sizing, and reports.

(setq *TT:IrrigationModuleLoaded* T
      *TT:IrrigationMasterFileName* "terratools-irrigation-master.dat")

(defun TT:IrrigationMasterValidate (data / records record ids id valid classes class diameter)
  (setq records (TT:DataValue data 'EQUIPMENT) valid T)
  (foreach record records
    (setq id (TT:DataValue record 'EQUIPMENT_ID))
    (if (or (not (eq (car record) 'IRRIGATION_RECORD))
            (not (TT:ProjectNonEmptyStringP id)) (member id ids)
            (not (member (TT:DataValue record 'CATEGORY)
                         '(SPRAY_HEAD ROTOR DRIP VALVE CONTROLLER POC FILTER_REGULATOR SLEEVE)))
            (not (TT:ProjectNonEmptyStringP (TT:DataValue record 'CODE)))
            (not (TT:ProjectNonEmptyStringP (TT:DataValue record 'DESCRIPTION)))
            (not (numberp (TT:DataValue record 'FLOW_GPM)))
            (< (TT:DataValue record 'FLOW_GPM) 0.0))
      (setq valid nil)
      (setq ids (cons id ids))))
  (setq classes (TT:DataValue data 'PIPE_CLASSES))
  (if (null classes) (setq valid nil))
  (foreach class classes
    (if (or (not (eq (car class) 'PIPE_CLASS))
            (not (numberp (TT:DataValue class 'C_FACTOR)))
            (<= (TT:DataValue class 'C_FACTOR) 0.0)
            (null (TT:DataValue class 'DIAMETERS)))
      (setq valid nil))
    (foreach diameter (TT:DataValue class 'DIAMETERS)
      (if (or (not (numberp diameter)) (<= diameter 0.0)) (setq valid nil))))
  valid)

(defun TT:IrrigationMasterLoad (/ path data)
  (setq path (TT:StorageJoinPath (TT:StorageJoinPath *TT:Root* "data")
                                 *TT:IrrigationMasterFileName*)
        data (TT:StorageRead path))
  (if (and (eq (type data) 'LIST) (eq (car data) 'TERRATOOLS_IRRIGATION_MASTER)
           (eq (type (TT:DataValue data 'EQUIPMENT)) 'LIST)
           (TT:IrrigationMasterValidate data)) data nil))

(defun TT:IrrigationLabel (record)
  (strcat (TT:DataValue record 'CODE) " | "
          (TT:DataValue record 'DESCRIPTION) " | "
          (rtos (TT:SafeNumber (TT:DataValue record 'FLOW_GPM) 0.0) 2 2) " gpm"))

(defun TT:IrrigationCategoryName (category)
  (cond ((eq category 'SPRAY_HEAD) "SPRAY_HEAD") ((eq category 'ROTOR) "ROTOR")
        ((eq category 'DRIP) "DRIP") ((eq category 'VALVE) "VALVE")
        ((eq category 'CONTROLLER) "CONTROLLER") ((eq category 'POC) "POC")
        ((eq category 'FILTER_REGULATOR) "FILTER_REGULATOR")
        ((eq category 'SLEEVE) "SLEEVE") (T "EQUIPMENT")))

(defun TT:IrrigationPalette (project / value)
  (setq value (TT:ProjectValue project 'IRRIGATION_PALETTE))
  (if (eq (type value) 'LIST) value nil))

(defun TT:IrrigationFind (records id) (TT:DataFindByValue records 'EQUIPMENT_ID id))

(defun TT:IrrigationAdd (/ project master selected palette)
  (setq project (TT:ProjectCurrent) master (TT:IrrigationMasterLoad))
  (cond
    ((null project) (princ "\nA TerraTools project must be active."))
    ((null master) (princ "\nThe irrigation equipment catalog is unavailable."))
    (T
      (setq selected (TT:PromptNumberedRecord (TT:DataValue master 'EQUIPMENT)
                                              'TT:IrrigationLabel "Select equipment number"))
      (if selected
        (progn
          (setq palette (TT:IrrigationPalette project))
          (if (TT:IrrigationFind palette (TT:DataValue selected 'EQUIPMENT_ID))
            (princ "\nThat equipment is already in the Project Irrigation Palette.")
            (if (TT:ProjectSaveSection 'IRRIGATION_PALETTE (append palette (list selected)))
              (princ "\nEquipment added to the Project Irrigation Palette.")
              (princ "\nThe irrigation palette could not be saved.")))))))
  (princ))

(defun TT:IrrigationList (/ project record)
  (setq project (TT:ProjectCurrent))
  (if project
    (progn (princ "\nProject Irrigation Palette")
      (if (TT:IrrigationPalette project)
        (foreach record (TT:IrrigationPalette project)
          (princ (strcat "\n  " (TT:IrrigationLabel record))))
        (princ "\n  (empty)")))
    (princ "\nA TerraTools project must be active."))
  (princ))

(defun TT:IrrigationChoose (/ project records)
  (setq project (TT:ProjectCurrent) records (if project (TT:IrrigationPalette project)))
  (if records (TT:PromptNumberedRecord records 'TT:IrrigationLabel "Select equipment number")
    (if project (princ "\nThe Project Irrigation Palette is empty.")
      (princ "\nA TerraTools project must be active."))))

(defun C:TTIRRIGATION (/ option)
  (initget "List Add Place Pipe Drip Coverage Label Assign Zone Analyze Size Watering Schedule Verify")
  (setq option (getkword "\nIrrigation [List/Add/Place/Pipe/Drip/Coverage/Label/Assign/Zone/Analyze/Size/Watering/Schedule/Verify] <List>: "))
  (if (null option) (setq option "List"))
  (cond ((equal option "List") (TT:IrrigationList))
        ((equal option "Add") (TT:IrrigationAdd))
        ((equal option "Place") (C:TTPLACEIRRIGATION))
        ((equal option "Pipe") (C:TTPIPE))
        ((equal option "Drip") (C:TTDRIPLINE))
        ((equal option "Coverage") (C:TTIRRIGATIONCOVERAGE))
        ((equal option "Label") (C:TTIRRIGATIONLABEL))
        ((equal option "Assign") (C:TTASSIGNSTATION))
        ((equal option "Zone") (C:TTZONEINFO))
        ((equal option "Analyze") (C:TTIRRIGATIONANALYZE))
        ((equal option "Size") (C:TTIRRIGATIONSIZE))
        ((equal option "Watering") (C:TTWATERING))
        ((equal option "Schedule") (C:TTIRRIGATIONSCHEDULE))
        ((equal option "Verify") (C:TTVERIFYIRRIGATION)))
  (princ))

(defun C:TTPLACEIRRIGATION (/ project equipment point station block layer entity metadata)
  (setq project (TT:ProjectCurrent) equipment (if project (TT:IrrigationChoose)))
  (if (and equipment (setq point (getpoint "\nEquipment insertion point: ")))
    (progn
      (setq station (getstring T "\nStation or zone <unassigned>: ")
            block (strcat "TT_IRR_" (TT:DataValue equipment 'CODE))
            layer (TT:EnsureLayer 'HELPER_NPLT))
      (if (and layer (TT:EnsureSymbolBlock block 'CIRCLE)
               (setq entity (TT:CreateInsert block point layer 1.0)))
        (progn
          (setq metadata (TT:SmartMetadata project "IRRIGATION"
                            (TT:IrrigationCategoryName (TT:DataValue equipment 'CATEGORY))
                            (TT:DataValue equipment 'EQUIPMENT_ID) nil))
          (if (not (equal station ""))
            (setq metadata (TT:SmartMetadataPut metadata 'STATION station)))
          (setq metadata (TT:SmartMetadataPut metadata 'FLOW_GPM
                           (TT:SafeNumber (TT:DataValue equipment 'FLOW_GPM) 0.0)))
          (TT:SetEntityXData entity metadata)
          (princ "\nIrrigation equipment placed.")))))
  (princ))

(defun C:TTPIPE (/ project type a b class diameter c station layer entity metadata)
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (initget "Mainline Lateral")
      (setq type (getkword "\nPipe type [Mainline/Lateral] <Lateral>: "))
      (if (null type) (setq type "Lateral"))
      (setq diameter (getreal "\nPipe diameter, inches <1.0>: "))
      (if (null diameter) (setq diameter 1.0))
      (setq c (getreal "\nHazen-Williams C factor <150>: "))
      (if (null c) (setq c 150.0))
      (setq station (getstring T "\nStation or zone <unassigned>: "))
      (if (and (> diameter 0.0) (> c 0.0)
               (setq a (getpoint "\nPipe start: "))
               (setq b (getpoint a "\nPipe end: "))
               (setq layer (TT:EnsureLayer 'HELPER_NPLT))
               (setq entity (TT:CreateLine a b layer)))
        (progn
          (setq metadata (TT:SmartMetadata project "IRRIGATION"
                           (if (equal type "Mainline") "MAINLINE_PIPE" "LATERAL_PIPE")
                           "PVC-CLASS-200" nil)
                metadata (TT:SmartMetadataPut metadata 'DIAMETER_IN diameter)
                metadata (TT:SmartMetadataPut metadata 'C_FACTOR c)
                metadata (TT:SmartMetadataPut metadata 'MANUAL_SIZE 1.0))
          (if (not (equal station ""))
            (setq metadata (TT:SmartMetadataPut metadata 'STATION station)))
          (TT:SetEntityXData entity metadata)
          (princ "\nSmart irrigation pipe created."))
        (princ "\nPipe input is invalid or placement was canceled."))))
  (princ))

(defun C:TTIRRIGATIONCOVERAGE (/ item point radius layer circle metadata)
  (setq item (TT:SelectSmartEntity "\nSelect an irrigation head: "))
  (if (and item (equal (cdr (assoc 'MODULE (cdr item))) "IRRIGATION")
           (member (cdr (assoc 'OBJECT_TYPE (cdr item))) '("SPRAY_HEAD" "ROTOR")))
    (progn
      (setq point (cdr (assoc 10 (entget (car item))))
            radius (getdist point "\nCoverage radius: ")
            layer (TT:EnsureLayer 'HELPER_NPLT))
      (if (and radius (> radius 0.0) layer
               (setq circle (entmakex (list '(0 . "CIRCLE") (cons 8 layer)
                                             (cons 10 point) (cons 40 radius)))))
        (progn
          (setq metadata (TT:SmartMetadata (TT:ProjectCurrent) "IRRIGATION"
                           "COVERAGE" (cdr (assoc 'ENTITY_UUID (cdr item))) nil))
          (TT:SetEntityXData circle metadata)
          (princ "\nCoverage circle created."))))
    (if item (princ "\nSelect a TerraTools spray head or rotor.")))
  (princ))

(defun C:TTDRIPLINE (/ project selection entity flow station data)
  (setq project (TT:ProjectCurrent) selection (if project (entsel "\nSelect LINE or LWPOLYLINE for drip tubing: ")))
  (if (and selection (TT:EntityLength (setq entity (car selection))))
    (progn
      (setq flow (getreal "\nTotal drip demand, gpm: ")
            station (if flow (getstring T "\nStation or zone: ")))
      (if (and flow (>= flow 0.0) (not (equal station "")))
        (progn
          (setq data (TT:SmartMetadata project "IRRIGATION" "DRIP_LINE" nil nil)
                data (TT:SmartMetadataPut data 'FLOW_GPM flow)
                data (TT:SmartMetadataPut data 'STATION station))
          (if (TT:SetEntityXData entity data) (princ "\nSmart drip line created.")))))
    (if selection (princ "\nA LINE or LWPOLYLINE is required.")))
  (princ))

(defun C:TTIRRIGATIONLABEL (/ item point height text entity metadata)
  (setq item (TT:SelectSmartEntity "\nSelect irrigation object to label: "))
  (if (and item (equal (cdr (assoc 'MODULE (cdr item))) "IRRIGATION")
           (setq point (getpoint "\nLabel insertion point: ")))
    (progn
      (setq height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT))
      (if (not (numberp height)) (setq height 0.1))
      (setq text (strcat (cdr (assoc 'OBJECT_TYPE (cdr item)))
                         (if (assoc 'STATION (cdr item))
                           (strcat "  STATION " (cdr (assoc 'STATION (cdr item)))) ""))
            entity (TT:CreateText point height text (TT:EnsureLayer 'PLANT_LABEL)))
      (if entity
        (progn
          (setq metadata (TT:SmartMetadata (TT:ProjectCurrent) "IRRIGATION"
                                           "IRRIGATION_LABEL"
                                           (cdr (assoc 'ENTITY_UUID (cdr item))) nil))
          (TT:SetEntityXData entity metadata)
          (princ "\nIrrigation label created.")))))
  (princ))

(defun TT:IrrigationStationDemand (station / item data total)
  (setq total 0.0)
  (foreach item (TT:SmartFilter (TT:SmartScan) "IRRIGATION" nil)
    (setq data (cdr item))
    (if (and (equal station (cdr (assoc 'STATION data)))
             (numberp (cdr (assoc 'FLOW_GPM data))))
      (setq total (+ total (cdr (assoc 'FLOW_GPM data))))))
  total)

(defun TT:IrrigationPipeP (metadata)
  (member (cdr (assoc 'OBJECT_TYPE metadata)) '("MAINLINE_PIPE" "LATERAL_PIPE")))

(defun TT:IrrigationEntityPoint (entity / data)
  (setq data (entget entity))
  (cdr (assoc 10 data)))

(defun TT:IrrigationPipeEndpoints (entity / data)
  (setq data (entget entity))
  (list (cdr (assoc 10 data)) (cdr (assoc 11 data))))

(defun TT:IrrigationNearP (a b tolerance)
  (and a b (<= (distance a b) tolerance)))

(defun TT:IrrigationStationItems (station / item data pipes equipment)
  (foreach item (TT:SmartFilter (TT:SmartScan) "IRRIGATION" nil)
    (setq data (cdr item))
    (if (equal station (cdr (assoc 'STATION data)))
      (if (TT:IrrigationPipeP data)
        (setq pipes (cons item pipes))
        (if (numberp (cdr (assoc 'FLOW_GPM data)))
          (setq equipment (cons item equipment))))))
  (list pipes equipment))

(defun TT:IrrigationDemandAtPoint (point equipment tolerance / item total)
  (setq total 0.0)
  (foreach item equipment
    (if (TT:IrrigationNearP point (TT:IrrigationEntityPoint (car item)) tolerance)
      (setq total (+ total (TT:SafeNumber (cdr (assoc 'FLOW_GPM (cdr item))) 0.0)))))
  total)

(defun TT:IrrigationDownstreamFlow (point pipes equipment tolerance visited
                                    / total ambiguous item ends uuid branch)
  (setq total (TT:IrrigationDemandAtPoint point equipment tolerance) ambiguous nil)
  (foreach item pipes
    (setq ends (TT:IrrigationPipeEndpoints (car item))
          uuid (cdr (assoc 'ENTITY_UUID (cdr item))))
    (if (TT:IrrigationNearP point (car ends) tolerance)
      (if (member uuid visited)
        (setq ambiguous T)
        (progn
          (setq branch (TT:IrrigationDownstreamFlow (cadr ends) pipes equipment tolerance
                                                    (cons uuid visited)))
          (setq total (+ total (car branch)))
          (if (cadr branch) (setq ambiguous T))))))
  (list total ambiguous))

(defun TT:IrrigationPipeDownstreamFlow (pipe-item pipes equipment tolerance / ends uuid)
  (setq ends (TT:IrrigationPipeEndpoints (car pipe-item))
        uuid (cdr (assoc 'ENTITY_UUID (cdr pipe-item))))
  (if (and ends uuid)
    (TT:IrrigationDownstreamFlow (cadr ends) pipes equipment tolerance (list uuid))
    (list nil T)))

(defun TT:IrrigationIncomingPipeCount (point pipes tolerance / item ends count)
  (setq count 0)
  (foreach item pipes
    (setq ends (TT:IrrigationPipeEndpoints (car item)))
    (if (TT:IrrigationNearP point (cadr ends) tolerance)
      (setq count (1+ count))))
  count)

(defun TT:IrrigationPointMemberP (point points tolerance / found candidate)
  (foreach candidate points
    (if (TT:IrrigationNearP point candidate tolerance) (setq found T)))
  found)

(defun TT:IrrigationMergedNodeCount (pipes tolerance / item ends count points point)
  (setq count 0)
  (foreach item pipes
    (setq ends (TT:IrrigationPipeEndpoints (car item)))
    (foreach point ends
      (if (not (TT:IrrigationPointMemberP point points tolerance))
        (setq points (cons point points)))))
  (foreach point points
    (if (> (TT:IrrigationIncomingPipeCount point pipes tolerance) 1)
      (setq count (1+ count))))
  count)

(defun TT:IrrigationDisconnectedCount (pipes equipment tolerance / item point pipe ends connected count)
  (setq count 0)
  (foreach item equipment
    (setq point (TT:IrrigationEntityPoint (car item)) connected nil)
    (foreach pipe pipes
      (setq ends (TT:IrrigationPipeEndpoints (car pipe)))
      (if (or (TT:IrrigationNearP point (car ends) tolerance)
              (TT:IrrigationNearP point (cadr ends) tolerance))
        (setq connected T)))
    (if (and (> (TT:SafeNumber (cdr (assoc 'FLOW_GPM (cdr item))) 0.0) 0.0)
             (not connected))
      (setq count (1+ count))))
  count)

(defun TT:IrrigationAnalyzeStation (station / items pipes equipment tolerance item data branch result rows total ambiguous disconnected merged length-feet)
  (setq items (TT:IrrigationStationItems station) pipes (car items)
        equipment (cadr items) tolerance 0.01 total 0.0 ambiguous nil)
  (foreach item pipes
    (setq data (cdr item)
          branch (TT:IrrigationPipeDownstreamFlow item pipes equipment tolerance)
          length-feet (TT:DrawingLengthToFeet (TT:EntityLength (car item)))
          result (if length-feet (TT:HydraulicPipeResult length-feet (car branch)
                   (TT:SafeNumber (cdr (assoc 'DIAMETER_IN data)) 0.0)
                   (TT:SafeNumber (cdr (assoc 'C_FACTOR data)) 0.0) 0.0 0.0)))
    (if (cadr branch) (setq ambiguous T))
    (if result (setq rows (append rows (list (list (car item) data result))))))
  (foreach item equipment
    (setq total (+ total (TT:SafeNumber (cdr (assoc 'FLOW_GPM (cdr item))) 0.0))))
  (setq disconnected (TT:IrrigationDisconnectedCount pipes equipment tolerance)
        merged (TT:IrrigationMergedNodeCount pipes tolerance))
  (if (> merged 0) (setq ambiguous T))
  (list total rows disconnected ambiguous merged))

(defun C:TTIRRIGATIONANALYZE (/ station analysis row result total)
  (setq station (getstring T "\nStation or zone to analyze: "))
  (if (not (equal station ""))
    (progn
      (setq analysis (TT:IrrigationAnalyzeStation station) total 0.0)
      (princ (strcat "\nStation " station " demand: " (rtos (car analysis) 2 2) " gpm"))
      (foreach row (cadr analysis)
        (setq result (caddr row))
        (if result (setq total (+ total (TT:DataValue result 'FRICTION_LOSS_PSI)))))
      (princ (strcat "\nSum of calculated directed pipe losses: " (rtos total 2 2) " psi"))
      (princ (strcat "\nDisconnected demand objects: " (itoa (caddr analysis))))
      (princ (strcat "\nAmbiguous merged nodes: " (itoa (nth 4 analysis))))
      (if (cadddr analysis)
        (princ "\nAmbiguous loop detected. Flow results require manual review.")
        (princ "\nFlow propagated from each LINE start point toward its end point."))))
  (princ))

(defun C:TTSIZEPIPE (/ length flow c maxv maxloss master class diameter)
  (setq length (getreal "\nDesign pipe length, feet: ")
        flow (if length (getreal "\nDesign flow, gpm: "))
        maxv (if flow (getreal "\nMaximum velocity, ft/s <5>: ")))
  (if (and flow (null maxv)) (setq maxv 5.0))
  (setq maxloss (if maxv (getreal "\nMaximum friction loss, psi <5>: ")))
  (if (and maxv (null maxloss)) (setq maxloss 5.0))
  (setq master (TT:IrrigationMasterLoad) class (if master (car (TT:DataValue master 'PIPE_CLASSES)))
        c (if class (TT:DataValue class 'C_FACTOR)))
  (setq diameter (if c (TT:HydraulicChooseDiameter length flow c
                            (TT:DataValue class 'DIAMETERS) maxv maxloss)))
  (if diameter (princ (strcat "\nSmallest passing nominal diameter: " (rtos diameter 2 2) " in"))
    (if length (princ "\nNo available diameter satisfies the criteria, or inputs are invalid.")))
  (princ))

(defun C:TTIRRIGATIONSIZE (/ item data station items pipes equipment pipe-item branch length master class diameter answer analysis)
  (setq item (TT:SelectSmartEntity "\nSelect a smart irrigation pipe: "))
  (cond
    ((null item) nil)
    ((not (TT:IrrigationPipeP (cdr item)))
      (princ "\nThe selected object is not a TerraTools irrigation pipe."))
    (T
      (setq data (cdr item)
            station (cdr (assoc 'STATION data))
            items (TT:IrrigationStationItems station)
            pipes (car items)
            equipment (cadr items)
            pipe-item (assoc (car item) pipes)
            branch (if pipe-item (TT:IrrigationPipeDownstreamFlow pipe-item pipes equipment 0.01))
            analysis (TT:IrrigationAnalyzeStation station)
            length (TT:DrawingLengthToFeet (TT:EntityLength (car item)))
            master (TT:IrrigationMasterLoad)
            class (if master (car (TT:DataValue master 'PIPE_CLASSES))))
      (if (and branch (not (cadr branch)) (not (cadddr analysis))
               (= 0 (nth 4 analysis)) length class)
        (setq diameter
          (TT:HydraulicChooseDiameter length (car branch)
            (TT:DataValue class 'C_FACTOR)
            (TT:DataValue class 'DIAMETERS) 5.0 5.0)))
      (cond
        ((or (null pipe-item) (null branch) (cadr branch)
             (cadddr analysis) (> (nth 4 analysis) 0))
          (princ "\nPipe sizing stopped: station topology is ambiguous or contains a loop."))
        ((null length)
          (princ "\nPipe sizing stopped: drawing length units could not be resolved."))
        ((null diameter)
          (princ "\nNo available size passes the velocity and friction criteria."))
        (T
          (princ (strcat "\nDownstream flow: " (rtos (car branch) 2 2) " gpm"
                         "\nCalculated diameter: " (rtos diameter 2 2) " in."))
          (initget "Yes No")
          (setq answer (getkword "\nApply calculated size? [Yes/No] <No>: "))
          (if (equal answer "Yes")
            (progn
              (setq data (TT:SmartMetadataPut data 'DIAMETER_IN diameter)
                    data (TT:SmartMetadataPut data 'MANUAL_SIZE 0.0))
              (TT:SetEntityXData (car item) data)
              (princ "\nPipe size updated.")))))))
  (princ))

(defun C:TTZONEINFO (/ station analysis)
  (setq station (getstring T "\nStation or zone: "))
  (if (not (equal station ""))
    (progn (setq analysis (TT:IrrigationAnalyzeStation station))
      (princ (strcat "\nStation: " station
                     "\n  Demand: " (rtos (car analysis) 2 2) " gpm"
                     "\n  Smart pipes: " (itoa (length (cadr analysis)))
                     "\n  Disconnected demand objects: " (itoa (caddr analysis)))))
  (princ)))

(defun C:TTASSIGNSTATION (/ station selection index entity data count)
  (setq station (getstring T "\nStation or zone: "))
  (if (not (equal station ""))
    (progn
      (princ "\nSelect TerraTools irrigation objects to assign.")
      (setq selection (ssget "_:L") index 0 count 0)
      (if selection
        (progn
          (command-s "_.UNDO" "_Begin")
          (while (< index (sslength selection))
            (setq entity (ssname selection index) data (TT:GetEntityXData entity))
            (if (and data (equal (cdr (assoc 'MODULE data)) "IRRIGATION"))
              (progn
                (setq data (TT:SmartMetadataPut data 'STATION station))
                (if (TT:SetEntityXData entity data) (setq count (1+ count)))))
            (setq index (1+ index)))
          (command-s "_.UNDO" "_End")
          (princ (strcat "\nAssigned " (itoa count) " object(s) to station " station "."))))))
  (princ))

(defun C:TTHIGHLIGHTSTATION (/ station item data count)
  (setq station (getstring T "\nStation or zone to highlight: ") count 0)
  (foreach item (TT:SmartFilter (TT:SmartScan) "IRRIGATION" nil)
    (setq data (cdr item))
    (if (equal station (cdr (assoc 'STATION data)))
      (progn (redraw (car item) 3) (setq count (1+ count)))))
  (princ (strcat "\nHighlighted " (itoa count) " object(s). REGEN clears highlighting."))
  (princ))

(defun C:TTCRITICALPATH (/ selection index entity data station items pipes demand-items pipe-item branch flow max-flow result total available required elevation equipment total-required margin ambiguous length-feet)
  (princ "\nSelect smart pipes in the path to report.")
  (setq selection (ssget) total 0.0)
  (if selection
    (progn
      (setq station (getstring T "\nStation or zone for path flow: ")
            items (TT:IrrigationStationItems station) pipes (car items)
            demand-items (cadr items) index 0 ambiguous nil flow 0.0 max-flow 0.0)
      (while (< index (sslength selection))
        (setq entity (ssname selection index) data (TT:GetEntityXData entity))
        (if (and data (TT:IrrigationPipeP data))
          (progn
            (setq pipe-item (assoc entity pipes)
                  branch (if pipe-item (TT:IrrigationPipeDownstreamFlow pipe-item pipes demand-items 0.01))
                  length-feet (TT:DrawingLengthToFeet (TT:EntityLength entity))
                  flow (if branch (car branch) 0.0)
                  result (if (and branch (not (cadr branch)) length-feet)
                           (TT:HydraulicPipeResult length-feet flow
                             (TT:SafeNumber (cdr (assoc 'DIAMETER_IN data)) 0.0)
                             (TT:SafeNumber (cdr (assoc 'C_FACTOR data)) 0.0) 0.0 0.0)))
            (if (> flow max-flow) (setq max-flow flow))
            (if (or (null result) (and branch (cadr branch))) (setq ambiguous T))
            (if result
              (setq total (+ total (TT:DataValue result 'TOTAL_LOSS_PSI))))
            (redraw entity 3)))
        (setq index (1+ index)))
      (if (> (TT:IrrigationMergedNodeCount pipes 0.01) 0) (setq ambiguous T))
      (if ambiguous
        (princ "\nCritical-path calculation stopped: selected topology is ambiguous or units are unresolved.")
        (progn
          (setq available (getreal "\nAvailable pressure at POC, psi: ")
                required (if available (getreal "\nRequired terminal pressure, psi: "))
                elevation (if required (getreal "\nNet elevation rise, feet <0>: ")))
          (if (and required (null elevation)) (setq elevation 0.0))
          (setq equipment (if required (getreal "\nEquipment losses, psi <0>: ")))
          (if (and required (null equipment)) (setq equipment 0.0))
          (if (and available required elevation equipment)
            (progn
              (setq total-required (+ total required equipment (TT:ElevationToPSI elevation))
                    margin (- available total-required))
              (princ (strcat "\nMaximum downstream flow on selected path: " (rtos max-flow 2 2) " gpm"
                             "\nPipe friction: " (rtos total 2 2) " psi"
                             "\nEquipment loss: " (rtos equipment 2 2) " psi"
                             "\nElevation effect: " (rtos (TT:ElevationToPSI elevation) 2 2) " psi"
                             "\nRequired terminal pressure: " (rtos required 2 2) " psi"
                             "\nAvailable pressure: " (rtos available 2 2) " psi"
                             "\nPressure margin: " (rtos margin 2 2) " psi"))))))))
  (princ))

(defun C:TTWATERING (/ station area depth flow gallons runtime)
  (setq station (getstring T "\nStation or zone: ")
        area (if (not (equal station "")) (getreal "\nIrrigated area, square feet: "))
        depth (if area (getreal "\nTarget application depth, inches: "))
        flow (if depth (TT:IrrigationStationDemand station)))
  (if (and area (> area 0.0) depth (> depth 0.0) flow (> flow 0.0))
    (progn
      (setq gallons (* 0.623 area depth) runtime (/ gallons flow))
      (princ (strcat "\nAssumed uniform application volume: " (rtos gallons 2 1) " gallons"
                     "\nCalculated runtime: " (rtos runtime 2 1) " minutes")))
    (if area (princ "\nArea, depth, and station flow must be greater than zero.")))
  (princ))

(defun C:TTIRRIGATIONSCHEDULE (/ project rows item data id record old point text count flow height layer length)
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (foreach item (TT:SmartFilter (TT:SmartScan) "IRRIGATION" nil)
        (setq data (cdr item) id (cdr (assoc 'CATALOG_ID data))
              record (TT:IrrigationFind (TT:IrrigationPalette project) id))
        (if record
          (progn
            (setq old (assoc id rows))
            (if old (setq rows (subst (list id record (1+ (caddr old))) old rows))
              (setq rows (append rows (list (list id record 1))))))))
      (if (and rows (setq point (getpoint "\nIrrigation schedule insertion point: ")))
        (progn
          (setq text "IRRIGATION SCHEDULE\\PCODE | DESCRIPTION | QTY | TOTAL FLOW")
          (foreach row rows
            (setq count (caddr row)
                  flow (* count (TT:SafeNumber (TT:DataValue (cadr row) 'FLOW_GPM) 0.0))
                  text (strcat text "\\P" (TT:DataValue (cadr row) 'CODE) " | "
                               (TT:DataValue (cadr row) 'DESCRIPTION) " | "
                               (itoa count) " | " (rtos flow 2 2) " gpm")))
          (foreach item (TT:SmartFilter (TT:SmartScan) "IRRIGATION" nil)
            (setq data (cdr item))
            (if (TT:IrrigationPipeP data)
              (progn
                (setq length (TT:DrawingLengthToFeet (TT:EntityLength (car item))))
                (setq text (strcat text "\\PPIPE | " (cdr (assoc 'OBJECT_TYPE data))
                             " | " (if length (rtos length 2 2) "UNRESOLVED") " ft | "
                             (rtos (TT:SafeNumber (cdr (assoc 'DIAMETER_IN data)) 0.0) 2 2)
                             " in")))))
          (setq height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT)
                layer (TT:EnsureLayer 'PLANT_SCHEDULE))
          (if (not (numberp height)) (setq height 0.1))
          (if (and layer (TT:CreateMText point height (* height 75.0) text layer))
            (princ "\nIrrigation schedule created.")))
        (if (null rows) (princ "\nNo scheduled irrigation equipment was found.")))))
  (princ))

(defun C:TTVERIFYIRRIGATION (/ project item data problems)
  (setq project (TT:ProjectCurrent) problems 0)
  (if project
    (foreach item (TT:SmartFilter (TT:SmartScan) "IRRIGATION" nil)
      (setq data (cdr item))
      (if (not (equal (cdr (assoc 'PROJECT_UUID data)) (TT:ProjectValue project 'PROJECT_UUID)))
        (setq problems (1+ problems)))
      (if (and (TT:IrrigationPipeP data)
               (or (null (TT:EntityLength (car item)))
                   (<= (TT:SafeNumber (cdr (assoc 'DIAMETER_IN data)) 0.0) 0.0)))
        (setq problems (1+ problems))))
    (princ "\nA TerraTools project must be active."))
  (if project (princ (strcat "\nIrrigation verification: "
                             (if (= problems 0) "PASS" (strcat "FAIL, " (itoa problems) " issue(s)")))))
  (princ))

T
