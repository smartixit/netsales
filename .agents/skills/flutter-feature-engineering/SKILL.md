---
name: flutter-feature-engineering
description: >-
  Standardized procedure for implementing new Flutter features in NetSales.
  Enforces 3-layer Clean Architecture (data, domain, presentation), GetX state management,
  mandatory reuse of lib/widgets/ and design tokens, and zero client-side financial calculations.
---

# Skill: NetSales Flutter Feature Engineering

## Purpose
Guides the implementation of Flutter features in NetSales according to established project conventions, Clean Architecture layers, GetX state management, and cursor pagination standards.

---

## 1. Feature Clean Architecture Structure

Every feature under `lib/features/<feature_name>/` must follow this exact 3-tier structure:

```text
lib/features/<feature_name>/
├── data/
│   ├── datasources/     # Remote and local API datasources (HTTP/Dio requests)
│   ├── models/          # Data transfer models (fromJson/toJson, API mappings)
│   └── repositories/    # Repository implementations (implements domain repository contracts)
│
├── domain/
│   ├── entities/        # Pure business entities (immutable domain models)
│   ├── repositories/    # Abstract repository interfaces/contracts
│   └── usecases/        # Reusable domain use cases encapsulating business actions
│
└── presentation/
    ├── screens/         # Full-screen responsive views and layouts
    ├── widgets/         # Feature-specific atomic UI components
    ├── controllers/     # GetxControllers managing view state and invoking use cases
    └── bindings/        # GetX Bindings instantiating controllers and dependencies
```

---

## 2. Layer Responsibilities & Component Placement

1. **Presentation Layer (`presentation/`):**
   - **Screens (`presentation/screens/`):**
     - Responsible exclusively for **page-level composition**: arranging layout, integrating feature-specific and shared widgets, and connecting the view to its `GetxController`.
     - **Strict Prohibition:** Screen files must NOT become containers for full widget implementations. Do not embed list items, cards, multi-field search bars, or dialogs inline within screen files.
   - **Feature-Specific Widgets (`presentation/widgets/`):**
     - Default location for widgets with meaning tied to the feature (e.g. `network_pos_card.dart`, `network_pos_search_filter_header.dart`, `link_pos_bottom_sheet.dart`).
     - Do NOT move feature-specific components into global `lib/widgets/`.
   - **Controllers (`presentation/controllers/`):**
     - Subclasses of `GetxController`. Sole owner of mutable presentation state (`Rx`, `.obs`, text controllers). Delegates business operations to Domain Use Cases. Prohibited from calling `ApiService` directly.
     - Manages cursor pagination, debounced server-side search, and load-more state.
   - **Bindings (`presentation/bindings/`):**
     - Extends `Bindings` to inject controllers, use cases, and repositories lazily via `Get.lazyPut(...)` and binds them to `AppPages` routes.
2. **Domain Layer (`domain/`):**
   - **Entities:** Pure Dart classes representing core business data structures. Free of JSON serialization dependencies.
   - **Repositories (Interfaces):** Abstract contracts defining data operations required by use cases, returning `PaginatedList<T>` for unbounded list operations.
   - **Use Cases:** Granular, single-responsibility business operations (e.g. `GetNetworkPosListUseCase`).
3. **Data Layer (`data/`):**
   - **Models:** Extends or maps to domain entities, containing `fromJson` and `toJson` serialization matching Laravel API resources.
   - **Data Sources:** Handle raw network calls (`ApiService`), headers, query parameters, and cursor propagation.
   - **Repositories (Implementations):** Implements domain repository interfaces, coordinating data sources and converting models to domain entities and `PaginatedList<T>`.
4. **Global Generic Widgets (`lib/widgets/`):**
   - Genuinely shared, domain-independent UI primitives (`CustomButton`, `CustomTextField`, `CustomDialog`, `CustomEmptyState`, `CustomSwitch`, `CustomSwitchListTile`).
5. **Shared Infrastructure (`lib/core/`):**
   - Application services, utilities, themes, exceptions, models (`PaginatedList`), and configuration. Never presentation widgets.

---

## 3. Engineering Rules & Invariants

- **State Management Ecosystem:** **GetX** is the exclusive ecosystem.
  - Bind UI with `Obx(() => ...)` or `GetBuilder<FeatureController>`.
  - **Prohibited:** Provider, Riverpod, Bloc, and custom state machines via `StatefulWidget`. `StatefulWidget` and `setState` are strictly prohibited in application feature presentation code.
- **Cursor Pagination & Load-More (Mandatory):**
  - Growing collections must use `PaginatedList<T>` from `lib/core/models/paginated_list.dart`.
  - Incremental load-more appends items to existing `RxList` without full-screen reload.
  - In-list load-more uses content-matching skeleton (e.g. `NetworkPosCardSkeleton`).
  - Search and filter queries must trigger debounced (300ms) server-side calls and reset pagination cursor.
- **Infrastructure & Core Reuse (Mandatory):**
  - **Dialogs & Sheets:** Reuse `CustomDialog`, `CustomAnimationOverlay`, `DialogActionBar`, `CustomBottomSheet`, `InvoicePrintFormatSheet`.
  - **Inputs & Switches:** Reuse `CustomTextField`, `CustomPasswordField`, `CustomPhoneField`, `CustomPinField`, `CustomDropdown`, `CustomNumericKeyboard`, `CustomSwitch`, `CustomSwitchListTile`.
  - **Buttons:** Reuse `CustomButton`, `CustomThemeToggleButton`.
  - **Feedback & Skeletons:** Reuse `CustomEmptyState`, `CustomErrorState`, `CustomLoadingState`, `CustomLoadingIndicatorBar`, `CustomNotFound`, `CustomOfflineBanner`, `CustomUnauthorized`, and skeleton shimmers (`CustomSkeletonCard`, `CustomSkeletonFeed`, `CustomSkeletonGrid`, `CustomSkeletonListTile`, `CustomSkeletonShimmer`, `CustomSkeletonText`).
  - **Toasts:** Reuse `CustomSnackbar`, `CustomToast`.
  - **Pickers:** Reuse `CustomDatePickerField`, `CustomDatePickerModal`, `CustomFilePicker`, `CustomImagePicker`, `CustomContactPickerIconButton`, `CustomColorPicker`, `CustomPosSelectorField`.
  - **Foundation, Nav & Media:** Reuse `CustomAppScaffold`, `CustomFloatingBottomNavBar`, `DoubleBackExitScope`, `MediaGalleryViewer`, `CustomCachedImage`, `CustomQrCode`.
  - **Dividers, Menus & Indicators:** Reuse `CustomLabeledDivider`, `CustomPopupMenu`, `CustomPageIndicator`, `CustomSegmentedBar`, `CustomInteractiveBounce`.
  - **Utils:** Reuse `DateFormatter`, `AmountFormatter`, `TextFormatter`, `FileSizeFormatter`, `FormValidators`, `IdempotencyHelper`, `SystemUiStyleResolver`.
- **Zero Financial Calculations:**
  - Never compute invoice line sums, discount subtotals, or repayment allocations on the client.
  - Display financial amounts originating directly from authoritative Laravel API responses.
- **Required View State Coverage:**
  - Explicit Loading, Empty, Error (with retry), and Success states on all data screens.
