import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('commercial directory controllers expose data and actions, not widget factories', () {
    final paths = [
      'lib/features/commercial/presentation/controllers/base_commercial_directory_controller.dart',
      'lib/features/commercial/presentation/controllers/network_commercial_directory_controller.dart',
      'lib/features/commercial/presentation/controllers/pos_commercial_directory_controller.dart',
    ];
    final violations = <String>[];

    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (RegExp(r'\bBuildContext\b|\bWidget\??\s+(?:get|build)').hasMatch(source) ||
          source.contains('CustomKpiCardData') ||
          source.contains('buildKpiCards') ||
          source.contains('buildCardActions') ||
          source.contains('buildExtraFilters')) {
        violations.add(path);
      }
    }

    expect(violations, isEmpty, reason: 'Commercial controllers must not construct or return presentation widgets.');
  });

  test('commercial uses one shared action bar for Network and POS', () {
    expect(
      File('lib/features/commercial/presentation/widgets/commercial_partner_action_bar.dart').existsSync(),
      isTrue,
    );
    expect(
      File('lib/features/commercial/presentation/widgets/commercial_partner_card_network_actions.dart').existsSync(),
      isFalse,
    );
    expect(
      File('lib/features/commercial/presentation/widgets/commercial_partner_card_pos_actions.dart').existsSync(),
      isFalse,
    );
  });

  test('commercial widgets do not use raw Material action buttons', () {
    final directory = Directory('lib/features/commercial/presentation/widgets');
    final forbidden = RegExp(
      r'\b(?:TextButton|ElevatedButton|OutlinedButton|IconButton|FloatingActionButton)\s*\(',
    );
    final violations = <String>[];

    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (forbidden.hasMatch(entity.readAsStringSync())) violations.add(entity.path);
    }

    expect(violations, isEmpty, reason: 'Use the shared button components from lib/widgets.');
  });
}
