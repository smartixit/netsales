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
