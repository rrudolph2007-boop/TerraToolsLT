;;; Operation-local directed network graph. No entity mutations during analysis.
(setq *TT:NetworkModuleLoaded* T)

(defun TT:NetworkTolerance (/ project value unit)
  (setq project (TT:ProjectCurrent) value (if project (TT:ProjectValue project 'IRRIGATION_TOLERANCE))
        unit (TT:DrawingUnitName))
  (cond ((and (numberp value) (> value 0.0)) value)
        (unit (TT:ConvertLength 0.003048 'METERS unit))
        (T nil)))

(defun TT:NetworkNodeAt (point nodes tolerance / found node)
  (foreach node nodes
    (if (<= (distance point (TT:DataValue node 'POINT)) tolerance)
      (setq found (TT:DataValue node 'NODE_ID))))
  found)

(defun TT:NetworkNode (nodes id)
  (TT:DataFindByValue nodes 'NODE_ID id))

(defun TT:NetworkBuild (edges demands sources tolerance / nodes edge point id serial updated built demand source roots errors node outgoing incoming flows pending progress remaining total child pair flow processed key)
  ;; Inputs are ordinary data; suitable for deterministic QA without a drawing.
  (setq serial 0 errors nil)
  (foreach edge edges
    (setq updated edge)
    (foreach key '(START END)
      (setq point (TT:DataValue edge key) id (TT:NetworkNodeAt point nodes tolerance))
      (if (null id)
        (progn
          (setq id serial serial (1+ serial)
                nodes (cons (list 'NETWORK_NODE (cons 'NODE_ID id) (cons 'POINT point)
                  '(INCOMING) '(OUTGOING) '(DEMAND . 0.0) '(REQUIRED . 0.0) '(LOSS . 0.0)) nodes))))
      (setq updated (TT:DataPut updated (if (eq key 'START) 'FROM 'TO) id)))
    (if (= (TT:DataValue updated 'FROM) (TT:DataValue updated 'TO)) (setq errors (cons "Zero-length or tolerance-collapsed pipe" errors)))
    (setq built (cons updated built)))
  (foreach edge built
    (foreach pair '((FROM . OUTGOING) (TO . INCOMING))
      (setq id (TT:DataValue edge (car pair)) node (TT:NetworkNode nodes id)
            updated (TT:DataPut node (cdr pair) (cons (TT:DataValue edge 'EDGE_ID) (TT:DataValue node (cdr pair))))
            nodes (subst updated node nodes))))
  (foreach demand demands
    (setq id (TT:NetworkNodeAt (car demand) nodes tolerance))
    (if (null id) (setq errors (cons "Disconnected demand" errors))
      (progn
        (setq node (TT:NetworkNode nodes id)
              updated (TT:DataPut node 'DEMAND (+ (TT:DataValue node 'DEMAND) (cadr demand)))
              updated (TT:DataPut updated 'REQUIRED (max (TT:DataValue node 'REQUIRED) (nth 2 demand)))
              updated (TT:DataPut updated 'LOSS (+ (TT:DataValue node 'LOSS) (nth 3 demand)))
              nodes (subst updated node nodes)))))
  (foreach source sources
    (setq id (TT:NetworkNodeAt source nodes tolerance))
    (if (null id) (setq errors (cons "Disconnected source" errors))
      (setq roots (cons id roots))))
  (if (/= (length roots) 1) (setq errors (cons "Exactly one connected source is required" errors)))
  (foreach node nodes
    (setq incoming (TT:DataValue node 'INCOMING) id (TT:DataValue node 'NODE_ID))
    (if (> (length incoming) 1) (setq errors (cons "Merged incoming paths" errors)))
    (if (and (null incoming) (not (member id roots))) (setq errors (cons "Orphan or reversed pipe branch" errors)))
    (if (and incoming (member id roots)) (setq errors (cons "Pipe points into the source" errors))))
  ;; Eliminate leaves, reusing child flows. A remainder identifies a directed loop.
  (setq pending nodes progress T processed 0)
  (while (and pending progress)
    (setq progress nil remaining nil)
    (foreach node pending
      (setq outgoing (TT:DataValue node 'OUTGOING) total (TT:DataValue node 'DEMAND) child T)
      (foreach id outgoing
        (setq edge (TT:DataFindByValue built 'EDGE_ID id) pair (assoc (TT:DataValue edge 'TO) flows))
        (if pair (setq total (+ total (cdr pair))) (setq child nil)))
      (if child
        (setq flows (cons (cons (TT:DataValue node 'NODE_ID) total) flows) progress T processed (1+ processed))
        (setq remaining (cons node remaining))))
    (setq pending (reverse remaining)))
  (if pending (setq errors (cons "Directed loop" errors)))
  (list 'IRRIGATION_GRAPH (cons 'NODES nodes) (cons 'EDGES (reverse built))
    (cons 'ROOT (car roots)) (cons 'FLOWS flows) (cons 'ERRORS (reverse errors))))

(defun TT:NetworkFromDrawing (station / items item data edges demands sources project palette record ends id tolerance invalid)
  (setq project (TT:ProjectCurrent) tolerance (TT:NetworkTolerance)
        palette (if project (TT:IrrigationPalette project)) id 0)
  (if (and project tolerance)
    (progn
      (setq items (TT:SmartFilter (TT:SmartScan) "IRRIGATION" nil))
      (foreach item items
        (setq data (cdr item))
        (if (and (equal station (cdr (assoc 'STATION data)))
                 (equal (TT:ProjectValue project 'PROJECT_UUID) (cdr (assoc 'PROJECT_UUID data))))
          (if (TT:IrrigationPipeP data)
            (if (= (cdr (assoc 0 (entget (car item)))) "LINE")
              (progn
                (setq ends (TT:IrrigationPipeEndpoints (car item))
                      edges (cons (list 'NETWORK_EDGE (cons 'EDGE_ID id) (cons 'ENTITY (car item))
                        (cons 'START (car ends)) (cons 'END (cadr ends))
                        (cons 'DATA data) (cons 'LENGTH_FT (TT:DrawingLengthToFeet (TT:EntityLength (car item))))) edges)
                      id (1+ id)))
              (setq invalid T))
            (cond
              ((equal (cdr (assoc 'OBJECT_TYPE data)) "POC")
                (setq sources (cons (TT:IrrigationEntityPoint (car item)) sources)))
              ((and (assoc 'FLOW_GPM data) (>= (cdr (assoc 'FLOW_GPM data)) 0.0))
                (setq record (TT:IrrigationFind palette (cdr (assoc 'CATALOG_ID data))))
                (if (or (and record (numberp (TT:DataValue record 'PRESSURE_PSI))) (numberp (cdr (assoc 'PRESSURE_PSI data))))
                  (setq demands (cons (list (TT:IrrigationEntityPoint (car item))
                    (cdr (assoc 'FLOW_GPM data)) (if record (TT:DataValue record 'PRESSURE_PSI) (cdr (assoc 'PRESSURE_PSI data)))
                    (TT:SafeNumber (TT:DataValue record 'LOSS_PSI) 0.0)) demands))
                  (setq invalid T)))))))
      (if invalid
        (list 'IRRIGATION_GRAPH (cons 'ERRORS '("Unsupported pipe or unresolved demand pressure")))
        (TT:NetworkBuild edges demands sources tolerance)))
    (list 'IRRIGATION_GRAPH (cons 'ERRORS '("Active project and resolved drawing units are required")))))

(defun TT:NetworkPressure (graph source-pressure unit / nodes edges flows pending losses paths reports progress remaining edge from to node loss result rise required maximum critical pair)
  (if (null (TT:DataValue graph 'ERRORS))
    (progn
      (setq nodes (TT:DataValue graph 'NODES) edges (TT:DataValue graph 'EDGES)
            flows (TT:DataValue graph 'FLOWS) pending edges progress T
            losses (list (cons (TT:DataValue graph 'ROOT)
                          (TT:DataValue (TT:NetworkNode (TT:DataValue graph 'NODES)
                            (TT:DataValue graph 'ROOT)) 'LOSS)))
            paths (list (cons (TT:DataValue graph 'ROOT) nil)) maximum 0.0)
      (while (and pending progress)
        (setq remaining nil progress nil)
        (foreach edge pending
          (setq from (TT:DataValue edge 'FROM) to (TT:DataValue edge 'TO) pair (assoc from losses))
          (if pair
            (progn
              (setq node (TT:NetworkNode nodes to)
                    rise (TT:ConvertLength (- (caddr (TT:DataValue node 'POINT))
                             (caddr (TT:DataValue (TT:NetworkNode nodes from) 'POINT))) unit 'FEET)
                    result (TT:HydraulicPipeResult (TT:DataValue edge 'LENGTH_FT)
                      (cdr (assoc to flows)) (TT:PipeInsideDiameter (TT:DataValue edge 'DATA))
                      (cdr (assoc 'C_FACTOR (TT:DataValue edge 'DATA))) rise (TT:DataValue node 'LOSS)))
              (if result
                (progn
                  (setq loss (+ (cdr pair) (TT:DataValue result 'TOTAL_LOSS_PSI))
                        losses (cons (cons to loss) losses)
                        paths (cons (cons to (append (cdr (assoc from paths)) (list (TT:DataValue edge 'EDGE_ID)))) paths)
                        required (+ loss (TT:DataValue node 'REQUIRED)))
                  (if (> required maximum) (setq maximum required critical (cdr (assoc to paths))))
                  (setq reports (cons (list 'EDGE_REPORT (cons 'EDGE edge) (cons 'HYDRAULICS result)
                    (cons 'AVAILABLE_PSI (- source-pressure loss)) (cons 'REQUIRED_PSI (TT:DataValue node 'REQUIRED))
                    (cons 'MARGIN_PSI (- source-pressure required))) reports)
                        progress T))
                (setq remaining (cons edge remaining))))
            (setq remaining (cons edge remaining))))
        (setq pending (reverse remaining)))
      (if pending nil
        (list 'NETWORK_PRESSURE (cons 'REPORTS (reverse reports)) (cons 'SOURCE_REQUIRED_PSI maximum)
          (cons 'SOURCE_MARGIN_PSI (- source-pressure maximum)) (cons 'CRITICAL_EDGE_IDS critical))))))

(defun C:TTAUTOCRITICALPATH (/ *error* station graph available report edge item)
  (defun *error* (message) (TT:ReportError "TTAUTOCRITICALPATH" message))
  (setq station (getstring T "\nStation to analyze: ") graph (TT:NetworkFromDrawing station))
  (if (TT:DataValue graph 'ERRORS)
    (foreach item (TT:DataValue graph 'ERRORS) (princ (strcat "\nNetwork unresolved: " item)))
    (progn
      (initget 4) (setq available (getreal "\nAvailable source pressure, psi: "))
      (if available
        (progn
          (setq report (TT:NetworkPressure graph available (TT:DrawingUnitName)))
          (if report
            (progn
              (TT:PrintValue "Required source pressure, psi" (TT:DataValue report 'SOURCE_REQUIRED_PSI))
              (TT:PrintValue "Source pressure margin, psi" (TT:DataValue report 'SOURCE_MARGIN_PSI))
              (foreach edge (TT:DataValue graph 'EDGES)
                (if (member (TT:DataValue edge 'EDGE_ID) (TT:DataValue report 'CRITICAL_EDGE_IDS))
                  (redraw (TT:DataValue edge 'ENTITY) 3)))
              (princ "\nCritical route highlighted. Uses stored demand pressures, friction, elevation and explicit equipment loss; omitted losses are zero."))
            (princ "\nPressure calculation stopped: pipe dimensions, coefficients or units are invalid."))))))
  (princ))

(defun C:TTREVERSEPIPE (/ *error* selected entity data a b)
  (defun *error* (message) (TT:ReportError "TTREVERSEPIPE" message))
  (setq selected (TT:SelectSmartEntity "\nSelect directed irrigation LINE to reverse: "))
  (if (and selected (TT:IrrigationPipeP (cdr selected))
           (= (cdr (assoc 0 (entget (car selected)))) "LINE"))
    (progn
      (setq entity (car selected) data (entget entity) a (assoc 10 data) b (assoc 11 data))
      (if (entmod (subst (cons 11 (cdr a)) b (subst (cons 10 (cdr b)) a data)))
        (princ "\nPipe direction reversed. Identity and metadata retained."))))
  (princ))

(defun C:TTNETWORKTOLERANCE (/ value)
  (TT:PrintValue "Current connectivity tolerance, drawing units" (TT:NetworkTolerance))
  (initget 6) (setq value (getdist "\nNew project tolerance <keep>: "))
  (if value (TT:ProjectSaveSection 'IRRIGATION_TOLERANCE value))
  (princ))

T
