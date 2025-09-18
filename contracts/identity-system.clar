;; Digital Identity Verification System Smart Contract
;; Self-sovereign identity with privacy-preserving credentials and decentralized verification
;; version: 1.0
;; summary: Decentralized identity management with zero-knowledge proofs and verifiable credentials
;; description: Complete digital identity infrastructure supporting DIDs, credentials, and privacy-preserving verification

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u500))
(define-constant ERR_IDENTITY_NOT_FOUND (err u501))
(define-constant ERR_CREDENTIAL_NOT_FOUND (err u502))
(define-constant ERR_INVALID_PROOF (err u503))
(define-constant ERR_CREDENTIAL_REVOKED (err u504))
(define-constant ERR_ISSUER_NOT_AUTHORIZED (err u505))
(define-constant ERR_VERIFICATION_FAILED (err u506))
(define-constant ERR_PRIVACY_VIOLATION (err u507))
(define-constant ERR_INVALID_DID_FORMAT (err u508))
(define-constant ERR_CREDENTIAL_EXPIRED (err u509))
(define-constant ERR_INSUFFICIENT_REPUTATION (err u510))

;; Identity and Credential Constants
(define-constant DID_METHOD_PREFIX "did:stacks:")
(define-constant MIN_KEY_LENGTH u32) ;; Minimum key length for security
(define-constant MAX_CREDENTIAL_VALIDITY u31536000) ;; 1 year maximum validity
(define-constant REPUTATION_THRESHOLD u500) ;; Minimum reputation for credential issuance
(define-constant PRIVACY_LEVEL_ANONYMOUS u5) ;; Highest privacy level
(define-constant VERIFICATION_EXPIRY u86400) ;; 24 hours verification validity
(define-constant MIN_ISSUER_STAKE u1000000000) ;; 10 STX minimum stake for issuers

;; Credential Types
(define-constant CRED_EDUCATION u1)
(define-constant CRED_PROFESSIONAL u2)
(define-constant CRED_GOVERNMENT u3)
(define-constant CRED_FINANCIAL u4)
(define-constant CRED_HEALTH u5)
(define-constant CRED_BIOMETRIC u6)

;; Verification Status Constants
(define-constant STATUS_PENDING u0)
(define-constant STATUS_VERIFIED u1)
(define-constant STATUS_REJECTED u2)
(define-constant STATUS_REVOKED u3)
(define-constant STATUS_EXPIRED u4)

;; Privacy Levels
(define-constant PRIVACY_PUBLIC u1)
(define-constant PRIVACY_SELECTIVE u2)
(define-constant PRIVACY_PSEUDONYMOUS u3)
(define-constant PRIVACY_ANONYMOUS u4)
(define-constant PRIVACY_ZERO_KNOWLEDGE u5)

;; Data Variables
(define-data-var identity-counter uint u0)
(define-data-var credential-counter uint u0)
(define-data-var issuer-counter uint u0)
(define-data-var verification-counter uint u0)
(define-data-var total-stake uint u0)
(define-data-var platform-reputation uint u1000)

;; Data Maps

;; Decentralized Identity (DID) Registry
(define-map digital-identities
  principal ;; Identity owner
  {
    did: (string-ascii 128), ;; Decentralized Identifier
    created-at: uint,
    last-updated: uint,
    public-key-hash: (buff 33), ;; Compressed public key
    authentication-methods: (list 5 (string-ascii 32)),
    service-endpoints: (list 3 (string-ascii 128)),
    privacy-level: uint,
    reputation-score: uint,
    verification-count: uint,
    active-credentials: uint,
    recovery-key-hash: (optional (buff 33)), ;; Emergency recovery key
    biometric-hash: (optional (buff 32)), ;; Encrypted biometric template
    multi-sig-threshold: uint, ;; Multi-signature requirement
    controller-list: (list 3 principal) ;; Additional controllers
  }
)

;; Verifiable Credentials Registry
(define-map verifiable-credentials
  uint ;; Credential ID
  {
    credential-id: uint,
    holder: principal,
    issuer: principal,
    credential-type: uint,
    schema-hash: (buff 32), ;; Credential schema identifier
    claims-hash: (buff 32), ;; Hash of encrypted claims
    issuance-date: uint,
    expiration-date: uint,
    status: uint,
    privacy-level: uint,
    proof-format: (string-ascii 32), ;; ZKP, signature, etc.
    proof-value: (buff 128), ;; Cryptographic proof
    revocation-registry: (optional uint),
    verification-method: (string-ascii 64),
    selective-disclosure: bool, ;; Supports selective disclosure
    zero-knowledge-proof: (optional (buff 256)) ;; ZK proof data
  }
)

