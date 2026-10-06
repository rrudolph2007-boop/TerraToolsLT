;;; WCS sampling and conservative planar containment for production helpers.
(setq *TT:GeometryModuleLoaded* T)

(defun TT:PointInPolygon (point polygon / inside a b x y)
  (setq inside nil x (car point) y (cadr point) b (last polygon))
  (foreach a polygon
    (if (and (not (eq (> (cadr a) y) (> (cadr b) y)))
             (< x (+ (car a) (* (- y (cadr a)) (/ (- (car b) (car a)) (- (cadr b) (cadr a)))))))
      (setq inside (not inside)))
    (setq b a))
  inside)

(defun TT:PointSegmentDistance (point a b / dx dy len2 fraction nearest)
  (setq dx (- (car b) (car a)) dy (- (cadr b) (cadr a)) len2 (+ (* dx dx) (* dy dy)))
  (setq fraction (if (> len2 0.0)
    (max 0.0 (min 1.0 (/ (+ (* (- (car point) (car a)) dx) (* (- (cadr point) (cadr a)) dy)) len2))) 0.0))
  (setq nearest (list (+ (car a) (* fraction dx)) (+ (cadr a) (* fraction dy))))
  (distance (list (car point) (cadr point)) nearest))

(defun TT:PointBoundaryDistance (point polygon / a b minimum value)
  (setq b (last polygon))
  (foreach a polygon
    (setq value (TT:PointSegmentDistance point a b))
    (if (or (null minimum) (< value minimum)) (setq minimum value))
    (setq b a))
  minimum)

(defun TT:PointsBounds (points / low high point)
  (if points
    (progn
      (setq low (car points) high low)
      (foreach point (cdr points)
        (setq low (mapcar 'min low point) high (mapcar 'max high point)))
      (list low high))))

(defun TT:PolylinePlanarXYP (entity / data normal)
  (setq data (entget entity) normal (cdr (assoc 210 data)))
  (and (= (cdr (assoc 0 data)) "LWPOLYLINE")
       (or (null normal) (equal normal '(0.0 0.0 1.0) 1e-10))))

(defun TT:PolylineSampleBoundary (entity tolerance / vertices a b remaining radius theta steps index fraction result elevation)
  ;; Sagitta of each chord <= tolerance; callers exclude that boundary band.
  (if (and (TT:PolylineClosedP entity) (TT:PolylinePlanarXYP entity) (> tolerance 0.0))
    (progn
      (setq vertices (TT:PolylineVertices entity) remaining vertices
            elevation (cdr (assoc 38 (entget entity))))
      (while remaining
        (setq a (car remaining) b (if (cdr remaining) (cadr remaining) (car vertices))
              radius (TT:BulgeSegmentRadius (car a) (car b) (cadr a))
              theta (abs (TT:BulgeIncludedAngle (cadr a)))
              steps (if radius (max 1 (fix (+ 1.0 (/ theta (sqrt (/ (* 8.0 tolerance) radius)))))) 1)
              index 0)
        (if (> steps 2000) (setq remaining nil result nil)
          (progn
            (while (< index steps)
              (setq fraction (/ (float index) steps)
                    result (cons (TT:BulgeSegmentPoint (car a) (car b) (cadr a)
                      (* fraction (TT:BulgeSegmentLength (car a) (car b) (cadr a)))) result)
                    index (1+ index)))
            (setq remaining (cdr remaining)))))
      (mapcar '(lambda (point) (list (car point) (cadr point) (if elevation elevation 0.0))) (reverse result)))))

T
