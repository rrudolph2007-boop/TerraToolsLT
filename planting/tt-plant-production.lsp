;;; Project planting controls and density-derived quantities.
(defun TT:PlantDensityQuantity (area record / density unit drawing-unit factor)
  (setq density (TT:DataValue record 'DENSITY_PER_AREA) unit (TT:DataValue record 'DENSITY_AREA_UNIT)
        drawing-unit (TT:DrawingUnitName))
  (if (and (numberp area) (>= area 0) (numberp density) (> density 0)
           (member unit '(FEET METERS)) drawing-unit)
    (progn (setq factor (TT:ConvertLength 1.0 drawing-unit unit))
      (fix (+ 0.999999 (* area factor factor density))))))

(defun C:TTDENSITYAREA (/ *error* record updated density unit selection project entity old)
  (defun *error* (message) (TT:ReportError "TTDENSITYAREA" message))
  (setq project (TT:ProjectCurrent) record (if project (TT:PlantSelectProjectRecord)))
  (if (and record (TT:DrawingUnitName))
    (progn
      (initget 6) (setq density (getreal "\nPlants per square unit <cancel>: "))
      (if density
        (progn
          (initget "Feet Meters") (setq unit (getkword "\nArea unit [Feet/Meters] <Feet>: "))
          (setq selection (entsel "\nSelect untagged closed planting boundary: "))
          (if (and selection (TT:PolylineClosedP (setq entity (car selection))) (not (TT:GetEntityXData entity)))
            (progn
              (setq updated (TT:DataPut record 'DENSITY_PER_AREA density)
                    updated (TT:DataPut updated 'DENSITY_AREA_UNIT (if (= unit "Meters") 'METERS 'FEET)))
              (if (TT:PlantPaletteStoreRecord updated record)
                (if (TT:SmartAttach entity project "PLANTING" "PLANT_AREA_DENSITY"
                      (TT:DataValue record 'PROJECT_PLANT_ID) (TT:ActiveWorkArea project))
                  (princ "\nDensity area created. Density belongs to this Project Plant variant.")
                  (TT:PlantPaletteStoreRecord record updated))))
            (princ "\nChoose an untagged closed polyline. Existing metadata is preserved."))))))
  (princ))

(defun C:TTPLANTSYMBOLS (/ record updated scale item data id block count key)
  (setq record (TT:PlantSelectProjectRecord))
  (if record
    (progn
      (initget 6) (setq scale (getreal "\nProject symbol scale <keep>: "))
      (setq updated (if scale (TT:DataPut record 'SYMBOL_SCALE scale) record))
      (if (or (null scale) (TT:PlantPaletteStoreRecord updated record))
        (progn
          (setq block (TT:PlantEnsureSymbol updated) id (TT:DataValue updated 'PROJECT_PLANT_ID) count 0)
          (if block
            (progn
              (command-s "_.UNDO" "_Begin")
              (foreach item (TT:PlantInstanceItems)
                (if (equal id (cdr (assoc 'CATALOG_ID (cdr item))))
                  (progn
                    (setq data (entget (car item)) data (subst (cons 2 block) (assoc 2 data) data))
                    (if scale (foreach key '(41 42 43) (setq data (subst (cons key scale) (assoc key data) data))))
                    (if (entmod data) (setq count (1+ count))))))
              (command-s "_.UNDO" "_End") (TT:PrintValue "Symbols refreshed" count)))))))
  (princ))

(defun C:TTCOUNTWORKAREA (/ project record rows row)
  (setq project (TT:ProjectCurrent) record (if project (TT:SelectWorkAreaRecord project)))
  (if record
    (progn
      (TT:PrintValue "Work Area" (TT:DataValue record 'NAME))
      (setq rows (TT:PlantScheduleRows (TT:DataValue record 'WORK_AREA_ID)))
      (foreach row rows (TT:PrintValue (TT:DataValue row 'CODE) (TT:DataValue row 'QUANTITY)))
      (TT:PrintValue "All module objects" (length (TT:WorkAreaAssignedItems (TT:DataValue record 'WORK_AREA_ID))))))
  (princ))
T
