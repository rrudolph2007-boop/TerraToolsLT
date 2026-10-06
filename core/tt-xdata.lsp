;;; TERRATOOLS smart-entity XData foundation.
;;; Only the TERRATOOLS application record is requested and modified so XData
;;; owned by other registered applications remains untouched.

(setq *TT:XDataApp* "TERRATOOLS"
      *TT:XDataSchemaVersion* 1)

(defun TT:XDataAppRegisteredP ()
  (if (tblsearch "APPID" *TT:XDataApp*) T nil)
)

(defun TT:RegisterXDataApp ()
  (if (TT:XDataAppRegisteredP)
    T
    (if (regapp *TT:XDataApp*) T nil)
  )
)

(defun TT:ValidEntityP (entity)
  (if (and (eq (type entity) 'ENAME) (entget entity)) T nil)
)

(defun TT:XDataKeyName (key)
  (cond
    ((eq key 'ENTITY_UUID) "entity_uuid")
    ((eq key 'PROJECT_UUID) "project_uuid")
    ((eq key 'MODULE) "module")
    ((eq key 'OBJECT_TYPE) "object_type")
    ((eq key 'CATALOG_ID) "catalog_id")
    ((eq key 'WORK_AREA_ID) "work_area_id")
    (T nil)
  )
)

(defun TT:XDataNameKey (name)
  (cond
    ((equal name "entity_uuid") 'ENTITY_UUID)
    ((equal name "project_uuid") 'PROJECT_UUID)
    ((equal name "module") 'MODULE)
    ((equal name "object_type") 'OBJECT_TYPE)
    ((equal name "catalog_id") 'CATALOG_ID)
    ((equal name "work_area_id") 'WORK_AREA_ID)
    (T nil)
  )
)

(defun TT:XDataStringValueP (value)
  (if (and (eq (type value) 'STR)
           (> (strlen value) 0)
           (<= (strlen value) 255))
    T
    nil
  )
)

(defun TT:XDataMetadataValidP (metadata / item keys valid)
  (setq valid (TT:XDataStringValueP (cdr (assoc 'ENTITY_UUID metadata)))
        keys '(PROJECT_UUID MODULE OBJECT_TYPE CATALOG_ID WORK_AREA_ID))
  (while (and valid keys)
    (setq item (assoc (car keys) metadata))
    (if (and item (not (TT:XDataStringValueP (cdr item))))
      (setq valid nil)
    )
    (setq keys (cdr keys))
  )
  valid
)

(defun TT:XDataAppendField (data key metadata / item key-name)
  (setq item (assoc key metadata)
        key-name (TT:XDataKeyName key))
  (if (and item key-name)
    (append data
      (list (cons 1000 key-name)
            (cons 1000 (cdr item))))
    data
  )
)

(defun TT:XDataBuildAppData (metadata / app-data keys)
  (setq app-data
          (list *TT:XDataApp*
                (cons 1000 "TT_ENTITY")
                (cons 1070 *TT:XDataSchemaVersion*))
        keys '(ENTITY_UUID PROJECT_UUID MODULE OBJECT_TYPE
               CATALOG_ID WORK_AREA_ID))
  (while keys
    (setq app-data (TT:XDataAppendField app-data (car keys) metadata)
          keys (cdr keys))
  )
  app-data
)

(defun TT:GetRawEntityXData (entity / entity-data)
  (if (and (TT:ValidEntityP entity) (TT:XDataAppRegisteredP))
    (progn
      (setq entity-data (entget entity (list *TT:XDataApp*)))
      (assoc -3 entity-data)
    )
    nil
  )
)

(defun TT:XDataParseFields (items result / key key-record value-record)
  (while (and items (cdr items))
    (setq key-record (car items)
          value-record (cadr items))
    (if (and (= (car key-record) 1000)
             (= (car value-record) 1000)
             (setq key (TT:XDataNameKey (cdr key-record))))
      (progn
        (setq result (append result (list (cons key (cdr value-record)))))
        (setq items (cddr items))
      )
      (setq items (cdr items))
    )
  )
  result
)

(defun TT:GetEntityXData (entity / app-data items raw-xdata result schema-record)
  (setq raw-xdata (TT:GetRawEntityXData entity))
  (if raw-xdata
    (progn
      (setq app-data (cadr raw-xdata)
            items (cdr app-data))
      (if (and (equal (car app-data) *TT:XDataApp*)
               items
               (= (caar items) 1000)
               (equal (cdar items) "TT_ENTITY")
               (cdr items)
               (= (caadr items) 1070))
        (progn
          (setq schema-record (cadr items)
                result
                  (list (cons 'SCHEMA_VERSION (cdr schema-record))))
          (TT:XDataParseFields (cddr items) result)
        )
        nil
      )
    )
    nil
  )
)

(defun TT:SetEntityXData (entity metadata / entity-data new-xdata old-xdata)
  (if (and (TT:ValidEntityP entity)
           (TT:XDataMetadataValidP metadata)
           (TT:RegisterXDataApp))
    (progn
      (setq entity-data (entget entity (list *TT:XDataApp*))
            old-xdata (assoc -3 entity-data)
            new-xdata (list -3 (TT:XDataBuildAppData metadata)))
      (if old-xdata
        (setq entity-data (subst new-xdata old-xdata entity-data))
        (setq entity-data (append entity-data (list new-xdata)))
      )
      (if (entmod entity-data) T nil)
    )
    nil
  )
)

(defun TT:GetEntityUUID (entity / metadata)
  (setq metadata (TT:GetEntityXData entity))
  (cdr (assoc 'ENTITY_UUID metadata))
)

(defun TT:GetObjectType (entity / metadata)
  (setq metadata (TT:GetEntityXData entity))
  (cdr (assoc 'OBJECT_TYPE metadata))
)

(defun TT:IsSmartEntity (entity)
  (if (TT:GetEntityUUID entity) T nil)
)

(defun TT:RemoveEntityXData (entity / entity-data old-xdata)
  (if (and (TT:ValidEntityP entity)
           (TT:XDataAppRegisteredP)
           (setq entity-data (entget entity (list *TT:XDataApp*)))
           (setq old-xdata (assoc -3 entity-data)))
    (if
      (entmod
        (subst (list -3 (list *TT:XDataApp*))
               old-xdata
               entity-data))
      T
      nil
    )
    nil
  )
)

(defun TT:PrintEntityMetadata (metadata)
  (TT:PrintValue "Schema version" (cdr (assoc 'SCHEMA_VERSION metadata)))
  (TT:PrintValue "Entity UUID" (cdr (assoc 'ENTITY_UUID metadata)))
  (TT:PrintValue "Project UUID" (cdr (assoc 'PROJECT_UUID metadata)))
  (TT:PrintValue "Module" (cdr (assoc 'MODULE metadata)))
  (TT:PrintValue "Object type" (cdr (assoc 'OBJECT_TYPE metadata)))
  (TT:PrintValue "Catalog ID" (cdr (assoc 'CATALOG_ID metadata)))
  (TT:PrintValue "Work Area ID" (cdr (assoc 'WORK_AREA_ID metadata)))
  (princ)
)

(defun C:TTTAGTEST (/ *error* entity metadata selection undo-open uuid)
  (defun *error* (message)
    (if undo-open
      (progn
        (command-s "_.UNDO" "_End")
        (setq undo-open nil)
      )
    )
    (TT:ReportError "TTTAGTEST" message)
  )
  (setq selection (entsel "\nSelect entity to tag: "))
  (cond
    ((not selection)
      (princ "\nNo entity selected."))
    ((TT:IsSmartEntity (car selection))
      (princ "\nEntity is already TerraTools-aware. Existing metadata was not changed."))
    (T
      (setq entity (car selection)
            uuid (TT:GenerateUUID)
            metadata
              (list (cons 'ENTITY_UUID uuid)
                    (cons 'MODULE "TEST")
                    (cons 'OBJECT_TYPE "TEST_OBJECT")))
      (command-s "_.UNDO" "_Begin")
      (setq undo-open T)
      (if (TT:SetEntityXData entity metadata)
        (princ (strcat "\nEntity UUID: " uuid))
        (princ "\nUnable to attach TERRATOOLS XData to the selected entity."))
      (command-s "_.UNDO" "_End")
      (setq undo-open nil)
    )
  )
  (princ)
)

(defun C:TTINFOTEST (/ *error* entity metadata selection)
  (defun *error* (message)
    (TT:ReportError "TTINFOTEST" message)
  )
  (setq selection (entsel "\nSelect entity to inspect: "))
  (cond
    ((not selection)
      (princ "\nNo entity selected."))
    ((setq metadata (TT:GetEntityXData (setq entity (car selection))))
      (princ "\nTerraTools entity metadata")
      (TT:PrintEntityMetadata metadata))
    (T
      (princ "\nEntity is not TerraTools-aware."))
  )
  (princ)
)

(defun C:TTUNTAGTEST (/ *error* entity selection undo-open)
  (defun *error* (message)
    (if undo-open
      (progn
        (command-s "_.UNDO" "_End")
        (setq undo-open nil)
      )
    )
    (TT:ReportError "TTUNTAGTEST" message)
  )
  (setq selection (entsel "\nSelect TerraTools-aware entity to untag: "))
  (cond
    ((not selection)
      (princ "\nNo entity selected."))
    ((not (TT:IsSmartEntity (setq entity (car selection))))
      (princ "\nEntity is not TerraTools-aware."))
    (T
      (command-s "_.UNDO" "_Begin")
      (setq undo-open T)
      (if (TT:RemoveEntityXData entity)
        (princ "\nTERRATOOLS XData removed. Entity geometry was not changed.")
        (princ "\nUnable to remove TERRATOOLS XData from the selected entity."))
      (command-s "_.UNDO" "_End")
      (setq undo-open nil)
    )
  )
  (princ)
)

(TT:RegisterXDataApp)
T
