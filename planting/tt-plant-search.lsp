;;; TerraTools LT - Scalable plant search, user library, and open-data import.

(setq *TT:PlantSearchModuleLoaded* T
      *TT:PlantSearchPageSize* 20
      *TT:PlantSearchIndex* nil
      *TT:PlantUserSchemaVersion* 1
      *TT:PlantNormalizedSchemaVersion* 1)

(defun TT:PlantUserPath (/ directory)
  (setq directory (TT:StandardsUserDirectory))
  (if directory (TT:StorageJoinPath directory "user-plants.dat") nil))

(defun TT:PlantUserEmpty ()
  (list 'TT_USER_PLANT_LIBRARY
        (cons 'DATA_SCHEMA_VERSION *TT:PlantUserSchemaVersion*)
        (cons 'PLANTS nil)))

(defun TT:PlantUserLoad (/ path value plants valid record)
  (setq path (TT:PlantUserPath))
  (if (or (null path) (not (TT:StorageFileExistsP path)))
    (TT:PlantUserEmpty)
    (progn
      (setq value (TT:StorageRead path))
      (if (and (eq (type value) 'LIST)
               (eq (car value) 'TT_USER_PLANT_LIBRARY)
               (equal (TT:DataValue value 'DATA_SCHEMA_VERSION) *TT:PlantUserSchemaVersion*))
        (progn
          (setq plants (TT:DataValue value 'PLANTS) valid T)
          (if (not (or (null plants) (eq (type plants) 'LIST)))
            (setq valid nil)
            (foreach record plants
              (if (not (TT:PlantMasterRecordValidate record)) (setq valid nil))))
          (if valid value nil))
        nil))))

(defun TT:PlantUserGetAll (/ library)
  (setq library (TT:PlantUserLoad))
  (if library (TT:DataValue library 'PLANTS) nil))

(defun TT:PlantUserSave (library / path)
  (setq path (TT:PlantUserPath))
  (if (and path (TT:StorageWrite path library))
    (progn (setq *TT:PlantSearchIndex* nil) T)
    nil))

(defun TT:PlantNormalizedValue (record key)
  (TT:DataValue record key))

(defun TT:PlantLegacyFromNormalized (record / scientific common code category)
  (setq scientific (TT:PlantNormalizedValue record 'SCIENTIFIC_NAME)
        common (TT:PlantNormalizedValue record 'COMMON_NAME)
        code (TT:PlantNormalizedValue record 'DEFAULT_CODE)
        category (TT:PlantCategoryFromValue (TT:PlantNormalizedValue record 'CATEGORY)))
  (if (not (TT:PlantNonEmptyStringP common)) (setq common "(common name unavailable)"))
  (if (not (TT:PlantNonEmptyStringP code)) (setq code (TT:PlantNormalizedValue record 'SOURCE_ID)))
  (list 'PLANT_RECORD
        (cons 'PLANT_ID (TT:PlantNormalizedValue record 'PLANT_ID))
        (cons 'CATEGORY category)
        (cons 'BOTANICAL_NAME scientific)
        (cons 'COMMON_NAME common)
        (cons 'PLANT_CODE code)
        (cons 'SIZE (if (TT:PlantNormalizedValue record 'DEFAULT_SIZE)
                      (TT:PlantNormalizedValue record 'DEFAULT_SIZE) ""))
        (cons 'SPACING (if (TT:PlantNormalizedValue record 'DEFAULT_SPACING)
                         (TT:PlantNormalizedValue record 'DEFAULT_SPACING) ""))
        (cons 'UNIT_COST "")
        (cons 'SYMBOL_BLOCK (if (TT:PlantNormalizedValue record 'DEFAULT_SYMBOL)
                              (TT:PlantNormalizedValue record 'DEFAULT_SYMBOL) ""))
        (cons 'NOTES (if (TT:PlantNormalizedValue record 'NOTES)
                       (TT:PlantNormalizedValue record 'NOTES) ""))
        (cons 'SOURCE (TT:PlantNormalizedValue record 'SOURCE))
        (cons 'SOURCE_ID (TT:PlantNormalizedValue record 'SOURCE_ID))
        (cons 'ACCEPTED_SCIENTIFIC_NAME
              (TT:PlantNormalizedValue record 'ACCEPTED_SCIENTIFIC_NAME))
        (cons 'GENUS (TT:PlantNormalizedValue record 'GENUS))
        (cons 'SPECIES (TT:PlantNormalizedValue record 'SPECIES))
        (cons 'CULTIVAR (TT:PlantNormalizedValue record 'CULTIVAR))
        (cons 'COMMON_NAMES (TT:PlantNormalizedValue record 'COMMON_NAMES))
        (cons 'FAMILY (TT:PlantNormalizedValue record 'FAMILY))
        (cons 'SYNONYMS (TT:PlantNormalizedValue record 'SYNONYMS))
        (cons 'GROWTH_HABIT (TT:PlantNormalizedValue record 'GROWTH_HABIT))
        (cons 'EVERGREEN_DECIDUOUS
              (TT:PlantNormalizedValue record 'EVERGREEN_DECIDUOUS))
        (cons 'HARDINESS_MIN (TT:PlantNormalizedValue record 'HARDINESS_MIN))
        (cons 'HARDINESS_MAX (TT:PlantNormalizedValue record 'HARDINESS_MAX))
        (cons 'WATER_USE (TT:PlantNormalizedValue record 'WATER_USE))
        (cons 'SUN_REQUIREMENT (TT:PlantNormalizedValue record 'SUN_REQUIREMENT))
        (cons 'SOIL_PREFERENCES (TT:PlantNormalizedValue record 'SOIL_PREFERENCES))
        (cons 'MATURE_HEIGHT_MIN (TT:PlantNormalizedValue record 'MATURE_HEIGHT_MIN))
        (cons 'MATURE_HEIGHT_MAX (TT:PlantNormalizedValue record 'MATURE_HEIGHT_MAX))
        (cons 'MATURE_WIDTH_MIN (TT:PlantNormalizedValue record 'MATURE_WIDTH_MIN))
        (cons 'MATURE_WIDTH_MAX (TT:PlantNormalizedValue record 'MATURE_WIDTH_MAX))
        (cons 'NATIVE_REGIONS (TT:PlantNormalizedValue record 'NATIVE_REGIONS))
        (cons 'STATE_DISTRIBUTION
              (TT:PlantNormalizedValue record 'STATE_DISTRIBUTION))
        (cons 'BLOOM_SEASON (TT:PlantNormalizedValue record 'BLOOM_SEASON))
        (cons 'BLOOM_COLOR (TT:PlantNormalizedValue record 'BLOOM_COLOR))
        (cons 'FOLIAGE_COLOR (TT:PlantNormalizedValue record 'FOLIAGE_COLOR))
        (cons 'GROWTH_RATE (TT:PlantNormalizedValue record 'GROWTH_RATE))
        (cons 'LANDSCAPE_USES (TT:PlantNormalizedValue record 'LANDSCAPE_USES))
        (cons 'WETLAND_STATUS (TT:PlantNormalizedValue record 'WETLAND_STATUS))
        (cons 'SOURCE_URL (TT:PlantNormalizedValue record 'SOURCE_URL))
        (cons 'SOURCE_LICENSE (TT:PlantNormalizedValue record 'SOURCE_LICENSE))
        (cons 'SOURCE_ATTRIBUTION (TT:PlantNormalizedValue record 'SOURCE_ATTRIBUTION))
        (cons 'SOURCE_DATE (TT:PlantNormalizedValue record 'SOURCE_DATE))))

(defun TT:PlantNormalizedLoad (path / catalog records record result)
  (setq catalog (TT:StorageRead path))
  (if (and (eq (type catalog) 'LIST)
           (eq (car catalog) 'TERRATOOLS_NORMALIZED_PLANTS)
           (equal (TT:DataValue catalog 'DATA_SCHEMA_VERSION) *TT:PlantNormalizedSchemaVersion*)
           (eq (type (TT:DataValue catalog 'PLANTS)) 'LIST))
    (progn
      (foreach record (TT:DataValue catalog 'PLANTS)
        (if (and (eq (type record) 'LIST)
                 (eq (car record) 'NORMALIZED_PLANT)
                 (TT:PlantNonEmptyStringP (TT:PlantNormalizedValue record 'PLANT_ID))
                 (TT:PlantNonEmptyStringP (TT:PlantNormalizedValue record 'SCIENTIFIC_NAME)))
          (setq result (cons (TT:PlantLegacyFromNormalized record) result))))
      (reverse result))
    nil))

(defun TT:PlantExternalGetAll (/ project paths path records)
  (setq project (TT:ProjectCurrent)
        paths (if project (TT:ProjectValue project 'PLANT_DATA_PATHS)))
  (if (not (eq (type paths) 'LIST)) (setq paths nil))
  (foreach path paths
    (if (TT:StorageReadableP path)
      (setq records (append records (TT:PlantNormalizedLoad path)))))
  records)

(defun TT:PlantSearchText (record / value text key)
  (setq text "")
  (foreach key '(PLANT_ID PLANT_CODE BOTANICAL_NAME ACCEPTED_SCIENTIFIC_NAME
                 COMMON_NAME COMMON_NAMES FAMILY GENUS SPECIES CULTIVAR SYNONYMS
                 CATEGORY SOURCE SOURCE_ID NATIVE_REGIONS STATE_DISTRIBUTION
                 HARDINESS_MIN HARDINESS_MAX SUN_REQUIREMENT WATER_USE
                 SOIL_PREFERENCES GROWTH_HABIT EVERGREEN_DECIDUOUS
                 MATURE_HEIGHT_MIN MATURE_HEIGHT_MAX MATURE_WIDTH_MIN
                 MATURE_WIDTH_MAX BLOOM_SEASON BLOOM_COLOR FOLIAGE_COLOR
                 GROWTH_RATE LANDSCAPE_USES WETLAND_STATUS NOTES)
    (setq value (TT:PlantRecordValue record key))
    (if value (setq text (strcat text " " (vl-princ-to-string value)))))
  (strcase text))

(defun TT:PlantSearchBuildIndex (/ record records)
  (setq records (append (TT:PlantMasterCatalogValue (TT:PlantMasterLoad) 'PLANTS)
                        (TT:PlantUserGetAll) (TT:PlantExternalGetAll))
        *TT:PlantSearchIndex* nil)
  (foreach record records
    (setq *TT:PlantSearchIndex*
      (cons (cons record (TT:PlantSearchText record)) *TT:PlantSearchIndex*)))
  (setq *TT:PlantSearchIndex* (reverse *TT:PlantSearchIndex*)))

(defun TT:StringWords (text / words position next word)
  (setq text (vl-string-trim " \t" text) position 0)
  (while (> (strlen text) 0)
    (setq next (vl-string-search " " text))
    (if next
      (progn
        (setq word (substr text 1 next) text (vl-string-trim " \t" (substr text (+ next 2)))))
      (setq word text text ""))
    (if (not (equal word "")) (setq words (cons (strcase word) words))))
  (reverse words))

(defun TT:PlantSearchMatchesP (entry words category favorites-only favorites / found word)
  (setq found T)
  (foreach word words
    (if (null (vl-string-search word (cdr entry))) (setq found nil)))
  (and found
       (or (null category) (eq category (TT:PlantRecordValue (car entry) 'CATEGORY)))
       (or (not favorites-only)
           (member (TT:PlantRecordValue (car entry) 'PLANT_ID) favorites))))

(defun TT:PlantSearch (query category favorites-only / words favorites entry result project cache-key)
  (setq project (TT:ProjectCurrent)
        cache-key (list (getvar "DWGPREFIX") (getvar "DWGNAME")
                    (if project (TT:ProjectValue project 'PROJECT_UUID))
                    (if project (TT:ProjectValue project 'PLANT_DATA_PATHS))))
  (if (or (not (boundp '*TT:PlantSearchContext*))
          (not (equal cache-key *TT:PlantSearchContext*)))
    (setq *TT:PlantSearchIndex* nil *TT:PlantSearchContext* cache-key))
  (if (null *TT:PlantSearchIndex*) (TT:PlantSearchBuildIndex))
  (setq words (TT:StringWords query)
        project (TT:ProjectCurrent)
        favorites (if project (TT:ProjectValue project 'PLANT_FAVORITES)))
  (if (not (eq (type favorites) 'LIST)) (setq favorites nil))
  (foreach entry *TT:PlantSearchIndex*
    (if (TT:PlantSearchMatchesP entry words category favorites-only favorites)
      (setq result (cons (car entry) result))))
  (reverse result))

(defun TT:PlantSearchLabel (record)
  (strcat (TT:PlantDisplayValue (TT:PlantRecordValue record 'PLANT_CODE)) " | "
          (TT:PlantDisplayValue (TT:PlantRecordValue record 'BOTANICAL_NAME)) " | "
          (TT:PlantDisplayValue (TT:PlantRecordValue record 'COMMON_NAME))))

(defun TT:PlantSearchPrintPage (records / index record)
  (setq index 1)
  (foreach record records
    (princ (strcat "\n  " (itoa index) ". " (TT:PlantSearchLabel record)
                   " | " (TT:PlantCategoryName (TT:PlantRecordValue record 'CATEGORY))))
    (setq index (1+ index)))
  (princ))

(defun TT:PlantPage (records page size / start index result)
  (setq start (* page size) index 0)
  (foreach record records
    (if (and (>= index start) (< index (+ start size)))
      (setq result (cons record result)))
    (setq index (1+ index)))
  (reverse result))

(defun TT:PlantRememberRecent (plant-id / project recent)
  (setq project (TT:ProjectCurrent) recent (if project (TT:ProjectValue project 'PLANT_RECENT)))
  (if (not (eq (type recent) 'LIST)) (setq recent nil))
  (if project
    (progn
      (setq recent (cons plant-id (vl-remove plant-id recent)))
      (while (> (length recent) 20) (setq recent (reverse (cdr (reverse recent)))))
      (TT:ProjectSaveSection 'PLANT_RECENT recent))))

(defun TT:PlantToggleFavorite (record / project id favorites)
  (setq project (TT:ProjectCurrent) id (TT:PlantRecordValue record 'PLANT_ID)
        favorites (if project (TT:ProjectValue project 'PLANT_FAVORITES)))
  (if (not (eq (type favorites) 'LIST)) (setq favorites nil))
  (if project
    (progn
      (if (member id favorites)
        (progn (setq favorites (vl-remove id favorites)) (princ "\nPlant removed from favorites."))
        (progn (setq favorites (cons id favorites)) (princ "\nPlant added to favorites.")))
      (TT:ProjectSaveSection 'PLANT_FAVORITES favorites))))

(defun TT:PlantSearchChooseFromPage (page-records)
  (if page-records
    (TT:PromptNumberedRecord page-records 'TT:PlantSearchLabel "Select result number")
    nil))

(defun C:TTPLANTSEARCHCLI (/ *error* query category favorites-only results page pages visible option selected enriched)
  (defun *error* (message) (TT:ReportError "TTPLANTSEARCH" message))
  (setq query (getstring T "\nPlant search words <all>: "))
  (initget "All Tree Shrub Groundcover Favorites")
  (setq category (getkword
    "\nFilter [All/Tree/Shrub/Groundcover/Favorites] <All>: "))
  (setq favorites-only (equal category "Favorites")
        category (if (member category '("Tree" "Shrub" "Groundcover"))
                   (TT:PlantCategoryFromValue category) nil)
        results (TT:PlantSearch query category favorites-only)
        page 0 pages (max 1 (fix (+ 0.999999 (/ (float (length results)) *TT:PlantSearchPageSize*)))))
  (if (null results)
    (princ "\nNo plants match the search.")
    (progn
      (setq option "Next")
      (while option
        (setq visible (TT:PlantPage results page *TT:PlantSearchPageSize*))
        (princ (strcat "\nPlant search results " (itoa (1+ (* page *TT:PlantSearchPageSize*)))
                       "-" (itoa (+ (* page *TT:PlantSearchPageSize*) (length visible)))
                       " of " (itoa (length results))))
        (TT:PlantSearchPrintPage visible)
        (initget "Add Favorite Next Previous Exit")
        (setq option (getkword "\nSearch [Add/Favorite/Next/Previous/Exit] <Exit>: "))
        (cond
          ((or (null option) (equal option "Exit")) (setq option nil))
          ((equal option "Next") (if (< (1+ page) pages) (setq page (1+ page))
                                    (princ "\nAlready at the last page.")))
          ((equal option "Previous") (if (> page 0) (setq page (1- page))
                                        (princ "\nAlready at the first page.")))
          ((member option '("Add" "Favorite"))
            (setq selected (TT:PlantSearchChooseFromPage visible))
            (if selected
              (if (equal option "Favorite")
                (TT:PlantToggleFavorite selected)
                (progn
                  (setq enriched selected)
                  (if (null (TT:PlantRecordValue enriched 'CATEGORY))
                    (progn
                      (princ "\nThis source does not supply a TerraTools category.")
                      (setq category (TT:PlantPromptCategory nil))
                      (if category (setq enriched (TT:PlantRecordWithValue enriched 'CATEGORY category)))))
                  (if (and (TT:PlantRecordValue enriched 'CATEGORY)
                           (TT:PlantPaletteAddMaster enriched))
                    (TT:PlantRememberRecent (TT:PlantRecordValue selected 'PLANT_ID)))))))))))
  (princ))

(defun TT:PlantUserAdd (/ library plants category scientific common code record)
  (setq library (TT:PlantUserLoad) plants (if library (TT:DataValue library 'PLANTS))
        category (TT:PlantPromptCategory nil))
  (if category
    (progn
      (setq scientific (getstring T "\nScientific name: ")
            common (if (not (equal scientific "")) (getstring T "\nCommon name: "))
            code (if (and common (not (equal common ""))) (getstring T "\nDefault plant code: ")))
      (if (and code (not (equal code "")))
        (progn
          (setq record (list 'PLANT_RECORD
            (cons 'PLANT_ID (strcat "USER-" (TT:GenerateUUID)))
            (cons 'CATEGORY category) (cons 'BOTANICAL_NAME scientific)
            (cons 'COMMON_NAME common) (cons 'PLANT_CODE code)
            (cons 'SIZE "") (cons 'SPACING "") (cons 'UNIT_COST "")
            (cons 'SYMBOL_BLOCK "") (cons 'NOTES "")
            (cons 'SOURCE "USER") (cons 'SOURCE_LICENSE "USER_PROVIDED")))
          (setq library (TT:DataPut library 'PLANTS (append plants (list record))))
          (if (TT:PlantUserSave library)
            (princ "\nUser plant saved outside the distributed master catalog.")
            (princ "\nCould not save the user plant library.")))
        (princ "\nScientific name, common name, and code are required."))))
  (princ))

(defun C:TTPLANTUSER (/ option plants)
  (initget "List Add")
  (setq option (getkword "\nUser plant library [List/Add] <List>: "))
  (if (or (null option) (equal option "List"))
    (progn
      (setq plants (TT:PlantUserGetAll))
      (TT:PlantPrintMasterList plants))
    (TT:PlantUserAdd))
  (princ))

(defun TT:USDARecord (row map / symbol scientific common family synonym)
  (setq symbol (TT:CSVField row map "Symbol")
        synonym (TT:CSVField row map "Synonym Symbol")
        scientific (TT:CSVField row map "Scientific Name with Authors")
        common (TT:CSVField row map "National Common Name")
        family (TT:CSVField row map "Family"))
  (if (and (TT:PlantNonEmptyStringP symbol) (TT:PlantNonEmptyStringP scientific))
    (list 'NORMALIZED_PLANT
      (cons 'PLANT_ID (strcat "USDA-PLANTS-" symbol))
      (cons 'SOURCE "USDA PLANTS") (cons 'SOURCE_ID symbol)
      (cons 'SCIENTIFIC_NAME scientific) (cons 'ACCEPTED_SCIENTIFIC_NAME "")
      (cons 'GENUS "") (cons 'SPECIES "") (cons 'CULTIVAR "")
      (cons 'COMMON_NAME (if common common "")) (cons 'COMMON_NAMES (if common (list common) nil))
      (cons 'FAMILY (if family family "")) (cons 'SYNONYMS (if synonym (list synonym) nil))
      (cons 'CATEGORY nil) (cons 'GROWTH_HABIT "")
      (cons 'EVERGREEN_DECIDUOUS "")
      (cons 'HARDINESS_MIN nil) (cons 'HARDINESS_MAX nil)
      (cons 'WATER_USE "") (cons 'SUN_REQUIREMENT "")
      (cons 'SOIL_PREFERENCES "")
      (cons 'MATURE_HEIGHT_MIN nil) (cons 'MATURE_HEIGHT_MAX nil)
      (cons 'MATURE_WIDTH_MIN nil) (cons 'MATURE_WIDTH_MAX nil)
      (cons 'NATIVE_REGIONS nil) (cons 'STATE_DISTRIBUTION nil)
      (cons 'BLOOM_SEASON "") (cons 'BLOOM_COLOR "")
      (cons 'FOLIAGE_COLOR "") (cons 'GROWTH_RATE "")
      (cons 'LANDSCAPE_USES nil) (cons 'WETLAND_STATUS "")
      (cons 'DEFAULT_SPACING "") (cons 'DEFAULT_SIZE "")
      (cons 'DEFAULT_CODE symbol) (cons 'DEFAULT_SYMBOL "")
      (cons 'SOURCE_URL "https://plants.usda.gov/home")
      (cons 'SOURCE_LICENSE "USDA federal plant text/data; see DATA_SOURCES.md")
      (cons 'SOURCE_ATTRIBUTION "USDA Natural Resources Conservation Service, PLANTS Database")
      (cons 'SOURCE_DATE "")
      (cons 'NOTES "Imported fields only; TerraTools category requires user classification."))))

(defun C:TTIMPORTUSDA (/ source destination rows map records row record catalog)
  ;; An empty extension shows all file types, including normal .csv and USDA .txt files.
  (setq source (getfiled "Select USDA PLANTS CSV or text checklist" "" "" 0))
  (if source
    (progn
      (princ "\nReading USDA source file...")
      (setq rows (TT:CSVReadFile source))
      (cond
        ((or (null rows) (< (length rows) 2))
          (princ "\nThe USDA source file is empty, unreadable, or has unsupported CSV rows."))
        (T
          (setq map (TT:CSVHeaderMap (car rows)))
          (if (or (null (assoc "SYMBOL" map))
                  (null (assoc "SCIENTIFIC NAME WITH AUTHORS" map)))
            (princ "\nRequired USDA checklist headers are missing.")
            (progn
              (foreach row (cdr rows)
                (setq record (TT:USDARecord row map))
                (if record (setq records (cons record records))))
              (setq records (reverse records))
              (if (null records)
                (princ "\nNo valid USDA plant records were found.")
                (progn
                  (setq destination (getfiled "Write normalized TerraTools plant data"
                                      "usda-plants-normalized.dat" "dat" 1))
                  (if destination
                    (progn
                      (setq catalog (list 'TERRATOOLS_NORMALIZED_PLANTS
                        (cons 'DATA_SCHEMA_VERSION *TT:PlantNormalizedSchemaVersion*)
                        (cons 'SOURCE "USDA PLANTS")
                        (cons 'SOURCE_URL "https://plants.usda.gov/downloads")
                        (cons 'IMPORTED_DATE (TT:ProjectCreatedDate))
                        (cons 'PLANTS records)))
                      (if (TT:StorageWrite destination catalog)
                        (princ (strcat "\nImported " (itoa (length records))
                                       " USDA record(s): " destination))
                        (princ "\nThe normalized plant catalog could not be written.")))))))))))
  (princ)))

(defun C:TTPLANTDATA (/ project option path paths records)
  (setq project (TT:ProjectCurrent))
  (if project
    (progn
      (initget "Info Attach Detach")
      (setq option (getkword "\nExternal plant data [Info/Attach/Detach] <Info>: ")
            paths (TT:ProjectValue project 'PLANT_DATA_PATHS))
      (if (not (eq (type paths) 'LIST)) (setq paths nil))
      (cond
        ((or (null option) (equal option "Info"))
          (princ "\nAttached normalized plant catalogs")
          (foreach path paths
            (setq records (TT:PlantNormalizedLoad path))
            (princ (strcat "\n  " path " | "
                           (if records (strcat (itoa (length records)) " records") "unreadable")))))
        ((equal option "Attach")
          (setq path (getfiled "Attach normalized TerraTools plant data" "" "dat" 0)
                records (if path (TT:PlantNormalizedLoad path)))
          (cond ((null path) nil)
                ((null records) (princ "\nThe selected normalized catalog is invalid or empty."))
                ((member path paths) (princ "\nThat plant catalog is already attached."))
                ((TT:ProjectSaveSection 'PLANT_DATA_PATHS (append paths (list path)))
                  (setq *TT:PlantSearchIndex* nil)
                  (princ (strcat "\nAttached " (itoa (length records)) " plant records.")))))
        ((equal option "Detach")
          (if paths
            (progn
              (setq path (TT:PromptNumberedRecord
                (mapcar '(lambda (value) (list 'PLANT_DATA_PATH (cons 'PATH value))) paths)
                '(lambda (record) (TT:DataValue record 'PATH)) "Select catalog number"))
              (if path
                (if (TT:ProjectSaveSection 'PLANT_DATA_PATHS
                      (vl-remove (TT:DataValue path 'PATH) paths))
                  (progn
                    (setq *TT:PlantSearchIndex* nil)
                    (princ
                      "\nPlant catalog detached. Project Plant copies remain available; the source file was not deleted."))
                  (princ "\nPlant catalog could not be detached."))))))))
    (princ "\nNo TerraTools project is associated with this drawing."))
  (princ))

T
