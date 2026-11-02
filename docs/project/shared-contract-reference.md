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
