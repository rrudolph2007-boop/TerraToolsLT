;;; TerraTools LT - Project preferences and logical layer roles.

(setq *TT:DefaultPreferenceSetName* "TT_DEFAULT"
      *TT:PreferencesSchemaVersion* 1
      *TT:PreferencesLastError* nil
      *TT:LayerRoles*
        '(TREE SHRUB GROUNDCOVER PLANT_LABEL PLANT_SCHEDULE HELPER_NPLT))

(defun TT:PreferencesSetError (message)
  (setq *TT:PreferencesLastError* message)
  nil
)

(defun TT:PreferencesLastError ()
  *TT:PreferencesLastError*
)

(defun TT:ProjectUnitSystem (units / normalized)
  (if (eq (type units) 'STR)
    (setq normalized (strcase units))
    (setq normalized ""))
  (cond
    ((member normalized
      '("IMPERIAL" "INCH" "INCHES" "FOOT" "FEET" "YARD" "YARDS"
        "ARCHITECTURAL"))
      "Imperial")
    ((member normalized
      '("METRIC" "MM" "MILLIMETER" "MILLIMETERS" "CM" "CENTIMETER"
        "CENTIMETERS" "M" "METER" "METERS" "METRE" "METRES"))
      "Metric")
    (T nil))
)

(defun TT:BaseLayerPreferences ()
  (list
    (list 'TREE
          (cons 'NAME "TT-TREE")
          (cons 'COLOR 3)
          (cons 'LINETYPE "Continuous")
          (cons 'PLOT T))
    (list 'SHRUB
          (cons 'NAME "TT-SHRUB")
          (cons 'COLOR 94)
          (cons 'LINETYPE "Continuous")
          (cons 'PLOT T))
    (list 'GROUNDCOVER
          (cons 'NAME "TT-GROUNDCOVER")
          (cons 'COLOR 82)
          (cons 'LINETYPE "Continuous")
          (cons 'PLOT T))
    (list 'PLANT_LABEL
          (cons 'NAME "TT-PLANT-LABEL")
          (cons 'COLOR 2)
          (cons 'LINETYPE "Continuous")
          (cons 'PLOT T))
    (list 'PLANT_SCHEDULE
          (cons 'NAME "TT-PLANT-SCHEDULE")
          (cons 'COLOR 7)
          (cons 'LINETYPE "Continuous")
          (cons 'PLOT T))
    (list 'HELPER_NPLT
          (cons 'NAME "TT-HELPER-NPLT")
          (cons 'COLOR 8)
          (cons 'LINETYPE "Continuous")
          (cons 'PLOT nil)))
)

(defun TT:DefaultPreferences (project-units / text-height)
  (if (equal (TT:ProjectUnitSystem project-units) "Metric")
    (setq text-height 2.5)
    (setq text-height 0.1))
  (list
    'TT_PREFERENCES
    (cons 'SCHEMA_VERSION *TT:PreferencesSchemaVersion*)
    (cons 'PREFERENCE_SET_NAME *TT:DefaultPreferenceSetName*)
    (cons 'ANNOTATION_TEXT_HEIGHT text-height)
    (cons 'NUMERIC_PRECISION 2)
    (cons 'CURRENCY_SYMBOL "$")
    (cons 'LAYERS (TT:DefaultLayerPreferences)))
)

(defun TT:PreferencesValue (preferences key / pair)
  (if (and (eq (type preferences) 'LIST)
           (eq (type (cdr preferences)) 'LIST))
    (setq pair (assoc key (cdr preferences)))
    (setq pair nil))
  (if pair (cdr pair) nil)
)

(defun TT:PreferencesPut (preferences key value / fields old new)
  (setq fields (cdr preferences)
        old (assoc key fields)
        new (cons key value))
  (if old
    (setq fields (subst new old fields))
    (setq fields (append fields (list new))))
  (cons (car preferences) fields)
)

(defun TT:LayerValue (layer-record key / pair)
  (if (and (eq (type layer-record) 'LIST)
           (eq (type (cdr layer-record)) 'LIST))
    (setq pair (assoc key (cdr layer-record)))
    (setq pair nil))
  (if pair (cdr pair) nil)
)

(defun TT:LayerPut (layer-record key value / fields old new)
  (setq fields (cdr layer-record)
        old (assoc key fields)
        new (cons key value))
  (if old
    (setq fields (subst new old fields))
    (setq fields (append fields (list new))))
  (cons (car layer-record) fields)
)

(defun TT:ValidLayerNameP (name / result)
  (if (and (eq (type name) 'STR) (not (equal name "")))
    (progn
      (setq result (vl-catch-all-apply 'snvalid (list name 0)))
      (if (vl-catch-all-error-p result) nil result))
    nil)
)

(defun TT:ValidateLayerRecord (role record / name color linetype plot)
  (setq name (TT:LayerValue record 'NAME)
        color (TT:LayerValue record 'COLOR)
        linetype (TT:LayerValue record 'LINETYPE)
        plot (TT:LayerValue record 'PLOT))
  (cond
    ((not (eq (car record) role))
      (TT:PreferencesSetError "A logical layer role is malformed."))
    ((not (assoc 'NAME (cdr record)))
      (TT:PreferencesSetError "A layer name is missing."))
    ((not (TT:ValidLayerNameP name))
      (TT:PreferencesSetError (strcat "Invalid layer name: " name)))
    ((not (assoc 'COLOR (cdr record)))
      (TT:PreferencesSetError (strcat "Layer color is missing for " name ".")))
    ((or (not (eq (type color) 'INT)) (< color 1) (> color 255))
      (TT:PreferencesSetError (strcat "Layer color is invalid for " name ".")))
    ((not (assoc 'LINETYPE (cdr record)))
      (TT:PreferencesSetError (strcat "Linetype is missing for " name ".")))
    ((or (not (eq (type linetype) 'STR)) (equal linetype ""))
      (TT:PreferencesSetError (strcat "Linetype is invalid for " name ".")))
    ((not (assoc 'PLOT (cdr record)))
      (TT:PreferencesSetError (strcat "Plot intent is missing for " name ".")))
    ((not (or (eq plot T) (null plot)))
      (TT:PreferencesSetError (strcat "Plot intent is invalid for " name ".")))
    (T T))
)

(defun TT:ValidatePreferencesWorker
  (preferences / set-name text-height precision currency layers roles record valid)
  (setq *TT:PreferencesLastError* nil)
  (cond
    ((or (not (eq (type preferences) 'LIST))
         (not (eq (car preferences) 'TT_PREFERENCES)))
      (TT:PreferencesSetError "The stored TerraTools preferences are malformed."))
    ((/= (TT:PreferencesValue preferences 'SCHEMA_VERSION)
         *TT:PreferencesSchemaVersion*)
      (TT:PreferencesSetError "The preference schema is not supported."))
    (T
      (setq set-name (TT:PreferencesValue preferences 'PREFERENCE_SET_NAME)
            text-height (TT:PreferencesValue preferences 'ANNOTATION_TEXT_HEIGHT)
            precision (TT:PreferencesValue preferences 'NUMERIC_PRECISION)
            currency (TT:PreferencesValue preferences 'CURRENCY_SYMBOL)
            layers (TT:PreferencesValue preferences 'LAYERS))
      (cond
        ((or (not (eq (type set-name) 'STR)) (equal set-name ""))
          (TT:PreferencesSetError "The preference-set name is missing or invalid."))
        ((or (not (numberp text-height)) (<= text-height 0.0))
          (TT:PreferencesSetError "Annotation text height must be greater than zero."))
        ((or (not (eq (type precision) 'INT))
             (< precision 0)
             (> precision 8))
          (TT:PreferencesSetError "Numeric precision must be an integer from 0 through 8."))
        ((or (not (eq (type currency) 'STR))
             (equal currency "")
             (> (strlen currency) 8))
          (TT:PreferencesSetError "Currency symbol must contain 1 through 8 characters."))
        ((not (eq (type layers) 'LIST))
          (TT:PreferencesSetError "The stored layer preferences are malformed."))
        (T
          (setq roles *TT:LayerRoles* valid T)
          (while (and roles valid)
            (setq record (assoc (car roles) layers))
            (if (or (null record)
                    (not (TT:ValidateLayerRecord (car roles) record)))
              (setq valid nil))
            (setq roles (cdr roles)))
          valid))))
)

(defun TT:ValidatePreferences (preferences / result)
  (setq *TT:PreferencesLastError* nil
        result
          (vl-catch-all-apply
            'TT:ValidatePreferencesWorker
            (list preferences)))
  (if (vl-catch-all-error-p result)
    (TT:PreferencesSetError "The stored TerraTools preferences are malformed.")
    result)
)

(defun TT:PreferencesProjectError ()
  (if (TT:ProjectLastError)
    (TT:PreferencesSetError (TT:ProjectLastError))
    (TT:PreferencesSetError "An active TerraTools project is required."))
)

(defun TT:LoadPreferences (/ project stored preferences unit-system)
  (setq *TT:PreferencesLastError* nil
        project (TT:ProjectCurrent))
  (if (null project)
    (TT:PreferencesProjectError)
    (progn
      (setq unit-system
        (TT:ProjectUnitSystem (TT:ProjectValue project 'UNITS)))
      (if (null unit-system)
        (TT:PreferencesSetError
          "Project units must identify an Imperial or Metric system.")
        (progn
          (setq stored (assoc 'PREFERENCES (cdr project)))
          (if stored
            (setq preferences (cdr stored))
            (setq preferences
              (TT:DefaultPreferences (TT:ProjectValue project 'UNITS))))
          (if (TT:ValidatePreferences preferences) preferences nil))))
  )
)

(defun TT:SavePreferences (preferences / project updated)
  (setq *TT:PreferencesLastError* nil)
  (cond
    ((not (TT:ValidatePreferences preferences)) nil)
    ((null (setq project (TT:ProjectCurrent)))
      (TT:PreferencesProjectError))
    ((null (TT:ProjectUnitSystem (TT:ProjectValue project 'UNITS)))
      (TT:PreferencesSetError
        "Project units must identify an Imperial or Metric system."))
    (T
      (setq updated
        (TT:ProjectWithValue project 'PREFERENCES preferences))
      (if (TT:ProjectSave updated *TT:CurrentProjectPath*)
        (progn
          (setq *TT:CurrentProject* updated)
          T)
        (TT:PreferencesSetError (TT:ProjectLastError)))))
)

(defun TT:GetActivePreferenceSet (/ preferences)
  (setq preferences (TT:LoadPreferences))
  (if preferences
    (TT:PreferencesValue preferences 'PREFERENCE_SET_NAME)
    nil)
)

(defun TT:GetPreference (key / project preferences units)
  (if (eq key 'UNITS)
    (progn
      (setq project (TT:ProjectCurrent))
      (if project
        (progn
          (setq units
            (TT:ProjectUnitSystem (TT:ProjectValue project 'UNITS)))
          (if units
            units
            (TT:PreferencesSetError
              "Project units must identify an Imperial or Metric system.")))
        (TT:PreferencesProjectError)))
    (progn
      (setq preferences (TT:LoadPreferences))
      (if preferences (TT:PreferencesValue preferences key) nil)))
)

(defun TT:SetPreference (key value / preferences updated)
  (if (eq key 'UNITS)
    (TT:PreferencesSetError
      "Project units are authoritative and cannot be changed through preferences.")
    (progn
      (setq preferences (TT:LoadPreferences))
      (if preferences
        (progn
          (setq updated (TT:PreferencesPut preferences key value))
          (TT:SavePreferences updated))
        nil)))
)

(defun TT:GetLayerRecordForRole (role / preferences layers record alias)
  (setq preferences (TT:LoadPreferences))
  (if preferences
    (progn
      (setq layers (TT:PreferencesValue preferences 'LAYERS))
      (setq alias (cdr (assoc role '((PLANT_TREE . TREE) (PLANT_SHRUB . SHRUB)
                                    (PLANT_GROUNDCOVER . GROUNDCOVER) (HELPER_NONPLOT . HELPER_NPLT)))))
      (if alias (setq role alias))
      (if (setq record (assoc role layers)) record (TT:ModuleLayerDefault role)))
    nil)
)

(defun TT:GetLayerForRole (role / record)
  (setq record (TT:GetLayerRecordForRole role))
  (if record (TT:LayerValue record 'NAME) nil)
)

(defun TT:SetLayerForRole (role name / preferences layers record updated-record)
  (setq preferences (TT:LoadPreferences))
  (cond
    ((null preferences) nil)
    ((not (or (member role *TT:LayerRoles*) (TT:ModuleLayerDefault role)))
      (TT:PreferencesSetError "Unknown TerraTools logical layer role."))
    ((not (TT:ValidLayerNameP name))
      (TT:PreferencesSetError (strcat "Invalid layer name: " name)))
    (T
      (setq layers (TT:PreferencesValue preferences 'LAYERS)
            record (TT:GetLayerRecordForRole role)
            updated-record (TT:LayerPut record 'NAME name)
            layers (if (assoc role layers) (subst updated-record (assoc role layers) layers)
                     (append layers (list updated-record)))
            preferences (TT:PreferencesPut preferences 'LAYERS layers))
      (TT:SavePreferences preferences)))
)

(defun TT:EnsureLayerFromRecord (record / name color linetype plot data result)
  (setq name (TT:LayerValue record 'NAME)
        color (TT:LayerValue record 'COLOR)
        linetype (TT:LayerValue record 'LINETYPE)
        plot (TT:LayerValue record 'PLOT))
  (cond
    ((not (TT:ValidLayerNameP name))
      (TT:PreferencesSetError (strcat "Invalid layer name: " name)))
    ((tblsearch "LAYER" name) name)
    ((not (tblsearch "LTYPE" linetype))
      (TT:PreferencesSetError
        (strcat "Linetype is not loaded: " linetype)))
    (T
      (setq data
        (list '(0 . "LAYER")
              '(100 . "AcDbSymbolTableRecord")
              '(100 . "AcDbLayerTableRecord")
              (cons 2 name)
              (cons 70 0)
              (cons 62 color)
              (cons 6 linetype)
              (cons 290 (if plot 1 0)))
        result (vl-catch-all-apply 'entmake (list data)))
      (if (or (vl-catch-all-error-p result) (null result))
        (TT:PreferencesSetError (strcat "Could not create layer: " name))
        name)))
)

(defun TT:EnsureLayer (role / record)
  (setq record (TT:GetLayerRecordForRole role))
  (cond
    ((null record)
      (if (null *TT:PreferencesLastError*)
        (TT:PreferencesSetError "Unknown TerraTools logical layer role."))
      nil)
    (T (TT:EnsureLayerFromRecord record)))
)

(defun TT:EnsureStandardLayers (/ preferences layers roles record valid)
  (setq preferences (TT:LoadPreferences))
  (if (null preferences)
    nil
    (progn
      (setq layers (TT:PreferencesValue preferences 'LAYERS)
            roles *TT:LayerRoles*
            valid T)
      (while (and roles valid)
        (setq record (assoc (car roles) layers))
        (if (null (TT:EnsureLayerFromRecord record))
          (setq valid nil))
        (setq roles (cdr roles)))
      valid))
)

(defun TT:StandardLayersExistP (/ preferences layers roles record exists)
  (setq preferences (TT:LoadPreferences))
  (if (null preferences)
    nil
    (progn
      (setq layers (TT:PreferencesValue preferences 'LAYERS)
            roles *TT:LayerRoles*
            exists T)
      (while (and roles exists)
        (setq record (assoc (car roles) layers))
        (if (not (tblsearch "LAYER" (TT:LayerValue record 'NAME)))
          (setq exists nil))
        (setq roles (cdr roles)))
      exists))
)

(defun TT:LayerRoleLabel (role)
  (cond
    ((eq role 'TREE) "Tree")
    ((eq role 'SHRUB) "Shrub")
    ((eq role 'GROUNDCOVER) "Groundcover")
    ((eq role 'PLANT_LABEL) "Plant label")
    ((eq role 'PLANT_SCHEDULE) "Plant schedule")
    ((eq role 'HELPER_NPLT) "Helper nonplot")
    (T "Unknown"))
)

(defun TT:LayerKeywordRole (keyword)
  (cond
    ((equal keyword "Tree") 'TREE)
    ((equal keyword "Shrub") 'SHRUB)
    ((equal keyword "Groundcover") 'GROUNDCOVER)
    ((equal keyword "Plant-Label") 'PLANT_LABEL)
    ((equal keyword "Plant-Schedule") 'PLANT_SCHEDULE)
    ((equal keyword "Helper-Nonplot") 'HELPER_NPLT)
    (T nil))
)

(defun TT:PrintLayerPreferencesFromPreferences
  (preferences / layers roles record plot-intent)
  (setq layers (TT:PreferencesValue preferences 'LAYERS)
        roles *TT:LayerRoles*)
  (princ "\nTerraTools logical layer mappings")
  (while roles
    (setq record (assoc (car roles) layers)
          plot-intent (if (TT:LayerValue record 'PLOT) "Plot" "Nonplot"))
    (princ (strcat "\n  "
                   (TT:LayerRoleLabel (car roles))
                   " -> "
                   (TT:LayerValue record 'NAME)
                   " | color "
                   (itoa (TT:LayerValue record 'COLOR))
                   " | "
                   (TT:LayerValue record 'LINETYPE)
                   " | "
                   plot-intent))
    (setq roles (cdr roles)))
  (princ)
)

(defun TT:PrintLayerPreferences (/ preferences)
  (setq preferences (TT:LoadPreferences))
  (if preferences
    (TT:PrintLayerPreferencesFromPreferences preferences)
    (TT:PreferencesPrintError))
)

(defun TT:PreferencesPrintError ()
  (if *TT:PreferencesLastError*
    (princ (strcat "\nTerraTools: " *TT:PreferencesLastError*)))
  (princ)
)

(defun TT:PreferencesPrintInfo (/ preferences project unit-system)
  (setq preferences (TT:LoadPreferences))
  (if preferences
    (progn
      (setq project *TT:CurrentProject*
            unit-system
              (TT:ProjectUnitSystem (TT:ProjectValue project 'UNITS)))
      (princ "\nTerraTools preferences")
      (TT:PrintValue "Active preference set"
        (TT:PreferencesValue preferences 'PREFERENCE_SET_NAME))
      (TT:PrintValue "Project units" (TT:ProjectValue project 'UNITS))
      (TT:PrintValue "Unit system" unit-system)
      (TT:PrintValue "Annotation text height"
        (TT:PreferencesValue preferences 'ANNOTATION_TEXT_HEIGHT))
      (TT:PrintValue "Numeric precision"
        (TT:PreferencesValue preferences 'NUMERIC_PRECISION))
      (TT:PrintValue "Currency symbol"
        (TT:PreferencesValue preferences 'CURRENCY_SYMBOL))
      (TT:PrintLayerPreferencesFromPreferences preferences))
    (TT:PreferencesPrintError))
  (princ)
)

(defun TT:PreferencesCommandGeneral
  (/ preferences project text-height precision currency updated)
  (setq preferences (TT:LoadPreferences))
  (if preferences
    (progn
      (setq project *TT:CurrentProject*)
      (TT:PrintValue "Project units (authoritative)"
        (TT:ProjectValue project 'UNITS))
      (princ "\nProject units are display-only in TTPREFERENCES.")
      (TT:PrintValue "Current annotation text height"
        (TT:PreferencesValue preferences 'ANNOTATION_TEXT_HEIGHT))
      (setq text-height
        (getreal "\nNew annotation text height <keep current>: "))
      (TT:PrintValue "Current numeric precision"
        (TT:PreferencesValue preferences 'NUMERIC_PRECISION))
      (setq precision
        (getint "\nNew numeric precision 0-8 <keep current>: "))
      (TT:PrintValue "Current currency symbol"
        (TT:PreferencesValue preferences 'CURRENCY_SYMBOL))
      (setq currency
        (getstring T "\nNew currency symbol <keep current>: "))
      (setq updated preferences)
      (if text-height
        (setq updated
          (TT:PreferencesPut updated 'ANNOTATION_TEXT_HEIGHT text-height)))
      (if precision
        (setq updated
          (TT:PreferencesPut updated 'NUMERIC_PRECISION precision)))
      (if (not (equal currency ""))
        (setq updated
          (TT:PreferencesPut updated 'CURRENCY_SYMBOL currency)))
      (if (equal updated preferences)
        (princ "\nGeneral preferences were not changed.")
        (if (TT:SavePreferences updated)
          (princ "\nTerraTools general preferences saved.")
          (TT:PreferencesPrintError))))
    (TT:PreferencesPrintError))
  (princ)
)

(defun TT:PreferencesCommandLayers (/ preferences keyword role old-name new-name)
  (setq preferences (TT:LoadPreferences))
  (if preferences
    (progn
      (TT:PrintLayerPreferencesFromPreferences preferences)
      (initget
        "Tree Shrub Groundcover Plant-Label Plant-Schedule Helper-Nonplot")
      (setq keyword
        (getkword
          "\nLogical role [Tree/Shrub/Groundcover/Plant-Label/Plant-Schedule/Helper-Nonplot] <cancel>: "))
      (if keyword
        (progn
          (setq role (TT:LayerKeywordRole keyword)
                old-name (TT:GetLayerForRole role))
          (setq new-name
            (getstring T
              (strcat "\nNew physical layer name for "
                      (TT:LayerRoleLabel role)
                      " <"
                      old-name
                      ">: ")))
          (if (equal new-name "")
            (princ "\nLayer mapping was not changed.")
            (if (TT:SetLayerForRole role new-name)
              (princ
                (strcat "\nLayer mapping saved: "
                        (TT:LayerRoleLabel role)
                        " -> "
                        new-name))
              (TT:PreferencesPrintError))))
        (princ "\nLayer mapping was not changed.")))
    (TT:PreferencesPrintError))
  (princ)
)

(defun TT:PreferencesCommandReset (/ project answer defaults)
  (setq project (TT:ProjectCurrent))
  (if (null project)
    (progn
      (TT:PreferencesProjectError)
      (TT:PreferencesPrintError))
    (progn
      (initget "Yes No")
      (setq answer
        (getkword "\nReset project preferences to TT_DEFAULT? [Yes/No] <No>: "))
      (if (equal answer "Yes")
        (progn
          (setq defaults
            (TT:DefaultPreferences (TT:ProjectValue project 'UNITS)))
          (if (TT:SavePreferences defaults)
            (princ "\nProject preferences reset to TT_DEFAULT.")
            (TT:PreferencesPrintError)))
        (princ "\nPreference reset canceled."))))
  (princ)
)

(defun C:TTPREFERENCES (/ *error* option)
  (defun *error* (message)
    (TT:ReportError "TTPREFERENCES" message))
  (initget "Info General Layers Reset")
  (setq option
    (getkword "\nTerraTools preferences [Info/General/Layers/Reset] <Info>: "))
  (if (null option) (setq option "Info"))
  (cond
    ((equal option "Info") (TT:PreferencesPrintInfo))
    ((equal option "General") (TT:PreferencesCommandGeneral))
    ((equal option "Layers") (TT:PreferencesCommandLayers))
    ((equal option "Reset") (TT:PreferencesCommandReset)))
  (princ)
)

(defun C:TTLAYERS (/ *error* option undo-open)
  (defun *error* (message)
    (if undo-open
      (progn
        (command-s "_.UNDO" "_End")
        (setq undo-open nil)))
    (TT:ReportError "TTLAYERS" message))
  (initget "Create Info")
  (setq option
    (getkword "\nTerraTools layers [Create/Info] <Info>: "))
  (if (null option) (setq option "Info"))
  (cond
    ((equal option "Create")
      (if (null (TT:LoadPreferences))
        (TT:PreferencesPrintError)
        (progn
          (command-s "_.UNDO" "_Begin")
          (setq undo-open T)
          (if (TT:EnsureStandardLayers)
            (princ "\nTerraTools standard layers are present.")
            (TT:PreferencesPrintError))
          (command-s "_.UNDO" "_End")
          (setq undo-open nil))))
    ((equal option "Info") (TT:PrintLayerPreferences)))
  (princ)
)

T
