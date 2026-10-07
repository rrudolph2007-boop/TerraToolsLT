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
    ((eq key 'CIRCUIT) "circuit")
    ((eq key 'CAPACITY_WATTS) "capacity_watts")
    ((eq key 'STATION) "station")
    ((eq key 'FLOW_GPM) "flow_gpm")
    ((eq key 'DIAMETER_IN) "diameter_in")
    ((eq key 'C_FACTOR) "c_factor")
    ((eq key 'MANUAL_SIZE) "manual_size")
    ((eq key 'COVERAGE_RADIUS) "coverage_radius")
    ((eq key 'COVERAGE_SWEEP) "coverage_sweep")
    ((eq key 'PRESSURE_PSI) "pressure_psi")
    ((eq key 'INSIDE_DIAMETER) "inside_diameter")
    ((eq key 'PIPE_CLASS) "pipe_class")
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
    ((equal name "circuit") 'CIRCUIT)
    ((equal name "capacity_watts") 'CAPACITY_WATTS)
    ((equal name "station") 'STATION)
    ((equal name "flow_gpm") 'FLOW_GPM)
    ((equal name "diameter_in") 'DIAMETER_IN)
    ((equal name "c_factor") 'C_FACTOR)
    ((equal name "manual_size") 'MANUAL_SIZE)
    ((equal name "coverage_radius") 'COVERAGE_RADIUS)
    ((equal name "coverage_sweep") 'COVERAGE_SWEEP)
    ((equal name "pressure_psi") 'PRESSURE_PSI)
    ((equal name "inside_diameter") 'INSIDE_DIAMETER)
    ((equal name "pipe_class") 'PIPE_CLASS)
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

(defun TT:XDataMetadataValidP (metadata / item keys numeric-keys valid)
  (setq valid (TT:XDataStringValueP (cdr (assoc 'ENTITY_UUID metadata)))
        keys '(PROJECT_UUID MODULE OBJECT_TYPE CATALOG_ID WORK_AREA_ID CIRCUIT STATION PIPE_CLASS)
        numeric-keys '(CAPACITY_WATTS FLOW_GPM DIAMETER_IN COVERAGE_RADIUS COVERAGE_SWEEP PRESSURE_PSI INSIDE_DIAMETER C_FACTOR MANUAL_SIZE))
  (while (and valid keys)
    (setq item (assoc (car keys) metadata))
    (if (and item (not (TT:XDataStringValueP (cdr item))))
      (setq valid nil)
    )
    (setq keys (cdr keys))
  )
  (while (and valid numeric-keys)
    (setq item (assoc (car numeric-keys) metadata))
    (if (and item (not (numberp (cdr item)))) (setq valid nil))
    (setq numeric-keys (cdr numeric-keys)))
  valid
)

(defun TT:XDataAppendField (data key metadata / item key-name)
  (setq item (assoc key metadata)
        key-name (TT:XDataKeyName key))
  (if (and item key-name)
    (append data
      (list (cons 1000 key-name)
            (if (numberp (cdr item))
              (cons 1040 (float (cdr item)))
              (cons 1000 (cdr item)))))
    data
  )
)

(defun TT:XDataBuildAppData (metadata / app-data keys)
  (setq app-data
          (list *TT:XDataApp*
                (cons 1000 "TT_ENTITY")
                (cons 1070 *TT:XDataSchemaVersion*))
        keys '(ENTITY_UUID PROJECT_UUID MODULE OBJECT_TYPE
               CATALOG_ID WORK_AREA_ID CIRCUIT CAPACITY_WATTS STATION
               FLOW_GPM DIAMETER_IN COVERAGE_RADIUS COVERAGE_SWEEP PRESSURE_PSI INSIDE_DIAMETER PIPE_CLASS C_FACTOR MANUAL_SIZE))
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
             (member (car value-record) '(1000 1040 1070))
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
  (if (assoc 'CIRCUIT metadata) (TT:PrintValue "Circuit" (cdr (assoc 'CIRCUIT metadata))))
  (if (assoc 'STATION metadata) (TT:PrintValue "Station" (cdr (assoc 'STATION metadata))))
  (if (assoc 'FLOW_GPM metadata) (TT:PrintValue "Flow gpm" (cdr (assoc 'FLOW_GPM metadata))))
  (if (assoc 'DIAMETER_IN metadata) (TT:PrintValue "Diameter in" (cdr (assoc 'DIAMETER_IN metadata))))
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
