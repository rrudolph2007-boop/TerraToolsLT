;;; Application UUID generation without entity handles, COM, or ActiveX.
;;; DATE, MILLISECS, machine/session text, and continuing generator state seed
;;; four Park-Miller sequences. This is intended for application identity, not
;;; cryptographic use.

(defun TT:UUIDNextState (state / high low test)
  (if (or (not (numberp state)) (< state 1) (> state 2147483646))
    (setq state 1)
  )
  (setq high (fix (/ state 127773))
        low (- state (* high 127773))
        test (- (* 16807 low) (* 2836 high)))
  (if (> test 0)
    test
    (+ test 2147483647)
  )
)

(defun TT:UUIDHashString (text state / character index)
  (if text
    (progn
      (setq index 1)
      (while (<= index (strlen text))
        (setq character (ascii (substr text index 1))
              state
                (fix
                  (rem
                    (+ (float (TT:UUIDNextState state)) (float character))
                    2147483646.0)))
        (if (< state 1) (setq state 1))
        (setq index (1+ index))
      )
    )
  )
  state
)

(defun TT:UUIDSeed (salt / date-value millisecond-value seed)
  (setq date-value (getvar "DATE")
        millisecond-value (getvar "MILLISECS")
        seed
          (fix
            (rem
              (+ (* (float (fix date-value)) 86400.0)
                 (* (- date-value (fix date-value)) 86400.0)
                 (abs (float millisecond-value))
                 (float salt))
              2147483646.0)))
  (if (< seed 1) (setq seed 1))
  (setq seed (TT:UUIDHashString (rtos date-value 2 8) seed)
        seed (TT:UUIDHashString (itoa millisecond-value) seed)
        seed (TT:UUIDHashString (getenv "COMPUTERNAME") seed)
        seed (TT:UUIDHashString (getenv "USERNAME") seed)
        seed (TT:UUIDHashString (getvar "DWGPREFIX") seed)
        seed (TT:UUIDHashString (getvar "DWGNAME") seed))
  seed
)

(defun TT:InitializeUUID ()
  (if (not (and (numberp *TT:UUIDState1*)
                (> *TT:UUIDState1* 0)
                (< *TT:UUIDState1* 2147483647)
                (numberp *TT:UUIDState2*)
                (> *TT:UUIDState2* 0)
                (< *TT:UUIDState2* 2147483647)
                (numberp *TT:UUIDState3*)
                (> *TT:UUIDState3* 0)
                (< *TT:UUIDState3* 2147483647)
                (numberp *TT:UUIDState4*)
                (> *TT:UUIDState4* 0)
                (< *TT:UUIDState4* 2147483647)))
    (setq *TT:UUIDState1* (TT:UUIDSeed 104729)
          *TT:UUIDState2* (TT:UUIDSeed 130363)
          *TT:UUIDState3* (TT:UUIDSeed 155921)
          *TT:UUIDState4* (TT:UUIDSeed 196613))
  )
  (if (not (numberp *TT:UUIDCounter*))
    (setq *TT:UUIDCounter* 0)
  )
  T
)

(defun TT:GenerateUUID (/ character hex-digits index result slot value)
  (TT:InitializeUUID)
  (setq *TT:UUIDCounter* (1+ *TT:UUIDCounter*)
        *TT:UUIDState1*
          (TT:UUIDHashString (itoa *TT:UUIDCounter*) *TT:UUIDState1*)
        *TT:UUIDState2*
          (TT:UUIDHashString (itoa *TT:UUIDCounter*) *TT:UUIDState2*)
        *TT:UUIDState3*
          (TT:UUIDHashString (itoa *TT:UUIDCounter*) *TT:UUIDState3*)
        *TT:UUIDState4*
          (TT:UUIDHashString (itoa *TT:UUIDCounter*) *TT:UUIDState4*)
        hex-digits "0123456789abcdef"
        index 1
        result "")
  (while (<= index 32)
    (setq slot (rem index 4))
    (cond
      ((= slot 1)
        (setq *TT:UUIDState1* (TT:UUIDNextState *TT:UUIDState1*)
              value (rem *TT:UUIDState1* 16)))
      ((= slot 2)
        (setq *TT:UUIDState2* (TT:UUIDNextState *TT:UUIDState2*)
              value (rem *TT:UUIDState2* 16)))
      ((= slot 3)
        (setq *TT:UUIDState3* (TT:UUIDNextState *TT:UUIDState3*)
              value (rem *TT:UUIDState3* 16)))
      (T
        (setq *TT:UUIDState4* (TT:UUIDNextState *TT:UUIDState4*)
              value (rem *TT:UUIDState4* 16)))
    )
    (setq
          character
            (cond
              ((= index 13) "4")
              ((= index 17) (substr hex-digits (+ 9 (rem value 4)) 1))
              (T (substr hex-digits (1+ value) 1))))
    (if (member index '(9 13 17 21))
      (setq result (strcat result "-"))
    )
    (setq result (strcat result character)
          index (1+ index))
  )
  result
)

(defun C:TTTESTUUID (/ *error* count duplicate-found uuid uuid-list)
  (defun *error* (message)
    (TT:ReportError "TTTESTUUID" message)
  )
  (setq count 0
        duplicate-found nil
        uuid-list nil)
  (princ "\nGenerated UUIDs:")
  (repeat 10
    (setq uuid (TT:GenerateUUID))
    (if (member uuid uuid-list)
      (setq duplicate-found T)
    )
    (setq uuid-list (cons uuid uuid-list)
          count (1+ count))
    (princ (strcat "\n" (itoa count) ": " uuid))
  )
  (if duplicate-found
    (princ "\nUUID test failed: a duplicate UUID was generated.")
    (princ "\nAll 10 UUIDs are unique."))
  (princ)
)

(TT:InitializeUUID)
T
