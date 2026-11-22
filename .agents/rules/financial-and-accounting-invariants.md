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
- All numbers displayed in the UI must originate directly from authoritative API responses.

## 2. Server Previews are Informational
- Where server-side modification preview endpoints exist, Flutter displays the returned preview with clear "Preview / Non-Binding" semantics.
- Previews do not represent finalized financial settlements.
- The authoritative transaction is the completed collection or approval response returned by Laravel.

## 3. Financial Formatting Consistency
- Always format currency, amounts, and percentages using the project's established utilities in `lib/core/utils/` (`AmountFormatter`, `CurrencyFormatter`).
- Never perform floating-point arithmetic on the client to reformat or aggregate numbers.

## 4. POS Procurement Display-Only Estimate Exception (DEC-PROC-01)

Only the POS new-procurement package cards and cart summary may calculate a **non-binding display estimate** from current Laravel-issued package pricing snapshots. Inputs are integer minor-unit base price and basis-point cash-discount rates, accompanied by a signed token and expiry timestamp. Flutter uses integer arithmetic, rounds the discount per line using half-up basis-point rounding, and recalculates locally when quantity changes.

This exception is not an accounting calculation and must never be submitted, persisted, or used for financial authorization. New request creation sends only package IDs, quantities, and each item's signed snapshot token. Laravel validates each snapshot against the current POS/network/package tariff and discount, then computes authoritative totals. Missing or expired snapshots block submission and require catalogue refresh. No other financial feature receives this exception.

## 5. POS CASH/CREDIT and Repayment Scope
- POS invoices and procurement requests support CASH and CREDIT according to the API contract.
- Flutter may collect an optional initial payment amount where the API contract permits it; it must pass the amount unchanged and must never derive paid_amount, remaining_amount, payment_status, or credit capacity.
- Invoice details and reports display the payment fields returned by Laravel. No local financial balance calculation is permitted.
- POS Repayment collection, reversal, invoice allocation/FIFO, and repayment-specific screens, navigation, reports, and documents are removed.
- Receivables aging and invoice-level outstanding balances remain distinct from repayment collection and must not be removed merely because Repayment is removed.
