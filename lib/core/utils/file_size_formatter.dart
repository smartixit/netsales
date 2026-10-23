/// ============================================================================
/// FileSizeFormatter — Centralized file/cache size formatting (project-agnostic)
/// ============================================================================
class FileSizeFormatter {
  const FileSizeFormatter._();

  static String format(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(mb < 10 ? 2 : 1)} MB';
    }
    final gb = bytes / (1024 * 1024 * 1024);
    return '${gb.toStringAsFixed(2)} GB';
  }
}
