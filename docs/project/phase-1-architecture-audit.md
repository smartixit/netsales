# Phase 1 — Flutter Architecture Inventory & Evidence

**Audit baseline:** `main` at `de3013a242240df883aa5aa9c4384969698c6bcb`  
**Audit branch:** `audit/phase-1-flutter-architecture-inventory-20261116` (created directly from that exact current `main` commit)  
**Scope:** Feature-layer ownership, presentation responsibility, GetX state boundaries, dependency direction, shared design-system reuse, and existing architecture tests/CI.  
**Status:** Source audit completed; no application refactor is included in this audit.

## 1. Method and limits

The audit reviewed the current `AGENTS.md`, Flutter architecture/GetX rule, UI/UX engineering rule, feature-engineering and premium UI skills, financial/security rules, `TESTING.md`, the project README/shared-contract reference, the architecture compliance test, and the current GitHub Actions workflow. It then inventoried all feature folders and inspected the highest-risk presentation widgets/controllers identified by source search.

The audit distinguishes a confirmed ownership breach from a large but potentially cohesive controller. File length alone is not treated as proof of a Clean Architecture violation.

No Flutter SDK, local working tree, emulator, or device is available in this session. No `dart format`, `flutter analyze`, `flutter test`, visual QA, or Android compile was executed for this audit branch. Those checks remain exact-HEAD PR gates.

## 2. Current feature surface

At the audit baseline, `lib/features/` contains 532 Dart files across 14 features:

| Feature | Data | Domain | Presentation | Total |
|---|---:|---:|---:|---:|
| auth | 14 | 24 | 53 | 91 |
| billing | 4 | 3 | 29 | 36 |
| catalog | 5 | 11 | 25 | 41 |
| commercial | 8 | 21 | 17 | 46 |
| expenses | 6 | 10 | 10 | 26 |
| finance | 10 | 20 | 39 | 69 |
| invoices | 7 | 11 | 16 | 34 |
| membership | 5 | 4 | 5 | 14 |
| notifications | 4 | 6 | 5 | 15 |
| onboarding | 4 | 4 | 7 | 15 |
| reports | 9 | 8 | 21 | 38 |
| requests | 8 | 16 | 19 | 43 |
| splash | 3 | 3 | 5 | 11 |
| workspace | 8 | 9 | 36 | 53 |
| **Total** | **95** | **142** | **290** | **532** |

The tree also contains 42 feature screen files and 181 feature widget files.

The approved dependency direction remains:

`Screen / Feature Widget → GetX Controller → Domain UseCase → Domain Repository Contract → Data Repository → DataSource → ApiService`

The core design system remains in `lib/core` and `lib/widgets`. Shared widgets must remain business-agnostic; feature-specific presentation stays under its feature.

## 3. Existing automated controls — what already works

### Architecture compliance test

`test/architecture/architecture_compliance_test.dart` currently checks:

1. No `StatefulWidget`, `State<...>`, or `setState()` in `lib/features/`.
2. No `ApiService`, `package:http`, or `package:dio` in feature presentation files.
3. Domain files do not reference `data/`, `presentation/`, GetX, or `flutter/material.dart`.
4. Files directly under `presentation/screens/` end with `_screen.dart`.
5. No raw `Switch` or `Switch.adaptive` outside the custom switch implementation.
6. The CommercialDirectoryController must not reintroduce the client-side `filteredLinks` getter.

### GitHub Actions

The repository has one workflow: `.github/workflows/datagrid-quality.yml`. Despite its historical name, the PR workflow runs dependency resolution/lockfile checks, `flutter analyze`, DataGrid tests, the full `flutter test` suite, and Android debug compilation without packaging an APK. It targets PRs to `main`.

There is no reason to create a duplicate general Flutter workflow. Phase 2 should extend the existing architecture test and ensure its checks remain in the existing full-suite gate.

### Verified strengths

- A repository search found no raw `TextButton`, `OutlinedButton`, or `ElevatedButton` construction in feature presentation.
- No feature presentation imports or direct calls to `ApiService` were found in the reviewed search results.
- No `setState()` or feature `StatefulWidget` implementation was found in the feature code search. Stateful implementations in generic `lib/widgets` are not a violation of the stated prohibition, which is scoped to `lib/features/`.
- Most feature remote HTTP implementations are placed under `data/datasources`, and most controllers reviewed receive Domain UseCases through constructor injection.

