;; Luggage Registration Contract - Simplified
;; Creates digital identifiers for checked bags

;; Define data variables
(define-data-var luggage-id-counter uint u0)

(define-map luggage
  { id: uint }
  {
    passenger: principal,
    flight-number: (string-ascii 10),
    departure: (string-ascii 3),
    arrival: (string-ascii 3),
    description: (string-ascii 50),
    weight: uint,
    is-active: bool
  }
)

;; Error codes
(define-constant ERR_UNAUTHORIZED u1)
(define-constant ERR_NOT_FOUND u2)

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Register luggage
(define-public (register-luggage
              (flight-number (string-ascii 10))
              (departure (string-ascii 3))
              (arrival (string-ascii 3))
              (description (string-ascii 50))
              (weight uint))
  (let
    (
      (luggage-id (+ (var-get luggage-id-counter) u1))
    )
    ;; Update counter
    (var-set luggage-id-counter luggage-id)

    ;; Store luggage information
    (map-set luggage
      { id: luggage-id }
      {
        passenger: tx-sender,
        flight-number: flight-number,
        departure: departure,
        arrival: arrival,
        description: description,
        weight: weight,
        is-active: true
      }
    )

    (ok luggage-id)
  )
)

;; Register luggage by airline
(define-public (register-by-airline
              (passenger principal)
              (flight-number (string-ascii 10))
              (departure (string-ascii 3))
              (arrival (string-ascii 3))
              (description (string-ascii 50))
              (weight uint))
  (let
    (
      (luggage-id (+ (var-get luggage-id-counter) u1))
    )
    ;; Check if caller is contract owner
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))

    ;; Update counter
    (var-set luggage-id-counter luggage-id)

    ;; Store luggage information
    (map-set luggage
      { id: luggage-id }
      {
        passenger: passenger,
        flight-number: flight-number,
        departure: departure,
        arrival: arrival,
        description: description,
        weight: weight,
        is-active: true
      }
    )

    (ok luggage-id)
  )
)

;; Deactivate luggage
(define-public (deactivate-luggage (luggage-id uint))
  (let
    (
      (luggage-data (unwrap! (map-get? luggage { id: luggage-id }) (err ERR_NOT_FOUND)))
    )
    ;; Check if caller is the passenger or contract owner
    (asserts! (or
              (is-eq tx-sender (get passenger luggage-data))
              (is-eq tx-sender (var-get contract-owner)))
              (err ERR_UNAUTHORIZED))

    ;; Update luggage status
    (map-set luggage
      { id: luggage-id }
      (merge luggage-data { is-active: false })
    )

    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-luggage (luggage-id uint))
  (map-get? luggage { id: luggage-id })
)

;; Set contract owner
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))
    (ok (var-set contract-owner new-owner))
  )
)

