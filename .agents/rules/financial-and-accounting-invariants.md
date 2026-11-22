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
- Where server-side modification preview endpoints exist, Flutter displays the returned preview with clear "Preview / Non-Binding" semantics.
- Previews do not represent finalized financial settlements.
- The authoritative transaction is the completed collection or approval response returned by Laravel.

## 3. Financial Formatting Consistency
- Always format currency, amounts, and percentages using the project's established utilities in `lib/core/utils/` (`AmountFormatter`, `CurrencyFormatter`).
- Never perform floating-point arithmetic on the client to reformat or aggregate numbers.

## 4. POS Procurement Display-Only Estimate Exception (DEC-PROC-01)

Only the POS new-procurement package cards and cart summary may calculate a **non-binding display estimate** from current Laravel-issued package pricing snapshots. Inputs are integer minor-unit base price and basis-point discount rates, accompanied by a signed token and expiry timestamp. Flutter uses integer arithmetic, rounds the discount per line using half-up basis-point rounding, and recalculates locally when quantity or sale type changes.

This exception is not an accounting calculation and must never be submitted, persisted, or used for financial authorization. New request creation sends only package IDs, quantities, and each item's signed snapshot token. Laravel validates each snapshot against the current POS/network/package tariff and discount, then computes authoritative totals. Missing or expired snapshots block submission and require catalogue refresh. No other financial feature receives this exception.

## 5. POS Sales Scope
- POS invoices are cash-settled only. Credit sales, POS debt ledgers, debt aging, repayment collection, reversal, and FIFO allocation are not supported.
- Flutter must not expose navigation, screens, forms, report types, or API clients for the removed POS debt/repayment domain.
