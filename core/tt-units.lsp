;;; TerraTools LT - Central linear, area, and spacing unit conversion.

(setq *TT:UnitsModuleLoaded* T)

(defun TT:UnitName (value / text)
  (if (eq (type value) 'STR) (setq text (strcase (vl-string-trim " \t" value))))
  (cond
    ((member text '("IN" "INCH" "INCHES")) 'INCHES)
    ((member text '("FT" "FOOT" "FEET" "IMPERIAL" "ARCHITECTURAL")) 'FEET)
    ((member text '("MM" "MILLIMETER" "MILLIMETERS")) 'MILLIMETERS)
    ((member text '("CM" "CENTIMETER" "CENTIMETERS")) 'CENTIMETERS)
    ((member text '("M" "METER" "METERS" "METRE" "METRES" "METRIC")) 'METERS)
    (T nil)))

(defun TT:INSUNITSName (/ code)
  (setq code (getvar "INSUNITS"))
  (cond ((= code 1) 'INCHES) ((= code 2) 'FEET)
        ((= code 4) 'MILLIMETERS) ((= code 5) 'CENTIMETERS)
        ((= code 6) 'METERS) (T nil)))

(defun TT:DrawingUnitName (/ project raw explicit ins system)
  (setq project (if (and (boundp '*TT:CurrentProject*) *TT:CurrentProject*)
                  *TT:CurrentProject* (TT:ProjectCurrent))
        raw (if project (TT:ProjectValue project 'UNITS))
        explicit (TT:UnitName raw)
        ins (TT:INSUNITSName)
        system (TT:ProjectUnitSystem raw))
  (cond
    ((and explicit
          (not (member (strcase raw) '("IMPERIAL" "ARCHITECTURAL" "METRIC")))) explicit)
    ((and ins (or (and (equal system "Imperial") (member ins '(INCHES FEET)))
                  (and (equal system "Metric") (member ins '(MILLIMETERS CENTIMETERS METERS))))) ins)
    (explicit explicit)
    (ins ins)
    (T nil)))

(defun TT:UnitMetersFactor (unit)
  (cond ((eq unit 'INCHES) 0.0254) ((eq unit 'FEET) 0.3048)
        ((eq unit 'MILLIMETERS) 0.001) ((eq unit 'CENTIMETERS) 0.01)
        ((eq unit 'METERS) 1.0) (T nil)))

(defun TT:ConvertLength (value from-unit to-unit / from-factor to-factor)
  (setq from-factor (TT:UnitMetersFactor from-unit)
        to-factor (TT:UnitMetersFactor to-unit))
  (if (and (numberp value) from-factor to-factor)
    (/ (* value from-factor) to-factor)
    nil))

(defun TT:ConvertArea (value from-unit to-unit / factor)
  (setq factor (TT:ConvertLength 1.0 from-unit to-unit))
  (if (and (numberp value) factor) (* value factor factor) nil))

(defun TT:DimensionNumberEnd (text / index character)
  (setq index 1)
  (while (and (<= index (strlen text))
              (member (setq character (substr text index 1))
                      '("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "." "+" "-")))
    (setq index (1+ index)))
  index)

(defun TT:ParseDimension (value / text split number unit-text unit)
  ;; Returns (numeric-value unit-or-nil). A missing unit means drawing units.
  (cond
    ((numberp value) (list value nil))
    ((and (eq (type value) 'STR)
          (not (equal (setq text (vl-string-trim " \t" value)) "")))
      (setq split (TT:DimensionNumberEnd text))
      (if (= split 1)
        nil
        (progn
          (setq number (atof (substr text 1 (1- split)))
                unit-text (vl-string-trim " \t" (substr text split))
                unit (if (not (equal unit-text "")) (TT:UnitName unit-text)))
          (if (and (not (equal unit-text "")) (null unit)) nil
            (list number unit)))))
    (T nil)))

(defun TT:DimensionToDrawingUnits (value / parsed number source target)
  (setq parsed (TT:ParseDimension value))
  (if parsed
    (progn
      (setq number (car parsed) source (cadr parsed) target (TT:DrawingUnitName))
      (cond ((null source) number)
            ((null target) nil)
            (T (TT:ConvertLength number source target))))
    nil))

(defun TT:DrawingLengthToFeet (value / unit)
  (setq unit (TT:DrawingUnitName))
  (if unit (TT:ConvertLength value unit 'FEET) nil))

(defun TT:DrawingAreaToSquareFeet (value / unit)
  (setq unit (TT:DrawingUnitName))
  (if unit (TT:ConvertArea value unit 'FEET) nil))

(defun C:TTUNITS (/ unit)
  (setq unit (TT:DrawingUnitName))
  (princ "\nTerraTools unit status")
  (TT:PrintValue "Project units" (if (TT:ProjectCurrent)
    (TT:ProjectValue *TT:CurrentProject* 'UNITS) nil))
  (TT:PrintValue "INSUNITS" (getvar "INSUNITS"))
  (TT:PrintValue "Resolved drawing unit"
    (cond ((eq unit 'INCHES) "Inches") ((eq unit 'FEET) "Feet")
          ((eq unit 'MILLIMETERS) "Millimeters") ((eq unit 'CENTIMETERS) "Centimeters")
          ((eq unit 'METERS) "Meters") (T nil)))
  (princ))

T
