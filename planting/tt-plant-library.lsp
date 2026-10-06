;;; Optional sharded open plant database. No full database parse at startup.
(setq *TT:PlantDatabaseLoaded* T)

(defun TT:PlantDatabaseRoot ()
  (TT:StorageJoinPath *TT:Root* "data/plants/production"))

(defun TT:PlantDatabaseManifest (/ value)
  (setq value (TT:StorageRead (TT:StorageJoinPath (TT:PlantDatabaseRoot) "manifest.dat")))
  (if (and value (eq (car value) 'TT_PLANT_DATABASE)
           (equal (TT:DataValue value 'DATA_SCHEMA_VERSION) 1)
           (equal (TT:DataValue value 'INDEX_VERSION) 1)
           (numberp (TT:DataValue value 'ACCEPTED_COUNT))
           (> (TT:DataValue value 'ACCEPTED_COUNT) 0)
           (equal (TT:DataValue value 'RECORD_SHARDS) 1024)) value))

(defun TT:PlantDatabaseOpen (path)
  (if (= (getvar "LISPSYS") 0)
    (progn (princ "\nOpen plant data requires LISPSYS 1 or 2. Set it and restart AutoCAD LT.") nil)
    (open path "r" "utf8")))

(defun TT:PlantDatabaseRecord (id / shard path stream line record found)
  (if (and (eq (type id) 'STR) (= (strlen id) 14)
           (= (substr (strcase id) 1 4) "WFO-") (TT:PlantDatabaseManifest))
    (progn
      (setq shard (itoa (rem (atoi (substr id 5)) 1024))
            path (TT:StorageJoinPath (TT:PlantDatabaseRoot) (strcat "records/" shard ".dat"))
            stream (TT:PlantDatabaseOpen path))
      (if stream
        (progn
          (while (and (null found) (setq line (read-line stream)))
            (setq record (vl-catch-all-apply 'read (list line)))
            (if (and (not (vl-catch-all-error-p record))
                     (eq (type record) 'LIST) (eq (car record) 'PLANT_RECORD)
                     (equal (TT:DataValue record 'PLANT_ID) (strcase id)))
              (setq found record)))
          (close stream)))))
  (if (and found (TT:PlantMasterRecordValidate found)) found))

(defun TT:PlantDatabaseSearchWords (query / index character text)
  (setq query (strcase query) index 1 text "")
  (while (<= index (strlen query))
    (setq character (substr query index 1) index (1+ index)
          text (strcat text (if (wcmatch character "[A-Z0-9]") character " "))))
  (TT:StringWords text))

(defun TT:PlantDatabaseSearch (query / words prefix path stream line row match word results exact count anchor summary)
  ;; Search one token-prefix shard; full records are fetched only when selected.
  (setq words (TT:PlantDatabaseSearchWords query) count 0 anchor "")
  (foreach word words (if (> (strlen word) (strlen anchor)) (setq anchor word)))
  (if (and words (>= (strlen anchor) 2) (TT:PlantDatabaseManifest))
    (progn
      (setq prefix (substr anchor 1 2))
      (if (wcmatch prefix "[A-Z0-9][A-Z0-9]")
        (progn
          (setq path (TT:StorageJoinPath (TT:PlantDatabaseRoot) (strcat "index/" prefix ".dat"))
                stream (if (findfile path) (TT:PlantDatabaseOpen path)))
          (if stream
            (progn
              ;; Finish the shard so an exact name after the display limit is retained.
              (while (setq line (read-line stream))
                (setq row (vl-catch-all-apply 'read (list line)) match T)
                (if (or (vl-catch-all-error-p row) (not (eq (type row) 'LIST))
                        (/= (length row) 5) (not (eq (type (nth 4 row)) 'STR)))
                  (setq match nil)
                  (foreach word words
                    (if (not (vl-string-search (strcat " " word) (strcat " " (nth 4 row)))) (setq match nil))))
                (if match
                  (progn
                    (setq count (1+ count)
                          summary (list 'PLANT_RECORD (cons 'PLANT_ID (car row))
                            (cons 'BOTANICAL_NAME (cadr row)) (cons 'COMMON_NAME "")
                            (cons 'FAMILY (nth 2 row)) (cons 'PLANT_CODE "WFO")
                            (cons 'CATEGORY 'OTHER) (cons 'DATABASE_SUMMARY T)))
                    (if (equal words (TT:StringWords (nth 3 row)))
                      (setq exact (cons summary exact))
                      (if (<= count 500) (setq results (cons summary results)))))))
              (close stream)))))))
  (append (reverse exact) (reverse results)))

(defun TT:PlantResolveSummary (record)
  (if (TT:DataValue record 'DATABASE_SUMMARY)
    (TT:PlantDatabaseRecord (TT:DataValue record 'PLANT_ID)) record))

(defun C:TTPLANTDATABASE (/ manifest field)
  (setq manifest (TT:PlantDatabaseManifest))
  (if manifest
    (progn
      (princ "\nInstalled open plant database")
      (foreach field (cdr manifest) (TT:PrintValue (vl-symbol-name (car field)) (cdr field))))
    (princ "\nNo valid open plant database is installed. See docs/PLANT_DATABASE.md."))
  (princ))

T