;; Trusted Credential Issuers
(define-map credential-issuers
  principal
  {
    issuer-id: uint,
    issuer-did: (string-ascii 128),
    name-hash: (buff 32), ;; Encrypted issuer name
    authorization-level: uint,
    authorized-types: (list 6 uint), ;; Credential types they can issue
    stake-amount: uint, ;; Economic stake for accountability
    reputation-score: uint,
    total-issued: uint,
    total-revoked: uint,
    public-key-hash: (buff 33),
    verification-methods: (list 3 (string-ascii 32)),
    compliance-certifications: (list 5 (string-ascii 32)),
    registered-at: uint,
    last-activity: uint
  }
)

;; Verification Requests and Results
(define-map verification-requests
  uint ;; Verification ID
  {
    verification-id: uint,
    verifier: principal,
    credential-holder: principal,
    credential-id: uint,
    requested-claims: (list 10 (string-ascii 32)),
    privacy-requirements: uint,
    verification-method: (string-ascii 32),
    requested-at: uint,
    expires-at: uint,
    status: uint,
    proof-submitted: (optional (buff 256)),
    verification-result: (optional bool),
    challenge-nonce: (buff 32), ;; Replay attack prevention
    selective-disclosure-map: (optional (buff 128))
  }
)

;; Privacy-Preserving Proofs
(define-map zero-knowledge-proofs
  { credential-id: uint, proof-type: (string-ascii 32) }
  {
    proof-id: uint,
    prover: principal,
    proof-system: (string-ascii 32), ;; zk-SNARKs, Bulletproofs, etc.
    public-inputs: (buff 128),
    proof-data: (buff 512),
    verification-key: (buff 64),
    circuit-hash: (buff 32), ;; Identifies the verification circuit
    generated-at: uint,
    expires-at: uint,
    verification-count: uint,
    privacy-level: uint
  }
)

;; Credential Revocation Registry
(define-map revocation-registry
  uint ;; Registry ID
  {
    registry-id: uint,
    issuer: principal,
    registry-type: (string-ascii 32), ;; accumulator, merkle-tree, etc.
    registry-root: (buff 32), ;; Current state root
    total-credentials: uint,
    revoked-count: uint,
    last-updated: uint,
    update-frequency: uint, ;; Blocks between updates
    public-key: (buff 33), ;; For signature verification
    metadata-uri: (optional (string-ascii 128))
  }
)

;; Identity Recovery and Delegation
(define-map identity-recovery
  principal ;; Identity owner
  {
    recovery-threshold: uint, ;; Number of guardians needed
    guardian-list: (list 5 principal),
    recovery-requests: uint,
    last-recovery: uint,
    emergency-contacts: (list 3 (buff 32)), ;; Encrypted contact info
    social-recovery: bool, ;; Enable social recovery
    time-lock-period: uint, ;; Minimum time before recovery
    backup-key-hash: (optional (buff 33))
  }
)

;; Credential Templates and Schemas
(define-map credential-schemas
  (buff 32) ;; Schema hash
  {
    schema-id: (buff 32),
    schema-version: (string-ascii 16),
    issuer-authority: principal,
    schema-type: uint,
    required-fields: (list 20 (string-ascii 32)),
    optional-fields: (list 10 (string-ascii 32)),
    validation-rules: (buff 256), ;; JSON Schema or similar
    privacy-features: (list 5 (string-ascii 32)),
    created-at: uint,
    deprecated: bool
  }
)

;; Biometric Templates (Encrypted)
(define-map biometric-registry
  principal ;; Identity owner
  {
    template-hash: (buff 32), ;; Encrypted biometric template
    biometric-type: (string-ascii 32), ;; fingerprint, iris, face, etc.
    encryption-method: (string-ascii 32),
    quality-score: uint, ;; 0-100 template quality
    enrollment-date: uint,
    last-verification: uint,
    false-accept-rate: uint, ;; Security metric
    false-reject-rate: uint, ;; Usability metric
    privacy-level: uint,
    backup-templates: (list 3 (buff 32)) ;; Multiple biometric backups
  }
)

;; Public Functions

