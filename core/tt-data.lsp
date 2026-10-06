;;; TerraTools LT - Shared keyed-record and additive project-section helpers.

(defun TT:DataValue (record key / pair)
  (if (and (eq (type record) 'LIST) (eq (type (cdr record)) 'LIST))
    (setq pair (assoc key (cdr record))))
  (if pair (cdr pair) nil)
)

(defun TT:DataPut (record key value / fields old new)
  (setq fields (cdr record)
        old (assoc key fields)
        new (cons key value))
  (if old
    (setq fields (subst new old fields))
    (setq fields (append fields (list new))))
  (cons (car record) fields)
)

(defun TT:DataRemoveByValue (records key value / result record)
  (foreach record records
    (if (not (equal (TT:DataValue record key) value))
      (setq result (cons record result))))
  (reverse result)
)

(defun TT:DataFindByValue (records key value / record found)
  (while (and records (null found))
    (setq record (car records))
    (if (equal (TT:DataValue record key) value)
      (setq found record))
    (setq records (cdr records)))
  found
)

(defun TT:ProjectSaveSection (key value / project updated)
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (setq updated (TT:ProjectWithValue project key value))
      (if (TT:ProjectSave updated *TT:CurrentProjectPath*)
        (progn (setq *TT:CurrentProject* updated) T)
        nil))
    nil)
)

(defun TT:PromptNumberedRecord (records label-function prompt / index record choice done selected)
  (setq index 1)
  (foreach record records
    (princ (strcat "\n  " (itoa index) ". "
                   (apply label-function (list record))))
    (setq index (1+ index)))
  (while (not done)
    (setq choice (getint (strcat "\n" prompt " <1-" (itoa (length records)) ">: ")))
    (cond
      ((null choice) (setq done T))
      ((or (< choice 1) (> choice (length records)))
        (princ (strcat "\nEnter a number from 1 to " (itoa (length records))
                       ", or press Enter to cancel.")))
      (T (setq selected (nth (1- choice) records) done T))))
  selected
)

(defun TT:CSVQuote (value / text position result character)
  (cond
    ((null value) (setq text ""))
    ((eq (type value) 'STR) (setq text value))
    ((numberp value) (setq text (rtos value 2 4)))
    (T (setq text "")))
  (setq position 1 result "\"")
  (while (<= position (strlen text))
    (setq character (substr text position 1)
          result (strcat result (if (equal character "\"") "\"\"" character))
          position (1+ position)))
  (strcat result "\"")
)

(defun TT:SafeNumber (value default)
  (if (numberp value) value default)
)

T
