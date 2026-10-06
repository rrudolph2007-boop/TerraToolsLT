;;; TerraTools LT - CSV helpers including quoted physical newlines.

(setq *TT:CSVModuleLoaded* T)

(defun TT:CSVParseLine (line / fields field index character state valid)
  (setq fields nil field "" index 1 state 'START valid (eq (type line) 'STR))
  (while (and valid (<= index (strlen line)))
    (setq character (substr line index 1) index (1+ index))
    (cond
      ((eq state 'QUOTED)
        (if (= character "\"") (setq state 'CLOSED) (setq field (strcat field character))))
      ((eq state 'CLOSED)
        (cond ((= character "\"") (setq field (strcat field "\"") state 'QUOTED))
          ((= character ",") (setq fields (cons field fields) field "" state 'START))
          (T (setq valid nil))))
      ((= character ",") (setq fields (cons field fields) field "" state 'START))
      ((= character "\"") (if (eq state 'START) (setq state 'QUOTED) (setq valid nil)))
      (T (setq field (strcat field character) state 'TEXT))))
  (if (and valid (not (eq state 'QUOTED))) (reverse (cons field fields))))

(defun TT:CSVQuotedP (text / index quoted)
  (setq index 1)
  (while (<= index (strlen text))
    (if (= (substr text index 1) "\"") (setq quoted (not quoted)))
    (setq index (1+ index)))
  quoted)

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

(defun TT:CSVReadFile (path / stream line rows parsed valid buffer)
  (setq stream (open path "r") valid T)
  (if stream
    (progn
      (while (and valid (setq line (read-line stream)))
        (setq buffer (if buffer (strcat buffer "\n" line) line))
        (if (not (TT:CSVQuotedP buffer))
          (progn
            (setq parsed (TT:CSVParseLine buffer) buffer nil)
            (if parsed (setq rows (cons parsed rows)) (setq valid nil)))))
      (close stream)
      (if (and valid (null buffer)) (reverse rows)))))
T
