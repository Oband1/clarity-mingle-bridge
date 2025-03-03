;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-event (err u102))
(define-constant err-already-rsvped (err u103))
(define-constant err-past-event (err u104))
(define-constant err-max-attendees (err u105))
(define-constant err-invalid-input (err u106))

;; Data variables
(define-data-var event-counter uint u0)
(define-data-var max-attendees uint u100)

;; Data maps
(define-map events uint {
    name: (string-ascii 50),
    description: (string-ascii 500),
    timestamp: uint,
    organizer: principal,
    location: (string-ascii 100),
    category: (string-ascii 20),
    attendee-count: uint,
    max-attendees: uint
})

(define-map event-rsvps {event-id: uint, user: principal} bool)
(define-map user-interests principal (list 10 (string-ascii 20)))

;; Private functions
(define-private (validate-timestamp (timestamp uint))
    (> timestamp block-height))

(define-private (validate-string (input (string-ascii 500)))
    (not (is-eq input "")))

;; Public functions
(define-public (create-event (name (string-ascii 50)) 
                          (description (string-ascii 500))
                          (timestamp uint)
                          (location (string-ascii 100))
                          (category (string-ascii 20))
                          (max-attendees-input uint))
    (begin
        (asserts! (validate-timestamp timestamp) err-past-event)
        (asserts! (and (validate-string name) 
                     (validate-string description)
                     (validate-string location)
                     (validate-string category)) err-invalid-input)
        (let ((event-id (+ (var-get event-counter) u1)))
            (map-set events event-id {
                name: name,
                description: description,
                timestamp: timestamp,
                organizer: tx-sender,
                location: location,
                category: category,
                attendee-count: u0,
                max-attendees: max-attendees-input
            })
            (var-set event-counter event-id)
            (ok event-id)
        )
    )
)

(define-public (rsvp-event (event-id uint) (attending bool))
    (let ((event (unwrap! (map-get? events event-id) err-not-found)))
        (asserts! (validate-timestamp (get timestamp event)) err-past-event)
        (asserts! (<= (get attendee-count event) (get max-attendees event)) err-max-attendees)
        (match (map-get? event-rsvps {event-id: event-id, user: tx-sender})
            prev-rsvp (begin
                (map-set event-rsvps {event-id: event-id, user: tx-sender} attending)
                (if attending
                    (map-set events event-id 
                        (merge event {attendee-count: (+ (get attendee-count event) u1)}))
                    true
                )
                (ok true)
            )
            (err err-already-rsvped)
        )
    )
)

(define-public (cancel-rsvp (event-id uint))
    (let ((event (unwrap! (map-get? events event-id) err-not-found))
          (rsvp-exists (unwrap! (map-get? event-rsvps {event-id: event-id, user: tx-sender}) err-not-found)))
        (map-delete event-rsvps {event-id: event-id, user: tx-sender})
        (if rsvp-exists
            (map-set events event-id 
                (merge event {attendee-count: (- (get attendee-count event) u1)}))
            true
        )
        (ok true)
    )
)

;; Remaining functions unchanged...
