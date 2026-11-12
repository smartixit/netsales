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
- Complex RTL is rendered only when a licensed shaping provider is explicitly injected; requests without one remain fail-closed. Renderer-wide shaping is integrated, while extraction and cross-platform output acceptance remain final-stage validation.

## M3 — Reusable visual components

- Styled multipage tables with repeated headers, compact density, optional alternating rows, border control, and validated relative column weights.
- Metric grids composed only from supplied values; no totals or aggregates are calculated by the engine.
- Native vector bar, line, pie, and donut charts generated from caller-supplied series and categories.
- Chart inputs are bounded (up to eight series, 24 Cartesian points per series, and twelve pie/donut slices) and validated before rendering.
- Chart source labels and optional exact display values are retained in a companion data table; numeric chart coordinates are presentation-only.
- Optional standalone cover page, cover metadata, and first-content-page-specific headers/footers.
- Cover pages are included in the configured maximum page budget.

## Bounded input contracts

Document snapshots accept at most 250 sections and 20,000 content nodes.
Each section accepts at most 20,000 nodes; tables accept at most 100 columns
and 10,000 rows. Binary image and visual-signature payloads are capped before
their defensive copies are allocated. Charts and semantic collections are
bounded by their typed contracts. Collection limits are enforced while
copying lazy iterables. Large result sets belong in server-side report jobs
and protected artifact delivery.

## Deliberate non-goals

- No implicit font-family or tenant-brand selection; the host supplies licensed font faces and resolved identity assets.
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
- `DocumentWatermark` is an image-only visual overlay. The host supplies bounded PNG/JPEG bytes, selecting the active Network logo, POS logo, or bundled application icon fallback. The engine does not select tenants, fetch URLs, or load host assets. Opacity, angle, and relative image bounds are configurable; the watermark never changes authoritative status.
- `DocumentSignatureArea` supports supplied signer identity, role, approval
  reference/time, and an optional bounded visual signature image. A visual
  mark or printed approval reference is not a cryptographic signature.
- Fixed-height 58 mm and 80 mm receipt PDF profiles are available. They define
  PDF page geometry only and are not ESC/POS or thermal-printer drivers.
- Template capabilities are enforced for QR, watermark, and signature areas.
  Watermarks do not accept text. Arabic shaping applies to text-bearing document
  content, not watermark branding.


## Production-readiness repair additions (2026-11-11)

- Cartesian chart validation now enforces the documented 24-point maximum per series; regression coverage asserts the 24/25 boundary.
- DocumentImage is a bounded, defensive-copy image node for host-supplied PNG/JPEG assets. Image use requires the template images capability; URLs are never fetched.
- DocumentBranding accepts host-provided organization identity, semantic colors, logo bytes, and bounded TrueType/OpenType font assets. The PDF renderer applies supplied base/bold fonts and organization identity; it never reads application assets or downloads fonts.
- DocumentTemplateLayout selects distinct PDF composition modes: standard, executive, compact, and receipt. This changes actual composition, not just metadata.
- ReportConfigurationStudio accepts an actionBuilder so the host can render Preview/Save actions with its own design-system buttons. The package remains independent from NetSales widgets and GetX.

These additions do not resolve Arabic shaping. Complex RTL still fails closed. The host action builder currently covers primary action buttons; several schema controls still use generic Flutter Material widgets and need a deliberate host-control injection strategy before strict NetSales design-system adoption.
 

- `ReportConfigurationStudio` now exposes host builders for the entire filter section and presentation section, in addition to action buttons. NetSales can replace all package-default Material controls with its own design-system fields, selectors, toggles, and buttons while the package remains UI-framework-independent from the host app's GetX architecture.


## Semantic composition primitives

The generic node model includes reusable, domain-neutral building blocks for
business documents:

- `DocumentInfoGrid` groups supplied party, account, reference, and date values.
- `DocumentStatusBanner` gives a transaction or document an explicit visual state.
- `DocumentFinancialSummary` displays supplied financial lines with total and
  outstanding emphasis. It never derives or recalculates an amount.
- `DocumentCallout` highlights explanatory or policy text.
- `DocumentDivider` provides controlled visual separation.
- `DocumentPageProfile.a5Portrait` and `a5Landscape` support compact
  business vouchers and receipts.

These primitives are deliberately generic. A host application composes them
into distinct invoice, repayment, expense, statement, and report templates.
Business labels, source values, currency rules, permissions, and financial
calculations remain owned by the host API and domain layer. The renderer only
lays out the supplied content.

The generic PDF renderer requires an explicitly injected, validated shaping
provider for complex RTL text. Without that provider it fails closed; with the
provider, renderer-owned text nodes are routed through the shared shaping gateway.


## Arabic shaping provider — integration foundation

The package pins `payv: 0.1.2` as the selected pure-Dart OpenType shaping
provider. It supplies UAX #9 bidirectional resolution (including isolates and
paired brackets), script itemization, Arabic joining and GSUB/GPOS shaping,
glyph advances/offsets, and TrueType glyph outlines. It has no FFI, native
platform channel, or runtime dependency, and its package supports Dart VM and
JavaScript compilation.

The internal `PayvTextShapingProvider` converts one logical line into visual
bidi/script runs and shaped glyph programs. `ShapedPdfTextLine` paints those
glyph outlines as vector paths inside the existing `pdf` widget tree. The
provider refuses fonts whose embedding/subsetting flags disallow PDF use and
rejects CFF/CFF2 outlines rather than silently drawing missing glyphs.