;; Create decentralized identity (DID)
(define-public (create-identity (public-key-hash (buff 33)) (authentication-methods (list 5 (string-ascii 32)))
                               (privacy-level uint) (recovery-key-hash (optional (buff 33))))
  (let (
    (identity-id (+ (var-get identity-counter) u1))
    (did-string (concat DID_METHOD_PREFIX (int-to-ascii identity-id)))
    (current-block block-height)
  )
    (asserts! (is-none (map-get? digital-identities tx-sender)) ERR_IDENTITY_NOT_FOUND)
    (asserts! (<= privacy-level PRIVACY_ZERO_KNOWLEDGE) ERR_PRIVACY_VIOLATION)
    (asserts! (>= (len public-key-hash) MIN_KEY_LENGTH) ERR_INVALID_DID_FORMAT)
    
    ;; Create digital identity
    (map-set digital-identities tx-sender {
      did: did-string,
      created-at: current-block,
      last-updated: current-block,
      public-key-hash: public-key-hash,
      authentication-methods: authentication-methods,
      service-endpoints: (list),
      privacy-level: privacy-level,
      reputation-score: u100, ;; Starting reputation
      verification-count: u0,
      active-credentials: u0,
      recovery-key-hash: recovery-key-hash,
      biometric-hash: none,
      multi-sig-threshold: u1,
      controller-list: (list tx-sender tx-sender tx-sender) ;; Self-controlled initially
    })
    
    ;; Update identity counter
    (var-set identity-counter identity-id)
    
    (ok identity-id)
  )
)

;; Register as credential issuer
(define-public (register-issuer (issuer-did (string-ascii 128)) (name-hash (buff 32)) 
                               (authorized-types (list 6 uint)) (stake-amount uint))
  (let (
    (issuer-id (+ (var-get issuer-counter) u1))
    (current-block block-height)
  )
    (asserts! (>= stake-amount MIN_ISSUER_STAKE) ERR_INSUFFICIENT_REPUTATION)
    (asserts! (is-none (map-get? credential-issuers tx-sender)) ERR_ISSUER_NOT_AUTHORIZED)
    
    ;; Transfer stake to contract
    (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))
    
    ;; Create issuer profile
    (map-set credential-issuers tx-sender {
      issuer-id: issuer-id,
      issuer-did: issuer-did,
      name-hash: name-hash,
      authorization-level: u1, ;; Basic authorization
      authorized-types: authorized-types,
      stake-amount: stake-amount,
      reputation-score: u1000, ;; High starting reputation
      total-issued: u0,
      total-revoked: u0,
      public-key-hash: 0x000000000000000000000000000000000000000000000000000000000000000000,
      verification-methods: (list "ecdsa-secp256k1" "rsa-pss" "ed25519"),
      compliance-certifications: (list),
      registered-at: current-block,
      last-activity: current-block
    })
    
    ;; Update counters and total stake
    (var-set issuer-counter issuer-id)
    (var-set total-stake (+ (var-get total-stake) stake-amount))
    
    (ok issuer-id)
  )
)

;; Issue verifiable credential
(define-public (issue-credential (holder principal) (credential-type uint) (schema-hash (buff 32))
                                (claims-hash (buff 32)) (expiration-date uint) (privacy-level uint))
  (let (
    (issuer (unwrap! (map-get? credential-issuers tx-sender) ERR_ISSUER_NOT_AUTHORIZED))
    (holder-identity (unwrap! (map-get? digital-identities holder) ERR_IDENTITY_NOT_FOUND))
    (credential-id (+ (var-get credential-counter) u1))
    (current-block block-height)
  )
    (asserts! (< credential-type u7) ERR_INVALID_PROOF)
    (asserts! (<= expiration-date (+ current-block MAX_CREDENTIAL_VALIDITY)) ERR_CREDENTIAL_EXPIRED)
    (asserts! (>= (get reputation-score issuer) REPUTATION_THRESHOLD) ERR_INSUFFICIENT_REPUTATION)
    
    ;; Verify issuer is authorized for this credential type
    (asserts! (is-some (index-of (get authorized-types issuer) credential-type)) ERR_ISSUER_NOT_AUTHORIZED)
    
    ;; Create verifiable credential
    (map-set verifiable-credentials credential-id {
      credential-id: credential-id,
      holder: holder,
      issuer: tx-sender,
      credential-type: credential-type,
      schema-hash: schema-hash,
      claims-hash: claims-hash,
      issuance-date: current-block,
      expiration-date: expiration-date,
      status: STATUS_VERIFIED,
      privacy-level: privacy-level,
      proof-format: "ecdsa-secp256k1",
      proof-value: 0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
      revocation-registry: none,
      verification-method: "did-resolution",
      selective-disclosure: (>= privacy-level PRIVACY_SELECTIVE),
      zero-knowledge-proof: none
    })
    
    ;; Update issuer statistics
    (map-set credential-issuers tx-sender (merge issuer {
      total-issued: (+ (get total-issued issuer) u1),
      last-activity: current-block
    }))
    
    ;; Update holder's credential count
    (map-set digital-identities holder (merge holder-identity {
      active-credentials: (+ (get active-credentials holder-identity) u1),
      last-updated: current-block
    }))
    
    ;; Update credential counter
    (var-set credential-counter credential-id)
    
    (ok credential-id)
  )
)

