---
trigger: always_on
description: Mandatory Flutter Clean Architecture (data, domain, presentation), GetX standards, and design system reuse.
---

# Rule: Flutter Architecture, GetX State Management & Clean Architecture Standards

## 1. Feature Clean Architecture Structure
Every feature module under `lib/features/<feature_name>/` must implement the 3-layer Clean Architecture layout:

```text
lib/features/<feature_name>/
├── data/
│   ├── datasources/     # Remote and local API datasources
│   ├── models/          # Data transfer models (fromJson/toJson)
│   └── repositories/    # Repository implementations
│
├── domain/
│   ├── entities/        # Pure business entities
│   ├── repositories/    # Abstract repository interfaces
│   └── usecases/        # Domain use cases encapsulating operations
│
└── presentation/
    ├── screens/         # Responsive screen views
    ├── widgets/         # Feature-specific atomic UI components
    ├── controllers/     # GetxControllers (UI state & use case delegation)
    └── bindings/        # GetX Bindings (dependency registration)
```

## 2. GetX Ecosystem Invariants
- **Exclusive State Management:** GetX is the exclusive state management, dependency injection, and routing ecosystem for NetSales.
  - Controllers must extend `GetxController`.
  - State observation must use `Obx(...)` or `GetBuilder(...)`.
  - Dependency registration must use `Bindings` classes bound to route definitions in `AppPages`.
- **Prohibitions:**
  - **NO Provider, Riverpod, Bloc, or MobX packages.**
  - **NO custom `StatefulWidget` state machines** for business logic or API state (use `GetxController`). `StatefulWidget` is permitted only for low-level UI ticker/animation controllers.

## 3. Mandatory Infrastructure & Design System Reuse
Never re-implement components or utilities that already exist in `lib/widgets/` or `lib/core/`:
- **Shared Widgets (`lib/widgets/`):**
  - **Buttons (`lib/widgets/buttons/`):** `CustomButton`, `CustomThemeToggleButton`.
  - **Dialogs (`lib/widgets/dialogs/`):** `CustomDialog`, `CustomAnimationOverlay`, `DialogActionBar`, `DialogBodyContent`, `DialogIconHeader`.
  - **Sheets (`lib/widgets/sheets/`):** `CustomBottomSheet`, `InvoicePrintFormatSheet`.
  - **Inputs (`lib/widgets/inputs/`):** `CustomTextField`, `CustomPasswordField`, `CustomPasswordRequirementItem`, `CustomPhoneField`, `CustomPinField`, `CustomDropdown`, `CustomNumericKeyboard`.
  - **Feedback & States (`lib/widgets/feedback/`):** `CustomEmptyState`, `CustomErrorState`, `CustomLoadingState`, `CustomLoadingIndicatorBar`, `CustomNotFound`, `CustomOfflineBanner`, `CustomUnauthorized`, `CustomTabPlaceholder`, Skeleton Shimmers (`CustomSkeletonCard`, `CustomSkeletonFeed`, `CustomSkeletonGrid`, `CustomSkeletonListTile`, `CustomSkeletonShimmer`, `CustomSkeletonText`).
  - **Toasts (`lib/widgets/toasts/`):** `CustomSnackbar`, `CustomToast`.
  - **Pickers (`lib/widgets/pickers/`):** `CustomDatePickerField`, `CustomDatePickerModal`, `CustomFilePicker`, `CustomImagePicker`, `CustomContactPickerIconButton`, `CustomColorPicker`, `CustomPosSelectorField`, `FileCardItem`, `FilePickerDropzone`.
  - **Foundation & Nav (`lib/widgets/foundation/` & `lib/widgets/navigations/`):** `CustomAppScaffold`, `CustomFloatingBottomNavBar`, `DoubleBackExitScope`.
  - **Media & QR (`lib/widgets/media_gallery/`, `images/`, `qr/`):** `MediaGalleryViewer`, `CustomCachedImage`, `CustomQrCode`.
  - **Dividers, Menus & Indicators (`lib/widgets/dividers/`, `menus/`, `indicators/`, `interactions/`):** `CustomLabeledDivider`, `CustomPopupMenu`, `CustomPageIndicator`, `CustomSegmentedBar`, `CustomInteractiveBounce`, `CustomeThemeSwitcher`.
- **Utils (`lib/core/utils/`):** `DateFormatter`, `AmountFormatter`, `TextFormatter`, `FileSizeFormatter`, `FormValidators`, `IdempotencyHelper`, `SystemUiStyleResolver`, `ConnectionFailure`.
- **Core Services (`lib/core/services/`):** `ApiService`, `WorkspaceService`, `SessionService`, `ThemeService`, `StorageService`, `CredentialService`, `AppCryptoService`, `AppCacheService`, `InternetConnectionService`, `PermissionService`, `DeviceService`, `PushNotificationService`, `SmsRetrieverService`, `SoundService`, `ShareService`, `UrlLauncherService`, `FilePickerService`, `FileExportService`, `DatePickerService`, `ContactPickerService`, `QrCodeService`, `PublicSettingsService`, `AppExitService`.
- **Theme & Design Tokens (`lib/core/themes/` & `lib/core/constants/`):**
  - Colors: `AppColors.primary` (`0xFF0D7A5F`), `AppColors.secondary` (`0xFF1ABC9C`), `AppColors.tertiary` (`0xFF2ECC71`), and Material 3 surface container hierarchy.
  - Typography: `AppTypography` (`badgeText`, `bodyLarge`, `titleMedium`, etc.).
  - Radii & Spacing: `AppRadius.full`, `AppRadius.chip`, `AppRadius.card`, `AppSpacing`.
  - Elevation, Gradients & Motion: `AppElevation`, `AppGradients`, `AppMotion`, `AppThemes`.
  - Breakpoints: `AppBreakpoints` (`mobileSmallMax: 360`, `mobileMax: 600`, `tabletMax: 900`, `desktopMax: 1240`).

## 4. UI State Coverage
Every view handling asynchronous data must explicitly implement:
- **Loading State:** Shimmers or controlled loaders.
- **Empty State:** Informative empty illustrations and messages.
- **Error State:** Actionable error display with retry capability.
- **Success State:** Loaded content rendered responsively.
