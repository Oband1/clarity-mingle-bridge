# MingleBridge
A decentralized platform for organizing and discovering social events with friend suggestions built on Stacks blockchain.

## Features
- Create and manage social events
- Search events by location and category
- RSVP to events
- Friend suggestion system based on shared interests
- Event check-in functionality

## Setup and Installation
1. Clone the repository
2. Install Clarinet
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to execute test suite

## Usage Examples
```clarity
;; Create a new event
(contract-call? .mingle-bridge create-event "Beach Party" "Fun beach gathering" 
  u1625097600 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM "Miami Beach" "Social")

;; RSVP to an event
(contract-call? .mingle-bridge rsvp-event u1 true)

;; Get event details
(contract-call? .mingle-bridge get-event-details u1)
```

## Dependencies
- Clarity language
- Clarinet testing framework
