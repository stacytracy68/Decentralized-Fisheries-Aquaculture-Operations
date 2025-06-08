;; Feed Tracking Contract
;; Tracks aquaculture feed usage

(define-constant ERR_UNAUTHORIZED (err u400))
(define-constant ERR_INSUFFICIENT_FEED (err u401))
(define-constant ERR_INVALID_QUANTITY (err u402))

;; Feed inventory
(define-map feed-inventory
  { farm-id: uint, feed-type: (string-ascii 50) }
  {
    quantity: uint,        ;; in kg * 100
    cost-per-kg: uint,     ;; in cents
    expiry-date: uint,     ;; block height
    supplier: (string-ascii 100),
    last-updated: uint
  }
)

;; Feed usage tracking
(define-map feed-usage
  { farm-id: uint, date: uint, feed-type: (string-ascii 50) }
  {
    quantity-used: uint,
    fish-species: (string-ascii 50),
    feeding-time: (string-ascii 20),
    recorder: principal
  }
)

;; Feed orders
(define-map feed-orders
  { order-id: uint }
  {
    farm-id: uint,
    feed-type: (string-ascii 50),
    quantity: uint,
    cost: uint,
    supplier: (string-ascii 100),
    order-date: uint,
    delivery-date: uint,
    status: (string-ascii 20)
  }
)

(define-data-var next-order-id uint u1)

;; Add feed to inventory
(define-public (add-feed-inventory
  (farm-id uint)
  (feed-type (string-ascii 50))
  (quantity uint)
  (cost-per-kg uint)
  (expiry-date uint)
  (supplier (string-ascii 100))
)
  (begin
    (asserts! (> quantity u0) ERR_INVALID_QUANTITY)
    (let ((current-inventory (get-current-inventory farm-id feed-type)))
      (map-set feed-inventory
        { farm-id: farm-id, feed-type: feed-type }
        {
          quantity: (+ current-inventory quantity),
          cost-per-kg: cost-per-kg,
          expiry-date: expiry-date,
          supplier: supplier,
          last-updated: block-height
        }
      )
      (ok (+ current-inventory quantity))
    )
  )
)

;; Record feed usage
(define-public (record-feed-usage
  (farm-id uint)
  (feed-type (string-ascii 50))
  (quantity-used uint)
  (fish-species (string-ascii 50))
  (feeding-time (string-ascii 20))
)
  (begin
    (asserts! (> quantity-used u0) ERR_INVALID_QUANTITY)
    (let ((current-inventory (get-current-inventory farm-id feed-type)))
      (asserts! (>= current-inventory quantity-used) ERR_INSUFFICIENT_FEED)

      ;; Update inventory
      (map-set feed-inventory
        { farm-id: farm-id, feed-type: feed-type }
        (merge
          (unwrap-panic (map-get? feed-inventory { farm-id: farm-id, feed-type: feed-type }))
          {
            quantity: (- current-inventory quantity-used),
            last-updated: block-height
          }
        )
      )

      ;; Record usage
      (map-set feed-usage
        { farm-id: farm-id, date: block-height, feed-type: feed-type }
        {
          quantity-used: quantity-used,
          fish-species: fish-species,
          feeding-time: feeding-time,
          recorder: tx-sender
        }
      )
      (ok true)
    )
  )
)

;; Create feed order
(define-public (create-feed-order
  (farm-id uint)
  (feed-type (string-ascii 50))
  (quantity uint)
  (cost uint)
  (supplier (string-ascii 100))
  (delivery-date uint)
)
  (let ((order-id (var-get next-order-id)))
    (map-set feed-orders
      { order-id: order-id }
      {
        farm-id: farm-id,
        feed-type: feed-type,
        quantity: quantity,
        cost: cost,
        supplier: supplier,
        order-date: block-height,
        delivery-date: delivery-date,
        status: "PENDING"
      }
    )
    (var-set next-order-id (+ order-id u1))
    (ok order-id)
  )
)

;; Get current feed inventory
(define-read-only (get-current-inventory (farm-id uint) (feed-type (string-ascii 50)))
  (match (map-get? feed-inventory { farm-id: farm-id, feed-type: feed-type })
    inventory-data (get quantity inventory-data)
    u0
  )
)

;; Get feed inventory details
(define-read-only (get-inventory-details (farm-id uint) (feed-type (string-ascii 50)))
  (map-get? feed-inventory { farm-id: farm-id, feed-type: feed-type })
)

;; Get feed usage for a specific date
(define-read-only (get-feed-usage (farm-id uint) (date uint) (feed-type (string-ascii 50)))
  (map-get? feed-usage { farm-id: farm-id, date: date, feed-type: feed-type })
)

;; Calculate feed conversion ratio
(define-read-only (calculate-fcr (feed-used uint) (fish-weight-gain uint))
  (if (> fish-weight-gain u0)
    (ok (/ (* feed-used u100) fish-weight-gain))
    (err u999)
  )
)
