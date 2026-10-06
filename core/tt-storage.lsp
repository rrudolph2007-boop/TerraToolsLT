;;; TerraTools LT - Project storage abstraction.

(setq *TT:StorageLastError* nil)

(defun TT:StorageSetError (message)
  (setq *TT:StorageLastError* message)
  nil
)

(defun TT:StorageLastError ()
  *TT:StorageLastError*
)

(defun TT:StorageNormalizePath (path)
  (if (eq (type path) 'STR)
    (vl-string-translate "\\" "/" path)
    path
  )
)

(defun TT:StorageJoinPath (directory filename / normalized last-character)
  (setq normalized (TT:StorageNormalizePath directory))
  (if (or (null normalized) (equal normalized ""))
    filename
    (progn
      (setq last-character (substr normalized (strlen normalized) 1))
      (if (equal last-character "/")
        (strcat normalized filename)
        (strcat normalized "/" filename)
      )
    )
  )
)

(defun TT:StorageFileExistsP (path)
  (if (and (eq (type path) 'STR) (not (equal path "")) (findfile path)) T nil)
)

(defun TT:StorageResolveFile (path / resolved)
  (if (and (eq (type path) 'STR) (not (equal path "")))
    (setq resolved (findfile path))
    (setq resolved nil)
  )
  (if resolved (TT:StorageNormalizePath resolved) nil)
)

(defun TT:StorageDirectoryExistsP (path / result)
  (if (and (eq (type path) 'STR) (not (equal path "")))
    (progn
      (setq result
        (vl-catch-all-apply 'vl-file-directory-p (list path)))
      (if (vl-catch-all-error-p result) nil result)
    )
    nil
  )
)

(defun TT:StorageReadableWorker (path / stream)
  (setq stream (open path "r"))
  (if stream
    (progn (close stream) T)
    nil
  )
)

(defun TT:StorageReadableP (path / result)
  (setq result
    (vl-catch-all-apply 'TT:StorageReadableWorker (list path))
  )
  (if (vl-catch-all-error-p result) nil result)
)

(defun TT:StorageReadWorker (path / stream line text value)
  (setq stream (open path "r"))
  (if (null stream)
    (TT:StorageSetError (strcat "Could not open project file for reading: " path))
    (progn
      (setq text "")
      (while (setq line (read-line stream))
        (setq text (strcat text line "\n"))
      )
      (close stream)
      (if (equal text "")
        (TT:StorageSetError (strcat "Project file is empty: " path))
        (progn
          (setq value (read text))
          (if (null value)
            (TT:StorageSetError
              (strcat "Project file contains no usable data: " path))
            (progn
              (setq *TT:StorageLastError* nil)
              value
            )
          )
        )
      )
    )
  )
)

(defun TT:StorageRead (path / result)
  (setq *TT:StorageLastError* nil)
  (cond
    ((or (not (eq (type path) 'STR)) (equal path ""))
      (TT:StorageSetError "A project data path is required."))
    ((not (TT:StorageFileExistsP path))
      (TT:StorageSetError (strcat "Project file was not found: " path)))
    (T
      (setq result (vl-catch-all-apply 'TT:StorageReadWorker (list path)))
      (if (vl-catch-all-error-p result)
        (TT:StorageSetError
          (strcat "Could not read project file: " path ". "
                  (vl-catch-all-error-message result)))
        result
      )
    )
  )
)

(defun TT:StorageWriteRawWorker (path data / stream)
  (setq stream (open path "w"))
  (if (null stream)
    nil
    (progn
      (prin1 data stream)
      (princ "\n" stream)
      (close stream)
      T
    )
  )
)

(defun TT:StorageWriteRaw (path data / result)
  (setq result
    (vl-catch-all-apply 'TT:StorageWriteRawWorker (list path data))
  )
  (if (vl-catch-all-error-p result) nil result)
)

(defun TT:StorageDeleteIfExists (path / result)
  (if (TT:StorageFileExistsP path)
    (progn
      (setq result (vl-catch-all-apply 'vl-file-delete (list path)))
      (if (vl-catch-all-error-p result) nil result)
    )
    T
  )
)

(defun TT:StorageBackup (path / backup-path staging-path copied result)
  (setq *TT:StorageLastError* nil)
  (if (not (TT:StorageFileExistsP path))
    T
    (progn
      (setq backup-path (strcat path ".bak"))
      (setq staging-path (strcat backup-path ".tmp"))
      (if (not (TT:StorageDeleteIfExists staging-path))
        (TT:StorageSetError
          (strcat "Could not remove stale backup staging file: " staging-path))
        (progn
          (setq copied
            (vl-catch-all-apply 'vl-file-copy (list path staging-path))
          )
          (if (or (vl-catch-all-error-p copied) (null copied))
            (TT:StorageSetError
              (strcat "Could not create project backup: " backup-path))
            (if (not (TT:StorageDeleteIfExists backup-path))
              (TT:StorageSetError
                (strcat "Could not replace project backup: " backup-path))
              (progn
                (setq result
                  (vl-catch-all-apply
                    'vl-file-rename
                    (list staging-path backup-path)
                  )
                )
                (if (or (vl-catch-all-error-p result) (null result))
                  (TT:StorageSetError
                    (strcat "Could not finalize project backup: " backup-path))
                  T
                )
              )
            )
          )
        )
      )
    )
  )
)

(defun TT:StorageWrite (path data / temp-path verify had-existing renamed restored)
  (setq *TT:StorageLastError* nil)
  (if (or (not (eq (type path) 'STR)) (equal path ""))
    (TT:StorageSetError "A project data path is required.")
    (progn
      (setq temp-path (strcat path ".tmp"))
      (setq had-existing (TT:StorageFileExistsP path))
      (cond
        ((not (TT:StorageDeleteIfExists temp-path))
          (TT:StorageSetError
            (strcat "Could not remove stale project staging file: " temp-path)))
        ((not (TT:StorageWriteRaw temp-path data))
          (TT:StorageSetError
            (strcat "Could not write project staging file: " temp-path)))
        (T
          (setq verify (TT:StorageRead temp-path))
          (cond
            ((null verify)
              (TT:StorageDeleteIfExists temp-path)
              nil)
            ((not (equal verify data))
              (TT:StorageDeleteIfExists temp-path)
              (TT:StorageSetError
                (strcat "Project staging file did not pass verification: " temp-path)))
            ((and had-existing (not (TT:StorageBackup path)))
              (TT:StorageDeleteIfExists temp-path)
              nil)
            ((and had-existing (not (TT:StorageDeleteIfExists path)))
              (TT:StorageDeleteIfExists temp-path)
              (TT:StorageSetError
                (strcat "Could not replace existing project file: " path)))
            (T
              (setq renamed
                (vl-catch-all-apply 'vl-file-rename (list temp-path path))
              )
              (if (or (vl-catch-all-error-p renamed) (null renamed))
                (progn
                  (if had-existing
                    (setq restored
                      (vl-catch-all-apply
                        'vl-file-copy
                        (list (strcat path ".bak") path)
                      )
                    )
                  )
                  (TT:StorageDeleteIfExists temp-path)
                  (TT:StorageSetError
                    (strcat "Could not finalize project file: " path))
                )
                (progn
                  (setq *TT:StorageLastError* nil)
                  T
                )
              )
            )
          )
        )
      )
    )
  )
)

T
