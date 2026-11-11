/// Immutable numeric semantic version for a registered template.
///
/// Template versions are exact references. The engine never silently resolves
/// an unspecified version to the latest registered version.
final class TemplateVersion implements Comparable<TemplateVersion> {
  TemplateVersion({
    required this.major,
    required this.minor,
    required this.patch,
  }) {
    if (major < 0) {
      throw ArgumentError.value(major, 'major', 'Must be zero or greater.');
    }
    if (minor < 0) {
      throw ArgumentError.value(minor, 'minor', 'Must be zero or greater.');
    }
    if (patch < 0) {
      throw ArgumentError.value(patch, 'patch', 'Must be zero or greater.');
    }
  }

  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(TemplateVersion other) {
    final majorOrder = major.compareTo(other.major);
    if (majorOrder != 0) return majorOrder;

    final minorOrder = minor.compareTo(other.minor);
    if (minorOrder != 0) return minorOrder;

    return patch.compareTo(other.patch);
  }

  @override
  bool operator ==(Object other) =>
      other is TemplateVersion &&
      other.major == major &&
      other.minor == minor &&
      other.patch == patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}
