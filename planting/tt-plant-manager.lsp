;;; TerraTools LT - Project Plant Palette storage and command-line manager.

(setq *TT:PlantPaletteSchemaVersion* 1)

(defun TT:PlantPaletteValue (palette key / pair)
  (if (and (eq (type palette) 'LIST) (eq (type (cdr palette)) 'LIST))
    (setq pair (assoc key (cdr palette)))
    (setq pair nil))
  (if pair (cdr pair) nil)
)

(defun TT:PlantPaletteEmpty ()
  (list 'TT_PLANT_PALETTE
        (cons 'DATA_SCHEMA_VERSION *TT:PlantPaletteSchemaVersion*)
        (cons 'PLANTS nil))
)

(defun TT:PlantPaletteWithPlants (palette plants / fields old new)
  (setq fields (cdr palette)
        old (assoc 'PLANTS fields)
        new (cons 'PLANTS plants))
  (if old
    (setq fields (subst new old fields))
    (setq fields (append fields (list new))))
  (cons (car palette) fields)
)

(defun TT:PlantPaletteGetAllFromPalette (palette)
  (TT:PlantPaletteValue palette 'PLANTS)
)

(defun TT:PlantPaletteRecordValidate (record / category)
  (setq category (TT:PlantRecordValue record 'CATEGORY))
  (cond
    ((or (not (eq (type record) 'LIST))
         (not (eq (car record) 'PROJECT_PLANT)))
      (TT:PlantSetError "The Project Plant Palette contains a malformed record."))
    ((not (TT:PlantNonEmptyStringP
            (TT:PlantRecordValue record 'PROJECT_PLANT_ID)))
      (TT:PlantSetError "A Project Plant record has an invalid project plant ID."))
    ((not (TT:PlantNonEmptyStringP
            (TT:PlantRecordValue record 'MASTER_PLANT_ID)))
      (TT:PlantSetError "A Project Plant record has an invalid master plant ID."))
    ((not (member category *TT:PlantCategories*))
      (TT:PlantSetError "A Project Plant record has an invalid category."))
    ((not (TT:PlantNonEmptyStringP
            (TT:PlantRecordValue record 'BOTANICAL_NAME)))
      (TT:PlantSetError "A Project Plant record has an invalid botanical name."))
    ((not (TT:PlantNonEmptyStringP
            (TT:PlantRecordValue record 'COMMON_NAME)))
      (TT:PlantSetError "A Project Plant record has an invalid common name."))
    ((not (TT:PlantNonEmptyStringP
            (TT:PlantRecordValue record 'PLANT_CODE)))
      (TT:PlantSetError "A Project Plant record has a blank or invalid plant code."))
    ((not (TT:PlantOptionalStringP (TT:PlantRecordValue record 'SIZE)))
      (TT:PlantSetError "A Project Plant record has an invalid size."))
    ((not (TT:PlantSpacingP (TT:PlantRecordValue record 'SPACING)))
      (TT:PlantSetError "A Project Plant record has an invalid spacing value."))
    ((not (TT:PlantUnitCostP (TT:PlantRecordValue record 'UNIT_COST)))
      (TT:PlantSetError "A Project Plant record has an invalid unit cost."))
    ((not (TT:PlantOptionalStringP
            (TT:PlantRecordValue record 'SYMBOL_BLOCK)))
      (TT:PlantSetError "A Project Plant record has an invalid symbol block."))
    ((not (TT:PlantOptionalStringP (TT:PlantRecordValue record 'NOTES)))
      (TT:PlantSetError "A Project Plant record has invalid notes."))
    (T T))
)

(defun TT:PlantPaletteValidateWorker
  (palette / plants masters project-ids master-ids record project-id
             master-id master valid)
  (setq *TT:PlantLastError* nil)
  (cond
    ((or (not (eq (type palette) 'LIST))
         (not (eq (car palette) 'TT_PLANT_PALETTE)))
      (TT:PlantSetError "The Project Plant Palette data is malformed."))
    ((not (equal (TT:PlantPaletteValue palette 'DATA_SCHEMA_VERSION)
                 *TT:PlantPaletteSchemaVersion*))
      (TT:PlantSetError "The Project Plant Palette schema is not supported."))
    ((null (assoc 'PLANTS (cdr palette)))
      (TT:PlantSetError "The Project Plant Palette plant list is missing."))
    ((not (or (null (TT:PlantPaletteValue palette 'PLANTS))
              (eq (type (TT:PlantPaletteValue palette 'PLANTS)) 'LIST)))
      (TT:PlantSetError "The Project Plant Palette plant list is malformed."))
    ((null (setq masters (TT:PlantMasterGetAll)))
      (if (null *TT:PlantLastError*)
        (TT:PlantSetError "The Master Plant Catalog contains no plants."))
      nil)
    (T
      (setq plants (TT:PlantPaletteValue palette 'PLANTS)
            project-ids nil
            master-ids nil
            valid T)
      (while (and plants valid)
        (setq record (car plants))
        (if (not (TT:PlantPaletteRecordValidate record))
          (setq valid nil)
          (progn
            (setq project-id
                    (strcase (TT:PlantRecordValue record 'PROJECT_PLANT_ID))
                  master-id
                    (strcase (TT:PlantRecordValue record 'MASTER_PLANT_ID))
                  master (TT:PlantMasterFindByIDInList masters master-id))
            (cond
              ((member project-id project-ids)
                (TT:PlantSetError
                  (strcat "The Project Plant Palette contains duplicate project plant ID: "
                          project-id))
                (setq valid nil))
              ((member master-id master-ids)
                (TT:PlantSetError
                  (strcat "The Project Plant Palette contains duplicate master plant ID: "
                          master-id))
                (setq valid nil))
              ((null master)
                (TT:PlantSetError
                  (strcat "A Project Plant record references missing master plant ID: "
                          master-id))
                (setq valid nil))
              ((not (eq (TT:PlantRecordValue record 'CATEGORY)
                        (TT:PlantRecordValue master 'CATEGORY)))
                (TT:PlantSetError
                  (strcat "A Project Plant category does not match master plant ID: "
                          master-id))
                (setq valid nil))
              (T
                (setq project-ids (cons project-id project-ids)
                      master-ids (cons master-id master-ids))))))
        (setq plants (cdr plants)))
      valid))
)

(defun TT:PlantPaletteValidate (palette / result)
  (setq *TT:PlantLastError* nil
        result
          (vl-catch-all-apply 'TT:PlantPaletteValidateWorker (list palette)))
  (if (vl-catch-all-error-p result)
    (TT:PlantSetError "The Project Plant Palette data is malformed.")
    result)
)

(defun TT:PlantPaletteLoadFromProject (project / palette)
  (setq *TT:PlantLastError* nil
        palette (TT:ProjectValue project 'PLANT_PALETTE))
  (if (null palette)
    (TT:PlantPaletteEmpty)
    (if (TT:PlantPaletteValidate palette) palette nil))
)

(defun TT:PlantPaletteLoad (/ project)
  (setq *TT:PlantLastError* nil
        project (TT:ProjectCurrent))
  (if (null project)
    (if (TT:ProjectLastError)
      (TT:PlantSetError (TT:ProjectLastError))
      (TT:PlantSetError "No TerraTools project is associated with this drawing."))
    (TT:PlantPaletteLoadFromProject project))
)

(defun TT:PlantPaletteSave (palette / project updated)
  (setq *TT:PlantLastError* nil
        project (TT:ProjectCurrent))
  (cond
    ((null project)
      (if (TT:ProjectLastError)
        (TT:PlantSetError (TT:ProjectLastError))
        (TT:PlantSetError
          "No TerraTools project is associated with this drawing.")))
    ((not (TT:PlantPaletteValidate palette)) nil)
    (T
      (setq updated (TT:ProjectWithValue project 'PLANT_PALETTE palette))
      (if (TT:ProjectSave updated *TT:CurrentProjectPath*)
        (progn
          (setq *TT:CurrentProject* updated)
          T)
        (TT:PlantSetError (TT:ProjectLastError)))))
)

(defun TT:PlantProjectRecordFromMaster (master)
  (list
    'PROJECT_PLANT
    (cons 'PROJECT_PLANT_ID (TT:GenerateUUID))
    (cons 'MASTER_PLANT_ID (TT:PlantRecordValue master 'PLANT_ID))
    (cons 'CATEGORY (TT:PlantRecordValue master 'CATEGORY))
    (cons 'BOTANICAL_NAME (TT:PlantRecordValue master 'BOTANICAL_NAME))
    (cons 'COMMON_NAME (TT:PlantRecordValue master 'COMMON_NAME))
    (cons 'PLANT_CODE (TT:PlantRecordValue master 'PLANT_CODE))
    (cons 'SIZE (TT:PlantRecordValue master 'SIZE))
    (cons 'SPACING (TT:PlantRecordValue master 'SPACING))
    (cons 'UNIT_COST (TT:PlantRecordValue master 'UNIT_COST))
    (cons 'SYMBOL_BLOCK (TT:PlantRecordValue master 'SYMBOL_BLOCK))
    (cons 'NOTES (TT:PlantRecordValue master 'NOTES)))
)

(defun TT:PlantPaletteFindByMasterID (plants master-id / record found)
  (if (eq (type master-id) 'STR)
    (progn
      (setq master-id (strcase master-id))
      (while (and plants (null found))
        (setq record (car plants))
        (if (equal master-id
                   (strcase (TT:PlantRecordValue record 'MASTER_PLANT_ID)))
          (setq found record))
        (setq plants (cdr plants)))))
  found
)

(defun TT:PlantDisplayValue (value)
  (cond
    ((null value) "(unavailable)")
    ((and (eq (type value) 'STR) (equal value "")) "(blank)")
    ((eq (type value) 'STR) value)
    ((numberp value) (rtos value 2 2))
    (T "(invalid)"))
)

(defun TT:PlantCategoryName (category)
  (cond
    ((eq category 'TREE) "TREE")
    ((eq category 'SHRUB) "SHRUB")
    ((eq category 'GROUNDCOVER) "GROUNDCOVER")
    (T "UNKNOWN"))
)

(defun TT:PlantPrintMasterRecord (record)
  (princ
    (strcat "\n  "
            (TT:PlantRecordValue record 'PLANT_ID)
            " | "
            (TT:PlantDisplayValue (TT:PlantRecordValue record 'PLANT_CODE))
            " | "
            (TT:PlantCategoryName (TT:PlantRecordValue record 'CATEGORY))
            " | "
            (TT:PlantRecordValue record 'BOTANICAL_NAME)
            " | "
            (TT:PlantRecordValue record 'COMMON_NAME)))
  (princ
    (strcat "\n    Size: "
            (TT:PlantDisplayValue (TT:PlantRecordValue record 'SIZE))
            " | Spacing: "
            (TT:PlantDisplayValue (TT:PlantRecordValue record 'SPACING))
            " | Unit cost: "
            (TT:PlantDisplayValue (TT:PlantRecordValue record 'UNIT_COST))
            " | Symbol: "
            (TT:PlantDisplayValue (TT:PlantRecordValue record 'SYMBOL_BLOCK))))
)

(defun TT:PlantPrintProjectRecord (record)
  (princ
    (strcat "\n  "
            (TT:PlantRecordValue record 'PLANT_CODE)
            " | "
            (TT:PlantCategoryName (TT:PlantRecordValue record 'CATEGORY))
            " | "
            (TT:PlantRecordValue record 'BOTANICAL_NAME)
            " | "
            (TT:PlantRecordValue record 'COMMON_NAME)))
  (princ
    (strcat "\n    Master ID: "
            (TT:PlantRecordValue record 'MASTER_PLANT_ID)
            " | Project plant ID: "
            (TT:PlantRecordValue record 'PROJECT_PLANT_ID)))
  (princ
    (strcat "\n    Size: "
            (TT:PlantDisplayValue (TT:PlantRecordValue record 'SIZE))
            " | Spacing: "
            (TT:PlantDisplayValue (TT:PlantRecordValue record 'SPACING))
            " | Unit cost: "
            (TT:PlantDisplayValue (TT:PlantRecordValue record 'UNIT_COST))
            " | Symbol: "
            (TT:PlantDisplayValue (TT:PlantRecordValue record 'SYMBOL_BLOCK))))
  (princ
    (strcat "\n    Notes: "
            (TT:PlantDisplayValue (TT:PlantRecordValue record 'NOTES))))
)

(defun TT:PlantPrintMasterList (plants / record)
  (if plants
    (progn
      (princ (strcat "\nMaster Plant Catalog (" (itoa (length plants)) ")"))
      (foreach record plants (TT:PlantPrintMasterRecord record)))
    (princ "\nThe Master Plant Catalog contains no plants."))
  (princ)
)

(defun TT:PlantPrintMasterSelectionList (category plants / index record)
  (princ
    (strcat "\nAvailable " (TT:PlantCategoryName category) " plants:"))
  (setq index 1)
  (foreach record plants
    (princ
      (strcat "\n  "
              (itoa index)
              ". "
              (TT:PlantRecordValue record 'PLANT_CODE)
              " | "
              (TT:PlantRecordValue record 'BOTANICAL_NAME)
              " | "
              (TT:PlantRecordValue record 'COMMON_NAME)))
    (setq index (1+ index)))
  (princ)
)

(defun TT:PlantPromptMasterSelection (plants / count selection selected done)
  (setq count (length plants)
        done nil)
  (while (not done)
    (setq selection
      (getint
        (strcat "\nSelect plant number <1-" (itoa count) ">: ")))
    (cond
      ((null selection)
        (setq done T))
      ((or (< selection 1) (> selection count))
        (princ
          (strcat "\nEnter a number from 1 to "
                  (itoa count)
                  ", or press Enter to cancel.")))
      (T
        (setq selected (nth (1- selection) plants)
              done T))))
  selected
)

(defun TT:PlantPrintPalette (palette / plants record)
  (setq plants (TT:PlantPaletteGetAllFromPalette palette))
  (if plants
    (progn
      (princ (strcat "\nProject Plant Palette (" (itoa (length plants)) ")"))
      (foreach record plants (TT:PlantPrintProjectRecord record)))
    (princ "\nThe Project Plant Palette is empty."))
  (princ)
)

(defun TT:PlantProjectSelectionLabel (record)
  (strcat (TT:PlantRecordValue record 'PLANT_CODE)
          " | " (TT:PlantCategoryName (TT:PlantRecordValue record 'CATEGORY))
          " | " (TT:PlantRecordValue record 'BOTANICAL_NAME)
          " | " (TT:PlantRecordValue record 'COMMON_NAME))
)

(defun TT:PlantPromptProjectSelection (plants prompt)
  (if plants
    (TT:PromptNumberedRecord plants 'TT:PlantProjectSelectionLabel prompt)
    nil)
)

(defun TT:PlantPrintError ()
  (if *TT:PlantLastError*
    (princ (strcat "\nTerraTools: " *TT:PlantLastError*)))
  (princ)
)

(defun TT:PlantCommandProject (/ project)
  (setq project (TT:ProjectCurrent))
  (if project
    project
    (progn
      (princ "\nNo TerraTools project is associated with this drawing.")
      nil))
)

(defun TT:PlantPromptCategory (allow-all / keyword)
  (if allow-all
    (progn
      (initget "All Tree Shrub Groundcover")
      (setq keyword
        (getkword
          "\nPlant category [All/Tree/Shrub/Groundcover] <All>: "))
      (if (null keyword) (setq keyword "All")))
    (progn
      (initget "Tree Shrub Groundcover")
      (setq keyword
        (getkword
          "\nPlant category [Tree/Shrub/Groundcover] <cancel>: "))))
  (if (or (null keyword) (equal keyword "All"))
    (if (and allow-all (equal keyword "All")) 'ALL nil)
    (TT:PlantCategoryFromValue keyword))
)

(defun TT:PlantCommandList (/ palette)
  (setq palette (TT:PlantPaletteLoad))
  (if palette
    (TT:PlantPrintPalette palette)
    (TT:PlantPrintError))
)

(defun TT:PlantCommandMaster (/ category plants)
  (setq category (TT:PlantPromptCategory T))
  (if (eq category 'ALL)
    (setq plants (TT:PlantMasterGetAll))
    (setq plants (TT:PlantMasterFindByCategory category)))
  (if (or plants (null *TT:PlantLastError*))
    (TT:PlantPrintMasterList plants)
    (TT:PlantPrintError))
)

(defun TT:PlantCommandAdd
  (/ palette plants category masters plant-id master new-record)
  (setq palette (TT:PlantPaletteLoad))
  (if (null palette)
    (TT:PlantPrintError)
    (progn
      (setq plants (TT:PlantPaletteGetAllFromPalette palette)
            category (TT:PlantPromptCategory nil))
      (if (null category)
        (princ "\nAdd plant canceled.")
        (progn
          (setq masters (TT:PlantMasterFindByCategory category))
          (if (null masters)
            (if *TT:PlantLastError*
              (TT:PlantPrintError)
              (princ "\nNo Master Plant records exist in that category."))
            (progn
              (TT:PlantPrintMasterSelectionList category masters)
              (setq master (TT:PlantPromptMasterSelection masters))
              (if (null master)
                (princ "\nAdd plant canceled.")
                (progn
                  (setq plant-id
                    (TT:PlantRecordValue master 'PLANT_ID))
                  (cond
                    ((TT:PlantPaletteFindByMasterID plants plant-id)
                      (princ
                        "\nThat Master Plant is already in the Project Plant Palette."))
                    (T
                      (setq new-record
                        (TT:PlantProjectRecordFromMaster master)
                            palette
                        (TT:PlantPaletteWithPlants
                          palette
                          (append plants (list new-record))))
                      (if (TT:PlantPaletteSave palette)
                        (princ
                          (strcat "\nPlant added to Project Plant Palette: "
                                  (TT:PlantRecordValue new-record 'PLANT_CODE)))
                        (TT:PlantPrintError))))))))))))
  (princ)
)

(defun TT:PlantEditStringValue (record key input)
  (cond
    ((equal input "") record)
    ((equal input "-") (TT:PlantRecordWithValue record key ""))
    (T (TT:PlantRecordWithValue record key input)))
)

(defun TT:PlantParseNumber (text / result)
  (setq result (vl-catch-all-apply 'distof (list text 2)))
  (if (vl-catch-all-error-p result) nil result)
)

(defun TT:PlantCommandEdit
  (/ palette plants old updated input parsed valid)
  (setq palette (TT:PlantPaletteLoad))
  (cond
    ((null palette) (TT:PlantPrintError))
    ((null (setq plants (TT:PlantPaletteGetAllFromPalette palette)))
      (princ "\nThe Project Plant Palette is empty."))
    (T
      (princ "\nSelect a Project Plant to edit:")
      (setq old (TT:PlantPromptProjectSelection plants "Select plant number"))
      (if (null old)
        (princ "\nEdit plant canceled.")
        (progn
          (progn
              (setq updated old valid T)
              (setq input
                (getstring T
                  (strcat "\nPlant code <"
                          (TT:PlantRecordValue updated 'PLANT_CODE)
                          ">: ")))
              (if (not (equal input ""))
                (setq updated
                  (TT:PlantRecordWithValue updated 'PLANT_CODE input)))
              (setq input
                (getstring T
                  (strcat "\nSize <"
                          (TT:PlantDisplayValue
                            (TT:PlantRecordValue updated 'SIZE))
                          "> (- clears): "))
                    updated (TT:PlantEditStringValue updated 'SIZE input)
                    input
                (getstring T
                  (strcat "\nSpacing <"
                          (TT:PlantDisplayValue
                            (TT:PlantRecordValue updated 'SPACING))
                          "> (- clears): "))
                    updated (TT:PlantEditStringValue updated 'SPACING input)
                    input
                (getstring T
                  (strcat "\nUnit cost <"
                          (TT:PlantDisplayValue
                            (TT:PlantRecordValue updated 'UNIT_COST))
                          "> (- clears): ")))
              (cond
                ((equal input ""))
                ((equal input "-")
                  (setq updated
                    (TT:PlantRecordWithValue updated 'UNIT_COST "")))
                ((setq parsed (TT:PlantParseNumber input))
                  (setq updated
                    (TT:PlantRecordWithValue updated 'UNIT_COST parsed)))
                (T
                  (setq valid nil)
                  (princ "\nUnit cost must be numeric or blank.")))
              (if valid
                (progn
                  (setq input
                    (getstring T
                      (strcat "\nSymbol block <"
                              (TT:PlantDisplayValue
                                (TT:PlantRecordValue updated 'SYMBOL_BLOCK))
                              "> (- clears): "))
                        updated
                    (TT:PlantEditStringValue updated 'SYMBOL_BLOCK input)
                        input
                    (getstring T
                      (strcat "\nNotes <"
                              (TT:PlantDisplayValue
                                (TT:PlantRecordValue updated 'NOTES))
                              "> (- clears): "))
                        updated (TT:PlantEditStringValue updated 'NOTES input)
                        palette
                    (TT:PlantPaletteWithPlants
                      palette (subst updated old plants)))
                  (if (TT:PlantPaletteSave palette)
                    (princ "\nProject Plant record updated.")
                    (TT:PlantPrintError)))))))))
  (princ)
)

(defun TT:PlantRemoveRecord (plants target / result record)
  (foreach record plants
    (if (not (equal record target))
      (setq result (cons record result))))
  (reverse result)
)

(defun TT:PlantCommandRemove (/ palette plants target answer)
  (setq palette (TT:PlantPaletteLoad))
  (cond
    ((null palette) (TT:PlantPrintError))
    ((null (setq plants (TT:PlantPaletteGetAllFromPalette palette)))
      (princ "\nThe Project Plant Palette is empty."))
    (T
      (princ "\nSelect a Project Plant to remove:")
      (setq target (TT:PlantPromptProjectSelection plants "Select plant number"))
      (if (null target)
        (princ "\nRemove plant canceled.")
        (progn
          (progn
              (initget "Yes No")
              (setq answer
                (getkword "\nRemove this plant? [Yes/No] <No>: "))
              (if (equal answer "Yes")
                (progn
                  (setq palette
                    (TT:PlantPaletteWithPlants
                      palette (TT:PlantRemoveRecord plants target)))
                  (if (TT:PlantPaletteSave palette)
                    (princ "\nPlant removed from Project Plant Palette.")
                    (TT:PlantPrintError)))
                (princ "\nRemove plant canceled.")))))))
  (princ)
)

(defun C:TTPLANTS (/ *error* project option)
  (defun *error* (message)
    (TT:ReportError "TTPLANTS" message))
  (setq project (TT:PlantCommandProject))
  (if project
    (progn
      (initget "List Add Edit Remove Master")
      (setq option
        (getkword
          "\nTerraTools plants [List/Add/Edit/Remove/Master] <List>: "))
      (if (null option) (setq option "List"))
      (cond
        ((equal option "List") (TT:PlantCommandList))
        ((equal option "Add") (TT:PlantCommandAdd))
        ((equal option "Edit") (TT:PlantCommandEdit))
        ((equal option "Remove") (TT:PlantCommandRemove))
        ((equal option "Master") (TT:PlantCommandMaster)))))
  (princ)
)

(defun C:TTPLANTLIST (/ *error* project)
  (defun *error* (message)
    (TT:ReportError "TTPLANTLIST" message))
  (setq project (TT:PlantCommandProject))
  (if project (TT:PlantCommandList))
  (princ)
)

(defun C:TTPLANTMASTER (/ *error*)
  (defun *error* (message)
    (TT:ReportError "TTPLANTMASTER" message))
  (TT:PlantCommandMaster)
  (princ)
)

(setq *TT:PlantingModuleLoaded* T)
T
