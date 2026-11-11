import 'report_definition.dart';
import 'report_id.dart';

/// In-memory registry of exact immutable report schema versions.
///
/// The host supplies definitions. The registry never substitutes a latest
/// schema when an exact version is absent.
final class ReportDefinitionRegistry {
  final Map<ReportId, Map<int, ReportDefinition>> _definitions = {};

  void register(ReportDefinition definition) {
    final versions = _definitions.putIfAbsent(
      definition.id,
      () => <int, ReportDefinition>{},
    );
    if (versions.containsKey(definition.schemaVersion)) {
      throw StateError(
        'Report ${definition.id} schema v${definition.schemaVersion} '
        'is already registered.',
      );
    }
    versions[definition.schemaVersion] = definition;
  }

  ReportDefinition? find({required ReportId id, required int schemaVersion}) =>
      _definitions[id]?[schemaVersion];

  ReportDefinition require({required ReportId id, required int schemaVersion}) {
    final definition = find(id: id, schemaVersion: schemaVersion);
    if (definition == null) {
      throw StateError('Report $id schema v$schemaVersion is not registered.');
    }
    return definition;
  }

  List<ReportDefinition> versionsOf(ReportId id) {
    final versions = _definitions[id];
    if (versions == null) return const <ReportDefinition>[];
    final result = versions.values.toList()
      ..sort((a, b) => a.schemaVersion.compareTo(b.schemaVersion));
    return List<ReportDefinition>.unmodifiable(result);
  }

  List<ReportDefinition> get definitions {
    final result =
        _definitions.values.expand((versions) => versions.values).toList()
          ..sort((a, b) {
            final idOrder = a.id.compareTo(b.id);
            return idOrder != 0
                ? idOrder
                : a.schemaVersion.compareTo(b.schemaVersion);
          });
    return List<ReportDefinition>.unmodifiable(result);
  }
}
