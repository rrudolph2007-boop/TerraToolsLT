;;; TerraTools LT - RFC 4180-style single-line CSV helpers.

(setq *TT:CSVModuleLoaded* T)

(defun TT:CSVParseLine (line / fields field index character quoted next)
  ;; Handles commas, quoted fields, doubled quotes, and blank fields.
  ;; Embedded physical newlines are deliberately unsupported by the line reader.
  (if (not (eq (type line) 'STR))
    nil
    (progn
      (setq fields nil field "" index 1 quoted nil)
      (while (<= index (strlen line))
        (setq character (substr line index 1)
              next (if (< index (strlen line)) (substr line (1+ index) 1) ""))
        (cond
          ((and quoted (equal character "\"") (equal next "\""))
            (setq field (strcat field "\"") index (1+ index)))
          ((equal character "\"") (setq quoted (not quoted)))
          ((and (not quoted) (equal character ","))
            (setq fields (cons field fields) field ""))
          (T (setq field (strcat field character))))
        (setq index (1+ index)))
      (if quoted
        nil
        (reverse (cons field fields))))))

(defun TT:CSVJoinRow (values / result value)
  (foreach value values
    (setq result (strcat (if result (strcat result ",") "") (TT:CSVQuote value))))
  (if result result ""))

(defun TT:CSVHeaderMap (headers / index result header)
  (setq index 0)
  (foreach header headers
    (setq result (cons (cons (strcase (vl-string-trim " \t" header)) index) result)
          index (1+ index)))
  (reverse result))

(defun TT:CSVField (row header-map name / pair)
  (setq pair (assoc (strcase name) header-map))
  (if (and pair (< (cdr pair) (length row))) (nth (cdr pair) row) nil))

(defun TT:CSVReadFile (path / stream line rows parsed valid)
  (setq stream (open path "r") valid T)
  (if stream
    (progn
      (while (and valid (setq line (read-line stream)))
        (setq parsed (TT:CSVParseLine line))
        (if parsed (setq rows (cons parsed rows)) (setq valid nil)))
      (close stream)
      (if valid (reverse rows) nil))
    nil))

T
