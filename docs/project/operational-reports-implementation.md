# Operational Reports — implementation record

## Scope

This feature belongs to the operational NetSales application and serves Network and POS workspaces. Platform Billing and subscription reporting remain exclusively in the Windows Platform Scope dashboard and are not part of this feature.

## Current implementation

- Added a typed report catalogue for sales, expenses, network/POS wallet statements, repayments, debt aging, and procurement requests.
- Added a domain repository and use case, remote data source using the existing ApiService, and response mapping that preserves cursor pagination metadata.
- Added a GetX controller with tenant/network resolution, explicit network selection where multiple networks are available, permission checks, stale-response protection, and incremental loading.
- Added a report screen using existing NetSales custom buttons, empty state, and skeleton components.
- Registered a guarded route and added entry points to both Network and POS workspace navigation shells.
- The backend remains the authority for report data and all financial values.

## Deferred work

- Server-side export request lifecycle, status polling, protected download, and save/share integration.
- Document-engine-backed PDF rendering and report-specific templates.
- Integration of invoice/repayment/expense document actions with the shared engine.
- Removal of superseded document/PDF/report implementations after replacement coverage is established.
- Tests, analyzer, formatters, builds, and GitHub Actions are deferred to the final verification milestone as directed.
