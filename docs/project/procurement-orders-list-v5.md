# POS Procurement Orders — V5 Redesign

## Approved visual direction
The POS procurement orders list follows the user-approved Arabic RTL reference image:
- A compact page header with the title/description and a prominent primary create action.
- Three horizontally aligned summary cards: total requests, pending review, and approved requests.
- One compact search field with a separate status-filter action.
- Independent request cards with a status-colored edge, lifecycle badge, numeric request reference, request date/time, package-color markers, item/quantity/type metrics, server-calculated request total, and a primary details action.
- The list remains responsive and supports light/dark themes and RTL/LTR direction.

## Lifecycle truth
The only request lifecycle values are `PENDING`, `APPROVED`, `REJECTED`, and `CANCELLED`. The UI must not invent a `COMPLETED` state. The approved summary tile is labelled `معتمدة`.

## Data ownership
- Full-scope summary counts are returned by Laravel through `GET /api/v1/requests/summary`; Flutter must not infer totals from the currently loaded cursor page.
- Request totals and item totals remain server-authoritative. Flutter only formats and displays the returned values.
- Package colors are visual identifiers for package lines, not request lifecycle state.
- Search, status filtering, and cursor pagination remain server-side.

## Scope boundaries
- This redesign applies only to the POS procurement orders list.
- The Network procurement review card and its approve/reject/modify workflow are not redesigned by this change.
- Repayment/debt features and actions are not part of this screen or its card.
- Existing request details, pending-request edit/cancel, and cancelled-request delete actions remain available subject to permissions.

## Implementation branches
- Flutter: `feat/procurement-orders-list-v5` (PR #46).
- API summary dependency: `feat/procurement-requests-summary` (netsales_api PR #33).

## Validation
The implementation is awaiting exact-HEAD CI analysis, tests, and build checks. This document is a design/contract record, not a claim of completed verification.
