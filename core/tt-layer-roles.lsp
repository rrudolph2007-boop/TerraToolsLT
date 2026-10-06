;;; Additive roles. Existing schema-1 layer mappings remain authoritative.
(defun TT:ModuleLayerRoles ()
  '(SITE_NOTE SITE_LABEL SITE_CONCEPT DETAIL DETAIL_CALLOUT LIGHT_FIXTURE LIGHT_WIRE
    LIGHT_TRANSFORMER LIGHT_LABEL LIGHT_SCHEDULE IRR_HEAD IRR_COVERAGE IRR_MAINLINE
    IRR_LATERAL IRR_VALVE IRR_CONTROLLER IRR_DRIP IRR_LABEL IRR_SCHEDULE WORK_AREA))

(defun TT:ModuleLayerDefault (role / name)
  (if (member role (TT:ModuleLayerRoles))
    (progn
      (setq name (strcat "TT-" (vl-string-translate "_" "-" (vl-symbol-name role))))
      (list role (cons 'NAME name) (cons 'COLOR (if (eq role 'IRR_COVERAGE) 8 7))
        '(LINETYPE . "Continuous") (cons 'PLOT (not (member role '(IRR_COVERAGE WORK_AREA))))))))
(defun TT:DefaultLayerPreferences ()
  (append (TT:BaseLayerPreferences) (mapcar 'TT:ModuleLayerDefault (TT:ModuleLayerRoles))))
T
