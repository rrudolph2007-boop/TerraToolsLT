;;; TerraTools LT - Fixture catalog, project palette, placement, circuits, and schedules.

(setq *TT:LightingModuleLoaded* T
      *TT:LightingMasterFileName* "terratools-lighting-master.dat")

(defun TT:LightingValue (record key) (TT:DataValue record key))

(defun TT:LightingMasterLoad (/ path data fixtures record ok ids id)
  (setq path (TT:StorageJoinPath (TT:StorageJoinPath *TT:Root* "data")
                                 *TT:LightingMasterFileName*)
        data (TT:StorageRead path) ok T)
  (if (and (eq (type data) 'LIST)
           (eq (car data) 'TERRATOOLS_LIGHTING_MASTER)
           (eq (type (TT:DataValue data 'FIXTURES)) 'LIST))
    (progn
      (setq fixtures (TT:DataValue data 'FIXTURES))
      (foreach record fixtures
        (setq id (TT:LightingValue record 'FIXTURE_ID))
        (if (or (not (eq (car record) 'FIXTURE_RECORD))
                (not (TT:ProjectNonEmptyStringP id)) (member id ids)
                (not (TT:ProjectNonEmptyStringP (TT:LightingValue record 'CODE)))
                (not (TT:ProjectNonEmptyStringP (TT:LightingValue record 'DESCRIPTION)))
                (not (numberp (TT:LightingValue record 'WATTAGE)))
                (< (TT:LightingValue record 'WATTAGE) 0.0)
                (not (numberp (TT:LightingValue record 'VOLTAGE)))
                (<= (TT:LightingValue record 'VOLTAGE) 0.0)
                (not (numberp (TT:LightingValue record 'UNIT_COST)))
                (< (TT:LightingValue record 'UNIT_COST) 0.0))
          (setq ok nil)
          (setq ids (cons id ids))))
      (if ok data nil))
    nil))

(defun TT:LightingLabel (record)
  (strcat (TT:LightingValue record 'CODE) " | "
          (TT:LightingValue record 'DESCRIPTION) " | "
          (rtos (TT:LightingValue record 'WATTAGE) 2 1) " W"))

(defun TT:LightingPalette (project / palette)
  (setq palette (TT:ProjectValue project 'LIGHTING_PALETTE))
  (if (eq (type palette) 'LIST) palette nil))

(defun TT:LightingFind (records id)
  (TT:DataFindByValue records 'FIXTURE_ID id))

(defun TT:LightingChooseProjectFixture (/ project records)
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (setq records (TT:LightingPalette project))
      (if records
        (TT:PromptNumberedRecord records 'TT:LightingLabel "Select fixture number")
        (princ "\nThe Project Fixture Palette is empty.")))
    (princ "\nA TerraTools project must be active.")))

(defun TT:LightingPaletteAdd (/ project master fixtures selected palette)
  (setq project (TT:ProjectCurrent) master (TT:LightingMasterLoad))
  (cond
    ((null project) (princ "\nA TerraTools project must be active."))
    ((null master) (princ "\nThe Master Fixture Catalog is missing or malformed."))
    (T
      (setq fixtures (TT:DataValue master 'FIXTURES)
            selected (TT:PromptNumberedRecord fixtures 'TT:LightingLabel
                                              "Select fixture number"))
      (if selected
        (progn
          (setq palette (TT:LightingPalette project))
          (if (TT:LightingFind palette (TT:LightingValue selected 'FIXTURE_ID))
            (princ "\nThat fixture is already in the Project Fixture Palette.")
            (if (TT:ProjectSaveSection 'LIGHTING_PALETTE (append palette (list selected)))
              (princ "\nFixture added to the Project Fixture Palette.")
              (princ "\nThe fixture palette could not be saved.")))))))
  (princ))

(defun TT:LightingPaletteEdit (/ project palette selected text value updated)
  (setq project (TT:ProjectCurrent) palette (if project (TT:LightingPalette project)))
  (if (and palette (setq selected (TT:PromptNumberedRecord palette 'TT:LightingLabel
                                                           "Select fixture number")))
    (progn
      (setq updated selected text (getstring T "\nProject fixture code <keep>: "))
      (if (not (equal text "")) (setq updated (TT:DataPut updated 'CODE text)))
      (setq text (getstring T "\nProject description <keep>: "))
      (if (not (equal text "")) (setq updated (TT:DataPut updated 'DESCRIPTION text)))
      (setq value (getreal "\nProject wattage <keep>: "))
      (if (and value (>= value 0.0)) (setq updated (TT:DataPut updated 'WATTAGE value)))
      (setq value (getreal "\nProject unit cost <keep>: "))
      (if (and value (>= value 0.0)) (setq updated (TT:DataPut updated 'UNIT_COST value)))
      (if (TT:ProjectSaveSection 'LIGHTING_PALETTE (subst updated selected palette))
        (princ "\nProject fixture record updated.")))
    (if project (princ "\nThe Project Fixture Palette is empty.")))
  (princ))

(defun TT:LightingPaletteRemove (/ project palette selected answer)
  (setq project (TT:ProjectCurrent) palette (if project (TT:LightingPalette project)))
  (if (and palette (setq selected (TT:PromptNumberedRecord palette 'TT:LightingLabel
                                                           "Select fixture number")))
    (progn
      (initget "Yes No")
      (setq answer (getkword "\nRemove this project fixture record? [Yes/No] <No>: "))
      (if (equal answer "Yes")
        (if (TT:ProjectSaveSection 'LIGHTING_PALETTE
              (TT:DataRemoveByValue palette 'FIXTURE_ID
                                    (TT:LightingValue selected 'FIXTURE_ID)))
          (princ "\nProject fixture record removed."))
        (princ "\nFixture removal canceled.")))
    (if project (princ "\nThe Project Fixture Palette is empty.")))
  (princ))

(defun TT:LightingList (/ project record)
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (princ "\nProject Fixture Palette")
      (if (TT:LightingPalette project)
        (foreach record (TT:LightingPalette project)
          (princ (strcat "\n  " (TT:LightingLabel record))))
        (princ "\n  (empty)")))
    (princ "\nA TerraTools project must be active."))
  (princ))

(defun C:TTLIGHTINGCLI (/ option)
  (initget "List Add Edit Remove Place Replace Info Wire Transformer Circuit Load Capacity VoltageDrop Schedule Verify")
  (setq option (getkword "\nLighting [List/Add/Edit/Remove/Place/Replace/Info/Wire/Transformer/Circuit/Load/Capacity/VoltageDrop/Schedule/Verify] <List>: "))
  (if (null option) (setq option "List"))
  (cond ((equal option "List") (TT:LightingList))
        ((equal option "Add") (TT:LightingPaletteAdd))
        ((equal option "Edit") (TT:LightingPaletteEdit))
        ((equal option "Remove") (TT:LightingPaletteRemove))
        ((equal option "Place") (C:TTPLACEFIXTURE))
        ((equal option "Replace") (C:TTREPLACEFIXTURE))
        ((equal option "Info") (C:TTLIGHTINGINFO))
        ((equal option "Wire") (C:TTLIGHTWIRE))
        ((equal option "Transformer") (C:TTTRANSFORMER))
        ((equal option "Circuit") (C:TTCIRCUITASSIGN))
        ((equal option "Load") (C:TTCIRCUITINFO))
        ((equal option "Capacity") (C:TTTRANSFORMERLOAD))
        ((equal option "VoltageDrop") (C:TTVOLTAGEDROP))
        ((equal option "Schedule") (C:TTLIGHTINGSCHEDULE))
        ((equal option "Verify") (C:TTVERIFYLIGHTING)))
  (princ))

(defun C:TTPLACEFIXTURE (/ project fixture point block layer entity metadata)
  (setq project (TT:ProjectCurrent) fixture (if project (TT:LightingChooseProjectFixture)))
  (if (and project fixture (setq point (getpoint "\nFixture insertion point: ")))
    (progn
      (setq block (TT:LightingValue fixture 'SYMBOL)
            layer (TT:EnsureLayer 'HELPER_NPLT))
      (if (and layer (TT:EnsureSymbolBlock block 'SQUARE)
               (setq entity (TT:CreateInsert block point layer 1.0)))
        (progn
          (setq metadata (TT:SmartMetadata project "LIGHTING" "FIXTURE"
                                           (TT:LightingValue fixture 'FIXTURE_ID) nil))
          (if (TT:SetEntityXData entity metadata)
            (princ "\nLighting fixture placed.")
            (progn (entdel entity) (princ "\nFixture placement failed.")))))))
  (princ))

(defun C:TTLIGHTWIRE (/ project a b layer entity)
  (setq project (TT:ProjectCurrent))
  (if (and project (setq a (getpoint "\nWire start: "))
           (setq b (getpoint a "\nWire end: "))
           (setq layer (TT:EnsureLayer 'HELPER_NPLT))
           (setq entity (TT:CreateLine a b layer)))
    (progn (TT:SmartAttach entity project "LIGHTING" "WIRE" nil nil)
           (princ "\nLighting wire created.")))
  (princ))

(defun C:TTTRANSFORMER (/ project point block layer entity kva metadata)
  (setq project (TT:ProjectCurrent))
  (if (and project (setq point (getpoint "\nTransformer insertion point: ")))
    (progn
      (setq kva (getreal "\nTransformer capacity in watts <300>: "))
      (if (null kva) (setq kva 300.0))
      (setq block "TT_LIGHT_TRANSFORMER" layer (TT:EnsureLayer 'HELPER_NPLT))
      (if (and (> kva 0.0) layer (TT:EnsureSymbolBlock block 'TRIANGLE)
               (setq entity (TT:CreateInsert block point layer 1.0)))
        (progn
          (setq metadata (TT:SmartMetadata project "LIGHTING" "TRANSFORMER" nil nil)
                metadata (TT:SmartMetadataPut metadata 'CAPACITY_WATTS kva))
          (TT:SetEntityXData entity metadata)
          (princ "\nTransformer placed."))
        (princ "\nTransformer capacity must be greater than zero."))))
  (princ))

(defun C:TTCIRCUITASSIGN (/ item circuit data)
  (setq item (TT:SelectSmartEntity "\nSelect lighting object: "))
  (if item
    (if (equal (cdr (assoc 'MODULE (cdr item))) "LIGHTING")
      (progn
        (setq circuit (getstring T "\nCircuit name: "))
        (if (not (equal circuit ""))
          (progn
            (setq data (TT:SmartMetadataPut (cdr item) 'CIRCUIT circuit))
            (TT:SetEntityXData (car item) data)
            (princ "\nCircuit assignment saved."))))
      (princ "\nThe selected object is not a lighting object.")))
  (princ))

(defun C:TTREPLACEFIXTURE (/ item fixture data entity-data block)
  (setq item (TT:SelectSmartEntity "\nSelect lighting fixture to replace: "))
  (if (and item (equal (cdr (assoc 'MODULE (cdr item))) "LIGHTING")
           (equal (cdr (assoc 'OBJECT_TYPE (cdr item))) "FIXTURE")
           (setq fixture (TT:LightingChooseProjectFixture)))
    (progn
      (setq block (TT:LightingValue fixture 'SYMBOL)
            entity-data (entget (car item)) data (cdr item))
      (if (and (TT:EnsureSymbolBlock block 'SQUARE) (assoc 2 entity-data)
               (entmod (subst (cons 2 block) (assoc 2 entity-data) entity-data)))
        (progn
          (setq data (TT:SmartMetadataPut data 'CATALOG_ID
                                          (TT:LightingValue fixture 'FIXTURE_ID)))
          (TT:SetEntityXData (car item) data)
          (princ "\nLighting fixture replaced."))))
    (if item (princ "\nThe selected object is not a TerraTools lighting fixture.")))
  (princ))

(defun C:TTLIGHTINGINFO (/ item data record)
  (setq item (TT:SelectSmartEntity "\nSelect lighting object: "))
  (if (and item (equal (cdr (assoc 'MODULE (cdr item))) "LIGHTING"))
    (progn
      (setq data (cdr item) record (TT:LightingFixtureRecordForMetadata data))
      (if record
        (progn (TT:PrintValue "Fixture code" (TT:LightingValue record 'CODE))
               (TT:PrintValue "Description" (TT:LightingValue record 'DESCRIPTION))
               (TT:PrintValue "Wattage" (TT:LightingValue record 'WATTAGE))))
      (TT:PrintValue "Object type" (cdr (assoc 'OBJECT_TYPE data)))
      (TT:PrintValue "Circuit" (cdr (assoc 'CIRCUIT data))))
    (princ "\nThe selected object is not a TerraTools lighting object."))
  (princ))

(defun C:TTCIRCUITINFO (/ circuit item data record count watts)
  (setq circuit (getstring T "\nCircuit name: ") count 0 watts 0.0)
  (if (not (equal circuit ""))
    (foreach item (TT:SmartFilter (TT:SmartScan) "LIGHTING" "FIXTURE")
      (setq data (cdr item))
      (if (equal circuit (cdr (assoc 'CIRCUIT data)))
        (progn
          (setq record (TT:LightingFixtureRecordForMetadata data))
          (if record
            (setq count (1+ count)
                  watts (+ watts (TT:LightingValue record 'WATTAGE)))))))
    )
  (if (not (equal circuit ""))
    (princ (strcat "\nCircuit " circuit ": " (itoa count) " fixture(s), "
                   (rtos watts 2 1) " connected watts.")))
  (princ))

(defun TT:LightingCircuitLoad (circuit / item data record watts)
  (setq watts 0.0)
  (foreach item (TT:SmartFilter (TT:SmartScan) "LIGHTING" "FIXTURE")
    (setq data (cdr item))
    (if (equal circuit (cdr (assoc 'CIRCUIT data)))
      (progn
        (setq record (TT:LightingFixtureRecordForMetadata data))
        (if record (setq watts (+ watts (TT:LightingValue record 'WATTAGE)))))))
  watts)

(defun TT:LightingTransformerCapacity (circuit / item metadata total)
  (setq total 0.0)
  (foreach item (TT:SmartFilter (TT:SmartScan) "LIGHTING" "TRANSFORMER")
    (setq metadata (cdr item))
    (if (equal circuit (cdr (assoc 'CIRCUIT metadata)))
      (setq total (+ total (TT:SafeNumber (cdr (assoc 'CAPACITY_WATTS metadata)) 0.0)))))
  total)

(defun C:TTTRANSFORMERLOAD (/ circuit load capacity spare)
  (setq circuit (getstring T "\nCircuit name: "))
  (if (not (equal circuit ""))
    (progn
      (setq load (TT:LightingCircuitLoad circuit)
            capacity (TT:LightingTransformerCapacity circuit)
            spare (- capacity load))
      (princ (strcat "\nCircuit " circuit
                     "\n  Connected load: " (rtos load 2 1) " W"
                     "\n  Assigned transformer capacity: " (rtos capacity 2 1) " W"
                     "\n  Spare capacity: " (rtos spare 2 1) " W"
                     "\n  Status: " (if (and (> capacity 0.0) (>= spare 0.0)) "PASS" "FAIL")))))
  (princ))

(defun TT:LightingAWGCircularMils (awg)
  (cond ((= awg 18) 1620.0) ((= awg 16) 2580.0) ((= awg 14) 4110.0)
        ((= awg 12) 6530.0) ((= awg 10) 10380.0) (T nil)))

(defun TT:LightingVoltageDrop (watts voltage one-way-length awg / current cmil)
  ;; Copper two-conductor estimate: Vd = 2 K I L / CM, K = 12.9 ohm-cmil/ft.
  (setq cmil (if (numberp awg) (TT:LightingAWGCircularMils awg)))
  (if (and (numberp watts) (>= watts 0.0) (numberp voltage) (> voltage 0.0)
           (numberp one-way-length) (>= one-way-length 0.0) cmil)
    (/ (* 2.0 12.9 (/ watts voltage) one-way-length) cmil)
    nil))

(defun C:TTVOLTAGEDROP (/ watts voltage length awg drop)
  (setq watts (getreal "\nConnected load, watts: ")
        voltage (if watts (getreal "\nSystem voltage: "))
        length (if voltage (getreal "\nOne-way conductor length, feet: "))
        awg (if length (getint "\nCopper conductor AWG [18/16/14/12/10]: "))
        drop (if awg (TT:LightingVoltageDrop watts voltage length awg)))
  (if drop
    (princ (strcat "\nEstimated voltage drop: " (rtos drop 2 2) " V ("
                   (rtos (* 100.0 (/ drop voltage)) 2 2) "%)."))
    (if watts (princ "\nVoltage-drop inputs or conductor size are invalid.")))
  (princ))

(defun TT:LightingFixtureRecordForMetadata (metadata / project)
  (setq project (if (and (boundp '*TT:CurrentProject*) *TT:CurrentProject*)
                  *TT:CurrentProject* (TT:ProjectCurrent)))
  (if project (TT:LightingFind (TT:LightingPalette project)
                               (cdr (assoc 'CATALOG_ID metadata)))))

(defun TT:LightingSummary (/ item metadata record key old rows)
  (foreach item (TT:SmartFilter (TT:SmartScan) "LIGHTING" "FIXTURE")
    (setq metadata (cdr item) record (TT:LightingFixtureRecordForMetadata metadata))
    (if record
      (progn
        (setq key (TT:LightingValue record 'FIXTURE_ID) old (assoc key rows))
        (if old
          (setq rows (subst (list key record (1+ (caddr old))) old rows))
          (setq rows (append rows (list (list key record 1))))))))
  rows)

(defun C:TTLIGHTINGSCHEDULE (/ rows point text row count watts cost height layer)
  (setq rows (TT:LightingSummary))
  (if (and rows (setq point (getpoint "\nLighting schedule insertion point: ")))
    (progn
      (setq text "LIGHTING SCHEDULE\\PCODE | DESCRIPTION | QTY | LOAD | COST")
      (foreach row rows
        (setq count (caddr row) watts (* count (TT:LightingValue (cadr row) 'WATTAGE))
              cost (* count (TT:SafeNumber (TT:LightingValue (cadr row) 'UNIT_COST) 0.0))
              text (strcat text "\\P" (TT:LightingValue (cadr row) 'CODE) " | "
                           (TT:LightingValue (cadr row) 'DESCRIPTION) " | " (itoa count)
                           " | " (rtos watts 2 1) " W | " (rtos cost 2 2))))
      (setq height (TT:GetPreference 'ANNOTATION_TEXT_HEIGHT)
            layer (TT:EnsureLayer 'PLANT_SCHEDULE))
      (if (not (numberp height)) (setq height 0.1))
      (if (and layer (TT:CreateMText point height (* height 70.0) text layer))
        (princ "\nLighting schedule created.")))
    (if (null rows) (princ "\nNo placed lighting fixtures were found.")))
  (princ))

(defun C:TTVERIFYLIGHTING (/ project item metadata record problems watts circuit checked load capacity)
  (setq project (TT:ProjectCurrent) problems 0)
  (if project
    (foreach item (TT:SmartFilter (TT:SmartScan) "LIGHTING" nil)
      (setq metadata (cdr item))
      (if (not (equal (cdr (assoc 'PROJECT_UUID metadata))
                      (TT:ProjectValue project 'PROJECT_UUID)))
        (progn (setq problems (1+ problems))
               (princ "\n  Lighting object belongs to another project.")))
      (if (equal (cdr (assoc 'OBJECT_TYPE metadata)) "FIXTURE")
        (progn
          (setq record (TT:LightingFixtureRecordForMetadata metadata))
          (if (null record)
            (progn (setq problems (1+ problems))
                   (princ "\n  Fixture has no Project Fixture Palette record."))
            (progn (setq watts (TT:LightingValue record 'WATTAGE))
                   (if (or (not (numberp watts)) (< watts 0.0))
                     (setq problems (1+ problems)))))
          (setq circuit (cdr (assoc 'CIRCUIT metadata)))
          (if (and circuit (not (member circuit checked)))
            (progn
              (setq checked (cons circuit checked)
                    load (TT:LightingCircuitLoad circuit)
                    capacity (TT:LightingTransformerCapacity circuit))
              (if (or (<= capacity 0.0) (> load capacity))
                (progn
                  (setq problems (1+ problems))
                  (princ (strcat "\n  Circuit " circuit
                                 " has no adequate assigned transformer capacity.")))))))))
    (princ "\nA TerraTools project must be active."))
  (if project (princ (strcat "\nLighting verification: "
                             (if (= problems 0) "PASS" (strcat "FAIL, " (itoa problems) " issue(s)")))))
  (princ))

T
