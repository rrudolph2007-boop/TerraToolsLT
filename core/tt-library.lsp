;;; User libraries are separate files. Project additions are independent copies.
(defun TT:LibraryPath (kind / directory)
  (setq directory (TT:StandardsUserDirectory))
  (if directory (TT:StorageJoinPath directory (strcat "library-" (strcase (vl-symbol-name kind) T) ".dat"))))

(defun TT:LibraryValidateWorker (data kind / config record ids id field value valid)
  (setq config (TT:ManagerConfig kind) valid (and (eq (car data) 'TT_USER_LIBRARY)
    (equal (TT:DataValue data 'SCHEMA_VERSION) 1) (eq (TT:DataValue data 'KIND) kind)
    (listp (TT:DataValue data 'RECORDS))))
  (foreach record (TT:DataValue data 'RECORDS)
    (setq id (TT:DataValue record (cadr config)))
    (if (or (not (TT:ProjectNonEmptyStringP id)) (member id ids)) (setq valid nil))
    (setq ids (cons id ids))
    (foreach field (nth 4 config)
      (setq value (TT:DataValue record (car field)))
      (if (if (member (nth 2 field) '(POSITIVE NONNEGATIVE INTEGER))
            (not (and (numberp value) (>= value 0) (or (not (eq (nth 2 field) 'POSITIVE)) (> value 0))))
            (not (and (eq (type value) 'STR) (or (not (eq (nth 2 field) 'REQUIRED)) (/= value "")))))
        (setq valid nil))))
  valid)

(defun TT:LibraryValidate (data kind / result)
  (setq result (vl-catch-all-apply 'TT:LibraryValidateWorker (list data kind)))
  (and (not (vl-catch-all-error-p result)) result))

(defun TT:LibraryLabel (record)
  (TT:ManagerLabel record (TT:ManagerConfig library-kind)))

(defun TT:LibraryCommand (library-kind / config option path data records project selected record old id source)
  (setq config (TT:ManagerConfig library-kind) project (TT:ProjectCurrent) path (TT:LibraryPath library-kind))
  (initget "Save Add Import Export")
  (setq option (getkword "\nUser library [Save/Add/Import/Export] <Add>: "))
  (if (null option) (setq option "Add"))
  (if path
    (progn
      (setq data (if (findfile path) (TT:StorageRead path)
        (list 'TT_USER_LIBRARY '(SCHEMA_VERSION . 1) (cons 'KIND library-kind) '(RECORDS))))
      (if (not (TT:LibraryValidate data library-kind))
        (princ "\nThe user library is malformed. Restore a known-good backup before writing it.")
        (progn
          (setq records (TT:DataValue data 'RECORDS))
          (cond
            ((= option "Save")
              (setq selected (TT:PromptNumberedRecord (TT:ProjectValue project (car config)) 'TT:LibraryLabel "Select project record to copy"))
              (if selected
                (progn
                  (setq id (TT:DataValue selected (cadr config)) old (TT:DataFindByValue records (cadr config) id))
                  (if old (princ "\nThis record is already saved in the user library.")
                    (if (TT:StorageWrite path (TT:DataPut data 'RECORDS (append records (list selected)))) (princ "\nUser library copy saved."))))))
            ((= option "Add")
              (if (null records) (princ "\nThe user library is empty. Save a project record or import an office library first.")
                (if (setq selected (TT:PromptNumberedRecord records 'TT:LibraryLabel "Select library record"))
                  (progn
                    (setq record (TT:DataPut selected 'SOURCE_ID (TT:DataValue selected (cadr config)))
                          record (TT:DataPut record (cadr config) (TT:GenerateUUID))
                          record (TT:UIEditRecord record (nth 4 config) "TerraTools LT | Project Copy"))
                    (if record (TT:ManagerSaveRecord library-kind record nil))))))
            ((= option "Export")
              (setq source (getfiled "Export user library" "terratools-library.dat" "dat" 1))
              (if source (TT:StorageWrite source data)))
            ((= option "Import")
              (setq source (getfiled "Import office/user library" "" "dat" 0) data (if source (TT:StorageRead source)))
              (if source
                (if (TT:LibraryValidate data library-kind)
                  (progn
                    (foreach record (TT:DataValue data 'RECORDS)
                      (if (not (TT:DataFindByValue records (cadr config) (TT:DataValue record (cadr config))))
                        (setq records (append records (list record)))))
                    (TT:StorageWrite path (TT:DataPut data 'RECORDS records)))
                  (princ "\nLibrary import refused: its schema or records are invalid.")))))))))
  (princ))
T
