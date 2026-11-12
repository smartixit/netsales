/// Semantic font weights used by the document PDF shaping pipeline.
///
/// Each weight selects a real OpenType face. The renderer never simulates
/// weight by stroking or scaling glyph outlines.
enum DocumentFontWeight {
  regular,
  medium,
  semiBold,
  bold,
}
