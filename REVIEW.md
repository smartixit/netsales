# Flutter Repository Review Notes

> Fill in this file for each application. Keep it short and specific to this repository.

## Project decisions

- State management and dependency injection: [record the selected approach, e.g. GetX; do not assume]
- Navigation/routing: [record package and conventions]
- Architecture and feature boundaries: [link to architecture document]
- Local persistence and secure storage: [record packages and sensitive data rules]
- API client, serialization, and error handling: [record conventions]
- Localization and RTL approach: [record supported locales and direction rules]

## High-risk areas to review

- Authentication/session/token storage and refresh.
- Permission handling and platform channels.
- Deep links, external intents, and WebView boundaries.
- Local files, backups, cache, and exported data.
- Payments or other sensitive user actions, if present.
- API request/response compatibility with the backend.
- State lifecycle, async cancellation, duplicate requests, and stale data.

## Generated or excluded files

- Generated files: [list paths and how they are regenerated]
- Files that reviewers should normally skip: [list only justified paths]

## Verification commands

- Format: `dart format --output=none --set-exit-if-changed .`
- Analyze: `flutter analyze`
- Unit/widget tests: `flutter test`
- Integration tests: [document exact command and device/emulator assumptions]
- Build: [document target-specific command]

## Repository-specific failure patterns

- [Add concrete defects that have occurred in this repository and how to detect them.]
