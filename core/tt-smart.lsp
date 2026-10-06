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

(defun TT:PolylinePoints (entity / data item points)
  (setq data (entget entity))
  (foreach item data
    (if (= (car item) 10)
      (setq points (cons (cdr item) points))))
  (reverse points)
)

(defun TT:PolygonAreaFromPoints (points / area index first current next)
  (setq area 0.0 index 0 first (car points))
  (while (< index (length points))
    (setq current (nth index points)
          next (if (= index (1- (length points))) first (nth (1+ index) points))
          area (+ area (- (* (car current) (cadr next))
                          (* (car next) (cadr current))))
          index (1+ index)))
  (/ (abs area) 2.0)
)

(defun TT:EntityArea (entity)
  (if (TT:PolylineClosedP entity)
    (TT:PolygonAreaFromPoints (TT:PolylinePoints entity))
    nil)
)

(defun TT:EntityLength (entity / data type points total index)
  (setq data (entget entity) type (cdr (assoc 0 data)))
  (cond
    ((equal type "LINE") (distance (cdr (assoc 10 data)) (cdr (assoc 11 data))))
    ((equal type "LWPOLYLINE")
      (setq points (TT:PolylinePoints entity) total 0.0 index 0)
      (while (< index (1- (length points)))
        (setq total (+ total (distance (nth index points) (nth (1+ index) points)))
              index (1+ index)))
      (if (TT:PolylineClosedP entity)
        (setq total (+ total (distance (car points) (car (last points))))))
      total)
    (T nil))
)

(defun TT:SelectSmartEntity (prompt / selection entity metadata)
  (setq selection (entsel prompt))
  (if selection
    (progn
      (setq entity (car selection) metadata (TT:GetEntityXData entity))
      (if metadata (cons entity metadata) nil))
    nil)
)

T
