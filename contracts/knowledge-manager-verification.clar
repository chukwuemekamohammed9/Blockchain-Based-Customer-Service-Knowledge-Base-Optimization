;; Knowledge Manager Verification Contract
;; Validates and manages customer service knowledge managers

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_NOT_FOUND (err u102))

;; Data maps
(define-map verified-managers principal bool)
(define-map manager-details principal {
    name: (string-ascii 50),
    department: (string-ascii 30),
    verification-date: uint,
    active: bool
})

;; Read-only functions
(define-read-only (is-verified-manager (manager principal))
    (default-to false (map-get? verified-managers manager))
)

(define-read-only (get-manager-details (manager principal))
    (map-get? manager-details manager)
)

;; Public functions
(define-public (verify-manager (manager principal) (name (string-ascii 50)) (department (string-ascii 30)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (not (is-verified-manager manager)) ERR_ALREADY_VERIFIED)
        (map-set verified-managers manager true)
        (map-set manager-details manager {
            name: name,
            department: department,
            verification-date: block-height,
            active: true
        })
        (ok true)
    )
)

(define-public (revoke-manager (manager principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-verified-manager manager) ERR_NOT_FOUND)
        (map-set verified-managers manager false)
        (map-set manager-details manager
            (merge (unwrap-panic (get-manager-details manager)) { active: false })
        )
        (ok true)
    )
)
