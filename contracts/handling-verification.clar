;; Handling Verification Contract - Simplified
;; Tracks movement through airport systems

;; Define data variables
(define-data-var handling-id-counter uint u0)

(define-map handling-events
  { id: uint }
  {
    luggage-id: uint,
    handler: principal,
    role: (string-ascii 20),
    location: (string-ascii 3),
    status: (string-ascii 20),
    notes: (string-ascii 50)
  }
)

;; Error codes
(define-constant ERR_UNAUTHORIZED u1)
(define-constant ERR_NOT_FOUND u2)

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Record handling event
(define-public (record-handling
              (luggage-id uint)
              (role (string-ascii 20))
              (location (string-ascii 3))
              (status (string-ascii 20))
              (notes (string-ascii 50)))
  (let
    (
      (handling-id (+ (var-get handling-id-counter) u1))
    )
    ;; Check if caller is contract owner
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))

    ;; Update counter
    (var-set handling-id-counter handling-id)

    ;; Store handling event
    (map-set handling-events
      { id: handling-id }
      {
        luggage-id: luggage-id,
        handler: tx-sender,
        role: role,
        location: location,
        status: status,
        notes: notes
      }
    )

    (ok handling-id)
  )
)

;; Read-only functions
(define-read-only (get-handling-event (handling-id uint))
  (map-get? handling-events { id: handling-id })
)

;; Set contract owner
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))
    (ok (var-set contract-owner new-owner))
  )
)

