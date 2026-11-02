---
trigger: always_on
description: Non-negotiable NetSales B2B product scope, operating workspaces, and explicit anti-definitions for Flutter.
---

# Rule: NetSales Product and Business Invariants (Flutter)

## 1. Product Identity
NetSales is an enterprise **B2B Network and Point-of-Sale (POS) Sales Management System**.
The mobile/tablet Flutter client serves two primary business roles:
- Network Providers managing wholesale tariffs, merchant links, and procurement orders.
- Retail Points of Sale ordering wholesale packages and tracking debts/wallets.

## 2. Explicit Anti-Definitions [STRICT PROHIBITION]
- **NOT a Voucher-Card Inventory App:** No card vaults, PIN reveal screens, serial number batch scans, or physical warehouse stock tracking.
- **NOT a Consumer Retail POS:** No consumer shopping cart, citizen checkout, or retail sale screens.
- **NOT an ISP Gateway:** No MikroTik/RADIUS router integration screens.

## 3. Workspace Scopes & Platform Exclusion
- The Flutter client is strictly restricted to **Network Workspace** and **POS Workspace**.
- Platform administration (`SUPER_ADMIN`, `SUPPORT_AGENT`) belongs exclusively to the Windows desktop platform.
- Never add Platform Workspace navigation, platform billing, or `SUPER_ADMIN` screens to the Flutter application.
