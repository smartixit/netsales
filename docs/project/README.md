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