The package bundles IBM Plex Sans Arabic Regular with its SIL Open Font
License 1.1 text. Flutter hosts can load this face through
`loadDocumentEngineArabicFont()`. Hosts that already own a complete font family
can load multiple licensed faces through `loadDocumentEngineFontFaces()`,
providing asset paths for Regular, Medium, SemiBold, and Bold. The returned
faces map to `DocumentFontWeight` and `DocumentFontRole`; optional missing
weights fall back to the nearest supplied face in `PayvTextShapingProvider`.
The engine does not copy or silently substitute unrelated font assets.

### Current integration boundary

The Payv shaper and measured paragraph layout are wired into the central
`PdfDocumentRenderer` text gateway. Renderer-owned Arabic and mixed-direction
text (metadata, headers/footers, paragraphs, headings, table headers/cells,
metrics, chart labels, signatures, QR captions, callouts, and cover fields)
uses the same injected shaping provider. The renderer still fails closed when
a host does not provide a compatible, embeddable TrueType face.

The shaped-line widget currently requires a fixed single-line box and rejects
overflow; it does not yet perform paragraph line breaking, cross-page flow,
repeated table-cell layout, or extraction/accessibility text tagging. Do not
remove the renderer guard or use this widget for official financial documents
until those remaining integrations are completed and the final cross-platform
verification stage passes.


### Measured paragraph flow and PDF path emission

- `ShapedPdfParagraph` now measures candidate lines using Payv's actual shaped advances, wraps at whitespace, preserves paragraph direction across all generated lines, and delegates page continuation to the PDF package's spanning `Column` layout.
- Unspaced long identifiers use a conservative grapheme-boundary fallback; a single unbreakable grapheme wider than the box fails rather than being clipped.
- `ShapedPdfTextLine` now emits Payv's cubic glyph-outline commands directly through `PdfGraphics`. It no longer passes Payv's PDF path-content string to the PDF package's SVG-path parser; those are different path syntaxes.
- These are reusable primitives. They are not yet wired into every `PdfDocumentRenderer` node or the table cell/header/footer/chart/cover paths. The renderer-wide RTL guard therefore remains enabled.
- Vector outlines alone do not provide searchable/selectable Unicode text or a ToUnicode map. Extraction/accessibility remains a production blocker.


### RTL and mixed-direction PDF rendering integration

- `PdfDocumentRenderer` accepts an explicitly injected `PayvTextShapingProvider`. The host loads a licensed TrueType font and creates the provider; the core renderer does not reach into Flutter's asset bundle.
- All renderer-owned text nodes now pass through one text gateway. Arabic/Hebrew-range strings in document title/subtitle, sections, paragraphs, headings, metrics, info grids, financial summaries, callouts, table headers/cells, chart labels/legends, image and QR captions, signature labels, branding, cover fields, and running headers/footers use the shaped paragraph path.
- Explicit RTL direction on paragraph, heading, and info-grid/table-cell nodes is preserved even when a value contains only Latin identifiers.
- Each paragraph resolves UAX #9 base direction once before wrapping. The same resolved direction is used for all wrapped lines; whitespace is preserved between words and long unspaced values split only at Unicode grapheme boundaries.
- Visible glyph outlines are paired with an invisible logical Unicode text layer using the same licensed font. This retains the original logical codepoint sequence in the PDF text stream for search/copy/extraction while the visible glyphs use Payv's GSUB/GPOS shaping and visual bidi order.
- The PDF Unicode font object is cached per shaping-provider instance, not reparsed for every line.
- Watermarks are image-only and use the host-supplied Network/POS logo or application icon fallback; they do not pass through the text shaping gateway.
- The default renderer remains fail-closed for RTL when no provider is injected. Hosts must load `loadDocumentEngineArabicFont()` or supply another appropriately licensed TrueType font and inject the provider.
- The package bundles IBM Plex Sans Arabic Regular; hosts may inject their licensed Regular, Medium, SemiBold, and Bold faces. Each requested weight selects its own Payv shaper, glyph outlines, advances, and matching invisible Unicode font face. Semantic renderer styles select Regular, Medium, SemiBold, or Bold rather than simulating weight by stroke expansion. Full extraction/search validation, complex font coverage/fallback, visual baselines, and Windows/Android/iOS output verification remain final-stage validation work. Tests have been authored but not run by instruction.

- Page watermarks are image-only, with the active Network/POS logo selected by the host and the bundled application icon used as fallback. The engine accepts defensive-copied PNG/JPEG bytes only, enforces a 2 MiB limit, and renders through the PDF package's fitted/rotated watermark decoration with configurable opacity.
- Running headers and footers, including first-page overrides, route through the shared shaping gateway. Table cells pass explicit cell direction where provided; table headers and chart-table labels use automatic first-strong direction detection.
- Each shaped line writes visible glyph outlines and a second invisible logical-order text run using the same embedded Unicode font. The text run uses LTR source order intentionally, with the font's ToUnicode map, so PDF extraction/search/copy can recover the original logical Unicode rather than visual bidi run order.
- A renderer test now inspects the generated PDF for a ToUnicode map and decodes Flate page streams to assert the invisible PDF text rendering mode. This is a structural regression test; it must still be executed in the final validation stage and supplemented by pdftotext/viewer extraction checks on Windows, Android and iOS.