## 4. Confirmed presentation ownership violations

### FL-01 — Commercial details sheets own form state, data loading, and API-shaped payload construction

**Evidence:**
- `lib/features/commercial/presentation/widgets/pos_details_bottom_sheet.dart`, main blob `21d1a1c35846e36a15c678a57b0109c04c2c3665`.
- `lib/features/commercial/presentation/widgets/network_details_bottom_sheet.dart`, main blob `6a5ca1736616bc5a1a19b907160b814f897858c8`.

Both static sheet entry points create form keys and text controllers, call `Get.find`, create Rx state, and start geographic data loading from the widget. Their callbacks also build raw `Map<String, dynamic>` values using Laravel wire keys before invoking the controller.

The POS sheet additionally passes `pos.posId` as `posWalletId` when opening the credit-limit sheet (around line 395). POS identity and POS-wallet identity are distinct IDs; the data model exposes wallet identity separately, and the existing `GetPosWalletByNetworkAndPosUseCase` can resolve the authoritative wallet. The same area passes a POS ID into a wallet transaction sheet as `walletId`. This is a concrete identifier-domain bug, not a cosmetic concern.

**Required direction:** move form controllers, form validation state, geography-loading state, and submit orchestration into dedicated GetX presentation controllers/bindings. Use typed domain input/command objects instead of widget-assembled wire maps; map to JSON only in the Data layer. Reuse one commercial geography selector/component for both network and POS forms. Resolve the wallet using network+POS identity through the existing UseCase before exposing a wallet action; never alias IDs.

### FL-02 — Billing dialog widgets build request payloads and own editable input state

**Evidence:** `lib/features/billing/presentation/widgets/billing_dialogs.dart`, main blob `0e18c22e5c924ef68eb990992a1dc4de381b2019`.

Methods such as `editAccount`, `addContact`, `editContact`, and `payInvoice` instantiate and dispose their own `TextEditingController` objects, read values, apply defaults/conversions, build `Map<String, dynamic>` payloads, and call the main BillingController. The controller's state contract is also heavily map-based.

**Required direction:** move editable form state and validation into a controller or dedicated dialog controller. Expose typed actions such as update account, create contact, and request payment using domain/application input objects. Keep these widgets as composition/rendering plus callbacks, not wire-contract builders.

### FL-03 — Procurement action dialog widgets own mutable form state

**Evidence:** `lib/features/requests/presentation/widgets/procurement_action_dialogs.dart`, main blob `a36bf890fa910aa90c6a957b33b2f27ae1c64ee8`.

The approval and rejection dialog helpers create local text controllers; rejection also creates a local `GlobalKey<FormState>` and owns the validation flow before invoking the action callback.

**Required direction:** let the feature controller own the note/reason state and submit validation, or introduce a narrowly scoped dialog controller where lifecycle isolation is justified. The widget should display validation and relay intent, not own mutable form state.

### FL-04 — Saved-report preset dialog owns text-entry state

**Evidence:** `lib/features/reports/presentation/widgets/operational_report_preset_dialog.dart`, main blob `e59aebea3532ce8ba5d2afec6f64d77b303d886c`.

The view creates, reads, and disposes its own `TextEditingController`, then invokes a save callback using the extracted value.

**Required direction:** move the preset-name state and validation to the report controller or a dedicated preset-dialog controller. Do not transfer this input state to a new local stateful widget.

### FL-05 — QR challenge sheet starts an asynchronous command from the view

**Evidence:** `lib/features/commercial/presentation/widgets/network_pos_qr_challenge_sheet.dart`, main blob `6b8ec054f57964da55d2222a3a8e5ebd9029582b`.

The sheet calls `Get.find<CommercialDirectoryController>()`, immediately starts `createQrChallenge()`, and uses `FutureBuilder` to manage the result. This is asynchronous workflow orchestration in a presentation widget.

**Required direction:** have the controller/use case create the challenge and expose loading/success/error state before or while opening the sheet. The sheet should render the supplied state/entity and relay revoke intent.

