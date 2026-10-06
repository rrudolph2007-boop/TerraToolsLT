;;; TerraTools LT - In-product command and workflow help.

(setq *TT:HelpModuleLoaded* T)

(defun TT:HelpPrint (topic)
  (cond
    ((equal topic "Project")
      (princ "\nPROJECT: TTPROJECT, TTPROJECTINFO, TTPREFERENCES, TTSCALE, TTUNITS, TTSTANDARDS"))
    ((equal topic "Planting")
      (princ "\nPLANTING: TTPLANTSEARCH, TTPLANTS, TTPLACEPLANT, TTPLANTLINE, TTPLANTARRAY, TTPLANTRANDOM, TTPLANTAREA, TTMIX, TTLABELPLANT, TTPLANTSCHEDULE, TTPLANTCOST"))
    ((equal topic "Site")
      (princ "\nSITE: TTREFNOTE, TTREFSCHEDULE, TTMEASURE, TTSLOPE, TTSPOTELEV, TTCONCEPT"))
    ((equal topic "Details")
      (princ "\nDETAILS: TTDETAILS, TTPLACEDETAIL, TTDETAILCALLOUT, TTDETAILINDEX"))
    ((equal topic "Lighting")
      (princ "\nLIGHTING: TTLIGHTING, TTPLACEFIXTURE, TTLIGHTWIRE, TTTRANSFORMER, TTCIRCUIT, TTLIGHTINGSCHEDULE"))
    ((equal topic "Irrigation")
      (princ "\nIRRIGATION: TTIRRIGATION, TTPLACEIRRIGATION, TTMAINLINE, TTLATERAL, TTVERIFYIRRIGATION, TTANALYZEIRRIGATION, TTIRRIGATIONSIZE, TTCRITICALPATH"))
    ((equal topic "Schedules")
      (princ "\nSCHEDULES: TTPLANTSCHEDULE, TTUPDATEPLANTSCHEDULE, TTREFSCHEDULE, TTDETAILINDEX, TTLIGHTINGSCHEDULE, TTIRRIGATIONSCHEDULE"))
    ((equal topic "Diagnostics")
      (princ "\nDIAGNOSTICS: TTINFO, TTVERIFY, TTFIX, TTRECONCILE, TTDEBUG, TTDEVSMOKE, TTQACHECK, TTRELOAD"))
    (T
      (princ "\nHELP: choose a module for its main commands. The full workflow guide is docs/USER_GUIDE.md.")))
  (princ))

(defun C:TTHELP (/ topic)
  (initget "Project Planting Site Details Lighting Irrigation Schedules Diagnostics")
  (setq topic (getkword
    "\nTerraTools help [Project/Planting/Site/Details/Lighting/Irrigation/Schedules/Diagnostics] <General>: "))
  (TT:HelpPrint topic))

T
