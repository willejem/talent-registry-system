;; ===============================================
;; TALENT REGISTRY SYSTEM
;; ===============================================
;;
;; A blockchain-based registry for tracking skilled individuals
;; who can contribute to community projects and initiatives.
;;
;; This contract enables talent management through:
;; - Creating new talent records
;; - Modifying existing talent information
;; - Querying talent details and expertise
;; - Verifying talent availability and capabilities
;;
;; The system maintains data integrity with comprehensive
;; validation and clear error reporting.
;; ===============================================

;; ------------------- DATA STORAGE -------------------
;; Central repository for all registered talent information
(define-map talent-database
    principal  ;; Identity key of the talent
    {
        personal-identifier: (string-ascii 100),  ;; Legal name or preferred identity
        base-region: (string-ascii 100),          ;; Geographic operating area
        expertise-areas: (list 10 (string-ascii 50)),  ;; Specialization fields (max 10)
        weekly-capacity: uint                     ;; Time commitment in hours
    }
)

;; ------------------- ERROR DEFINITIONS -------------------
;; Standardized error codes for consistent response handling
(define-constant ERROR-RECORD-MISSING (err u404))       ;; Requested talent not in database
(define-constant ERROR-DUPLICATE-ENTRY (err u409))      ;; Talent already registered
(define-constant ERROR-EXPERTISE-INVALID (err u403))    ;; Expertise data validation failed
(define-constant ERROR-CAPACITY-INVALID (err u400))     ;; Weekly hours validation failed

;; ------------------- READ OPERATIONS -------------------
;; Collection of non-state-changing query functions

;; Retrieve complete talent record by principal ID
(define-read-only (fetch-talent-record (identity principal))
    (match (map-get? talent-database identity)
        record (ok record)
        ERROR-RECORD-MISSING
    )
)

;; Extract only expertise information from talent record
(define-read-only (fetch-talent-expertise (identity principal))
    (match (map-get? talent-database identity)
        record (ok (get expertise-areas record))
        ERROR-RECORD-MISSING
    )
)

;; Determine talent registration status
(define-read-only (check-registration-status (identity principal))
    (if (is-some (map-get? talent-database identity))
        (ok "Registered")
        (ok "Not Registered")
    )
)

;; Retrieve talent's weekly time availability
(define-read-only (fetch-talent-capacity (identity principal))
    (match (map-get? talent-database identity)
        record (ok (get weekly-capacity record))
        ERROR-RECORD-MISSING
    )
)

;; Get talent's operating location
(define-read-only (fetch-talent-region (identity principal))
    (match (map-get? talent-database identity)
        record (ok (get base-region record))
        ERROR-RECORD-MISSING
    )
)

;; Check if talent exists in the registry
(define-read-only (verify-talent-exists (identity principal))
    (if (is-some (map-get? talent-database identity))
        (ok true)
        (ok false)
    )
)

;; Retrieve personal identifier for a talent
(define-read-only (fetch-talent-identifier (identity principal))
    (match (map-get? talent-database identity)
        record (ok (get personal-identifier record))
        ERROR-RECORD-MISSING
    )
)

;; Count expertise areas for a talent
(define-read-only (count-expertise-areas (identity principal))
    (match (map-get? talent-database identity)
        record (ok (len (get expertise-areas record)))
        ERROR-RECORD-MISSING
    )
)

;; Generate summarized view of talent record
(define-read-only (generate-talent-summary (identity principal))
    (match (map-get? talent-database identity)
        record (ok {
            personal-identifier: (get personal-identifier record),
            base-region: (get base-region record),
            expertise-count: (len (get expertise-areas record))
        })
        ERROR-RECORD-MISSING
    )
)

;; Verify talent has valid expertise areas
(define-read-only (validate-talent-expertise (identity principal))
    (match (map-get? talent-database identity)
        record (if (> (len (get expertise-areas record)) u0)
                   (ok true)
                   (ok false))
        ERROR-RECORD-MISSING
    )
)

;; Get complete talent profile data
(define-read-only (fetch-complete-talent-profile (identity principal))
    (match (map-get? talent-database identity)
        record (ok {
            personal-identifier: (get personal-identifier record),
            base-region: (get base-region record),
            expertise-areas: (get expertise-areas record),
            weekly-capacity: (get weekly-capacity record)
        })
        ERROR-RECORD-MISSING
    )
)

;; Get geography and specializations together
(define-read-only (fetch-region-and-expertise (identity principal))
    (match (map-get? talent-database identity)
        record (ok {
            base-region: (get base-region record),
            expertise-areas: (get expertise-areas record)
        })
        ERROR-RECORD-MISSING
    )
)

;; ------------------- WRITE OPERATIONS -------------------
;; State-changing functions for talent record management

;; Create new talent entry in the registry
(define-public (create-talent-entry
    (personal-identifier (string-ascii 100))
    (base-region (string-ascii 100))
    (expertise-areas (list 10 (string-ascii 50)))
    (weekly-capacity uint)
)
    (let
        (
            (initiator tx-sender)
            (existing-entry (map-get? talent-database initiator))
        )
        (if (is-none existing-entry)
            (begin
                ;; Input validation
                (if (or (is-eq personal-identifier "")
                        (is-eq base-region "")
                        (is-eq (len expertise-areas) u0)
                        (< weekly-capacity u1))
                    (err ERROR-CAPACITY-INVALID)
                    (begin
                        ;; Create new talent record
                        (map-set talent-database initiator
                            {
                                personal-identifier: personal-identifier,
                                base-region: base-region,
                                expertise-areas: expertise-areas,
                                weekly-capacity: weekly-capacity
                            }
                        )
                        (ok "Talent successfully registered in system.")
                    )
                )
            )
            (err ERROR-DUPLICATE-ENTRY)
        )
    )
)

;; Modify existing talent record
(define-public (modify-talent-entry
    (personal-identifier (string-ascii 100))
    (base-region (string-ascii 100))
    (expertise-areas (list 10 (string-ascii 50)))
    (weekly-capacity uint)
)
    (let
        (
            (initiator tx-sender)
            (existing-entry (map-get? talent-database initiator))
        )
        (if (is-some existing-entry)
            (begin
                ;; Input validation
                (if (or (is-eq personal-identifier "")
                        (is-eq base-region "")
                        (is-eq (len expertise-areas) u0)
                        (< weekly-capacity u1))
                    (err ERROR-CAPACITY-INVALID)
                    (begin
                        ;; Update talent record
                        (map-set talent-database initiator
                            {
                                personal-identifier: personal-identifier,
                                base-region: base-region,
                                expertise-areas: expertise-areas,
                                weekly-capacity: weekly-capacity
                            }
                        )
                        (ok "Talent record successfully updated.")
                    )
                )
            )
            (err ERROR-RECORD-MISSING)
        )
    )
)

;; ------------------- END OF CONTRACT -------------------



