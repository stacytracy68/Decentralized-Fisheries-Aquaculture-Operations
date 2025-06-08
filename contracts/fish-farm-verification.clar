;; Fish Farm Verification Contract
;; Validates and manages aquaculture operations

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_FARM_NOT_FOUND (err u101))
(define-constant ERR_FARM_ALREADY_EXISTS (err u102))

;; Farm verification status
(define-data-var next-farm-id uint u1)

;; Farm data structure
(define-map farms
  { farm-id: uint }
  {
    owner: principal,
    location: (string-ascii 100),
    farm-type: (string-ascii 50),
    capacity: uint,
    verified: bool,
    registration-date: uint
  }
)

;; Verified operators
(define-map verified-operators principal bool)

;; Register a new fish farm
(define-public (register-farm (location (string-ascii 100)) (farm-type (string-ascii 50)) (capacity uint))
  (let ((farm-id (var-get next-farm-id)))
    (map-set farms
      { farm-id: farm-id }
      {
        owner: tx-sender,
        location: location,
        farm-type: farm-type,
        capacity: capacity,
        verified: false,
        registration-date: block-height
      }
    )
    (var-set next-farm-id (+ farm-id u1))
    (ok farm-id)
  )
)

;; Verify a farm (only contract owner)
(define-public (verify-farm (farm-id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (match (map-get? farms { farm-id: farm-id })
      farm-data (begin
        (map-set farms
          { farm-id: farm-id }
          (merge farm-data { verified: true })
        )
        (ok true)
      )
      ERR_FARM_NOT_FOUND
    )
  )
)

;; Get farm details
(define-read-only (get-farm (farm-id uint))
  (map-get? farms { farm-id: farm-id })
)

;; Check if farm is verified
(define-read-only (is-farm-verified (farm-id uint))
  (match (map-get? farms { farm-id: farm-id })
    farm-data (ok (get verified farm-data))
    ERR_FARM_NOT_FOUND
  )
)

;; Add verified operator
(define-public (add-verified-operator (operator principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set verified-operators operator true)
    (ok true)
  )
)

;; Check if operator is verified
(define-read-only (is-verified-operator (operator principal))
  (default-to false (map-get? verified-operators operator))
)
