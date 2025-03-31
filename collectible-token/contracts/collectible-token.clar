;; collectible-token.clar
;; An enhanced NFT implementation in Clarity 6.0 with batch minting, burn and URI update functionality

;; Constants
(define-constant admin-owner tx-sender)
(define-constant err-admin-only (err u100))
(define-constant err-not-collectible-owner (err u101))
(define-constant err-collectible-exists (err u102))
(define-constant err-collectible-not-found (err u103))
(define-constant err-invalid-collectible-uri (err u104))
(define-constant err-destroy-failed (err u105))
(define-constant err-already-destroyed (err u106))
(define-constant err-not-collectible-owner-update (err u107))
(define-constant err-invalid-batch-size (err u108))
(define-constant err-batch-mint-failed (err u109))
(define-constant max-batch-size u100)  ;; Maximum tokens that can be minted in a single batch

;; Data Variables
(define-non-fungible-token collectible-token uint)
(define-data-var latest-collectible-id uint u0)

;; Maps
(define-map collectible-uri uint (string-ascii 256))
(define-map destroyed-collectibles uint bool)  ;; Track burned tokens
(define-map batch-info uint (string-ascii 256))  ;; Store batch metadata

;; Private Functions
(define-private (is-collectible-owner (collectible-id uint) (sender principal))
    (is-eq sender (unwrap! (nft-get-owner? collectible-token collectible-id) false)))

(define-private (is-valid-collectible-uri (uri (string-ascii 256)))
    (let ((uri-length (len uri)))
        (and (>= uri-length u1)
             (<= uri-length u256))))

(define-private (is-collectible-destroyed (collectible-id uint))
    (default-to false (map-get? destroyed-collectibles collectible-id)))

(define-private (mint-single (collectible-uri-data (string-ascii 256)))
    (let ((collectible-id (+ (var-get latest-collectible-id) u1)))
        (asserts! (is-valid-collectible-uri collectible-uri-data) err-invalid-collectible-uri)
        (try! (nft-mint? collectible-token collectible-id tx-sender))
        (map-set collectible-uri collectible-id collectible-uri-data)
        (var-set latest-collectible-id collectible-id)
        (ok collectible-id)))

;; Public Functions
(define-public (mint (collectible-uri-data (string-ascii 256)))
    (begin
        ;; Validate that the caller is the contract owner
        (asserts! (is-eq tx-sender admin-owner) err-admin-only)

        ;; Validate the token URI
        (asserts! (is-valid-collectible-uri collectible-uri-data) err-invalid-collectible-uri)

        ;; Proceed with minting the token
        (mint-single collectible-uri-data)))

(define-public (batch-mint (uris (list 100 (string-ascii 256))))
    (let 
        ((batch-size (len uris)))
        (begin
            (asserts! (is-eq tx-sender admin-owner) err-admin-only)
            (asserts! (<= batch-size max-batch-size) err-invalid-batch-size)
            (asserts! (> batch-size u0) err-invalid-batch-size)

            ;; Use fold to process the URIs and mint tokens
            (ok (fold mint-single-in-batch uris (list)))
        )))

(define-private (mint-single-in-batch (uri (string-ascii 256)) (previous-results (list 100 uint)))
    (match (mint-single uri)
        success (unwrap-panic (as-max-len? (append previous-results success) u100))
        error previous-results))

(define-public (destroy (collectible-id uint))
    (let ((collectible-owner (unwrap! (nft-get-owner? collectible-token collectible-id) err-collectible-not-found)))
        (asserts! (is-eq tx-sender collectible-owner) err-not-collectible-owner)
        (asserts! (not (is-collectible-destroyed collectible-id)) err-already-destroyed)
        (try! (nft-burn? collectible-token collectible-id collectible-owner))
        (map-set destroyed-collectibles collectible-id true)
        (ok true)))

(define-public (transfer (collectible-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq recipient tx-sender) err-not-collectible-owner)
        (asserts! (not (is-collectible-destroyed collectible-id)) err-already-destroyed)
        (let ((actual-sender (unwrap! (nft-get-owner? collectible-token collectible-id) err-not-collectible-owner)))
            (asserts! (is-eq actual-sender sender) err-not-collectible-owner)
            (try! (nft-transfer? collectible-token collectible-id sender recipient))
            (ok true))))

(define-public (update-collectible-uri (collectible-id uint) (new-uri (string-ascii 256)))
    (begin
        (let ((collectible-owner (unwrap! (nft-get-owner? collectible-token collectible-id) err-collectible-not-found)))
            (asserts! (is-eq collectible-owner tx-sender) err-not-collectible-owner-update)
            (asserts! (is-valid-collectible-uri new-uri) err-invalid-collectible-uri)
            (map-set collectible-uri collectible-id new-uri)
            (ok true))))

;; Read-Only Functions
(define-read-only (get-collectible-uri (collectible-id uint))
    (ok (map-get? collectible-uri collectible-id)))

(define-read-only (get-owner (collectible-id uint))
    (ok (nft-get-owner? collectible-token collectible-id)))

(define-read-only (get-latest-collectible-id)
    (ok (var-get latest-collectible-id)))

(define-read-only (is-destroyed (collectible-id uint))
    (ok (is-collectible-destroyed collectible-id)))

(define-read-only (get-batch-collectible-ids (start-id uint) (count uint))
    (ok (map uint-to-response 
        (unwrap-panic (as-max-len? 
            (list-collectibles start-id count) 
            u100)))))

(define-private (uint-to-response (id uint))
    {
        collectible-id: id,
        uri: (unwrap-panic (get-collectible-uri id)),
        owner: (unwrap-panic (get-owner id)),
        destroyed: (unwrap-panic (is-destroyed id))
    })

(define-private (list-collectibles (start uint) (count uint))
    (map + 
        (list start) 
        (generate-sequence count)))

(define-private (generate-sequence (length uint))
    (map - (list length)))

;; Contract initialization
(begin
    (var-set latest-collectible-id u0))