## 5. High-complexity controllers — candidates requiring cohesive extraction

These are not to be split by line count alone. Each extraction must preserve the current request-revision, stale-response, cursor, consistency, and lifecycle protections.

| Candidate | Current responsibility concentration | Possible boundary to evaluate |
|---|---|---|
| `CommercialDirectoryController` | Network/POS lists, membership-linked directory, detail loading/updating, QR challenge flow, sheet/navigation entry points. | Separate detail-edit form workflows and QR challenge use-case orchestration; retain directory list state in its own controller. |
| `OperationalReportsController` | Report catalog, criteria/presentation state, cursor result loading, POS lookup, saved presets, export job state, summary/PDF generation, full-page retrieval and consistency guards. | A report-document preparation UseCase for cursor traversal and snapshot-consistency verification; separate preset lifecycle coordination if the call graph shows independent ownership. |
| `PosWalletDashboardController` | Wallet dashboard/log state plus full ledger traversal, repeated-cursor/row-limit checks, latest-log verification, wallet snapshot comparison and PDF export coordination. | A statement preparation UseCase returning a complete, verified statement snapshot; controller retains UI loading/error and selection state. |
| `BillingController` | Six cursor collections, filters, detail/event/usage state, payment workflows, and raw `Map<String, dynamic>` response/payload data. | Typed Billing entities and command inputs; potentially separate controllers by independently navigable workspace area after mapping screens and bindings. |

The PDF export consistency checks in Reports and Finance are useful correctness protections. The refactor must relocate orchestration without weakening those checks or moving financial calculation authority into Flutter.

## 6. Shared UI and data-contract observations

- The scan found no raw stock button constructors in feature presentation; continue using the existing `CustomButton` and other approved components.
- Do not relocate Network/POS-specific selectors or domain-aware widgets into global `lib/widgets`; those belong in the feature unless the component can be made genuinely business-agnostic.
- The Reports and Billing features expose a substantial amount of `Map<String, dynamic>` to presentation. This is not an HTTP-boundary violation by itself, but it weakens typed contracts and encourages widgets to assemble server payloads. Convert one action at a time to typed input objects/entities without adding a new JSON abstraction at the UI layer.
- The architecture audit did not establish a general duplicate-widget inventory across all features. Phase 2 should add a mechanical inventory/check that flags duplicate shared control implementations for review, then each refactor must reuse the current central components.

## 7. Phase 1 conclusion and ordered remediation

The main confirmed Flutter architectural debt is concentrated in presentation widgets that own form state, data loading, async commands, or API-shaped payload construction. The broad Clean Architecture dependency direction is otherwise present, and existing automated tests already protect several important boundaries.

The next stages remain:

1. **Phase 2 — Preventive gates:** strengthen the existing architecture compliance tests for widget-owned mutable state, use-case delegation, typed command contracts, screen/widget placement, and cross-feature import boundaries. Do not create a duplicate workflow.
2. **Phase 3 — Commercial:** refactor both detail sheets and QR challenge sheet; correct the POS-ID/wallet-ID misuse; consolidate geography form behavior; keep the work on a fresh branch from current `main`.
3. **Phase 4 — Finance/Wallet/Debt:** extract statement preparation and preserve all cursor/snapshot consistency guarantees; no client-side financial calculations.
4. **Phase 5 — Remaining Flutter features:** invoices, requests, catalog, billing, reports, membership, workspace, notifications, then auth. Apply the same responsibility audit to each feature before moving code.
5. **Phase 6 — Laravel backend:** address the confirmed Controller/FormRequest/Service/Repository boundary breaches recorded in the canonical API audit.
6. **Phase 7 — Proof:** full Flutter and Laravel tests, analyzer/static analysis, architecture checks, RTL/LTR and light/dark rendered UI QA, and exact-HEAD Actions.
7. **Phase 8 — Closeout:** verify no duplicate components, no regression in contracts/security/financial authority, append work log/state, and hand off the verified result.

**No application source was changed by this audit.** Every implementation phase must start from the then-current `main`, use its own branch and PR, and pass exact-HEAD CI before merge.
