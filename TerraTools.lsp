;;; TerraTools LT 0.1.0 - application loader for AutoCAD LT 2024+ on Windows.
;;; Add the installation folder to the Support File Search Path, then APPLOAD
;;; this file. If it cannot be found there, select this file when prompted.
;;; The installation folder and loaded subfolders must be trusted by AutoCAD.

(defun TT:Load
  (/ *error* requested-loader-path loader-path module-path modules module-name ok)
  ;; A local handler also covers failures before tt-errors.lsp is available.
  ;; Localizing *error* restores the caller's handler when this function exits.
  (defun *error* (message)
    (setq *TT:CoreLoaded* nil)
    (princ "\nTerraTools LT load failed")
    (if module-path (princ (strcat " in " module-path)))
    (princ (strcat ": " message))
    (princ)
  )

  ;; TTRELOAD supplies an exact loader path so another support-path copy cannot
  ;; take precedence. Consume the override once and clear it immediately.
  (if (and (boundp '*TT:LoaderPathOverride*)
           (eq (type *TT:LoaderPathOverride*) 'STR))
    (setq requested-loader-path (findfile *TT:LoaderPathOverride*)))
  (setq *TT:LoaderPathOverride* nil)

  ;; Clear readiness on every attempt, including a failed reload.
  (setq *TT:Version* "0.1.0"
        *TT:CoreLoaded* nil
        *TT:PlantingModuleLoaded* nil
        *TT:Root* nil
        loader-path requested-loader-path)

  (if (not loader-path)
    (setq loader-path (findfile "TerraTools.lsp")))

  (if (not loader-path)
    (setq loader-path
      (getfiled "Locate the TerraTools.lsp you are loading" "" "lsp" 0))
  )

  (cond
    ((not loader-path)
      (princ "\nTerraTools LT load cancelled. Core is not loaded."))
    ((not (and (= (strcase (vl-filename-base loader-path)) "TERRATOOLS")
               (vl-filename-extension loader-path)
               (= (strcase (vl-filename-extension loader-path)) ".LSP")))
      (princ "\nTerraTools LT load failed: select TerraTools.lsp."))
    (T
      (setq *TT:Root* (vl-filename-directory loader-path)
            modules '("core/tt-errors.lsp"
                      "core/tt-utils.lsp"
                      "core/tt-core.lsp"
                      "core/tt-uuid.lsp"
                      "core/tt-xdata.lsp"
                      "core/tt-storage.lsp"
                      "core/tt-project.lsp"
                      "core/tt-preferences.lsp"
                      "core/tt-scale.lsp"
                      "planting/tt-plant-db.lsp"
                      "planting/tt-plant-manager.lsp"
                      "core/tt-debug.lsp"
                      "core/tt-dev.lsp")
            ok T)
      ;; Always use explicit paths under one installation, never bare module
      ;; names that could resolve to files in another support directory.
      (while (and ok modules)
        (setq module-name (car modules)
              module-path (strcat *TT:Root* "/" module-name))
        (cond
          ((not (findfile module-path))
            (setq ok nil)
            (princ (strcat "\nTerraTools LT load failed: missing " module-path)))
          ((not (load module-path nil))
            (setq ok nil)
            (princ (strcat "\nTerraTools LT load failed: could not load "
                           module-path)))
        )
        (setq modules (cdr modules))
      )
      (if ok
        (progn
          (setq *TT:CoreLoaded* T)
          (princ (strcat "\nTerraTools LT " *TT:Version*
                         " ready. Commands: TTHELLO, TTDEBUG."))
        )
      )
    )
  )
  (princ)
)

(TT:Load)
(princ)