;; Request credential verification
(define-public (request-verification (credential-holder principal) (credential-id uint) 
                                   (requested-claims (list 10 (string-ascii 32))) (privacy-requirements uint))
  (let (
    (credential (unwrap! (map-get? verifiable-credentials credential-id) ERR_CREDENTIAL_NOT_FOUND))
    (verification-id (+ (var-get verification-counter) u1))
    (current-block block-height)
    (nonce (keccak256 (concat (unwrap-panic (to-consensus-buff? tx-sender)) (unwrap-panic (to-consensus-buff? current-block)))))
  )
    (asserts! (is-eq (get holder credential) credential-holder) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status credential) STATUS_VERIFIED) ERR_CREDENTIAL_REVOKED)
    (asserts! (> (get expiration-date credential) current-block) ERR_CREDENTIAL_EXPIRED)
    
    ;; Create verification request
    (map-set verification-requests verification-id {
      verification-id: verification-id,
      verifier: tx-sender,
      credential-holder: credential-holder,
      credential-id: credential-id,
      requested-claims: requested-claims,
      privacy-requirements: privacy-requirements,
      verification-method: "zero-knowledge-proof",
      requested-at: current-block,
      expires-at: (+ current-block VERIFICATION_EXPIRY),
      status: STATUS_PENDING,
      proof-submitted: none,
      verification-result: none,
      challenge-nonce: nonce,
      selective-disclosure-map: none
    })
    
    ;; Update verification counter
    (var-set verification-counter verification-id)
    
    (ok verification-id)
  )
)

;; Submit verification proof (privacy-preserving)
(define-public (submit-verification-proof (verification-id uint) (proof-data (buff 256)) 
                                         (selective-disclosure-map (optional (buff 128))))
  (let (
    (verification (unwrap! (map-get? verification-requests verification-id) ERR_VERIFICATION_FAILED))
    (credential (unwrap! (map-get? verifiable-credentials (get credential-id verification)) ERR_CREDENTIAL_NOT_FOUND))
    (current-block block-height)
  )
    (asserts! (is-eq (get credential-holder verification) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status verification) STATUS_PENDING) ERR_VERIFICATION_FAILED)
    (asserts! (< current-block (get expires-at verification)) ERR_CREDENTIAL_EXPIRED)
    
    ;; Verify zero-knowledge proof (simplified - real implementation would use cryptographic libraries)
    (let ((proof-valid (verify-zkp-proof proof-data (get challenge-nonce verification) credential)))
      (asserts! proof-valid ERR_INVALID_PROOF)
      
      ;; Update verification request with proof
      (map-set verification-requests verification-id (merge verification {
        proof-submitted: (some proof-data),
        verification-result: (some true),
        status: STATUS_VERIFIED,
        selective-disclosure-map: selective-disclosure-map
      }))
      
      ;; Update credential holder's reputation
      (let ((holder-identity (unwrap! (map-get? digital-identities tx-sender) ERR_IDENTITY_NOT_FOUND)))
        (map-set digital-identities tx-sender (merge holder-identity {
          verification-count: (+ (get verification-count holder-identity) u1),
          reputation-score: (+ (get reputation-score holder-identity) u10),
          last-updated: current-block
        }))
      )
      
      (ok true)
    )
  )
)

