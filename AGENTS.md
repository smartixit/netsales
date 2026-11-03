# NETSALES (FLUTTER) — CONSTITUTIONAL INVARIANTS & PERMANENT AGENT GOVERNANCE

## 1. Product Identity and Scope Restrictions
- NetSales is an enterprise **B2B Network and Point-of-Sale (POS) Sales Management Platform**.
- **Mobile/Tablet Scope Restriction:** The Flutter application is strictly restricted to two operating workspaces:
  1. **Network Workspace** (`NETWORK_OWNER`, `NETWORK_USER`, `NETWORK_ACCOUNTANT`)
  2. **POS Workspace** (`POS_AGENT`, `POS_USER`, `POS_ACCOUNTANT`)
- **Platform Scope Exclusion:** `SUPER_ADMIN` and Platform SaaS licensing are strictly outside the mobile application's scope (reserved for Windows desktop). Do not introduce Platform Workspace navigation or platform management screens.
- **Explicit Anti-Definitions:**
  - **NOT** a voucher-card inventory management app (no card vaults, serial numbers, PIN reveals, or physical warehouse stock).
  - **NOT** a consumer retail checkout POS (no retail sales to end-user citizens).
  - **NOT** a router/RADIUS gateway configuration tool.

## 2. Financial Authority — Zero Client-Side Accounting
- The Laravel API backend is the **100% authoritative entity** for all prices, package tariffs, contractual discounts, invoice line items, wallet balances, credit ceilings, debt aging tiers, and FIFO repayment allocations.
- Flutter is a **presentation-only consumer**. Flutter collects input, optionally requests server previews where endpoints exist, submits operations, and renders authoritative server responses.
- **Strict Prohibition:** Flutter code must **never** calculate, extrapolate, or persist authoritative financial totals, ledger statements, or repayment allocations.

## 3. Security and Authorization Boundary
- The Laravel backend is the **sole security boundary**.
- Flutter client-side role checks, route guards, and workspace selection are purely for UX and navigation convenience. They do NOT provide security enforcement.
- Active tenant context (selected Network ID or POS ID) must be authoritatively transmitted via API headers/payloads as required by Laravel.

## 4. Flutter Architectural Standards & State Management
- **State Management Ecosystem:** **GetX** is the project's exclusive state management and dependency injection ecosystem (`GetxController`, `GetBuilder`/`Obx`, `Bindings`).
  - **PROHIBITIONS:**
    - **NO Provider, Riverpod, Bloc, or MobX.**
    - **NO `StatefulWidget` or `setState()` in application feature code.** All screens, dialogs, bottom sheets, and presentation widgets must be `StatelessWidget` (or `GetView<T>`), driven exclusively by GetX reactive state (`Rx`, `Obx`).
    - **NO direct HTTP calls in controllers or UI:** `GetxController` classes must delegate to Domain Use Cases and are strictly forbidden from importing `ApiService`, `package:http`, or `package:dio` directly.
- **Architecture:** Feature-first 3-layer Clean Architecture:
  - `data/` (`datasources/`, `models/`, `repositories/`)
  - `domain/` (`entities/`, `repositories/`, `usecases/`) — Must remain pure Dart (zero imports from data, presentation, GetX, or Flutter material).
  - `presentation/` (`screens/`, `widgets/`, `controllers/`, `bindings/`)
- **Infrastructure Reuse:** Mandatory reuse of existing foundation (never create redundant duplicates):
  - **Error & Toast Feedback:** All errors, exceptions, and API failure messages must use `CustomSnackbar.show(..., type: SnackType.error)`.
  - **Action Loading & Success Overlays:** Mutating actions must use `CustomAnimationOverlay.showLoading()` / `CustomAnimationOverlay.showSuccess()`, always safely hidden in `finally { if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide(); }`.
  - **Feed & Card Loading:** All asynchronous list/feed loading states must use `CustomSkeletonFeed` or `CustomSkeletonShimmer`.
  - **Dialogs & Confirmations:** Confirmation and alert dialogs must use `CustomDialog` (`CustomDialog.danger`, `CustomDialog.confirmation`).
  - **Sheets:** Modal sheets must use `CustomBottomSheet.show(...)`.
  - **Widgets (`lib/widgets/`):**
    - Dialogs: `CustomDialog`, `CustomAnimationOverlay`, `DialogActionBar`, `DialogBodyContent`, `DialogIconHeader`.
    - Sheets: `CustomBottomSheet`, `InvoicePrintFormatSheet`.
    - Buttons: `CustomButton`, `CustomThemeToggleButton`.
    - Inputs: `CustomTextField`, `CustomPasswordField`, `CustomPasswordRequirementItem`, `CustomPhoneField`, `CustomPinField`, `CustomDropdown`, `CustomNumericKeyboard`.
    - Feedback & States: `CustomEmptyState`, `CustomErrorState`, `CustomLoadingState`, `CustomLoadingIndicatorBar`, `CustomNotFound`, `CustomOfflineBanner`, `CustomUnauthorized`, `CustomTabPlaceholder`, Skeleton Shimmers (`CustomSkeletonCard`, `CustomSkeletonFeed`, `CustomSkeletonGrid`, `CustomSkeletonListTile`, `CustomSkeletonShimmer`, `CustomSkeletonText`).
    - Toasts & Snackbars: `CustomSnackbar`, `CustomToast`.
    - Pickers: `CustomDatePickerField`, `CustomDatePickerModal`, `CustomFilePicker`, `CustomImagePicker`, `CustomContactPickerIconButton`, `CustomColorPicker`, `CustomPosSelectorField`.
    - Navigation & Foundation: `CustomAppScaffold`, `CustomFloatingBottomNavBar`, `DoubleBackExitScope`.
    - Media & QR: `MediaGalleryViewer`, `CustomCachedImage`, `CustomQrCode`.
    - Menus, Dividers & Interactions: `CustomPopupMenu`, `CustomLabeledDivider`, `CustomInteractiveBounce`, `CustomeThemeSwitcher`, `CustomPageIndicator`, `CustomSegmentedBar`.
  - **Utils (`lib/core/utils/`):** `DateFormatter`, `AmountFormatter`, `TextFormatter`, `FileSizeFormatter`, `FormValidators`, `IdempotencyHelper`, `SystemUiStyleResolver`.
  - **Core Services (`lib/core/services/`):** `ApiService`, `WorkspaceService`, `SessionService`, `ThemeService`, `StorageService`, `CredentialService`, `AppCryptoService`, `AppCacheService`, `InternetConnectionService`, `PermissionService`, `DeviceService`, `PushNotificationService`, `SmsRetrieverService`, `SoundService`, `ShareService`, `UrlLauncherService`, `FilePickerService`, `FileExportService`, `DatePickerService`, `ContactPickerService`, `QrCodeService`, `PublicSettingsService`, `AppExitService`.
  - **Theme & Design Tokens (`lib/core/themes/` & `lib/core/constants/`):** `AppColors`, `AppTypography`, `AppRadius`, `AppSpacing`, `AppBreakpoints`, `AppElevation`, `AppGradients`, `AppMotion`, `AppThemes`.
- **Responsive Design:** Strict adherence to `AppBreakpoints` across mobile and tablet form factors.

## 5. Milestone Approval Discipline & Project Memory
- Never implement features or start a new milestone without explicit user approval.
- All persistent project memory, state, and decisions are canonically documented in `netsales_api/docs/project/` and referenced locally in `docs/project/`.
- Maintain clean handoffs and update `docs/project/WORK_LOG.md` upon completing authorized tasks.
