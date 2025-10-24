;; SurfLog - Digital Surfing Community Platform
;; A blockchain-based platform for surf spots, session logs,
;; and surfer community rewards

;; Contract constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))

;; Token constants
(define-constant token-name "SurfLog Wave Token")
(define-constant token-symbol "SWT")
(define-constant token-decimals u6)
(define-constant token-max-supply u44000000000) ;; 44k tokens with 6 decimals

;; Reward amounts (in micro-tokens)
(define-constant reward-session u2000000) ;; 2.0 SWT
(define-constant reward-spot u2600000) ;; 2.6 SWT
(define-constant reward-milestone u9400000) ;; 9.4 SWT

;; Data variables
(define-data-var total-supply uint u0)
(define-data-var next-spot-id uint u1)
(define-data-var next-session-id uint u1)

;; Token balances
(define-map token-balances principal uint)

;; Surfer profiles
(define-map surfer-profiles
  principal
  {
    username: (string-ascii 24),
    surf-style: (string-ascii 12), ;; "longboard", "shortboard", "bodyboard", "sup", "beginner"
    sessions-logged: uint,
    spots-shared: uint,
    waves-ridden: uint,
    surfer-level: uint, ;; 1-5
    join-date: uint
  }
)

;; Surf spots
(define-map surf-spots
  uint
  {
    spot-name: (string-ascii 34),
    location: (string-ascii 24),
    break-type: (string-ascii 12), ;; "beach", "reef", "point", "rivermouth"
    wave-direction: (string-ascii 8), ;; "left", "right", "both"
    skill-level: (string-ascii 12), ;; "beginner", "intermediate", "advanced"
    best-conditions: (string-ascii 20),
    submitter: principal,
    session-count: uint,
    average-rating: uint
  }
)

;; Surf sessions
(define-map surf-sessions
  uint
  {
    spot-id: uint,
    surfer: principal,
    wave-height: uint, ;; centimeters
    wind-conditions: (string-ascii 8), ;; "offshore", "onshore", "calm"
    session-duration: uint, ;; minutes
    waves-caught: uint,
    session-notes: (string-ascii 100),
    session-date: uint,
    epic-session: bool
  }
)

;; Spot reviews
(define-map spot-reviews
  { spot-id: uint, reviewer: principal }
  {
    rating: uint, ;; 1-10
    review-text: (string-ascii 140),
    crowd-level: (string-ascii 8), ;; "empty", "light", "moderate", "crowded"
    review-date: uint,
    stoked-votes: uint
  }
)

;; Surfer milestones
(define-map surfer-milestones
  { surfer: principal, milestone: (string-ascii 12) }
  {
    achievement-date: uint,
    session-count: uint
  }
)

;; Helper function to get or create profile
(define-private (get-or-create-profile (surfer principal))
  (match (map-get? surfer-profiles surfer)
    profile profile
    {
      username: "",
      surf-style: "beginner",
      sessions-logged: u0,
      spots-shared: u0,
      waves-ridden: u0,
      surfer-level: u1,
      join-date: stacks-block-height
    }
  )
)

;; Token functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? token-balances user)))
)

(define-private (mint-tokens (recipient principal) (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? token-balances recipient)))
    (new-balance (+ current-balance amount))
    (new-total-supply (+ (var-get total-supply) amount))
  )
    (asserts! (<= new-total-supply token-max-supply) err-invalid-input)
    (map-set token-balances recipient new-balance)
    (var-set total-supply new-total-supply)
    (ok amount)
  )
)

;; Add surf spot
(define-public (add-surf-spot (spot-name (string-ascii 34)) (location (string-ascii 24)) (break-type (string-ascii 12)) (wave-direction (string-ascii 8)) (skill-level (string-ascii 12)) (best-conditions (string-ascii 20)))
  (let (
    (spot-id (var-get next-spot-id))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len spot-name) u0) err-invalid-input)
    (asserts! (> (len location) u0) err-invalid-input)
    (asserts! (> (len break-type) u0) err-invalid-input)
    
    (map-set surf-spots spot-id {
      spot-name: spot-name,
      location: location,
      break-type: break-type,
      wave-direction: wave-direction,
      skill-level: skill-level,
      best-conditions: best-conditions,
      submitter: tx-sender,
      session-count: u0,
      average-rating: u0
    })
    
    ;; Update profile
    (map-set surfer-profiles tx-sender
      (merge profile {spots-shared: (+ (get spots-shared profile) u1)})
    )
    
    ;; Award spot sharing tokens
    (try! (mint-tokens tx-sender reward-spot))
    
    (var-set next-spot-id (+ spot-id u1))
    (print {action: "surf-spot-added", spot-id: spot-id, submitter: tx-sender})
    (ok spot-id)
  )
)

