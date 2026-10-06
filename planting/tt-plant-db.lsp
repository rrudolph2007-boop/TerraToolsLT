;;; TerraTools LT - Shared Master Plant Catalog access and validation.

(setq *TT:PlantMasterFileName* "terratools-plant-master.dat"
      *TT:PlantMasterSchemaVersion* 1
      *TT:PlantCategories* '(TREE SHRUB GROUNDCOVER)
      *TT:PlantLastError* nil)

(defun TT:PlantSetError (message)
  (setq *TT:PlantLastError* message)
  nil
)

(defun TT:PlantLastError ()
  *TT:PlantLastError*
)

(defun TT:PlantNonEmptyStringP (value)
  (and (eq (type value) 'STR) (not (equal value "")))
)

(defun TT:PlantOptionalStringP (value)
  (eq (type value) 'STR)
)

(defun TT:PlantUnitCostP (value)
  (or (and (numberp value) (>= value 0.0))
      (and (eq (type value) 'STR) (equal value "")))
)

(defun TT:PlantSpacingP (value)
  (or (and (numberp value) (>= value 0.0))
      (eq (type value) 'STR))
)

(defun TT:PlantCategoryFromValue (value / text)
  (cond
    ((member value *TT:PlantCategories*) value)
    ((eq (type value) 'STR)
      (setq text (strcase value))
      (cond
        ((equal text "TREE") 'TREE)
        ((equal text "SHRUB") 'SHRUB)
        ((equal text "GROUNDCOVER") 'GROUNDCOVER)
        (T nil)))
    (T nil))
)

(defun TT:PlantRecordValue (record key / pair)
  (if (and (eq (type record) 'LIST) (eq (type (cdr record)) 'LIST))
    (setq pair (assoc key (cdr record)))
    (setq pair nil))
  (if pair (cdr pair) nil)
)

(defun TT:PlantRecordWithValue (record key value / fields old new)
  (setq fields (cdr record)
        old (assoc key fields)
        new (cons key value))
  (if old
    (setq fields (subst new old fields))
    (setq fields (append fields (list new))))
  (cons (car record) fields)
)

(defun TT:PlantMasterCatalogValue (catalog key / pair)
  (if (and (eq (type catalog) 'LIST) (eq (type (cdr catalog)) 'LIST))
    (setq pair (assoc key (cdr catalog)))
    (setq pair nil))
  (if pair (cdr pair) nil)
)

(defun TT:PlantMasterPath (/ data-directory)
  (if (TT:PlantNonEmptyStringP *TT:Root*)
    (progn
      (setq data-directory (TT:StorageJoinPath *TT:Root* "data"))
      (TT:StorageJoinPath data-directory *TT:PlantMasterFileName*))
    (TT:PlantSetError "The TerraTools installation folder is unavailable."))
)

(defun TT:PlantMasterRecordValidate (record / category)
  (setq category (TT:PlantRecordValue record 'CATEGORY))
  (cond
    ((or (not (eq (type record) 'LIST))
         (not (eq (car record) 'PLANT_RECORD)))
      (TT:PlantSetError "The Master Plant Catalog contains a malformed record."))
    ((not (TT:PlantNonEmptyStringP
            (TT:PlantRecordValue record 'PLANT_ID)))
      (TT:PlantSetError "A Master Plant record has a missing or invalid plant ID."))
    ((not (member category *TT:PlantCategories*))
      (TT:PlantSetError "A Master Plant record has an invalid category."))
    ((not (TT:PlantNonEmptyStringP
            (TT:PlantRecordValue record 'BOTANICAL_NAME)))
      (TT:PlantSetError "A Master Plant record has an invalid botanical name."))
    ((not (TT:PlantNonEmptyStringP
            (TT:PlantRecordValue record 'COMMON_NAME)))
      (TT:PlantSetError "A Master Plant record has an invalid common name."))
    ((not (TT:PlantNonEmptyStringP
            (TT:PlantRecordValue record 'PLANT_CODE)))
      (TT:PlantSetError "A Master Plant record has a blank or invalid plant code."))
    ((not (TT:PlantOptionalStringP (TT:PlantRecordValue record 'SIZE)))
      (TT:PlantSetError "A Master Plant record has an invalid size."))
    ((not (TT:PlantSpacingP (TT:PlantRecordValue record 'SPACING)))
      (TT:PlantSetError "A Master Plant record has an invalid spacing value."))
    ((not (TT:PlantUnitCostP (TT:PlantRecordValue record 'UNIT_COST)))
      (TT:PlantSetError "A Master Plant record has an invalid unit cost."))
    ((not (TT:PlantOptionalStringP
            (TT:PlantRecordValue record 'SYMBOL_BLOCK)))
      (TT:PlantSetError "A Master Plant record has an invalid symbol block."))
    ((not (TT:PlantOptionalStringP (TT:PlantRecordValue record 'NOTES)))
      (TT:PlantSetError "A Master Plant record has invalid notes."))
    (T T))
)

(defun TT:PlantMasterValidateWorker (catalog / plants ids record plant-id valid)
  (setq *TT:PlantLastError* nil)
  (cond
    ((or (not (eq (type catalog) 'LIST))
         (not (eq (car catalog) 'TERRATOOLS_PLANT_MASTER)))
      (TT:PlantSetError "The file is not a TerraTools Master Plant Catalog."))
    ((not (equal (TT:PlantMasterCatalogValue catalog 'DATA_SCHEMA_VERSION)
                 *TT:PlantMasterSchemaVersion*))
      (TT:PlantSetError "The Master Plant Catalog schema is not supported."))
    ((null (assoc 'PLANTS (cdr catalog)))
      (TT:PlantSetError "The Master Plant Catalog plant list is missing."))
    (T
      (setq plants (TT:PlantMasterCatalogValue catalog 'PLANTS))
      (if (not (or (null plants) (eq (type plants) 'LIST)))
        (TT:PlantSetError "The Master Plant Catalog plant list is malformed.")
        (progn
          (setq ids nil valid T)
          (while (and plants valid)
            (setq record (car plants))
            (if (not (TT:PlantMasterRecordValidate record))
              (setq valid nil)
              (progn
                (setq plant-id (strcase (TT:PlantRecordValue record 'PLANT_ID)))
                (if (member plant-id ids)
                  (progn
                    (TT:PlantSetError
                      (strcat "The Master Plant Catalog contains duplicate plant ID: "
                              plant-id))
                    (setq valid nil))
                  (setq ids (cons plant-id ids)))))
            (setq plants (cdr plants)))
          valid))))
)

(defun TT:PlantMasterValidate (catalog / result)
  (setq *TT:PlantLastError* nil
        result
          (vl-catch-all-apply 'TT:PlantMasterValidateWorker (list catalog)))
  (if (vl-catch-all-error-p result)
    (TT:PlantSetError "The Master Plant Catalog data is malformed.")
    result)
)

(defun TT:PlantMasterLoad (/ path catalog)
  (setq *TT:PlantLastError* nil
        path (TT:PlantMasterPath))
  (if (null path)
    nil
    (progn
      (setq catalog (TT:StorageRead path))
      (cond
        ((null catalog)
          (TT:PlantSetError
            (strcat "Could not read the Master Plant Catalog. "
                    (TT:StorageLastError))))
        ((not (TT:PlantMasterValidate catalog)) nil)
        (T catalog))))
)

(defun TT:PlantMasterSave (catalog / path)
  (setq *TT:PlantLastError* nil)
  (cond
    ((not (TT:PlantMasterValidate catalog)) nil)
    ((null (setq path (TT:PlantMasterPath))) nil)
    ((TT:StorageWrite path catalog) T)
    (T
      (TT:PlantSetError
        (strcat "Could not save the Master Plant Catalog. "
                (TT:StorageLastError)))))
)

(defun TT:PlantMasterGetAll (/ catalog plants user-plants external-plants)
  (setq catalog (TT:PlantMasterLoad))
  (if catalog
    (progn
      (setq plants (TT:PlantMasterCatalogValue catalog 'PLANTS)
            user-plants (if (and (boundp '*TT:PlantSearchModuleLoaded*)
                                 *TT:PlantSearchModuleLoaded*)
                          (TT:PlantUserGetAll))
            external-plants (if (and (boundp '*TT:PlantSearchModuleLoaded*)
                                     *TT:PlantSearchModuleLoaded*)
                              (TT:PlantExternalGetAll)))
      (append plants user-plants external-plants))
    nil)
)

(defun TT:PlantMasterFindByIDInList (plants plant-id / record found)
  (if (eq (type plant-id) 'STR)
    (progn
      (setq plant-id (strcase plant-id))
      (while (and plants (null found))
        (setq record (car plants))
        (if (equal plant-id
                   (strcase (TT:PlantRecordValue record 'PLANT_ID)))
          (setq found record))
        (setq plants (cdr plants)))))
  found
)

(defun TT:PlantMasterFindByID (plant-id / plants)
  (setq plants (TT:PlantMasterGetAll))
  (if plants
    (TT:PlantMasterFindByIDInList plants plant-id)
    nil)
)

(defun TT:PlantMasterFindByCategory (category / plants record matches)
  (setq category (TT:PlantCategoryFromValue category)
        matches nil)
  (cond
    ((null category)
      (TT:PlantSetError "The requested plant category is invalid."))
    ((null (setq plants (TT:PlantMasterGetAll))) nil)
    (T
      (foreach record plants
        (if (eq category (TT:PlantRecordValue record 'CATEGORY))
          (setq matches (cons record matches))))
      (reverse matches)))
)

T
