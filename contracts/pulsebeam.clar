;; PulseBeam Task Tracker Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-task-not-found (err u101))
(define-constant err-invalid-deadline (err u102))

;; Data variables
(define-data-var task-counter uint u0)

;; Define task storage structure
(define-map tasks
  uint
  {
    owner: principal,
    title: (string-ascii 64),
    deadline: uint,
    completed: bool,
    light-notify: bool,
    sound-notify: bool
  }
)

;; Create new task
(define-public (create-task (title (string-ascii 64)) (deadline uint) (light-notify bool) (sound-notify bool))
  (let
    (
      (task-id (+ (var-get task-counter) u1))
    )
    (map-set tasks task-id {
      owner: tx-sender,
      title: title,
      deadline: deadline,
      completed: false,
      light-notify: light-notify,
      sound-notify: sound-notify
    })
    (var-set task-counter task-id)
    (ok task-id)
  )
)

;; Mark task as complete
(define-public (complete-task (task-id uint))
  (let
    (
      (task (unwrap! (map-get? tasks task-id) (err err-task-not-found)))
    )
    (asserts! (is-eq tx-sender (get owner task)) (err err-owner-only))
    (ok (map-set tasks task-id (merge task { completed: true })))
  )
)

;; Get task details
(define-read-only (get-task (task-id uint))
  (ok (map-get? tasks task-id))
)

;; Update notification preferences
(define-public (update-notifications (task-id uint) (light-notify bool) (sound-notify bool))
  (let
    (
      (task (unwrap! (map-get? tasks task-id) (err err-task-not-found)))
    )
    (asserts! (is-eq tx-sender (get owner task)) (err err-owner-only))
    (ok (map-set tasks task-id (merge task { light-notify: light-notify, sound-notify: sound-notify })))
  )
)
