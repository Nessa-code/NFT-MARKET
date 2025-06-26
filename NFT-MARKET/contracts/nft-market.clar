;; NFT Marketplace Contract
;; Enables listing and trading of NFTs

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u300))
(define-constant err-listing-not-found (err u301))
(define-constant err-not-owner (err u302))
(define-constant err-insufficient-payment (err u303))
(define-constant err-listing-expired (err u304))
(define-constant err-fee-too-high (err u305))

(define-data-var listing-counter uint u0)
(define-data-var marketplace-fee uint u250) ;; 2.5% fee

(define-map listings uint {
  seller: principal,
  nft-contract: principal,
  token-id: uint,
  price: uint,
  expiry: uint,
  active: bool
})

(define-map sales-history uint {
  seller: principal,
  buyer: principal,
  price: uint,
  block-height: uint
})

(define-data-var total-volume uint u0)
(define-data-var total-sales uint u0)

(define-read-only (get-listing (listing-id uint))
  (map-get? listings listing-id))

(define-read-only (get-marketplace-fee)
  (var-get marketplace-fee))

(define-read-only (get-marketplace-stats)
  {
    total-volume: (var-get total-volume),
    total-sales: (var-get total-sales),
    active-listings: (var-get listing-counter)
  })

(define-public (create-listing (nft-contract principal) (token-id uint) (price uint) (duration uint))
  (let ((listing-id (+ (var-get listing-counter) u1)))
    (asserts! (> price u0) err-insufficient-payment)
    (map-set listings listing-id {
      seller: tx-sender,
      nft-contract: nft-contract,
      token-id: token-id,
      price: price,
      expiry: (+ stacks-block-height duration),
      active: true
    })
    (var-set listing-counter listing-id)
    (ok listing-id)))

(define-public (update-listing (listing-id uint) (new-price uint))
  (let ((listing (unwrap! (get-listing listing-id) err-listing-not-found)))
    (asserts! (is-eq tx-sender (get seller listing)) err-not-owner)
    (asserts! (get active listing) err-listing-not-found)
    (asserts! (< stacks-block-height (get expiry listing)) err-listing-expired)
    (map-set listings listing-id (merge listing {price: new-price}))
    (ok true)))

(define-public (cancel-listing (listing-id uint))
  (let ((listing (unwrap! (get-listing listing-id) err-listing-not-found)))
    (asserts! (is-eq tx-sender (get seller listing)) err-not-owner)
    (map-set listings listing-id (merge listing {active: false}))
    (ok true)))

(define-public (buy-nft (listing-id uint))
  (let ((listing (unwrap! (get-listing listing-id) err-listing-not-found))
        (price (get price listing))
        (fee (/ (* price (var-get marketplace-fee)) u10000))
        (seller-amount (- price fee)))
    (asserts! (get active listing) err-listing-not-found)
    (asserts! (< stacks-block-height (get expiry listing)) err-listing-expired)
    
    ;; Transfer payment to seller
    (try! (stx-transfer? seller-amount tx-sender (get seller listing)))
    
    ;; Transfer fee to contract
    (try! (stx-transfer? fee tx-sender (as-contract tx-sender)))
    
    ;; Mark listing as inactive
    (map-set listings listing-id (merge listing {active: false}))
    
    ;; Record sale
    (map-set sales-history listing-id {
      seller: (get seller listing),
      buyer: tx-sender,
      price: price,
      block-height: stacks-block-height
    })
    
    ;; Update stats
    (var-set total-volume (+ (var-get total-volume) price))
    (var-set total-sales (+ (var-get total-sales) u1))
    
    (ok true)))

(define-public (set-marketplace-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-fee u1000) err-fee-too-high)
    (var-set marketplace-fee new-fee)
    (ok true)))

(define-public (withdraw-fees)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let ((balance (stx-get-balance (as-contract tx-sender))))
      (try! (as-contract (stx-transfer? balance tx-sender contract-owner)))
      (ok balance))))
      