;; Location Tracking Contract - Simplified
;; Monitors baggage location throughout journey

;; Define data variables
(define-data-var location-id-counter uint u0)

(define-map location-updates
  { id: uint }
  {
    luggage-id: uint,
    airport: (string-ascii 3),
    zone: (string-ascii 20),
    scanner: principal,
    is-on-track: bool,
    notes: (string-ascii 50)
  }
)

(define-map current-location
  { luggage-id: uint }
  {
    airport: (string-ascii 3),
    zone: (string-ascii 20),
    is-on-track: bool
  }
)

;; Error codes
(define-constant ERR_UNAUTHORIZED u1)
(define-constant ERR_NOT_FOUND u2)

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Record location update
(define-public (record-location
              (luggage-id uint)
              (airport (string-ascii 3))
              (zone (string-ascii 20))
              (is-on-track bool)
              (notes (string-ascii 50)))
  (let
    (
      (location-id (+ (var-get location-id-counter) u1))
    )
    ;; Check if caller is contract owner
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))

    ;; Update counter
    (var-set location-id-counter location-id)

    ;; Store location update
    (map-set location-updates
      { id: location-id }
      {
        luggage-id: luggage-id,
        airport: airport,
        zone: zone,
        scanner: tx-sender,
        is-on-track: is-on-track,
        notes: notes
      }
    )

    ;; Update current location
    (map-set current-location
      { luggage-id: luggage-id }
      {
        airport: airport,
        zone: zone,
        is-on-track: is-on-track
      }
    )

    (ok location-id)
  )
)

;; Read-only functions
(define-read-only (get-location-update (location-id uint))
  (map-get? location-updates { id: location-id })
)

(define-read-only (get-current-location (luggage-id uint))
  (map-get? current-location { luggage-id: luggage-id })
)

;; Set contract owner
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))
    (ok (var-set contract-owner new-owner))
  )
)

