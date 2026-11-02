---
trigger: always_on
description: Prohibition of client-side financial calculations and requirement for server authority.
---

# Rule: Financial and Accounting Invariants (Flutter)

## 1. Absolute Prohibition on Client-Side Financial Calculations
- Flutter must **NEVER** calculate, predict, or persist:
  - Invoice totals, subtotals, tax, or net line amounts.
  - Contractual discount deductions or promotional pricing.
  - Wallet balances or running ledger statements.
  - POS debt aging buckets or repayment allocations.
- All numbers displayed in the UI must originate directly from authoritative API responses.

## 2. Server Previews are Informational
- Where server-side modification or repayment preview endpoints exist, Flutter displays the returned preview with clear "Preview / Non-Binding" semantics.
- Previews do not represent finalized financial settlements.
- The authoritative transaction is the completed collection or approval response returned by Laravel.

## 3. Financial Formatting Consistency
- Always format currency, amounts, and percentages using the project's established utilities in `lib/core/utils/` (`AmountFormatter`, `CurrencyFormatter`).
- Never perform floating-point arithmetic on the client to reformat or aggregate numbers.
