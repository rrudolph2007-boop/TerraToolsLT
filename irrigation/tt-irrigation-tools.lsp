;;; Metric input adapter uses the same tested US customary calculation core.
(defun C:TTHYDRAULICMETRIC (/ length flow diameter c rise loss result)
  (initget 6) (setq length (getreal "\nPipe length, meters: "))
  (if length (progn (initget 4) (setq flow (getreal "\nFlow, liters/second: "))))
  (if flow (progn (initget 6) (setq diameter (getreal "\nActual inside diameter, mm: "))))
  (if diameter
    (progn
      (initget 6) (setq c (getreal "\nHazen-Williams C <150>: ")) (if (null c) (setq c 150.0))
      (setq rise (getreal "\nElevation rise, meters <0>: ")) (if (null rise) (setq rise 0.0))
      (initget 4) (setq loss (getreal "\nEquipment loss, kPa <0>: ")) (if (null loss) (setq loss 0.0))
      (setq result (TT:HydraulicPipeResult (TT:ConvertLength length 'METERS 'FEET) (TT:FlowLPSToGPM flow)
        (TT:ConvertLength diameter 'MILLIMETERS 'INCHES) c (TT:ConvertLength rise 'METERS 'FEET) (TT:PressureKPaToPSI loss)))
      (if result
        (progn
          (TT:PrintValue "Velocity, m/s" (TT:ConvertLength (TT:DataValue result 'VELOCITY_FPS) 'FEET 'METERS))
          (TT:PrintValue "Friction, kPa" (* (TT:DataValue result 'FRICTION_LOSS_PSI) 6.894757293168))
          (TT:PrintValue "Total loss, kPa" (* (TT:DataValue result 'TOTAL_LOSS_PSI) 6.894757293168))))))
  (princ))

(defun TT:CoverageCreate (item / metadata data point radius sweep rotation layer entity)
  (setq metadata (cdr item) data (entget (car item)) point (trans (cdr (assoc 10 data)) (car item) 0)
        radius (cdr (assoc 'COVERAGE_RADIUS metadata)) sweep (cdr (assoc 'COVERAGE_SWEEP metadata))
        rotation (TT:SafeNumber (cdr (assoc 50 data)) 0.0) layer (TT:EnsureLayer 'IRR_COVERAGE))
  (if (and layer (numberp radius) (> radius 0) (numberp sweep) (> sweep 0) (<= sweep 360)
    (or (null (assoc 210 data)) (equal (cdr (assoc 210 data)) '(0.0 0.0 1.0) 1e-8)))
    (progn
      (setq entity (entmakex (append (list (cons 0 (if (= sweep 360) "CIRCLE" "ARC")) (cons 8 layer)
        (cons 10 point) (cons 40 radius))
        (if (< sweep 360) (list (cons 50 rotation) (cons 51 (+ rotation (* pi (/ sweep 180.0)))))))))
      (if (and entity (TT:SmartAttach entity (TT:ProjectCurrent) "IRRIGATION" "COVERAGE"
            (cdr (assoc 'ENTITY_UUID metadata)) (cdr (assoc 'WORK_AREA_ID metadata)))) entity
        (progn (if entity (entdel entity)) nil)))))

(defun TT:CoverageRefresh (head items / created item)
  (if (setq created (TT:CoverageCreate head))
    (foreach item items
      (if (and (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "COVERAGE")
        (equal (cdr (assoc 'CATALOG_ID (cdr item))) (cdr (assoc 'ENTITY_UUID (cdr head)))))
        (entdel (car item)))))
  created)

(defun C:TTIRRIGATIONCOVERAGE (/ item record radius sweep rotation metadata data unit)
  (setq item (TT:SelectSmartEntity "\nSelect spray head or rotor: "))
  (if (and item (member (cdr (assoc 'OBJECT_TYPE (cdr item))) '("SPRAY_HEAD" "ROTOR")))
    (progn
      (setq record (TT:IrrigationFind (TT:IrrigationPalette (TT:ProjectCurrent)) (cdr (assoc 'CATALOG_ID (cdr item))))
        unit (TT:DrawingUnitName) radius (if (and unit record) (TT:ConvertLength (TT:DataValue record 'RADIUS_FT) 'FEET unit)))
      (TT:PrintValue "Catalog radius in drawing units" radius)
      (initget 6) (setq sweep (getdist "\nCoverage radius <catalog value>: ")) (if sweep (setq radius sweep))
      (if (and (numberp radius) (> radius 0))
        (progn
          (initget 6) (setq sweep (getreal "\nCoverage sweep degrees <360>: ")) (if (null sweep) (setq sweep 360.0))
          (setq rotation (getangle "\nStart direction <keep>: ") data (entget (car item)))
          (if (<= sweep 360)
            (progn
              (setq metadata (TT:SmartMetadataPut (cdr item) 'COVERAGE_RADIUS radius)
                    metadata (TT:SmartMetadataPut metadata 'COVERAGE_SWEEP sweep))
              (if rotation (entmod (subst (cons 50 rotation) (assoc 50 data) data)))
              (if (TT:SetEntityXData (car item) metadata)
                (TT:CoverageRefresh (cons (car item) metadata) (TT:SmartScan))))
            (princ "\nSweep cannot exceed 360 degrees."))))))
  (princ))

(defun C:TTUPDATECOVERAGE (/ items item count)
  (setq items (TT:SmartScan) count 0)
  (foreach item items
    (if (and (member (cdr (assoc 'OBJECT_TYPE (cdr item))) '("SPRAY_HEAD" "ROTOR"))
      (assoc 'COVERAGE_RADIUS (cdr item)) (TT:CoverageRefresh item items)) (setq count (1+ count))))
  (TT:PrintValue "Coverage graphics refreshed" count) (princ))

(defun TT:DripAreaDemand (area row-spacing emitter-spacing emitter-gph)
  (if (and (numberp area) (> area 0) (numberp row-spacing) (> row-spacing 0)
    (numberp emitter-spacing) (> emitter-spacing 0) (numberp emitter-gph) (>= emitter-gph 0))
    (/ (* (fix (+ 0.999999 (/ area (* row-spacing emitter-spacing)))) emitter-gph) 60.0)))

(defun C:TTDRIPAREA (/ project selection entity area row-spacing emitter-spacing flow pressure station metadata)
  (setq project (TT:ProjectCurrent) selection (if project (entsel "\nSelect untagged closed drip boundary: ")))
  (if (and selection (setq entity (car selection)) (not (TT:GetEntityXData entity)) (setq area (TT:EntityArea entity)))
    (progn
      (initget 6) (setq row-spacing (getdist "\nRow spacing, drawing units: "))
      (if row-spacing (progn (initget 6) (setq emitter-spacing (getdist "\nEmitter spacing, drawing units: "))))
      (if emitter-spacing (progn (initget 4) (setq flow (getreal "\nEmitter flow, gallons/hour: "))))
      (if flow (progn (initget 4) (setq pressure (getreal "\nRequired inlet pressure, psi: "))))
      (if pressure
        (progn
          (setq station (getstring T "\nStation: ") flow (TT:DripAreaDemand area row-spacing emitter-spacing flow)
            metadata (TT:SmartMetadata project "IRRIGATION" "DRIP_AREA" nil (TT:ActiveWorkArea project))
            metadata (append metadata (list (cons 'FLOW_GPM flow) (cons 'PRESSURE_PSI pressure))))
          (if (/= station "") (setq metadata (append metadata (list (cons 'STATION station)))))
          (if (TT:SetEntityXData entity metadata)
            (progn (TT:PrintValue "Calculated design demand, gpm" flow)
              (princ "\nConnect the directed inlet pipe to the boundary's first vertex. Recalculate if area or spacing changes.")))))))
  (princ))
T
