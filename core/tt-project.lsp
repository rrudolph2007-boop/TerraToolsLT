;;; TerraTools LT - Project management and persistent drawing association.

(setq *TT:ProjectFileName* "terratools-project.dat"
      *TT:ProjectDataSchemaVersion* 1
      *TT:ProjectAssociationMarker* "TT_PROJECT_ASSOC"
      *TT:ProjectAssociationSchemaVersion* 1
      *TT:ProjectXDataChunkLength* 60
      *TT:ProjectLastError* nil
      *TT:ProjectAssociationError* nil
      *TT:CurrentProject* nil
      *TT:CurrentProjectPath* nil)

(defun TT:ProjectSetError (message)
  (setq *TT:ProjectLastError* message)
  nil
)

(defun TT:ProjectLastError ()
  *TT:ProjectLastError*
)

(defun TT:ProjectValue (project key / pair fields)
  (if (eq (type project) 'LIST)
    (setq fields (cdr project))
    (setq fields nil)
  )
  (if (eq (type fields) 'LIST)
    (setq pair (assoc key fields))
    (setq pair nil)
  )
  (if pair (cdr pair) nil)
)

(defun TT:ProjectNonEmptyStringP (value)
  (and (eq (type value) 'STR) (not (equal value "")))
)

(defun TT:ProjectValidateWorker (project)
  (setq *TT:ProjectLastError* nil)
  (cond
    ((or (not (eq (type project) 'LIST))
         (not (eq (car project) 'TERRATOOLS_PROJECT)))
      (TT:ProjectSetError "The file is not a TerraTools project file."))
    ((/= (TT:ProjectValue project 'DATA_SCHEMA_VERSION)
         *TT:ProjectDataSchemaVersion*)
      (TT:ProjectSetError "The TerraTools project data schema is not supported."))
    ((not (TT:ProjectNonEmptyStringP
            (TT:ProjectValue project 'PROJECT_UUID)))
      (TT:ProjectSetError "The project UUID is missing or invalid."))
    ((not (TT:ProjectNonEmptyStringP
            (TT:ProjectValue project 'PROJECT_NUMBER)))
      (TT:ProjectSetError "The project number is missing or invalid."))
    ((not (TT:ProjectNonEmptyStringP
            (TT:ProjectValue project 'PROJECT_NAME)))
      (TT:ProjectSetError "The project name is missing or invalid."))
    ((not (eq (type (TT:ProjectValue project 'CLIENT)) 'STR))
      (TT:ProjectSetError "The project client is missing or invalid."))
    ((not (eq (type (TT:ProjectValue project 'DESIGNER)) 'STR))
      (TT:ProjectSetError "The project designer is missing or invalid."))
    ((not (eq (type (TT:ProjectValue project 'DESCRIPTION)) 'STR))
      (TT:ProjectSetError "The project description is missing or invalid."))
    ((not (TT:ProjectNonEmptyStringP (TT:ProjectValue project 'UNITS)))
      (TT:ProjectSetError "The project units are missing or invalid."))
    ((or (not (numberp (TT:ProjectValue project 'DRAWING_SCALE)))
         (<= (TT:ProjectValue project 'DRAWING_SCALE) 0.0))
      (TT:ProjectSetError "The project drawing scale is missing or invalid."))
    ((not (TT:ProjectNonEmptyStringP
            (TT:ProjectValue project 'CREATED_DATE)))
      (TT:ProjectSetError "The project creation date is missing or invalid."))
    ((not (TT:ProjectNonEmptyStringP
            (TT:ProjectValue project 'TERRATOOLS_VERSION)))
      (TT:ProjectSetError "The TerraTools version is missing or invalid."))
    (T T)
  )
)

(defun TT:ProjectValidate (project / result)
  (setq *TT:ProjectLastError* nil
        result
          (vl-catch-all-apply 'TT:ProjectValidateWorker (list project)))
  (if (vl-catch-all-error-p result)
    (TT:ProjectSetError "The TerraTools project data is malformed.")
    result)
)

(defun TT:ProjectPadNumber (number width / text)
  (setq text (itoa number))
  (while (< (strlen text) width)
    (setq text (strcat "0" text))
  )
  text
)

(defun TT:ProjectCreatedDate
  (/ value date-part time-part year month day hour minute second)
  (setq value (getvar "CDATE")
        date-part (fix value)
        time-part (fix (+ 0.5 (* (- value (fix value)) 1000000.0))))
  (if (>= time-part 1000000) (setq time-part 0))
  (setq year (fix (/ date-part 10000))
        month (fix (/ (rem date-part 10000) 100))
        day (rem date-part 100)
        hour (fix (/ time-part 10000))
        minute (fix (/ (rem time-part 10000) 100))
        second (rem time-part 100))
  (strcat (TT:ProjectPadNumber year 4) "-"
          (TT:ProjectPadNumber month 2) "-"
          (TT:ProjectPadNumber day 2) " "
          (TT:ProjectPadNumber hour 2) ":"
          (TT:ProjectPadNumber minute 2) ":"
          (TT:ProjectPadNumber second 2))
)

(defun TT:ProjectMakeData
  (project-number project-name client designer description units)
  (list
    'TERRATOOLS_PROJECT
    (cons 'DATA_SCHEMA_VERSION *TT:ProjectDataSchemaVersion*)
    (cons 'PROJECT_UUID (TT:GenerateUUID))
    (cons 'PROJECT_NUMBER project-number)
    (cons 'PROJECT_NAME project-name)
    (cons 'CLIENT client)
    (cons 'DESIGNER designer)
    (cons 'DESCRIPTION description)
    (cons 'UNITS units)
    (cons 'DRAWING_SCALE 1.0)
    (cons 'CREATED_DATE (TT:ProjectCreatedDate))
    (cons 'TERRATOOLS_VERSION *TT:Version*))
)

(defun TT:ProjectSplitString (value maximum / pieces position count)
  (setq pieces nil position 1)
  (while (<= position (strlen value))
    (setq count (min maximum (+ 1 (- (strlen value) position)))
          pieces (cons (substr value position count) pieces)
          position (+ position count))
  )
  (if (equal value "") (setq pieces (list "")))
  (reverse pieces)
)

(defun TT:ProjectStringRecords (value / records piece)
  (setq records nil)
  (foreach piece (TT:ProjectSplitString value *TT:ProjectXDataChunkLength*)
    (setq records (append records (list (cons 1000 piece))))
  )
  records
)

(defun TT:ProjectDropItems (items count)
  (while (and items (> count 0))
    (setq items (cdr items) count (1- count))
  )
  items
)

(defun TT:ProjectJoinStringRecords (items count / value record valid)
  (setq value "" valid T)
  (while (and valid (> count 0))
    (setq record (car items))
    (if (and record (= (car record) 1000) (eq (type (cdr record)) 'STR))
      (setq value (strcat value (cdr record))
            items (cdr items)
            count (1- count))
      (setq valid nil)
    )
  )
  (if valid value nil)
)

(defun TT:ProjectPathPrefixP (prefix path / prefix-length)
  (setq prefix (strcase (TT:StorageNormalizePath prefix))
        path (strcase (TT:StorageNormalizePath path))
        prefix-length (strlen prefix))
  (and (> prefix-length 0)
       (<= prefix-length (strlen path))
       (equal prefix (substr path 1 prefix-length)))
)

(defun TT:ProjectRelativePath (path / drawing-directory normalized-path)
  (setq drawing-directory (TT:StorageNormalizePath (getvar "DWGPREFIX"))
        normalized-path (TT:StorageNormalizePath path))
  (if (and (= (getvar "DWGTITLED") 1)
           (TT:ProjectPathPrefixP drawing-directory normalized-path))
    (substr normalized-path (1+ (strlen drawing-directory)))
    "")
)

(defun TT:ProjectBuildAssociationData
  (project path / uuid relative absolute-parts relative-parts data)
  (setq uuid (TT:ProjectValue project 'PROJECT_UUID)
        path (TT:StorageNormalizePath path)
        relative (TT:ProjectRelativePath path)
        absolute-parts
          (TT:ProjectSplitString path *TT:ProjectXDataChunkLength*)
        relative-parts
          (TT:ProjectSplitString relative *TT:ProjectXDataChunkLength*)
        data
          (list *TT:XDataApp*
                (cons 1000 *TT:ProjectAssociationMarker*)
                (cons 1070 *TT:ProjectAssociationSchemaVersion*)
                (cons 1000 uuid)
                (cons 1070 (length absolute-parts))))
  (setq data (append data (TT:ProjectStringRecords path))
        data (append data (list (cons 1070 (length relative-parts))))
        data (append data (TT:ProjectStringRecords relative)))
  data
)

(defun TT:ProjectParseAssociationWorker
  (app-data / items marker schema uuid absolute-count absolute-path
              relative-count relative-path)
  (setq items (cdr app-data)
        marker (car items)
        items (cdr items)
        schema (car items)
        items (cdr items)
        uuid (car items)
        items (cdr items)
        absolute-count (car items)
        items (cdr items))
  (if (not (and (equal (car app-data) *TT:XDataApp*)
                (= (car marker) 1000)
                (equal (cdr marker) *TT:ProjectAssociationMarker*)
                (= (car schema) 1070)
                (= (cdr schema) *TT:ProjectAssociationSchemaVersion*)
                (= (car uuid) 1000)
                (TT:ProjectNonEmptyStringP (cdr uuid))
                (= (car absolute-count) 1070)
                (numberp (cdr absolute-count))
                (> (cdr absolute-count) 0)))
    nil
    (progn
      (setq absolute-path
              (TT:ProjectJoinStringRecords items (cdr absolute-count))
            items (TT:ProjectDropItems items (cdr absolute-count))
            relative-count (car items)
            items (cdr items))
      (if (not (and absolute-path
                    (= (car relative-count) 1070)
                    (numberp (cdr relative-count))
                    (> (cdr relative-count) 0)))
        nil
        (progn
          (setq relative-path
            (TT:ProjectJoinStringRecords items (cdr relative-count)))
          (if (eq (type relative-path) 'STR)
            (list (cons 'PROJECT_UUID (cdr uuid))
                  (cons 'PROJECT_PATH absolute-path)
                  (cons 'RELATIVE_PATH relative-path))
            nil
          )
        )
      )
    )
  )
)

(defun TT:ProjectGetAssociationWorker (/ entity data raw app-data result)
  (setq entity (namedobjdict)
        data (entget entity (list *TT:XDataApp*))
        raw (assoc -3 data))
  (if (null raw)
    nil
    (progn
      (setq app-data (cadr raw)
            result
              (vl-catch-all-apply
                'TT:ProjectParseAssociationWorker
                (list app-data)))
      (if (or (vl-catch-all-error-p result) (null result))
        (progn
          (setq *TT:ProjectAssociationError*
            "The drawing contains a malformed TerraTools project association.")
          nil)
        result)
    )
  )
)

(defun TT:ProjectGetAssociation (/ result)
  (setq *TT:ProjectAssociationError* nil
        result
          (vl-catch-all-apply 'TT:ProjectGetAssociationWorker nil))
  (if (vl-catch-all-error-p result)
    (progn
      (setq *TT:ProjectAssociationError*
        "Could not read the TerraTools project association from this drawing.")
      nil)
    result)
)

(defun TT:ProjectSetAssociationWorker (project path / entity data old new)
  (if (not (TT:RegisterXDataApp))
    nil
    (progn
      (setq entity (namedobjdict)
            data (entget entity (list *TT:XDataApp*))
            old (assoc -3 data)
            new (list -3 (TT:ProjectBuildAssociationData project path)))
      (if old
        (setq data (subst new old data))
        (setq data (append data (list new))))
      (if (entmod data) T nil)
    )
  )
)

(defun TT:ProjectSetAssociation (project path / result)
  (setq result
    (vl-catch-all-apply
      'TT:ProjectSetAssociationWorker
      (list project path)))
  (if (or (vl-catch-all-error-p result) (null result))
    (TT:ProjectSetError
      "Could not store the TerraTools project association in this drawing.")
    T)
)

(defun TT:ProjectRemoveAssociationWorker (/ entity data old)
  (setq entity (namedobjdict)
        data (entget entity (list *TT:XDataApp*))
        old (assoc -3 data))
  (if old
    (if (entmod (subst (list -3 (list *TT:XDataApp*)) old data)) T nil)
    T)
)

(defun TT:ProjectRemoveAssociation (/ result)
  (setq result
    (vl-catch-all-apply 'TT:ProjectRemoveAssociationWorker nil))
  (if (or (vl-catch-all-error-p result) (null result))
    (TT:ProjectSetError
      "Could not remove the TerraTools project association from this drawing.")
    T)
)

(defun TT:ProjectLoad (path / project)
  (setq *TT:ProjectLastError* nil
        path (TT:StorageNormalizePath path)
        project (TT:StorageRead path))
  (cond
    ((null project) (TT:ProjectSetError (TT:StorageLastError)))
    ((not (TT:ProjectValidate project)) nil)
    (T project))
)

(defun TT:ProjectSave (project path / existing project-uuid existing-uuid)
  (setq *TT:ProjectLastError* nil
        path (TT:StorageNormalizePath path))
  (cond
    ((not (TT:ProjectValidate project)) nil)
    ((TT:StorageFileExistsP path)
      (setq existing (TT:ProjectLoad path))
      (if (null existing)
        nil
        (progn
          (setq project-uuid (TT:ProjectValue project 'PROJECT_UUID)
                existing-uuid (TT:ProjectValue existing 'PROJECT_UUID))
          (if (not (equal project-uuid existing-uuid))
            (TT:ProjectSetError
              "The existing project file has a different project UUID.")
            (if (TT:StorageWrite path project)
              T
              (TT:ProjectSetError (TT:StorageLastError)))))))
    ((TT:StorageWrite path project) T)
    (T (TT:ProjectSetError (TT:StorageLastError))))
)

(defun TT:ProjectResolvePath (association / absolute)
  ;; A moved project must be reopened explicitly so the drawing association
  ;; cannot silently adopt a different file near the current DWG.
  (setq absolute (cdr (assoc 'PROJECT_PATH association)))
  (if (TT:StorageFileExistsP absolute) absolute nil)
)

(defun TT:ProjectRefresh
  (/ association path project expected-uuid actual-uuid)
  (setq *TT:CurrentProject* nil
        *TT:CurrentProjectPath* nil
        *TT:ProjectLastError* nil
        association (TT:ProjectGetAssociation))
  (cond
    ((and (null association) *TT:ProjectAssociationError*)
      (TT:ProjectSetError *TT:ProjectAssociationError*))
    ((null association) nil)
    (T
      (setq path (TT:ProjectResolvePath association))
      (if (null path)
        (TT:ProjectSetError
          (strcat "The associated TerraTools project file is missing: "
                  (cdr (assoc 'PROJECT_PATH association))))
        (progn
          (setq project (TT:ProjectLoad path))
          (if project
            (progn
              (setq expected-uuid (cdr (assoc 'PROJECT_UUID association))
                    actual-uuid (TT:ProjectValue project 'PROJECT_UUID))
              (if (not (equal expected-uuid actual-uuid))
                (TT:ProjectSetError
                  "The drawing association and project file UUIDs do not match.")
                (progn
                  (setq *TT:CurrentProject* project
                        *TT:CurrentProjectPath* path)
                  project))))))))
)

(defun TT:ProjectCurrent ()
  (TT:ProjectRefresh)
)

(defun TT:ProjectIsActive ()
  (if (TT:ProjectCurrent) T nil)
)

(defun TT:ProjectCreate
  (directory project-number project-name client designer description units
   / path absolute-path project)
  (setq *TT:ProjectLastError* nil
        directory (TT:StorageNormalizePath directory))
  (cond
    ((not (TT:ProjectNonEmptyStringP directory))
      (TT:ProjectSetError "A project directory is required."))
    ((not (TT:StorageDirectoryExistsP directory))
      (TT:ProjectSetError
        (strcat "The project directory does not exist or is inaccessible: "
                directory)))
    ((not (TT:ProjectNonEmptyStringP project-number))
      (TT:ProjectSetError "A project number is required."))
    ((not (TT:ProjectNonEmptyStringP project-name))
      (TT:ProjectSetError "A project name is required."))
    ((not (TT:ProjectNonEmptyStringP units))
      (TT:ProjectSetError "Project units are required."))
    (T
      (setq path (TT:StorageJoinPath directory *TT:ProjectFileName*))
      (if (TT:StorageFileExistsP path)
        (TT:ProjectSetError
          (strcat "A TerraTools project file already exists: " path))
        (progn
          (setq project
            (TT:ProjectMakeData project-number project-name client designer
                                description units))
          (if (TT:ProjectSave project path)
            (progn
              (setq absolute-path (TT:StorageResolveFile path))
              (if (TT:ProjectSetAssociation project absolute-path)
                (progn
                  (setq *TT:CurrentProject* project
                        *TT:CurrentProjectPath* absolute-path)
                  project))))))))
)

(defun TT:ProjectOpen (path / normalized absolute-path project)
  (setq *TT:ProjectLastError* nil
        normalized (TT:StorageNormalizePath path))
  (if (TT:StorageDirectoryExistsP normalized)
    (setq normalized
      (TT:StorageJoinPath normalized *TT:ProjectFileName*)))
  (setq project (TT:ProjectLoad normalized))
  (if project
    (progn
      (setq absolute-path (TT:StorageResolveFile normalized))
      (if (TT:ProjectSetAssociation project absolute-path)
        (progn
          (setq *TT:CurrentProject* project
                *TT:CurrentProjectPath* absolute-path)
          project))))
)

(defun TT:ProjectClose ()
  (if (TT:ProjectRemoveAssociation)
    (progn
      (setq *TT:CurrentProject* nil
            *TT:CurrentProjectPath* nil
            *TT:ProjectLastError* nil)
      T)
    nil)
)

(defun TT:ProjectPrintError ()
  (if *TT:ProjectLastError*
    (princ (strcat "\nTerraTools: " *TT:ProjectLastError*)))
  (princ)
)

(defun TT:ProjectPrintInfo (/ project association)
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (princ "\nTerraTools project information")
      (TT:PrintValue "Project UUID" (TT:ProjectValue project 'PROJECT_UUID))
      (TT:PrintValue "Project number" (TT:ProjectValue project 'PROJECT_NUMBER))
      (TT:PrintValue "Project name" (TT:ProjectValue project 'PROJECT_NAME))
      (TT:PrintValue "Client" (TT:ProjectValue project 'CLIENT))
      (TT:PrintValue "Designer" (TT:ProjectValue project 'DESIGNER))
      (TT:PrintValue "Description" (TT:ProjectValue project 'DESCRIPTION))
      (TT:PrintValue "Units" (TT:ProjectValue project 'UNITS))
      (TT:PrintValue "Drawing scale" (TT:ProjectValue project 'DRAWING_SCALE))
      (TT:PrintValue "Created date" (TT:ProjectValue project 'CREATED_DATE))
      (TT:PrintValue "TerraTools version"
                     (TT:ProjectValue project 'TERRATOOLS_VERSION))
      (TT:PrintValue "Schema version"
                     (TT:ProjectValue project 'DATA_SCHEMA_VERSION))
      (TT:PrintValue "Project data path" *TT:CurrentProjectPath*))
    (progn
      (setq association (TT:ProjectGetAssociation))
      (if (or association *TT:ProjectAssociationError*)
        (TT:ProjectPrintError)
        (princ "\nNo TerraTools project is associated with this drawing."))))
  (princ)
)

(defun C:TTPROJECTINFO (/ *error*)
  (defun *error* (message)
    (TT:ReportError "TTPROJECTINFO" message))
  (TT:ProjectPrintInfo)
)

(defun TT:ProjectCommandCreate
  (/ directory project-number project-name client designer description units project)
  (setq directory
    (getstring T "\nProject directory (must already exist): "))
  (if (equal directory "")
    (princ "\nProject creation canceled.")
    (progn
      (setq project-number (getstring T "\nProject number: ")
            project-name (getstring T "\nProject name: ")
            client (getstring T "\nClient: ")
            designer (getstring T "\nDesigner: ")
            description (getstring T "\nDescription: ")
            units (getstring T "\nUnits: ")
            project
              (TT:ProjectCreate directory project-number project-name client
                                designer description units))
      (if project
        (princ (strcat "\nTerraTools project created: "
                       *TT:CurrentProjectPath*))
        (TT:ProjectPrintError))))
)

(defun TT:ProjectCommandOpen (/ path project)
  (setq path
    (getstring T "\nProject file or directory <Browse>: "))
  (if (equal path "")
    (setq path
      (getfiled "Open TerraTools Project" *TT:ProjectFileName* "dat" 0)))
  (if path
    (progn
      (setq project (TT:ProjectOpen path))
      (if project
        (princ (strcat "\nTerraTools project opened: "
                       *TT:CurrentProjectPath*))
        (TT:ProjectPrintError)))
    (princ "\nOpen project canceled."))
)

(defun TT:ProjectCommandClose ()
  (if (TT:ProjectGetAssociation)
    (if (TT:ProjectClose)
      (princ "\nTerraTools project disassociated from this drawing.")
      (TT:ProjectPrintError))
    (if *TT:ProjectAssociationError*
      (if (TT:ProjectClose)
        (princ "\nMalformed TerraTools project association removed from this drawing.")
        (TT:ProjectPrintError))
      (princ "\nNo TerraTools project is associated with this drawing.")))
)

(defun C:TTPROJECT (/ *error* option)
  (defun *error* (message)
    (TT:ReportError "TTPROJECT" message))
  (initget "Create Open Info CLose")
  (setq option
    (getkword "\nTerraTools project [Create/Open/Info/CLose] <Info>: "))
  (if (null option) (setq option "Info"))
  (cond
    ((equal option "Create") (TT:ProjectCommandCreate))
    ((equal option "Open") (TT:ProjectCommandOpen))
    ((equal option "Info") (TT:ProjectPrintInfo))
    ((equal option "CLose") (TT:ProjectCommandClose)))
  (princ)
)

T
