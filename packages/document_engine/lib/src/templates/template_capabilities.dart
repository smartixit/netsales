/// Features a template declares that it can consume or render.
enum TemplateCapability {
  coverPage,
  repeatingHeader,
  repeatingFooter,
  pageNumbering,
  tables,
  metrics,
  charts,
  images,
  qrCodes,
  watermark,
  signatureArea,
  appendices,
  portraitPage,
  landscapePage,
}

/// Immutable set of capabilities declared by a template.
final class TemplateCapabilities {
  TemplateCapabilities(Iterable<TemplateCapability> values)
    : values = Set<TemplateCapability>.unmodifiable(values);

  final Set<TemplateCapability> values;

  bool supports(TemplateCapability capability) => values.contains(capability);

  bool supportsAll(Iterable<TemplateCapability> capabilities) =>
      capabilities.every(supports);

  @override
  bool operator ==(Object other) =>
      other is TemplateCapabilities &&
      values.length == other.values.length &&
      values.containsAll(other.values);

  @override
  int get hashCode => Object.hashAllUnordered(values);
}
