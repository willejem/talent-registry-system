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
