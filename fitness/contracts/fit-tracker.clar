;; Fitness Tracker Smart Contract
;; Enhanced with input validation and safety checks

(define-constant CONTRACT-ADMIN tx-sender)
(define-constant ERR-ACCESS-DENIED (err u1))
(define-constant ERR-INVALID-USER (err u2))
(define-constant ERR-INSUFFICIENT-FUNDS (err u3))
(define-constant ERR-WORKOUT-NOT-FOUND (err u4))
(define-constant ERR-BADGE-EXISTS (err u5))
(define-constant ERR-BADGE-NOT-FOUND (err u6))
(define-constant ERR-INVALID-DATA (err u7))

;; Helper functions for input validation
(define-private (is-valid-workout-id (id uint))
  (< id u1000000))

(define-private (is-valid-intensity (intensity uint))
  (and (> intensity u0) (< intensity u100)))

(define-private (is-valid-completion-rate (rate uint))
  (<= rate u100))

(define-private (is-valid-badge-title (title (string-ascii 100)))
  (and (> (len title) u0) (<= (len title) u100)))

(define-private (is-valid-details (details (string-ascii 255)))
  (and (> (len details) u0) (<= (len details) u255)))

;; Simplified nickname validation
(define-private (is-valid-nickname (nickname (string-ascii 50)))
  (and 
    (> (len nickname) u2)  ;; Minimum 3 characters
    (<= (len nickname) u50)  ;; Maximum 50 characters
  ))

;; Data Maps
(define-map user-profiles 
  principal 
  {
    nickname: (string-ascii 50),
    total-points: uint,
    fitness-level: uint,
    workouts-completed: uint
  })

(define-map workout-tracking 
  { user: principal, workout-id: uint }
  {
    current-intensity: uint,
    completion-rate: uint,
    finished: bool
  })

(define-map fitness-badges 
  { user: principal, badge-id: uint }
  {
    title: (string-ascii 100),
    details: (string-ascii 255),
    bonus-points: uint,
    earned-at: uint
  })

(define-map fitness-tokens 
  principal 
  uint)

;; Helper function to check if badge exists
(define-private (badge-exists? (user principal) (badge-id uint))
  (is-some (map-get? fitness-badges { user: user, badge-id: badge-id })))

;; Public functions
(define-public (create-profile (nickname (string-ascii 50)))
  (begin
    (asserts! (is-valid-nickname nickname) ERR-INVALID-DATA)
    (asserts! (is-none (map-get? user-profiles tx-sender)) ERR-INVALID-USER)
    
    (map-set user-profiles 
      tx-sender 
      {
        nickname: nickname,
        total-points: u0,
        fitness-level: u1,
        workouts-completed: u0
      })
    (ok true)))

(define-public (record-workout-session 
  (workout-id uint) 
  (current-intensity uint) 
  (completion-rate uint))
  (let 
    ((user-profile (unwrap! 
      (map-get? user-profiles tx-sender) 
      ERR-INVALID-USER)))
    
    (asserts! (is-valid-workout-id workout-id) ERR-INVALID-DATA)
    (asserts! (is-valid-intensity current-intensity) ERR-INVALID-DATA)
    (asserts! (is-valid-completion-rate completion-rate) ERR-INVALID-DATA)
    
    (map-set workout-tracking 
      { user: tx-sender, workout-id: workout-id }
      {
        current-intensity: current-intensity,
        completion-rate: completion-rate,
        finished: (is-eq completion-rate u100)
      })
    
    (map-set user-profiles 
      tx-sender 
      (merge user-profile { 
        workouts-completed: (+ (get workouts-completed user-profile) u1) 
      }))
    
    (ok true)))

(define-public (earn-fitness-badge 
  (badge-id uint) 
  (title (string-ascii 100)) 
  (details (string-ascii 255)) 
  (bonus-points uint))
  (let 
    ((user-profile (unwrap! 
      (map-get? user-profiles tx-sender) 
      ERR-INVALID-USER)))
    
    (asserts! (is-valid-badge-title title) ERR-INVALID-DATA)
    (asserts! (is-valid-details details) ERR-INVALID-DATA)
    (asserts! (> bonus-points u0) ERR-INVALID-DATA)
    (asserts! 
      (not (badge-exists? tx-sender badge-id)) 
      ERR-BADGE-EXISTS)
    
    (map-set fitness-badges 
      { user: tx-sender, badge-id: badge-id }
      {
        title: title,
        details: details,
        bonus-points: bonus-points,
        earned-at: block-height
      })
    
    (map-set user-profiles 
      tx-sender 
      (merge user-profile { 
        total-points: (+ (get total-points user-profile) bonus-points) 
      }))
    
    (ok true)))

(define-public (admin-clear-user-data (user principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-ADMIN) ERR-ACCESS-DENIED)
    (asserts! 
      (is-some (map-get? user-profiles user)) 
      ERR-INVALID-USER)
    
    (map-delete user-profiles user)
    (ok true)))

(define-public (generate-fitness-tokens (amount uint))
  (begin
    (asserts! (> amount u0) ERR-INVALID-DATA)
    
    (let 
      ((current-balance (default-to u0 (map-get? fitness-tokens tx-sender))))
      (map-set fitness-tokens 
        tx-sender 
        (+ current-balance amount))
      (ok true))))

;; Read-only functions
(define-read-only (get-user-profile (user principal))
  (map-get? user-profiles user))

(define-read-only (get-workout-tracking (user principal) (workout-id uint))
  (map-get? workout-tracking { user: user, workout-id: workout-id }))

(define-read-only (get-user-badges (user principal))
  (begin
    (list 
      (map-get? fitness-badges { user: user, badge-id: u1 })
      (map-get? fitness-badges { user: user, badge-id: u2 })
      (map-get? fitness-badges { user: user, badge-id: u3 })
      (map-get? fitness-badges { user: user, badge-id: u4 })
      (map-get? fitness-badges { user: user, badge-id: u5 }))))

(define-read-only (get-fitness-token-balance (user principal))
  (default-to u0 (map-get? fitness-tokens user)))