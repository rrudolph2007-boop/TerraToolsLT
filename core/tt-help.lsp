;;; Workflow help uses the same trusted task inventory as the UI menus.
(setq *TT:HelpModuleLoaded* T)

(defun TT:HelpPrint (topic / kind task command-name)
  (setq kind (cdr (assoc topic '(("Project" . PROJECT) ("Planting" . PLANTS)
    ("WorkAreas" . WORK) ("Site" . SITE) ("Details" . DETAIL) ("Lighting" . LIGHT)
    ("Irrigation" . IRR) ("Schedules" . OUTPUT) ("Diagnostics" . CHECK) ("Recovery" . RECOVERY) ("Libraries" . DATA)))))
  (if kind
    (progn
      (princ (strcat "\n" (TT:UXTitle kind)))
      (if (eq kind 'PLANTS)
        (princ "\nTTPLANTS - Project Plants are your design copies. Search Plant Library to add more.\nThe database banner reports installed open data; SAMPLE rows are demonstrations."))
      (foreach task (TT:UXTasks kind)
        (setq command-name (vl-symbol-name (cadr task)))
        (princ (strcat "\n" (car task) " - " (nth 2 task)
          (if (= (substr command-name 1 2) "C:") (strcat " [" (substr command-name 3) "]") "")))))
    (princ "\nStart with TT: open a project, add project records, place objects, then review output.\nPlant Library holds source plants; Project Plants holds editable design copies.\nTools menus expose common tasks. Full guide: docs/USER_GUIDE.md."))
  (princ))

(defun C:TTHELP (/ topic)
  (initget "Project Planting WorkAreas Site Details Lighting Irrigation Schedules Diagnostics Recovery Libraries")
  (setq topic (getkword "\nHelp [Project/Planting/WorkAreas/Site/Details/Lighting/Irrigation/Schedules/Diagnostics/Recovery/Libraries] <GettingStarted>: "))
  (TT:HelpPrint topic))
T
