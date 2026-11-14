# NetSales (Flutter) — Project Documentation & Canonical Authority

## 1. Canonical Project Memory Location
The authoritative canonical project memory, architecture definitions, API contracts, financial invariants, and append-only decision log reside in the primary API repository:

👉 **`netsales_api/docs/project/`**

Do not maintain competing, uncoordinated copies of shared specifications.

---

## 2. Local Documentation Index
- **[shared-contract-reference.md](./shared-contract-reference.md):** Maps local Flutter architecture and feature implementations to their canonical backend API resources, Enums, and financial rules.
- **[AGENTS.md](../../AGENTS.md):** Permanent constitutional rules and invariants for Flutter development.
- **[.agents/rules/](../../.agents/rules/):** Modular rules governing GetX state management, theme preservation, and security boundaries.

---

## 3. Cross-Repository Verification Tool
To verify that canonical documentation exists and is accessible from the Flutter workspace without cross-platform symlink issues:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-project-governance.ps1
```
This script checks the status and synchronization of canonical documents in `netsales_api/docs/project/`.


## 2026-11-13 — Reports and official document integration

- Operational Reports is embedded in both Network Workspace and POS Workspace shells through the workspace bindings. The same Report Configuration Studio is used in both scopes.
- Saved report presets are persisted by the API and exposed in Report Studio: load, save, update-by-name, apply, and delete. Presets store typed Document Engine criteria and presentation options; schema incompatibilities require review and are not silently migrated.
- Detailed report PDFs apply visible columns, sorting, grouping, template/version, language, page profile, metrics, and charts. They enforce a 1,500-row bound and do not calculate financial totals locally.
- Network/POS wallet statement PDFs use a dedicated Document Engine renderer with full cursor traversal, a 1,500-row bound, currency and per-entry balance-snapshot validation, concurrent wallet/new-ledger checks, A4 landscape ledger tables, IBM Plex Sans Arabic branding, and an image watermark.
- Invoice, expense, and repayment documents use the shared Document Engine and the server-issued immutable snapshot/artifact workflow. Historical invoice generator source was compared with the replacement: parties, reference/date, sale/payment state, request reference, line items, and authoritative totals are retained, with currency, richer party metadata, image branding/watermark, multi-page output, and immutable artifact retrieval added.
- Final formatter/analyzer/tests, migration execution, PDF text extraction, visual inspection, and GitHub Actions remain deferred to the final validation stage.


## 2026-11-14 — Billing self-service and Reports collection controls

- Billing workspace list groups now use independent server-side cursor pages, search and status criteria for plans, subscriptions, invoices, payments, credit notes, and refunds. Each list keeps its own debounce, filter values, loading/error state, and cursor.
- The shared filter bar is implemented under `lib/widgets/lists/custom_collection_filter_bar.dart` and cursor tails use `lib/widgets/lists/custom_cursor_load_more.dart`; feature sections compose these shared widgets rather than duplicating Material controls.
- Billing and Billing Reports controllers observe the active network signal and reject stale responses from previous network/account/report scopes.
- Billing Reports continues to use the shared `ReportConfigurationStudio`; filters, PDF presentation, column visibility, summary/charts, and records are composed from focused feature widgets.
- Operational Reports scope changes invalidate catalogue, preset, export-status, CSV and PDF actions; record status labels use the central enum presentation registry.
- Implementation branch: `feat/subscriptions-network-module`. Source changes only. Formatter/analyzer/tests, PDF extraction/visual QA and GitHub Actions remain pending for final validation.
