---
trigger: always_on
description: Flutter client-side authorization boundaries and tenant context propagation.
---

# Rule: Security and Tenant Isolation Invariants (Flutter)

## 1. Client-Side Checks are Presentation-Only
- All client-side role checks, workspace switches, and UI permission toggles exist solely to improve usability and navigation.
- Flutter checks do **NOT** provide security enforcement.
- The Laravel API is the sole authorization authority. Never rely on client state to prevent unauthorized data access.

## 2. Tenant Context Propagation
- When making API calls within a selected Network or POS context, pass the active tenant ID in the required request headers/parameters.
- Never persist or switch tenant context silently without explicit user action.

## 3. Graceful Authorization Failure
- On 401 Unauthorized or 403 Forbidden responses, the application must handle the failure gracefully (clear invalid session, prompt for re-authentication, or route back to the workspace selector).
