---
trigger: always_on
description: Mandatory NetSales Premium UI/UX Engineering Standard, Information Architecture, Visual Hierarchy, and Screen Composition.
---

# Rule: Premium UI/UX Engineering Standard & Screen Composition

## 1. Core Principle: Visual Quality is an Engineering Requirement
NetSales is an enterprise B2B sales and financial management platform. Functional correctness alone is **insufficient** for UI acceptance. Every screen must demonstrate deliberate, polished, and distinctive enterprise design.

## 2. Design Freedom — No Mandatory Screen Templates (STRICT)
- **No Universal Templates:** Shell navigation patterns (such as floating bottom navigation for mobile or navigation rails for tablets) are suitable workspace shell options, but they must **never** become mandatory layouts for every screen.
- **Purpose-Driven Layout:** Each screen must select its composition according to its specific business purpose, user workflow, and information density:
  - *Overview screens:* Meaningful operational summaries, urgent indicators, and actionable shortcuts.
  - *Directories & Lists:* High-efficiency scanning, comparison, filtering, and clear entity badges.
  - *Detail views:* Strong hierarchical grouping and structured metadata.
  - *Forms:* Logical stages or sections without overwhelming inputs.
  - *Financial & Data-Dense screens:* High numerical readability, transaction signs (+/-), and structured tables or ledger timelines instead of forced cards.
- **NO Excessive Nested Containers / "Cardification":** Do not wrap every label, statistic, or input in a separate card. Use cards only when physical boundaries genuinely aid comprehension.
- **NO Blind Widget Stacking:** Never start building a screen by dumping widgets inside a `Column` or `ListView` without establishing information architecture first.

## 3. Information Architecture & Spatial Composition
Before writing any UI widgets:
1. Identify primary vs. secondary user goals and actions.
2. Group related information logically into coherent visual sections.
3. Establish a clear reading sequence and visual hierarchy (using typography, weight, and deliberate whitespace rather than competing loud colors).
4. Apply **progressive disclosure** for secondary details to keep screens clean and uncluttered.

## 4. Multi-Form Factor Adaptation (Mobile vs. Tablet)
- **Mobile (< 600dp):** Focused, efficient vertical hierarchy, appropriate touch targets, and clear primary actions.
- **Tablet (≥ 600dp):** Intelligent multi-column layouts, master-detail views, side panels, and constrained content width (`AppBreakpoints.maxContentWidth`). Never stretch mobile lists across full tablet width.
- Always reuse `AppBreakpoints` (`mobileSmallMax: 360`, `mobileMax: 600`, `tabletMax: 900`, `desktopMax: 1240`).

## 5. Design System Token Invariants
- **Colors:** Mandatory use of `AppColors.primary`, `AppColors.secondary`, `AppColors.tertiary`, and Material 3 surface hierarchy.
- **Typography:** Mandatory use of `AppTypography` styles (`badgeText`, `bodyLarge`, `titleMedium`, etc.).
- **Radii & Spacing:** Strict adherence to `AppRadius` and `AppSpacing`. Never hardcode raw numeric margins or paddings.
- **Motion & Interactions:** Reuse `AppMotion`, `AppElevation`, and `CustomInteractiveBounce`. Keep animations purposeful and responsive.

## 6. Arabic, RTL & Complete Interface State Quality
- **First-Class RTL:** Verify correct reading order, logical alignment, appropriate icon orientation, and zero label clipping or awkward wraps.
- **Explicit State Handling:** Every data view must implement contextual:
  - **Loading:** Tailored skeleton shimmers (`CustomSkeletonFeed`, `CustomSkeletonGrid`, etc.).
  - **Empty:** Feature-specific contextual message explaining what is missing and offering a clear next action.
  - **Error:** Actionable error state with user retry.
  - **Success:** Polished, responsive data presentation.

## 7. Mandatory Design Quality & Visual QA Gate
A UI feature is **incomplete** and rejected if it exhibits:
- Repetitive generic templating without architectural purpose.
- Excessive nested cards or visual clutter.
- Broken responsive layout or awkward stretching.
- Poor information hierarchy or unverified visual rendering.
- Visual verification must cover actual affected screens across representative phone/tablet sizes and Light/Dark themes. Never claim visual verification without real rendered evidence.
