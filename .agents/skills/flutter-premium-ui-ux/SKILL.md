---
name: flutter-premium-ui-ux
description: >-
  Enterprise visual design, deliberate information architecture, distinct screen composition,
  and proportionate visual QA verification across mobile and tablet form factors for NetSales Flutter screens.
---

# Skill: NetSales Premium UI/UX Engineering & Screen Composition

## Purpose
Enforces the **NetSales Permanent Premium UI/UX Engineering Standard**. Guides agents in designing, structuring, and verifying enterprise-grade, visually polished, and responsive screens across mobile and tablet form factors before marking UI work complete.

---

## 1. Design Freedom — No Universal Screen Templates
- Shell navigation patterns (such as floating bottom nav for mobile shells or navigation rails for tablet shells) are suitable workspace shell options, but must **NOT** become mandatory layouts for every screen.
- Layouts are design options chosen according to each screen's business purpose, information architecture, content density, and user workflow:
  - *Overview screens:* Meaningful metrics, contextual status indicators, actionable shortcuts.
  - *Directories/Lists:* Fast scanning, distinct entity badges, filters, clear actions.
  - *Detail views:* Strong hierarchical grouping, structured metadata, and progressive disclosure.
  - *Forms:* Logical visual stages or sections with inline validation; no overwhelming stacks.
  - *Financial screens:* Bold figures, explicit currency indicators, transaction signs (+/-), and structured tables or ledger timelines instead of forced cards.

---

## 2. Information Architecture Before Widget Implementation
Before assembling any widget tree:
1. **Identify Primary User Goal:** What is the single most important action or decision the user must make on this screen?
2. **Establish Information Hierarchy:**
   - Level 1: Key entity identifier, primary balance/status, or urgent alert.
   - Level 2: Core operational data (e.g., requested package counts, contracted rates).
   - Level 3: Supporting metadata (timestamps, reference IDs, audit logs).
3. **Group by Relationship:** Group related fields logically; do NOT scatter them across separate containers.
4. **Apply Progressive Disclosure:** Secondary details belong in bottom sheets, expansion panels, or dedicated details views—never overcrowd the primary screen.

---

## 3. Spatial Composition & Anti-Patterns
- **Avoid "Cardification":** Do not wrap every statistic or text block in a separate card. Use clean typography, surface container colors, and whitespace.
- **Avoid Generic Repetition:** Do not replicate the same layout across different business features. Design specifically for the entity's workflow.
- **Use Tokens Exclusively:**
  - `AppColors.primary`, `AppColors.secondary`, `AppColors.tertiary`, `surface`, `surfaceContainer*`.
  - `AppTypography.titleLarge`, `titleMedium`, `bodyLarge`, `badgeText`.
  - `AppSpacing.xs`, `sm`, `md`, `lg`, `xl`, `cardPadding`.
  - `AppRadius.card`, `chip`, `full`.
  - `AppElevation.level1` through `level4`.

---

## 4. Responsive Form Factor Adaptation
- Evaluate the best composition for:
  - Small phones (< 360dp)
  - Standard phones (< 600dp)
  - Tablet portrait & landscape (≥ 600dp)
- On mobile, prioritize focused content, efficient navigation, and a clear primary action.
- On tablets, use the available width intelligently through suitable multi-column layouts, side panels, navigation rails, or split views where justified.
- Constrain content width using `AppBreakpoints.maxContentWidth`. Never stretch narrow mobile lists across wide tablet displays.
- Always reuse `AppBreakpoints` (`mobileSmallMax: 360`, `mobileMax: 600`, `tabletMax: 900`, `desktopMax: 1240`).

---

## 5. Arabic & RTL Localization Verification
- Ensure reading flow is natural from right to left.
- Verify numbers and dates format according to locale using `DateFormatter` and `AmountFormatter`.
- Ensure icon directions (e.g., arrows, chevrons) correctly flip for RTL where directional.
- Check that long Arabic labels do not clip or wrap awkwardly.

---

## 6. UI State & Feedback Checklist
Every data-driven screen must implement:
1. **Loading State:** Tailored skeleton shimmers (`CustomSkeletonFeed`, `CustomSkeletonGrid`, `CustomSkeletonListTile`).
2. **Empty State:** Distinct [`CustomEmptyState`](file:///d:/Smartix/NetSales/netsales/lib/widgets/feedback/custom_empty_state.dart) with feature-specific title, explanatory subtitle, and next action.
3. **Error State:** [`CustomErrorState`](file:///d:/Smartix/NetSales/netsales/lib/widgets/feedback/custom_error_state.dart) with actionable retry button.
4. **Success State:** Crisp, responsive presentation of authoritative server data.

---

## 7. Proportionate Visual QA Gate
Before reporting any UI feature complete:
1. **Targeted Verification:** Visual verification must specifically cover the actual screens affected by the UI task.
2. **Representative Viewports:** Test at representative phone and tablet sizes using widget tests or rendered inspection.
3. **Theme Coverage:** Verify both Light and Dark theme palettes.
4. **No Unrendered Claims:** Inspect rendered output when the environment allows it; never claim visual verification without real rendered evidence.
5. **Quality Standard:** Confirm zero layout overflows (`RenderFlex overflowed`) and responsive user feedback.