;; Log surf session
(define-public (log-session (spot-id uint) (wave-height uint) (wind-conditions (string-ascii 8)) (session-duration uint) (waves-caught uint) (session-notes (string-ascii 100)) (epic-session bool))
  (let (
    (session-id (var-get next-session-id))
    (spot (unwrap! (map-get? surf-spots spot-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> wave-height u0) err-invalid-input)
    (asserts! (> session-duration u0) err-invalid-input)
    (asserts! (>= waves-caught u0) err-invalid-input)
    
    (map-set surf-sessions session-id {
      spot-id: spot-id,
      surfer: tx-sender,
      wave-height: wave-height,
      wind-conditions: wind-conditions,
      session-duration: session-duration,
      waves-caught: waves-caught,
      session-notes: session-notes,
      session-date: stacks-block-height,
      epic-session: epic-session
    })
    
    ;; Update spot session count
    (map-set surf-spots spot-id
      (merge spot {session-count: (+ (get session-count spot) u1)})
    )
    
    ;; Update profile
    (map-set surfer-profiles tx-sender
      (merge profile {
        sessions-logged: (+ (get sessions-logged profile) u1),
        waves-ridden: (+ (get waves-ridden profile) waves-caught),
        surfer-level: (+ (get surfer-level profile) (/ waves-caught u20))
      })
    )
    
    ;; Award session tokens with epic bonus
    (let (
      (base-reward reward-session)
      (epic-bonus (if epic-session u1500000 u0))
    )
      (try! (mint-tokens tx-sender (+ base-reward epic-bonus)))
    )
    
    (var-set next-session-id (+ session-id u1))
    (print {action: "surf-session-logged", session-id: session-id, spot-id: spot-id})
    (ok session-id)
  )
)

;; Write spot review
(define-public (write-review (spot-id uint) (rating uint) (review-text (string-ascii 140)) (crowd-level (string-ascii 8)))
  (let (
    (spot (unwrap! (map-get? surf-spots spot-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (and (>= rating u1) (<= rating u10)) err-invalid-input)
    (asserts! (> (len review-text) u0) err-invalid-input)
    (asserts! (is-none (map-get? spot-reviews {spot-id: spot-id, reviewer: tx-sender})) err-already-exists)
    
    (map-set spot-reviews {spot-id: spot-id, reviewer: tx-sender} {
      rating: rating,
      review-text: review-text,
      crowd-level: crowd-level,
      review-date: stacks-block-height,
      stoked-votes: u0
    })
    
    ;; Update spot average rating (simplified calculation)
    (let (
      (current-avg (get average-rating spot))
      (session-count (get session-count spot))
      (new-avg (if (> session-count u0)
                 (/ (+ (* current-avg session-count) rating) (+ session-count u1))
                 rating))
    )
      (map-set surf-spots spot-id (merge spot {average-rating: new-avg}))
    )
    
    (print {action: "review-written", spot-id: spot-id, reviewer: tx-sender})
    (ok true)
  )
)

;; Vote review stoked
(define-public (vote-stoked (spot-id uint) (reviewer principal))
  (let (
    (review (unwrap! (map-get? spot-reviews {spot-id: spot-id, reviewer: reviewer}) err-not-found))
  )
    (asserts! (not (is-eq tx-sender reviewer)) err-unauthorized)
    
    (map-set spot-reviews {spot-id: spot-id, reviewer: reviewer}
      (merge review {stoked-votes: (+ (get stoked-votes review) u1)})
    )
    
    (print {action: "review-voted-stoked", spot-id: spot-id, reviewer: reviewer})
    (ok true)
  )
)

;; Update surf style
(define-public (update-surf-style (new-surf-style (string-ascii 12)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-surf-style) u0) err-invalid-input)
    
    (map-set surfer-profiles tx-sender (merge profile {surf-style: new-surf-style}))
    
    (print {action: "surf-style-updated", surfer: tx-sender, style: new-surf-style})
    (ok true)
  )
)

;; Claim milestone
(define-public (claim-milestone (milestone (string-ascii 12)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (is-none (map-get? surfer-milestones {surfer: tx-sender, milestone: milestone})) err-already-exists)
    
    ;; Check milestone requirements
    (let (
      (milestone-met
        (if (is-eq milestone "surfer-45") (>= (get sessions-logged profile) u45)
        (if (is-eq milestone "explorer-8") (>= (get spots-shared profile) u8)
        false)))
    )
      (asserts! milestone-met err-unauthorized)
      
      ;; Record milestone
      (map-set surfer-milestones {surfer: tx-sender, milestone: milestone} {
        achievement-date: stacks-block-height,
        session-count: (get sessions-logged profile)
      })
      
      ;; Award milestone tokens
      (try! (mint-tokens tx-sender reward-milestone))
      
      (print {action: "milestone-claimed", surfer: tx-sender, milestone: milestone})
      (ok true)
    )
  )
)

;; Update username
(define-public (update-username (new-username (string-ascii 24)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-username) u0) err-invalid-input)
    (map-set surfer-profiles tx-sender (merge profile {username: new-username}))
    (print {action: "username-updated", surfer: tx-sender})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-surfer-profile (surfer principal))
  (map-get? surfer-profiles surfer)
)

(define-read-only (get-surf-spot (spot-id uint))
  (map-get? surf-spots spot-id)
)

(define-read-only (get-surf-session (session-id uint))
  (map-get? surf-sessions session-id)
)

(define-read-only (get-spot-review (spot-id uint) (reviewer principal))
  (map-get? spot-reviews {spot-id: spot-id, reviewer: reviewer})
)

(define-read-only (get-milestone (surfer principal) (milestone (string-ascii 12)))
  (map-get? surfer-milestones {surfer: surfer, milestone: milestone})
)