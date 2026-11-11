# Independent host example

This is a second Flutter host for the document engine. It uses a distinct
Northstar Labs brand profile and intentionally has no GetX dependency.

From this directory:

\`\`\`sh
flutter pub get
flutter run -d windows
\`\`\`

The sample builds a branded operations brief, previews the immutable artifact,
and demonstrates host-owned save/share/print adapters. It uses only the public
document-engine contracts and Flutter Material widgets.
