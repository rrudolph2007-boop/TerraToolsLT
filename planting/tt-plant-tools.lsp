;;; Bounded polygon fill and selection tools using project-owned identities.
(defun TT:PlantFillSeparatedP (point points spacing / valid existing)
  (setq valid T)
  (while (and points valid)
    (setq existing (car points) points (cdr points))
    (if (< (distance point existing) spacing) (setq valid nil)))
  valid)

(defun C:TTPLANTFILL (/ *error* project record selected boundary spacing requested polygon bounds low high count attempts limit points point entity undo-open made seed *TT:RandomSeed*)
  (defun *error* (message)
    (foreach entity made (if (entget entity) (entdel entity)))
    (if undo-open (command-s "_.UNDO" "_End"))
    (TT:ReportError "TTPLANTFILL" message))
  (setq project (TT:ProjectCurrent) record (if project (TT:PlantSelectProjectRecord)))
  (if record
    (progn
      (setq selected (entsel "\nSelect closed XY planting boundary: ") boundary (car selected))
      (cond
        ((null boundary) nil)
        ((not (and (TT:PolylineClosedP boundary) (TT:PolylinePlanarXYP boundary)))
          (princ "\nUse a closed WCS XY polyline. Tilted boundaries are not supported for fill."))
        (T
          (initget 6) (setq spacing (getdist "\nMinimum separation in drawing units: "))
          (if spacing
            (progn
              (initget 6) (setq requested (getint "\nMaximum plants (1-2000): "))
              (if (and requested (<= requested 2000))
                (progn
                  (initget 6) (setq seed (getint "\nRepeatable scatter seed <1>: ")
                                   *TT:RandomSeed* (if seed seed 1))
                  (setq polygon (TT:PolylineSampleBoundary boundary (/ spacing 100.0)) bounds (TT:PointsBounds polygon))
                  (if bounds
                    (progn
                      (setq low (car bounds) high (cadr bounds) count 0 attempts 0 limit (* requested 100))
                      (command-s "_.UNDO" "_Begin") (setq undo-open T)
                      (while (and (< count requested) (< attempts limit))
                        (setq point (list (+ (car low) (* (TT:RandomUnit) (- (car high) (car low))))
                                          (+ (cadr low) (* (TT:RandomUnit) (- (cadr high) (cadr low)))) (caddr low))
                              attempts (1+ attempts))
                        (if (and (TT:PointInPolygon point polygon)
                                 (> (TT:PointBoundaryDistance point polygon) (/ spacing 50.0))
                                 (TT:PlantFillSeparatedP point points spacing))
                          (if (setq entity (TT:PlantCreateInstance project record point nil))
                            (setq points (cons point points) made (cons entity made) count (1+ count))
                            (setq attempts limit))))
                      (command-s "_.UNDO" "_End") (setq undo-open nil made nil)
                      (princ (strcat "\nPlaced " (itoa count) " plants. Requested " (itoa requested)
                        "; attempts " (itoa attempts) ". Separation and boundary limits may prevent a full count.")))
                    (princ "\nBoundary could not be sampled within the safety limit.")))
                (if requested (princ "\nUse a count from 1 to 2000.")))))))))
  (princ))

(defun C:TTSELECTSIMILAR (/ selected data selection item)
  (setq selected (TT:SelectSmartEntity "\nSelect a TerraTools object to match: "))
  (if selected
    (progn
      (setq data (cdr selected) selection (ssadd))
      (foreach item (TT:SmartScan)
        (if (and (equal (cdr (assoc 'PROJECT_UUID data)) (cdr (assoc 'PROJECT_UUID (cdr item))))
                 (equal (cdr (assoc 'MODULE data)) (cdr (assoc 'MODULE (cdr item))))
                 (equal (cdr (assoc 'OBJECT_TYPE data)) (cdr (assoc 'OBJECT_TYPE (cdr item))))
                 (equal (cdr (assoc 'CATALOG_ID data)) (cdr (assoc 'CATALOG_ID (cdr item)))))
          (ssadd (car item) selection)))
      (sssetfirst nil selection)
      (princ (strcat "\nSelected " (itoa (sslength selection)) " matching objects."))))
  (princ))

(defun C:TTCOUNTSELECTED (/ selection index data count)
  (setq selection (ssget) index 0 count 0)
  (if selection
    (progn
      (while (< index (sslength selection))
        (setq data (TT:GetEntityXData (ssname selection index)) index (1+ index))
        (if (equal (cdr (assoc 'OBJECT_TYPE data)) "PLANT_INSTANCE") (setq count (1+ count))))
      (princ (strcat "\nSelected plant instances: " (itoa count)))))
  (princ))

(defun C:TTUNASSIGNWORKAREA (/ selection index entity data count)
  (setq selection (ssget "_:L") index 0 count 0)
  (if selection
    (progn
      (while (< index (sslength selection))
        (setq entity (ssname selection index) data (TT:GetEntityXData entity) index (1+ index))
        (if (and data (assoc 'WORK_AREA_ID data)
                 (TT:SetEntityXData entity (vl-remove (assoc 'WORK_AREA_ID data) data)))
          (setq count (1+ count))))
      (princ (strcat "\nRemoved Work Area assignment from " (itoa count) " objects."))))
  (princ))

T
