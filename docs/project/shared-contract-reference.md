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
   - Use `lib/widgets/` for all UI components (`CustomDialog`, `CustomBottomSheet`, `CustomButton`, `CustomTextField`, `CustomSnackbar`, `CustomToast`, `CustomStateView`, specialized state components under `widgets/feedback/states/`, skeleton recipes under `widgets/feedback/skeletons/`, pickers). Never invent fake names or redundant dialogs.
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


## Wallet ledger statement export contract

The Finance feature's detailed network/POS wallet statement PDF consumes these API resource fields:
- Wallet resource: `currency_code`, `opening_balance`, `opening_balance_source`, `wallet_balance`, and the related network/POS profile logo path.
- Wallet-log resource: `currency_code`, `balance_before`, `balance_after`, and `balance_snapshot_source`, in addition to log ID, operation label, amount, statement, date, and creator.
- `opening_balance_source` is interpreted only as `INITIAL` or `BACKFILLED`; unknown values are displayed as unspecified. `balance_snapshot_source` is interpreted only as `LIVE` or `BACKFILLED`.
- The PDF is generated from all cursor pages up to 1,500 rows, ordered by ledger ID, and is rejected if the wallet changes, a new ledger ID appears during retrieval, any row has missing balance snapshots, or any row currency differs from the wallet currency. The Flutter renderer does not calculate balances or totals.


## Saved operational report presets

Presets are persisted by the API under the authenticated user and current network/POS scope. Routes are `GET /reports/presets`, `POST /reports/presets`, `PUT /reports/presets/{presetUuid}`, and `DELETE /reports/presets/{presetUuid}`.
The write payload includes `report_type`, `network_id`, optional `pos_id`, `name`, `report_schema_version`, `criteria` (`ReportCriteria.toJson()`), and `presentation` (`ReportPresentationOptions.toJson()`). The API returns `preset_schema_version`, `id` (opaque preset UUID), `name`, `report_id`, `report_schema_version`, `criteria`, and `presentation`.
Preset schema version is currently 1. The API validates the saved report schema version, typed filter values and choices, required filters, visible/required columns, sort and grouping permissions, selected template/version, locale, page profile, and metric/chart availability against the current provider definition. A schema mismatch is rejected for re-review rather than silently migrated.


## Document output integration status

The Reports feature is embedded in both workspace shells and uses the shared Report Configuration Studio. User-owned saved presets are stored by the API with `ReportCriteria` and `ReportPresentationOptions` JSON; see the preset endpoint contract above.
Detailed report PDF rendering consumes the current presentation options (columns, sorts, grouping, template/version, locale, page profile, metrics, charts). It rejects more than 1,500 rows and never recomputes financial values.
Network/POS wallet statements use server-supplied opening/current balances and per-entry balance snapshots, reject mixed currencies or concurrent source changes, and render a branded landscape ledger PDF. Invoice/expense/repayment PDFs use the immutable API document snapshot and artifact workflow.


## Billing self-service collections — 2026-11-14

The canonical Laravel collection endpoints validate `search`, `status`, `per_page`, and `cursor` as applicable. Flutter must send search/status in the initial request and repeat the same criteria with each subsequent cursor. The server remains responsible for filtering and account authorization.

- Plans: plan name/key search; currency-scoped catalogue.
- Subscriptions: status, subscription ID, plan name/key search.
- Invoices: status, invoice number/ID, and related plan search.
- Payments: status, payment reference, external reference, invoice number, and ID search.
- Credit notes: status, credit-note number, reason, invoice number, and ID search.
- Refunds: status, refund reference, reason, related payment reference, and ID search.

Each Flutter collection owns an independent filter and cursor state. A change in one collection must not reset another collection's criteria or pages. Switching Billing account or Network clears all prior-scope criteria. First-page and load-more responses must be discarded when account, network, or page revision changes.

Financial resources expose decimal money values (`total`, `remaining`, `amount`) and nested `currency.code` / `currency.decimal_places`. Render those authoritative values with shared currency widgets; do not display `*_minor` values as decimal currency amounts.


## 4. Canonical Shared Feedback & State UI

`lib/widgets/feedback/custom_state_view.dart` is the single visual source for all application-level data states:
- **Loading** — `CustomStateView.loading`
- **Empty** — `CustomStateView.empty`
- **Error** — `CustomStateView.error`
- **Offline** — `CustomStateView.offline`
- **Pricing expired** — `CustomStateView.pricingExpired`\n- **Not found** — `CustomStateView.notFound` (a missing resource is not an empty query result)

