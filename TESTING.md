# Flutter Test Strategy

This file is a starting checklist. Adapt it to the actual app and keep it current.

## Required layers

- Unit tests for domain logic, parsers, validators, formatters, and data mapping.
- Widget tests for screens/components, user interaction, and loading/empty/error states.
- Integration tests for a small number of critical journeys on an emulator/device or browser target.
- Golden tests for stable, high-value screens where visual regressions are expensive.

## Project-specific decisions to record

- App entry point and bootstrap method used by tests:
- GetX binding/controller cleanup strategy:
- Test API base URL configuration:
- Test user/account provisioning:
- Device/emulator(s) used for integration tests:
- Golden test platform, fonts, and viewport policy:
- CI commands and any intentionally excluded device-only tests:

## Baseline commands

```powershell
flutter test
flutter test --coverage
flutter test integration_test
flutter analyze
 dart format --output=none --set-exit-if-changed .
```

Run integration tests with a selected target device when needed, for example:

```powershell
flutter test integration_test/app_flow_test.dart -d <device-id> --dart-define=API_BASE_URL=<test-api-url>
```

Replace placeholders with actual project values. Do not put a production URL or secret in source control.

## Test data and safety

- Use a dedicated test backend and isolated database.
- Reset test state between scenarios.
- Do not use real customer data or production credentials.
- Avoid depending on live third-party services in ordinary CI tests; mock them or use a sandbox.

## Visual review checklist

- Phone widths, tablet/desktop if supported, portrait/landscape where relevant.
- Arabic RTL and English LTR.
- Loading, empty, success, validation, server failure, and offline states.
- Keyboard, scrolling, safe areas, text scaling, long text, and accessibility semantics.
- Review golden diffs before updating baseline images.
