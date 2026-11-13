# NetSales — Shared Contract & Reference Index (Flutter)

This document provides direct mapping from Flutter feature domains to their canonical source specifications in `netsales_api/docs/project/`.

---

## 1. Canonical Reference Map

| Business Area | Canonical Specification File | Flutter Implementation Responsibility |
|---|---|---|
| **Product Scope & Anti-Definitions** | [`PRODUCT_SCOPE.md`](file:///d:/Smartix/NetSales/netsales_api/docs/project/PRODUCT_SCOPE.md) | Strictly enforce Network and POS workspaces; reject Platform / Card Vault / Consumer POS screens. |
| **Business Domains** | [`DOMAIN_MAP.md`](file:///d:/Smartix/NetSales/netsales_api/docs/project/DOMAIN_MAP.md) | Align feature directory names with official system domains. |
| **System Architecture** | [`ARCHITECTURE.md`](file:///d:/Smartix/NetSales/netsales_api/docs/project/ARCHITECTURE.md) | Enforce GetX Controllers, Bindings, and AppPages routing. |
| **API Wire Contracts & Enums** | [`API_CONTRACTS.md`](file:///d:/Smartix/NetSales/netsales_api/docs/project/API_CONTRACTS.md) | Parse exact Enum wire values and map translated `*_label` fields. |
| **RBAC & Tenant Scoping** | [`RBAC_AND_TENANT_CONTEXT.md`](file:///d:/Smartix/NetSales/netsales_api/docs/project/RBAC_AND_TENANT_CONTEXT.md) | Propagate tenant headers; presentation-only client role checks. |
| **Financial Authority** | [`FINANCIAL_INVARIANTS.md`](file:///d:/Smartix/NetSales/netsales_api/docs/project/FINANCIAL_INVARIANTS.md) | **Zero client-side calculations.** Render authoritative numbers; treat previews as non-binding. |
| **Active Project State** | [`PROJECT_STATE.md`](file:///d:/Smartix/NetSales/netsales_api/docs/project/PROJECT_STATE.md) | Check current authorized milestone before coding. |
| **Decision Register** | [`DECISION_LOG.md`](file:///d:/Smartix/NetSales/netsales_api/docs/project/DECISION_LOG.md) | Adhere to `APPROVED` decisions; never implement `PROPOSED` decisions without authorization. |
| **Work History** | [`WORK_LOG.md`](file:///d:/Smartix/NetSales/netsales_api/docs/project/WORK_LOG.md) | Log all executed tasks and verification outcomes. |

---

## 2. Invariant Rules for Flutter Engineers
1. **Never calculate financial balances on client:** Rely 100% on Laravel API responses.
2. **Reuse existing infrastructure (Mandatory):**
   - Use `lib/widgets/` for all UI components (`CustomDialog`, `CustomBottomSheet`, `CustomButton`, `CustomTextField`, `CustomSnackbar`, `CustomToast`, `CustomEmptyState`, `CustomLoadingState`, `CustomErrorState`, skeletons, pickers). Never invent fake names or redundant dialogs.
   - Use `lib/core/utils/` for formatters (`DateFormatter`, `AmountFormatter`, `TextFormatter`, `FileSizeFormatter`, `FormValidators`, `IdempotencyHelper`).
   - Use `lib/core/services/` for system services (`ApiService`, `WorkspaceService`, `SessionService`, `ThemeService`, `StorageService`, etc.).
   - Use `lib/core/themes/` and `lib/core/constants/` for tokens (`AppColors`, `AppTypography`, `AppRadius`, `AppSpacing`, `AppElevation`, `AppGradients`, `AppMotion`, `AppThemes`).
3. **Use GetX exclusively:** Prohibit Provider, Riverpod, Bloc, or stateful widget state machines.
4. **Adaptive Breakpoints:** Build all screens to adapt across `AppBreakpoints` (Mobile: <=600dp, Tablet: <=900dp, Desktop: <=1240dp).


## 3. Operational Reports & Official Document Snapshots (2026-11-13)

- Canonical API contract: `netsales_api/docs/project/API_CONTRACTS.md`, section **Operational Reports Provider Contract**.
- `OperationalReportCatalogModel` parses the Laravel catalog into `document_engine` `ReportDefinition` schemas and registers exact schema versions with `ReportDefinitionRegistry`.
- Localized labels and chart slots are catalog metadata; view/export permissions and supported workspace scopes are carried separately as access descriptors. They are not security grants. Laravel reauthorizes catalog availability, report execution, CSV export, document issue, and artifact download.
- Operational report data and financial summaries are server-computed. Flutter may display returned metrics/chart series but must not derive balances, aging buckets, wallet totals, or accounting results.
- Report execution, summary, and CSV export requests send provider-defined values only under the nested `filters` object. Laravel validates filter IDs, types, choices, and workspace authorization; the retired top-level flat filter contract is prohibited.
- The Flutter integration currently exposes the seven known `OperationalReportType` values and fixed filter arguments through its existing GetX controller/use cases. The package-level schema studio is not yet hosted by the operational reports feature, so arbitrary provider-defined filter controls are not yet end-to-end dynamic.
- `document_engine` includes a controlled `ReportConfigurationStudio` and versioned `SavedReportPreset` value object. NetSales has not yet integrated the studio into its reports navigation/controller or added server-side preset persistence endpoints/migrations.
- Current report PDF output is an executive summary based on server metrics and charts; row-level report results are delivered through CSV. A detailed PDF wallet ledger statement remains outstanding.
- Official invoice, repayment, and expense PDFs are rendered only from the server-issued immutable `source_snapshot`. The app uploads the rendered PDF artifact, retrieves the canonical protected artifact, and verifies its SHA-256 before save/share/print.
- Currency shown in an official document comes from the snapshot's `currency_code`; snapshots with missing/invalid currency are rejected. No fixed currency symbol or client-side currency conversion is allowed.
- Validation of migrations, typed contract parsing, platform PDF rendering, Arabic text extraction/order, and final CI remains pending for the final plan stage. Do not interpret source integration as verified platform readiness.
