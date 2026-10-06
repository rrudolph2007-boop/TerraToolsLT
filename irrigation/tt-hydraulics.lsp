;;; TerraTools LT - Pure irrigation hydraulic calculations in US customary units.

(setq *TT:HydraulicsModuleLoaded* T)

(defun TT:PipeInsideDiameter (metadata / actual)
  ;; All stored pipe diameters are inches. Legacy DIAMETER_IN remains a fallback.
  (setq actual (assoc 'INSIDE_DIAMETER metadata))
  (if actual (cdr actual) (cdr (assoc 'DIAMETER_IN metadata))))

(defun TT:PSIToFeetHead (psi) (if (numberp psi) (* psi 2.31)))

(defun TT:HydraulicVelocityFPS (flow-gpm diameter-in)
  (if (and (numberp flow-gpm) (>= flow-gpm 0.0)
           (numberp diameter-in) (> diameter-in 0.0))
    (/ (* 0.4085 flow-gpm) (* diameter-in diameter-in))
    nil))

(defun TT:HazenWilliamsHeadLossFT (length-ft flow-gpm diameter-in c-factor)
  (if (and (numberp length-ft) (>= length-ft 0.0)
           (numberp flow-gpm) (>= flow-gpm 0.0)
           (numberp diameter-in) (> diameter-in 0.0)
           (numberp c-factor) (> c-factor 0.0))
    ;; 4.52 yields psi for gpm/inches/feet. Convert that pressure to feet of head.
    (/ (* 2.31 4.52 length-ft (expt flow-gpm 1.85))
       (* (expt c-factor 1.85) (expt diameter-in 4.87)))
    nil))

(defun TT:FeetHeadToPSI (feet) (if (numberp feet) (/ feet 2.31) nil))
(defun TT:ElevationToPSI (feet) (if (numberp feet) (/ feet 2.31) nil))

(defun TT:HydraulicPipeResult (length flow diameter c elevation equipment-loss
                              / head friction velocity)
  (setq head (TT:HazenWilliamsHeadLossFT length flow diameter c)
        velocity (TT:HydraulicVelocityFPS flow diameter))
  (if (and head velocity (numberp elevation) (numberp equipment-loss))
    (progn
      (setq friction (TT:FeetHeadToPSI head))
      (list 'HYDRAULIC_RESULT
            (cons 'FLOW_GPM flow) (cons 'LENGTH_FT length)
            (cons 'DIAMETER_IN diameter) (cons 'C_FACTOR c)
            (cons 'VELOCITY_FPS velocity) (cons 'FRICTION_LOSS_PSI friction)
            (cons 'ELEVATION_LOSS_PSI (TT:ElevationToPSI elevation))
            (cons 'EQUIPMENT_LOSS_PSI equipment-loss)
            (cons 'TOTAL_LOSS_PSI (+ friction (TT:ElevationToPSI elevation)
                                     equipment-loss))))))

(defun TT:HydraulicChooseDiameter (length flow c diameters max-velocity max-loss
                                  / diameter result selected)
  (while (and diameters (null selected))
    (setq diameter (car diameters)
          result (TT:HydraulicPipeResult length flow diameter c 0.0 0.0))
    (if (and result
             (<= (TT:DataValue result 'VELOCITY_FPS) max-velocity)
             (<= (TT:DataValue result 'FRICTION_LOSS_PSI) max-loss))
      (setq selected diameter))
    (setq diameters (cdr diameters)))
  selected)

(defun C:TTHYDRAULIC (/ length flow diameter c elevation loss result)
  (setq length (getreal "\nPipe length, feet: ")
        flow (if length (getreal "\nFlow, gpm: "))
        diameter (if flow (getreal "\nInside diameter, inches: "))
        c (if diameter (getreal "\nHazen-Williams C factor <150>: ")))
  (if (and diameter (null c)) (setq c 150.0))
  (setq elevation (if c (getreal "\nElevation rise, feet <0>: ")))
  (if (and c (null elevation)) (setq elevation 0.0))
  (setq loss (if c (getreal "\nEquipment loss, psi <0>: ")))
  (if (and c (null loss)) (setq loss 0.0))
  (setq result (if loss (TT:HydraulicPipeResult length flow diameter c elevation loss)))
  (if result
    (progn
      (princ (strcat "\nVelocity: " (rtos (TT:DataValue result 'VELOCITY_FPS) 2 2) " ft/s"))
      (princ (strcat "\nFriction loss: " (rtos (TT:DataValue result 'FRICTION_LOSS_PSI) 2 2) " psi"))
      (princ (strcat "\nTotal loss: " (rtos (TT:DataValue result 'TOTAL_LOSS_PSI) 2 2) " psi")))
    (if length (princ "\nHydraulic inputs are invalid.")))
  (princ))

T