Choose `CustomStatePresentation.fullscreen`, `boxed`, `compact`, or `banner` according to the actual available space and user workflow. `CustomEmptyState`, `CustomErrorState`, and `CustomNotFoundState` are canonical semantic components under `states/`; they delegate shared presentation to `CustomStateView`. There are no compatibility facades for loading/empty/error states. `CustomOfflineState` handles full-content offline failures; `CustomOfflineBanner` remains a distinct inline warning that preserves already-loaded content.

All shared loading placeholders use the adaptive skeleton engine exposed by `CustomStateView.loading`, the pure `CustomStateSkeleton` recipe model, `CustomStateSkeletonView` renderer, and named `SkeletonRecipes` in `widgets/feedback/skeletons/. It supports responsive `list`, `cards`, `grid`, and `detail` layouts, configurable item count, minimum grid item width, maximum columns, card height, spacing, leading/trailing placeholders, and custom widget builders. `CustomSkeletonFeed`, `CustomSkeletonGrid`, and `CustomSkeletonListTile` are removed and must not be reintroduced. The low-level `CustomSkeletonShimmer` remains an animation primitive only. During cursor pagination, the skeleton is appended to existing content and never replaces loaded records. Expired authoritative pricing must clearly block submission and provide a refresh action when supported by the relevant use case.

## POS procurement pricing snapshots — DEC-PROC-01

The POS procurement package catalogue request must include the active `pos_id` when loading packages for a selected Network. Laravel returns a signed `procurement_pricing` snapshot per package, including integer minor-unit base price, cash/credit discount basis points, signed token, and 30-minute expiry.

The POS procurement UI may use these snapshot inputs for a non-binding display-only line estimate and cart summary. Recalculate locally on quantity/payment-type changes; do not call a quote endpoint to refresh totals before new-request submission. Submit package IDs, quantities, and each item's `pricing_snapshot_token` only. Laravel validates each token against current tariff/discount state and computes the final request totals. This exception is limited to the new POS procurement workspace and does not weaken server financial authority in any other domain.

When a cart snapshot expires, refreshing the tariff must request the cart's package IDs through the same network/POS-scoped catalogue endpoint (`package_ids[]`, maximum 50 per request), replace each cart line's package snapshot only after every requested active package is returned with a current signed token, and preserve the selected voucher quantities. A partial/failed refresh must leave the existing cart untouched and the expired-pricing state visible.

## Network–POS targeted QR invitations — 2026-11-22

The canonical API contract is `netsales_api/docs/project/API_CONTRACTS.md`, section **M4 POS–Network Linking Challenge API Contracts (Targeted QR Workflow)**.

- A Network invitation always targets exactly one Network and one POS. Never expose or call a public POS directory/search endpoint.
- Resolve a POS by its commercial business code using `POST /network-pos/challenges/resolve-target` with `network_id` and `pos_uuid`. The value called `pos_uuid` on the wire is the formatted business code (for example `POS-YYMM-00001-AB12`), not an RFC UUID. Keep the target dialog open after resolution, display the verified POS name and business code, and require explicit user confirmation before creating the challenge.
- The minimal resolve response includes `pos_id`, `pos_uuid`, `pos_name`, and optional governorate/directorate names. The `pos_uuid` field is required by Flutter's subsequent create-challenge call; do not infer it from `pos_id`.
- Create challenge with the same `network_id` and resolved `pos_uuid`. The API requires exactly one of `pos_id` or `pos_uuid`; never create an untargeted challenge. Its nested network projection is limited to ID/name, and its POS projection to ID/business-code/name; do not depend on owner, contact, address, or administrative fields in this response.
- The encrypted QR payload is the only challenge payload rendered in the QR. Do not expose internal IDs, nonce, or secret fields on the share card.
- Read challenge lifecycle from `GET /network-pos/challenges/{uuid}`; the safe response contains only `status`, `status_label`, and `expires_at`. It must not include challenge UUID, target IDs, or encrypted payload.
- Parse challenge expiry as an ISO-8601 instant. Display the server-confirmed status and exact expiry; client countdown is presentation only and never changes server status.
- The target-selection dialog and QR invitation sheet are presentation-only `StatelessWidget` views. The owning GetX controller manages form state, validation, target resolution, challenge creation, polling/timers, revocation, export/share state, and asynchronous errors.
- Open dialogs through `CustomDialog` and sheets through `CustomBottomSheet.show`. Use `CustomTextField`, `CustomButton`, `CustomSnackbar`, and the canonical file/share services. No raw `AlertDialog`, `Get.dialog`, local `StatefulWidget`, `setState`, or feature-local duplicate of shared QR primitives.
- The invitation share-card composition is Commercial-specific and belongs under `features/commercial/presentation/widgets`; generic QR rendering remains in `lib/widgets/qr`.
- The server remains the sole authority for Network/POS eligibility, tenant authorization, target binding, challenge lifecycle, and expiry.

