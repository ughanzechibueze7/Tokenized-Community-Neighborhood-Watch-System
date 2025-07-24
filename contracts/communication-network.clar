;; Crime Prevention Contract
;; Analyzes patterns and manages prevention initiatives

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-INVALID-INPUT (err u501))
(define-constant ERR-INITIATIVE-NOT-FOUND (err u502))
(define-constant ERR-PATTERN-NOT-FOUND (err u503))

;; Data Variables
(define-data-var next-initiative-id uint u1)
(define-data-var next-pattern-id uint u1)
(define-data-var total-initiatives uint u0)
(define-data-var crime-trend-score uint u50)

;; Data Maps
(define-map prevention-initiatives
  { initiative-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    target-area: (string-ascii 100),
    start-date: uint,
    end-date: uint,
    budget: uint,
    status: (string-ascii 20),
    effectiveness-score: uint,
    participants-count: uint
  }
)

(define-map crime-patterns
  { pattern-id: uint }
  {
    pattern-type: (string-ascii 50),
    location-area: (string-ascii 100),
    time-pattern: (string-ascii 50),
    frequency: uint,
    severity-level: uint,
    last-occurrence: uint,
    prevention-recommendations: (string-ascii 300)
  }
)

(define-map safety-recommendations
  { area: (string-ascii 100) }
  {
    risk-level: uint,
    recommendations: (string-ascii 500),
    last-updated: uint,
    implementation-status: (string-ascii 20),
    community-feedback: uint
  }
)

(define-map initiative-participants
  { initiative-id: uint, participant: principal }
  {
    join-date: uint,
    contribution-level: uint,
    feedback-score: uint
  }
)

;; Public Functions

;; Create prevention initiative
(define-public (create-initiative
  (title (string-ascii 100))
  (description (string-ascii 500))
  (target-area (string-ascii 100))
  (start-date uint)
  (end-date uint)
  (budget uint))
  (let
    (
      (initiative-id (var-get next-initiative-id))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u10) ERR-INVALID-INPUT)
    (asserts! (> end-date start-date) ERR-INVALID-INPUT)

    ;; Store initiative
    (map-set prevention-initiatives
      { initiative-id: initiative-id }
      {
        title: title,
        description: description,
        target-area: target-area,
        start-date: start-date,
        end-date: end-date,
        budget: budget,
        status: "planned",
        effectiveness-score: u0,
        participants-count: u0
      }
    )

    ;; Update counters
    (var-set next-initiative-id (+ initiative-id u1))
    (var-set total-initiatives (+ (var-get total-initiatives) u1))

    (ok initiative-id)
  )
)

;; Join prevention initiative
(define-public (join-initiative (initiative-id uint))
  (let
    (
      (initiative (unwrap! (map-get? prevention-initiatives { initiative-id: initiative-id }) ERR-INITIATIVE-NOT-FOUND))
      (current-time block-height)
    )
    (asserts! (is-eq (get status initiative) "active") ERR-INVALID-INPUT)

    ;; Add participant
    (map-set initiative-participants
      { initiative-id: initiative-id, participant: tx-sender }
      {
        join-date: current-time,
        contribution-level: u1,
        feedback-score: u0
      }
    )

    ;; Update participant count
    (map-set prevention-initiatives
      { initiative-id: initiative-id }
      (merge initiative {
        participants-count: (+ (get participants-count initiative) u1)
      })
    )

    (ok true)
  )
)

;; Record crime pattern
(define-public (record-crime-pattern
  (pattern-type (string-ascii 50))
  (location-area (string-ascii 100))
  (time-pattern (string-ascii 50))
  (frequency uint)
  (severity-level uint))
  (let
    (
      (pattern-id (var-get next-pattern-id))
      (current-time block-height)
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len pattern-type) u0) ERR-INVALID-INPUT)
    (asserts! (<= severity-level u5) ERR-INVALID-INPUT)

    ;; Store pattern
    (map-set crime-patterns
      { pattern-id: pattern-id }
      {
        pattern-type: pattern-type,
        location-area: location-area,
        time-pattern: time-pattern,
        frequency: frequency,
        severity-level: severity-level,
        last-occurrence: current-time,
        prevention-recommendations: ""
      }
    )

    ;; Update trend score
    (update-crime-trend-score severity-level)

    (var-set next-pattern-id (+ pattern-id u1))
    (ok pattern-id)
  )
)

;; Update safety recommendations
(define-public (update-safety-recommendations
  (area (string-ascii 100))
  (risk-level uint)
  (recommendations (string-ascii 500)))
  (let
    (
      (current-time block-height)
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (<= risk-level u5) ERR-INVALID-INPUT)
    (asserts! (> (len recommendations) u10) ERR-INVALID-INPUT)

    (map-set safety-recommendations
      { area: area }
      {
        risk-level: risk-level,
        recommendations: recommendations,
        last-updated: current-time,
        implementation-status: "pending",
        community-feedback: u0
      }
    )

    (ok true)
  )
)

;; Update initiative status
(define-public (update-initiative-status
  (initiative-id uint)
  (new-status (string-ascii 20))
  (effectiveness-score uint))
  (let
    (
      (initiative (unwrap! (map-get? prevention-initiatives { initiative-id: initiative-id }) ERR-INITIATIVE-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (<= effectiveness-score u100) ERR-INVALID-INPUT)

    (map-set prevention-initiatives
      { initiative-id: initiative-id }
      (merge initiative {
        status: new-status,
        effectiveness-score: effectiveness-score
      })
    )

    (ok true)
  )
)

;; Provide community feedback
(define-public (provide-feedback
  (area (string-ascii 100))
  (feedback-score uint))
  (let
    (
      (recommendations (unwrap! (map-get? safety-recommendations { area: area }) ERR-PATTERN-NOT-FOUND))
    )
    (asserts! (<= feedback-score u5) ERR-INVALID-INPUT)

    (map-set safety-recommendations
      { area: area }
      (merge recommendations {
        community-feedback: feedback-score
      })
    )

    (ok true)
  )
)

;; Read-only Functions

;; Get initiative details
(define-read-only (get-initiative (initiative-id uint))
  (map-get? prevention-initiatives { initiative-id: initiative-id })
)

;; Get crime pattern
(define-read-only (get-crime-pattern (pattern-id uint))
  (map-get? crime-patterns { pattern-id: pattern-id })
)

;; Get safety recommendations
(define-read-only (get-safety-recommendations (area (string-ascii 100)))
  (map-get? safety-recommendations { area: area })
)

;; Get participant info
(define-read-only (get-participant-info (initiative-id uint) (participant principal))
  (map-get? initiative-participants { initiative-id: initiative-id, participant: participant })
)

;; Get crime trend score
(define-read-only (get-crime-trend-score)
  (var-get crime-trend-score)
)

;; Get total initiatives count
(define-read-only (get-total-initiatives)
  (var-get total-initiatives)
)

;; Private Functions

;; Update crime trend score based on new patterns
(define-private (update-crime-trend-score (severity uint))
  (let
    (
      (current-score (var-get crime-trend-score))
      (adjustment (if (> severity u3) u5 u0))
    )
    (if (> severity u3)
      (var-set crime-trend-score (+ current-score adjustment))
      (var-set crime-trend-score (- current-score u1))
    )
  )
)