;; Revoke credential
(define-public (revoke-credential (credential-id uint) (revocation-reason (string-ascii 64)))
  (let (
    (credential (unwrap! (map-get? verifiable-credentials credential-id) ERR_CREDENTIAL_NOT_FOUND))
    (issuer (unwrap! (map-get? credential-issuers tx-sender) ERR_ISSUER_NOT_AUTHORIZED))
    (current-block block-height)
  )
    (asserts! (is-eq (get issuer credential) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (not (is-eq (get status credential) STATUS_REVOKED)) ERR_CREDENTIAL_REVOKED)
    
    ;; Revoke credential
    (map-set verifiable-credentials credential-id (merge credential {
      status: STATUS_REVOKED
    }))
    
    ;; Update issuer revocation count
    (map-set credential-issuers tx-sender (merge issuer {
      total-revoked: (+ (get total-revoked issuer) u1),
      reputation-score: (if (> (get reputation-score issuer) u50)
                           (- (get reputation-score issuer) u50)
                           u0),
      last-activity: current-block
    }))
    
    ;; Update holder's active credential count
    (let ((holder-identity (unwrap! (map-get? digital-identities (get holder credential)) ERR_IDENTITY_NOT_FOUND)))
      (map-set digital-identities (get holder credential) (merge holder-identity {
        active-credentials: (if (> (get active-credentials holder-identity) u0)
                              (- (get active-credentials holder-identity) u1)
                              u0),
        last-updated: current-block
      }))
    )
    
    (ok true)
  )
)

;; Register biometric template (encrypted)
(define-public (register-biometric (template-hash (buff 32)) (biometric-type (string-ascii 32))
                                  (quality-score uint) (privacy-level uint))
  (let (
    (identity (unwrap! (map-get? digital-identities tx-sender) ERR_IDENTITY_NOT_FOUND))
    (current-block block-height)
  )
    (asserts! (<= quality-score u100) ERR_INVALID_PROOF)
    (asserts! (<= privacy-level PRIVACY_ZERO_KNOWLEDGE) ERR_PRIVACY_VIOLATION)
    (asserts! (>= quality-score u70) ERR_INSUFFICIENT_REPUTATION) ;; Minimum quality threshold
    
    ;; Register biometric template
    (map-set biometric-registry tx-sender {
      template-hash: template-hash,
      biometric-type: biometric-type,
      encryption-method: "aes-256-gcm",
      quality-score: quality-score,
      enrollment-date: current-block,
      last-verification: u0,
      false-accept-rate: u1, ;; 0.1% FAR
      false-reject-rate: u100, ;; 1% FRR
      privacy-level: privacy-level,
      backup-templates: (list)
    })
    
    ;; Update identity with biometric hash
    (map-set digital-identities tx-sender (merge identity {
      biometric-hash: (some template-hash),
      last-updated: current-block,
      reputation-score: (+ (get reputation-score identity) u50) ;; Bonus for biometric enrollment
    }))
    
    (ok true)
  )
)

;; Private Functions

;; Verify zero-knowledge proof (simplified implementation)
(define-private (verify-zkp-proof (proof-data (buff 256)) (challenge (buff 32)) (credential (tuple (credential-id uint) (holder principal) (issuer principal) (credential-type uint) (schema-hash (buff 32)) (claims-hash (buff 32)) (issuance-date uint) (expiration-date uint) (status uint) (privacy-level uint) (proof-format (string-ascii 32)) (proof-value (buff 128)) (revocation-registry (optional uint)) (verification-method (string-ascii 64)) (selective-disclosure bool) (zero-knowledge-proof (optional (buff 256))))))
  ;; Simplified proof verification - real implementation would use cryptographic libraries
  ;; This would verify zk-SNARKs, Bulletproofs, or other zero-knowledge proof systems
  (let (
    (proof-hash (keccak256 proof-data))
    (credential-hash (keccak256 (get claims-hash credential)))
    (combined-hash (keccak256 (concat proof-hash credential-hash)))
  )
    ;; Simplified verification logic - in production would use actual ZKP verification
    (not (is-eq combined-hash 0x0000000000000000000000000000000000000000000000000000000000000000))
  )
)

;; Calculate reputation score based on verification history
(define-private (calculate-reputation (verification-count uint) (credential-count uint) (time-active uint))
  (let (
    (verification-score (* verification-count u5))
    (credential-score (* credential-count u10))
    (longevity-score (/ time-active u8640)) ;; Days active
  )
    (+ verification-score credential-score longevity-score)
  )
)

;; Generate DID string from identity ID
(define-private (generate-did (identity-id uint))
  (concat DID_METHOD_PREFIX (int-to-ascii identity-id))
)

;; Validate credential schema
(define-private (validate-credential-schema (schema-hash (buff 32)) (credential-type uint))
  (match (map-get? credential-schemas schema-hash)
    schema (is-eq (get schema-type schema) credential-type)
    false
  )
)

;; Check if credential is still valid
(define-private (is-credential-valid (credential (tuple (credential-id uint) (holder principal) (issuer principal) (credential-type uint) (schema-hash (buff 32)) (claims-hash (buff 32)) (issuance-date uint) (expiration-date uint) (status uint) (privacy-level uint) (proof-format (string-ascii 32)) (proof-value (buff 128)) (revocation-registry (optional uint)) (verification-method (string-ascii 64)) (selective-disclosure bool) (zero-knowledge-proof (optional (buff 256))))))
  (and 
    (is-eq (get status credential) STATUS_VERIFIED)
    (> (get expiration-date credential) block-height)
  )
)

;; Read-Only Functions

;; Get identity information (privacy-preserving)
(define-read-only (get-identity-info (identity-owner principal))
  (match (map-get? digital-identities identity-owner)
    identity (some {
      did: (get did identity),
      privacy-level: (get privacy-level identity),
      reputation-score: (get reputation-score identity),
      verification-count: (get verification-count identity),
      active-credentials: (get active-credentials identity),
      created-at: (get created-at identity)
    })
    none
  )
)

;; Get credential information (public data only)
(define-read-only (get-credential-info (credential-id uint))
  (match (map-get? verifiable-credentials credential-id)
    credential (some {
      credential-type: (get credential-type credential),
      issuer: (get issuer credential),
      issuance-date: (get issuance-date credential),
      status: (get status credential),
      selective-disclosure: (get selective-disclosure credential)
    })
    none
  )
)

;; Get issuer information
(define-read-only (get-issuer-info (issuer principal))
  (match (map-get? credential-issuers issuer)
    issuer-data (some {
      authorization-level: (get authorization-level issuer-data),
      authorized-types: (get authorized-types issuer-data),
      reputation-score: (get reputation-score issuer-data),
      total-issued: (get total-issued issuer-data),
      total-revoked: (get total-revoked issuer-data)
    })
    none
  )
)

;; Get verification request status
(define-read-only (get-verification-status (verification-id uint))
  (match (map-get? verification-requests verification-id)
    verification (some {
      status: (get status verification),
      expires-at: (get expires-at verification),
      verification-result: (get verification-result verification)
    })
    none
  )
)

;; Get platform statistics
(define-read-only (get-platform-stats)
  (ok {
    total-identities: (var-get identity-counter),
    total-credentials: (var-get credential-counter),
    total-issuers: (var-get issuer-counter),
    total-verifications: (var-get verification-counter),
    platform-reputation: (var-get platform-reputation),
    total-stake: (var-get total-stake)
  })
)

;; Verify credential authenticity without revealing details
(define-read-only (verify-credential-authenticity (credential-id uint) (challenge-nonce (buff 32)))
  (match (map-get? verifiable-credentials credential-id)
    credential (
      let (
        (is-valid (is-credential-valid credential))
        (issuer-valid (is-some (map-get? credential-issuers (get issuer credential))))
      )
      (ok (and is-valid issuer-valid))
    )
    (ok false)
  )
)

;; Check if DID is valid and active
(define-read-only (resolve-did (did-owner principal))
  (match (map-get? digital-identities did-owner)
    identity (some {
      did: (get did identity),
      public-key-hash: (get public-key-hash identity),
      authentication-methods: (get authentication-methods identity),
      service-endpoints: (get service-endpoints identity)
    })
    none
  )
)

;; Get biometric verification status (privacy-preserving)
(define-read-only (get-biometric-status (identity-owner principal))
  (match (map-get? biometric-registry identity-owner)
    biometric (some {
      biometric-type: (get biometric-type biometric),
      quality-score: (get quality-score biometric),
      enrollment-date: (get enrollment-date biometric),
      privacy-level: (get privacy-level biometric)
    })
    none
  )
)

;; Check credential schema validity
(define-read-only (get-schema-info (schema-hash (buff 32)))
  (match (map-get? credential-schemas schema-hash)
    schema (some {
      schema-version: (get schema-version schema),
      schema-type: (get schema-type schema),
      issuer-authority: (get issuer-authority schema),
      created-at: (get created-at schema),
      deprecated: (get deprecated schema)
    })
    none
  )
)
