;;; TerraTools LT - Shared ordinary-entity smart-object helpers.

(setq *TT:KnownModules* '("PLANTING" "SITE" "DETAILS" "LIGHTING" "IRRIGATION" "CORE" "SCHEDULES"))

(defun TT:SmartMetadata (project module object-type catalog-id work-area-id)
  (append
    (list (cons 'ENTITY_UUID (TT:GenerateUUID))
          (cons 'PROJECT_UUID (TT:ProjectValue project 'PROJECT_UUID))
          (cons 'MODULE module)
          (cons 'OBJECT_TYPE object-type))
    (if catalog-id (list (cons 'CATALOG_ID catalog-id)) nil)
    (if work-area-id (list (cons 'WORK_AREA_ID work-area-id)) nil))
)

(defun TT:SmartMetadataPut (metadata key value / old new)
  (setq old (assoc key metadata) new (cons key value))
  (if old (subst new old metadata) (append metadata (list new)))
)

(defun TT:SmartScan (/ selection index entity metadata result)
  (setq selection
    (ssget "_X" (list (list -3 (list *TT:XDataApp*)))))
  (if selection
    (progn
      (setq index 0)
      (while (< index (sslength selection))
        (setq entity (ssname selection index)
              metadata (TT:GetEntityXData entity))
        (if metadata (setq result (cons (cons entity metadata) result)))
        (setq index (1+ index)))))
  (reverse result)
)

(defun TT:SmartFilter (items module object-type / result item metadata)
  (foreach item items
    (setq metadata (cdr item))
    (if (and (or (null module) (equal module (cdr (assoc 'MODULE metadata))))
             (or (null object-type)
                 (equal object-type (cdr (assoc 'OBJECT_TYPE metadata)))))
      (setq result (cons item result))))
  (reverse result)
)

(defun TT:SmartFindByUUID (uuid / item found)
  (foreach item (TT:SmartScan)
    (if (equal uuid (cdr (assoc 'ENTITY_UUID (cdr item))))
      (setq found item)))
  found
)

(defun TT:SmartAttach (entity project module object-type catalog-id work-area-id)
  (TT:SetEntityXData
    entity (TT:SmartMetadata project module object-type catalog-id work-area-id))
)

(defun TT:EnsureSymbolBlock (name style / made)
  (if (tblsearch "BLOCK" name)
    name
    (progn
      (setq made
        (entmake
          (list '(0 . "BLOCK") (cons 2 name) '(70 . 0)
                (list 10 0.0 0.0 0.0))))
      (if made
        (progn
          (cond
            ((eq style 'SQUARE)
              (entmake
                (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity")
                      '(100 . "AcDbPolyline") '(90 . 4) '(70 . 1)
                      '(10 -0.5 -0.5) '(10 0.5 -0.5)
                      '(10 0.5 0.5) '(10 -0.5 0.5))))
            ((eq style 'TRIANGLE)
              (entmake
                (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity")
                      '(100 . "AcDbPolyline") '(90 . 3) '(70 . 1)
                      '(10 0.0 0.6) '(10 -0.52 -0.3) '(10 0.52 -0.3))))
            (T
              (entmake (list '(0 . "CIRCLE") (list 10 0.0 0.0 0.0) '(40 . 0.5)))
              (entmake (list '(0 . "LINE") (list 10 -0.5 0.0 0.0)
                             (list 11 0.5 0.0 0.0)))
              (entmake (list '(0 . "LINE") (list 10 0.0 -0.5 0.0)
                             (list 11 0.0 0.5 0.0)))))
          (entmake '((0 . "ENDBLK")))
          name)
        nil)))
)

(defun TT:CreateInsert (block point layer scale / entity)
  (setq entity
    (entmakex
      (list '(0 . "INSERT") (cons 2 block) (cons 10 point)
            (cons 8 layer) (cons 41 scale) (cons 42 scale) (cons 43 scale)
            '(50 . 0.0))))
  entity
)

(defun TT:CreateText (point height text layer / entity)
  (entmakex
    (list '(0 . "TEXT") (cons 8 layer) (cons 10 point)
          (cons 40 height) (cons 1 text) '(50 . 0.0) '(7 . "STANDARD")))
)

(defun TT:CreateLine (start end layer)
  (entmakex
    (list '(0 . "LINE") (cons 8 layer) (cons 10 start) (cons 11 end)))
)

(defun TT:PolylineClosedP (entity / data flags)
  (setq data (entget entity) flags (cdr (assoc 70 data)))
  (and (equal (cdr (assoc 0 data)) "LWPOLYLINE")
       flags (= 1 (logand flags 1)))
)

(defun TT:PolylineVertices (entity / data item current vertices)
  ;; Each result item is (point bulge). A vertex bulge describes the segment
  ;; from that vertex to the next vertex, including the closing segment.
  (setq data (entget entity))
  (foreach item data
    (cond
      ((= (car item) 10)
        (if current (setq vertices (cons current vertices)))
        (setq current (list (cdr item) 0.0)))
      ((and current (= (car item) 42))
        (setq current (list (car current) (cdr item))))))
  (if current (setq vertices (cons current vertices)))
  (reverse vertices))

(defun TT:PolylinePoints (entity / vertex points)
  (foreach vertex (TT:PolylineVertices entity)
    (setq points (cons (car vertex) points)))
  (reverse points))

(defun TT:BulgeIncludedAngle (bulge)
  (* 4.0 (atan bulge)))

(defun TT:BulgeSegmentRadius (start end bulge / chord)
  (setq chord (distance start end))
  (if (and (> chord 0.0) (numberp bulge) (not (equal bulge 0.0 1e-14)))
    (/ (* chord (+ 1.0 (* bulge bulge))) (* 4.0 (abs bulge)))
    nil))

(defun TT:BulgeSegmentLength (start end bulge / radius theta)
  (if (or (null bulge) (equal bulge 0.0 1e-14))
    (distance start end)
    (progn
      (setq radius (TT:BulgeSegmentRadius start end bulge)
            theta (TT:BulgeIncludedAngle bulge))
      (if radius (* radius (abs theta)) 0.0))))

(defun TT:BulgeSegmentSignedArea (start end bulge / cross radius theta arc-area)
  ;; Green's theorem gives the chord term plus the signed circular segment.
  (setq cross (* 0.5 (- (* (car start) (cadr end))
                           (* (car end) (cadr start)))))
  (if (or (null bulge) (equal bulge 0.0 1e-14))
    cross
    (progn
      (setq radius (TT:BulgeSegmentRadius start end bulge)
            theta (TT:BulgeIncludedAngle bulge)
            arc-area (if radius (* 0.5 radius radius (- theta (sin theta))) 0.0))
      (+ cross arc-area))))

(defun TT:BulgeSegmentPoint (start end bulge distance-on-segment
                            / length fraction chord midpoint offset center start-angle theta)
  (setq length (TT:BulgeSegmentLength start end bulge))
  (cond
    ((or (null length) (<= length 0.0)) start)
    ((or (null bulge) (equal bulge 0.0 1e-14))
      (setq fraction (max 0.0 (min 1.0 (/ distance-on-segment length))))
      (list (+ (car start) (* fraction (- (car end) (car start))))
            (+ (cadr start) (* fraction (- (cadr end) (cadr start))))
            0.0))
    (T
      (setq fraction (max 0.0 (min 1.0 (/ distance-on-segment length)))
            chord (distance start end)
            midpoint (list (/ (+ (car start) (car end)) 2.0)
                           (/ (+ (cadr start) (cadr end)) 2.0) 0.0)
            offset (/ (* chord (- 1.0 (* bulge bulge))) (* 4.0 bulge))
            center (polar midpoint (+ (angle start end) (/ pi 2.0)) offset)
            start-angle (angle center start)
            theta (TT:BulgeIncludedAngle bulge))
      (polar center (+ start-angle (* theta fraction))
             (TT:BulgeSegmentRadius start end bulge)))))

(defun TT:PolylineLengthFromVertices (vertices closed / total index current next limit)
  (setq total 0.0 index 0 limit (if closed (length vertices) (1- (length vertices))))
  (while (< index limit)
    (setq current (nth index vertices)
          next (if (= index (1- (length vertices))) (car vertices)
                 (nth (1+ index) vertices))
          total (+ total (TT:BulgeSegmentLength (car current) (car next)
                                                (cadr current)))
          index (1+ index)))
  total)

(defun TT:PolylineAreaFromVertices (vertices / total index current next)
  (setq total 0.0 index 0)
  (while (< index (length vertices))
    (setq current (nth index vertices)
          next (if (= index (1- (length vertices))) (car vertices)
                 (nth (1+ index) vertices))
          total (+ total (TT:BulgeSegmentSignedArea (car current) (car next)
                                                    (cadr current)))
          index (1+ index)))
  (abs total))

(defun TT:PolylinePointAtDistance (vertices closed requested / remaining index current next segment-length point limit)
  (setq remaining (max 0.0 requested) index 0
        limit (if closed (length vertices) (1- (length vertices))))
  (while (and (< index limit) (null point))
    (setq current (nth index vertices)
          next (if (= index (1- (length vertices))) (car vertices)
                 (nth (1+ index) vertices))
          segment-length (TT:BulgeSegmentLength (car current) (car next) (cadr current)))
    (if (<= remaining segment-length)
      (setq point (TT:BulgeSegmentPoint (car current) (car next) (cadr current) remaining))
      (setq remaining (- remaining segment-length) index (1+ index))))
  (if point point (if vertices (car (last vertices)) nil)))

(defun TT:EntityPointAtDistance (entity requested / data type length center radius angle-start sweep point a b fraction elevation)
  (setq data (entget entity) type (cdr (assoc 0 data)) length (TT:EntityLength entity)
        requested (if length (max 0.0 (min requested length))))
  (cond
    ((equal type "LINE")
      (setq a (cdr (assoc 10 data)) b (cdr (assoc 11 data))
            fraction (if (> length 0.0) (/ requested length) 0.0))
      (mapcar '(lambda (x y) (+ x (* fraction (- y x)))) a b))
    ((equal type "LWPOLYLINE")
      (setq point (TT:PolylinePointAtDistance (TT:PolylineVertices entity)
                                  (TT:PolylineClosedP entity) requested)
            elevation (cdr (assoc 38 data)))
      (if point (trans (list (car point) (cadr point) (if elevation elevation 0.0)) entity 0)))
    ((equal type "ARC")
      (setq center (cdr (assoc 10 data)) radius (cdr (assoc 40 data))
            angle-start (cdr (assoc 50 data))
            sweep (TT:ArcSweep angle-start (cdr (assoc 51 data))))
      (if (> length 0.0)
        (trans (polar center (+ angle-start (* sweep (/ requested length))) radius) entity 0)))
    (T nil)))

(defun TT:PolygonAreaFromPoints (points / vertices point)
  (foreach point points (setq vertices (cons (list point 0.0) vertices)))
  (TT:PolylineAreaFromVertices (reverse vertices)))

(defun TT:ArcSweep (start-angle end-angle / sweep)
  (setq sweep (- end-angle start-angle))
  (while (< sweep 0.0) (setq sweep (+ sweep (* 2.0 pi))))
  sweep)

(defun TT:EntityArea (entity / data type radius)
  (setq data (entget entity) type (cdr (assoc 0 data)))
  (cond
    ((and (equal type "LWPOLYLINE") (TT:PolylineClosedP entity))
      (TT:PolylineAreaFromVertices (TT:PolylineVertices entity)))
    ((equal type "CIRCLE")
      (setq radius (cdr (assoc 40 data)))
      (* pi radius radius))
    (T nil)))

(defun TT:EntityLength (entity / data type radius)
  (setq data (entget entity) type (cdr (assoc 0 data)))
  (cond
    ((equal type "LINE") (distance (cdr (assoc 10 data)) (cdr (assoc 11 data))))
    ((equal type "LWPOLYLINE")
      (TT:PolylineLengthFromVertices (TT:PolylineVertices entity)
                                     (TT:PolylineClosedP entity)))
    ((equal type "ARC")
      (setq radius (cdr (assoc 40 data)))
      (* radius (TT:ArcSweep (cdr (assoc 50 data)) (cdr (assoc 51 data)))))
    ((equal type "CIRCLE") (* 2.0 pi (cdr (assoc 40 data))))
    (T nil)))

(defun TT:SelectSmartEntity (prompt / selection entity metadata)
  (setq selection (entsel prompt))
  (if selection
    (progn
      (setq entity (car selection) metadata (TT:GetEntityXData entity))
      (if metadata (cons entity metadata) nil))
    nil)
)

T
