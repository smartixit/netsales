# document_engine

Reusable, framework-agnostic document contracts, template registry, and bounded PDF renderer for Dart/Flutter hosts.

## M1 — Core contracts

- Stable typed identifiers for documents, document types, and templates.
- Exact semantic template versions.
- Locale and reading-direction metadata.
- Typed document values and immutable content nodes.
- Structured tables with validated column/row consistency.
- Immutable document sections and snapshots.
- Template capability declarations and deterministic in-memory registration.

## M2 — PDF rendering foundation

- Renderer port with typed success/failure results.
- Immutable page profiles and render options.
- Concrete PDF backend with multipage layout, headers, footers, page numbers, metrics, and structured tables.
- Artifact provenance, byte length, SHA-256 digest, and defensive byte copies.
- Template/document type, locale, capability, and orientation validation before rendering.
- Complex RTL scripts are explicitly rejected until the Arabic shaping milestone; this renderer does not claim Arabic PDF support.

## M3 — Reusable visual components

- Styled multipage tables with repeated headers, compact density, optional alternating rows, border control, and validated relative column weights.
- Metric grids composed only from supplied values; no totals or aggregates are calculated by the engine.
- Native vector bar, line, pie, and donut charts generated from caller-supplied series and categories.
- Chart inputs are bounded (up to eight series, 24 Cartesian points per series, and twelve pie/donut slices) and validated before rendering.
- Chart source labels and optional exact display values are retained in a companion data table; numeric chart coordinates are presentation-only.
- Optional standalone cover page, cover metadata, and first-content-page-specific headers/footers.
- Cover pages are included in the configured maximum page budget.

## Deliberate non-goals

- No Arabic shaping provider selection or RTL PDF output.
- No printing/preview widgets or platform output adapters.
- No Flutter widgets, GetX, routing, or application-specific models.
- No Laravel client, API endpoint, authorization policy, or persistence adapter.
- No financial arithmetic, totals, currency conversion, or data aggregation.
- No implicit clock, document numbering, template-version upgrade, or default selection.
- No reliance on Syncfusion/Flutter UI widget capture for vector PDF charts.

## Usage

```dart
import 'package:document_engine/document_engine.dart';

final documentType = DocumentTypeId('sales.invoice');
final templateId = TemplateId('sales.invoice.standard');

final definition = DocumentTemplateDefinition(
  id: templateId,
  version: TemplateVersion(major: 1, minor: 0, patch: 0),
  documentTypeId: documentType,
  displayName: 'Standard invoice',
  supportedLocaleTags: const ['en'],
  capabilities: TemplateCapabilities({
    TemplateCapability.tables,
    TemplateCapability.metrics,
    TemplateCapability.charts,
    TemplateCapability.coverPage,
    TemplateCapability.pageNumbering,
    TemplateCapability.portraitPage,
  }),
);

final registry = TemplateRegistry()..register(definition);
```

Decimal business values remain canonical base-10 strings. The chart model accepts numeric coordinates only for plotting and retains optional exact display strings separately. The engine does not calculate or aggregate source values.

## Verification

From the repository root:

```sh
flutter pub get
dart analyze packages/document_engine
flutter test packages/document_engine/test
```


## M5 — Report definitions and configuration contracts

- `ReportDefinitionRegistry` registers immutable schema versions and requires exact ID/version lookup; it never falls back to latest.
- Application-supplied `ReportDefinition` schemas declare the only available
  filters, output columns, metric slots, chart availability, templates,
  locales, page profiles, execution policy, and optional client row bound.
- `ReportCriteria` stores typed filter values only. It validates against the
  report's allowlist; it does not hold result rows or execute queries.
- `ReportPresentationOptions` stores visible columns, sort order, grouping,
  template, locale, page profile, and optional metrics/charts toggles. Each
  selection is validated against the same definition.
- `SavedReportPreset` serializes criteria and presentation with independent
  preset-schema and report-schema versions. Unsupported versions or changed
  definitions require explicit review; fields are never silently dropped.
- `document_engine_flutter.dart` exposes a controlled responsive
  `ReportConfigurationStudio`. The host owns state, localization, navigation,
  API calls, execution, and persistence; no GetX or backend dependency is used.
- A client-capable report must declare its own bounded row limit. Large reports
  can be marked server-only. Laravel remains the authorization and query
  authority, and the engine never calculates or aggregates report values.


## M8 — QR, watermark, signature, and receipt finishing primitives

- `DocumentQrCode` renders an opaque, bounded payload supplied by the host.
  It does not encrypt, sign, or verify the payload.
- `DocumentWatermark` is a constrained visual overlay for draft/copy/
  confidential/cancelled presentation. It never changes authoritative status.
- `DocumentSignatureArea` supports supplied signer identity, role, approval
  reference/time, and an optional bounded visual signature image. A visual
  mark or printed approval reference is not a cryptographic signature.
- Fixed-height 58 mm and 80 mm receipt PDF profiles are available. They define
  PDF page geometry only and are not ESC/POS or thermal-printer drivers.
- Template capabilities are enforced for QR, watermark, and signature areas.
  RTL text in captions/labels/watermarks continues to fail closed until a
  production shaping provider is separately approved.


## Production-readiness repair additions (2026-11-11)

- Cartesian chart validation now enforces the documented 24-point maximum per series; regression coverage asserts the 24/25 boundary.
- DocumentImage is a bounded, defensive-copy image node for host-supplied PNG/JPEG assets. Image use requires the template images capability; URLs are never fetched.
- DocumentBranding accepts host-provided organization identity, semantic colors, logo bytes, and bounded TrueType/OpenType font assets. The PDF renderer applies supplied base/bold fonts and organization identity; it never reads application assets or downloads fonts.
- DocumentTemplateLayout selects distinct PDF composition modes: standard, executive, compact, and receipt. This changes actual composition, not just metadata.
- ReportConfigurationStudio accepts an actionBuilder so the host can render Preview/Save actions with its own design-system buttons. The package remains independent from NetSales widgets and GetX.

These additions do not resolve Arabic shaping. Complex RTL still fails closed. The host action builder currently covers primary action buttons; several schema controls still use generic Flutter Material widgets and need a deliberate host-control injection strategy before strict NetSales design-system adoption.
 

- `ReportConfigurationStudio` now exposes host builders for the entire filter section and presentation section, in addition to action buttons. NetSales can replace all package-default Material controls with its own design-system fields, selectors, toggles, and buttons while the package remains UI-framework-independent from the host app's GetX architecture.
