;;; Shared DCL record editor. Caller-owned state uses AutoLISP dynamic scope.
(setq *TT:RecordUIModuleLoaded* T)

(defun TT:UIValue (value)
  (cond ((null value) "") ((eq (type value) 'STR) value)
        ((numberp value) (rtos value 2 6)) (T (vl-princ-to-string value))))

(defun TT:UIRecordDetails (record / dialog-id pair)
  (setq dialog-id (load_dialog (TT:StorageJoinPath *TT:Root* "dialogs/terratools-records.dcl")))
  (if (and (> dialog-id 0) (new_dialog "terratools_record_details" dialog-id))
    (progn
      (start_list "details")
      (foreach pair (cdr record) (add_list (strcat (vl-symbol-name (car pair)) ": " (TT:UIValue (cdr pair)))))
      (end_list) (action_tile "cancel" "(done_dialog 0)") (start_dialog))
    (princ "\nThis dialog could not be opened. Reload TerraTools and check its trusted dialogs folder."))
  (if (> dialog-id 0) (unload_dialog dialog-id)))

(defun TT:UIRecordAccept (/ index field value kind message candidate)
  (setq index 0 candidate edit-record)
  (foreach field edit-fields
    (setq value (vl-string-trim " " (get_tile (strcat "f" (itoa index)))) kind (nth 2 field))
    (cond
      ((member kind '(POSITIVE NONNEGATIVE INTEGER))
        (setq value (TT:StrictDecimal value))
        (if (or (null value) (< value 0.0) (and (eq kind 'POSITIVE) (= value 0.0))
                (and (eq kind 'INTEGER) (or (< value 1) (/= value (fix value)))))
          (setq message (strcat (cadr field) ": enter " (if (eq kind 'INTEGER) "a positive whole number." "a valid number.")))))
      ((and (eq kind 'REQUIRED) (= value "")) (setq message (strcat (cadr field) " is required."))))
    (setq candidate (TT:DataPut candidate (car field) value) index (1+ index)))
  (if message (set_tile "error" message) (progn (setq edited candidate) (done_dialog 1))))

(defun TT:UIEditRecord (edit-record edit-fields title / dialog-id edited index field key)
  (setq dialog-id (load_dialog (TT:StorageJoinPath *TT:Root* "dialogs/terratools-records.dcl")))
  (if (and (> dialog-id 0) (new_dialog "terratools_record_edit" dialog-id))
    (progn
      (set_tile "title" title) (setq index 0)
      (repeat 8
        (setq key (strcat "f" (itoa index)) field (nth index edit-fields))
        (if field
          (progn (set_tile key (if (and (null (TT:DataValue edit-record (car field)))
                                       (eq (nth 2 field) 'NONNEGATIVE)) "0"
                                (TT:UIValue (TT:DataValue edit-record (car field)))))
                 (set_tile (strcat "l" (itoa index)) (cadr field))
                 (mode_tile key 0))
          (mode_tile key 1))
        (setq index (1+ index)))
      (action_tile "accept" "(TT:UIRecordAccept)")
      (action_tile "cancel" "(setq edited nil)(done_dialog 0)")
      (start_dialog))
    (princ "\nThis dialog could not be opened. Reload TerraTools and check its trusted dialogs folder."))
  (if (> dialog-id 0) (unload_dialog dialog-id))
  edited)
T
