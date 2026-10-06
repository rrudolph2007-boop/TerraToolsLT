;;; DEVELOPMENT ONLY: creates 10,000 entities. Use a disposable drawing.
;;; Not part of TTDEVSMOKE or TTQACHECK. Deletes only entities created here.
(defun TT:RunBenchmark (/ *error* made target count entity start items row elapsed id)
  (defun *error* (message)
    (foreach entity made (if (entget entity) (entdel entity)))
    (TT:ReportError "Development benchmark" message))
  (setq count 0)
  (foreach target '(1000 5000 10000)
    (while (< count target)
      (setq count (1+ count) entity (entmakex (list '(0 . "POINT") (cons 10 (list (float count) 0.0 0.0)))))
      (if entity
        (progn
          (setq made (cons entity made))
          (TT:SetEntityXData entity (list (cons 'ENTITY_UUID (TT:GenerateUUID))
            '(PROJECT_UUID . "DEVELOPMENT-BENCHMARK") '(MODULE . "CORE") '(OBJECT_TYPE . "BENCHMARK"))))))
    (setq start (getvar "MILLISECS") items (TT:SmartScan) elapsed (- (getvar "MILLISECS") start))
    (princ (strcat "\nBENCHMARK objects=" (itoa target) " scan_ms=" (itoa elapsed) " found=" (itoa (length items))))
    (setq start (getvar "MILLISECS") row (TT:ReconcileScan nil) elapsed (- (getvar "MILLISECS") start))
    (princ (strcat " reconcile_ms=" (itoa elapsed))))
  (foreach entity made (if (entget entity) (entdel entity)))
  (setq start (getvar "MILLISECS") items (TT:PlantDatabaseSearch "Quercus alba"))
  (princ (strcat "\nBENCHMARK WFO Quercus alba search_ms=" (itoa (- (getvar "MILLISECS") start)) " matches=" (itoa (length items))))
  (princ))
T
