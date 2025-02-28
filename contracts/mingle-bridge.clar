;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-event (err u102))
(define-constant err-already-rsvped (err u103))

;; Data variables
(define-data-var event-counter uint u0)

;; Data maps
(define-map events uint {
    name: (string-ascii 50),
    description: (string-ascii 500),
    timestamp: uint,
    organizer: principal,
    location: (string-ascii 100),
    category: (string-ascii 20),
    attendee-count: uint
})

(define-map event-rsvps {event-id: uint, user: principal} bool)

(define-map user-interests principal (list 10 (string-ascii 20)))

;; Public functions
(define-public (create-event (name (string-ascii 50)) 
                            (description (string-ascii 500))
                            (timestamp uint)
                            (location (string-ascii 100))
                            (category (string-ascii 20)))
    (let ((event-id (+ (var-get event-counter) u1)))
        (map-set events event-id {
            name: name,
            description: description,
            timestamp: timestamp,
            organizer: tx-sender,
            location: location,
            category: category,
            attendee-count: u0
        })
        (var-set event-counter event-id)
        (ok event-id)
    )
)

(define-public (rsvp-event (event-id uint) (attending bool))
    (let ((event (unwrap! (map-get? events event-id) err-not-found)))
        (if (is-some (map-get? event-rsvps {event-id: event-id, user: tx-sender}))
            err-already-rsvped
            (begin
                (map-set event-rsvps {event-id: event-id, user: tx-sender} attending)
                (if attending
                    (map-set events event-id 
                        (merge event {attendee-count: (+ (get attendee-count event) u1)}))
                    true
                )
                (ok true)
            )
        )
    )
)

(define-public (set-interests (interests (list 10 (string-ascii 20))))
    (begin
        (map-set user-interests tx-sender interests)
        (ok true)
    )
)

;; Read only functions
(define-read-only (get-event-details (event-id uint))
    (ok (unwrap! (map-get? events event-id) err-not-found))
)

(define-read-only (get-user-rsvp (event-id uint) (user principal))
    (ok (default-to false (map-get? event-rsvps {event-id: event-id, user: user})))
)

(define-read-only (get-user-interests (user principal))
    (ok (default-to (list) (map-get? user-interests user)))
)
