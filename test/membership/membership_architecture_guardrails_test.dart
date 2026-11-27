import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('membership controllers expose state and actions, not widget factories', () {
    final paths = [
      'lib/features/membership/presentation/controllers/base_memberships_controller.dart',
      'lib/features/membership/presentation/controllers/network_memberships_controller.dart',
      'lib/features/membership/presentation/controllers/pos_memberships_controller.dart',
    ];
    final violations = <String>[];

    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (RegExp(r'\bBuildContext\b|\bWidget\??\s+(?:get|build)').hasMatch(source) ||
          source.contains('CustomKpiCardData') ||
          source.contains('buildKpiCards') ||
          source.contains('buildCardActions') ||
          source.contains('buildExtraFilters') ||
          RegExp(r'''import\\s+['\"]package:netsales/features/membership/presentation/widgets/''').hasMatch(source) ||
          source.contains('CustomBottomSheet') ||
          source.contains('CustomSnackbar')) {
        violations.add(path);
      }
    }

    expect(violations, isEmpty, reason: 'Membership controllers must not construct or return presentation widgets.');
  });

  test('membership uses one shared action bar for Network and POS', () {
    expect(
      File('lib/features/membership/presentation/widgets/membership_card_action_bar.dart').existsSync(),
      isTrue,
    );
    expect(
      File('lib/features/membership/presentation/widgets/membership_card_network_actions.dart').existsSync(),
      isFalse,
    );
    expect(
      File('lib/features/membership/presentation/widgets/membership_card_pos_actions.dart').existsSync(),
      isFalse,
    );
  });

  test('membership widgets do not use raw Material action buttons', () {
    final directory = Directory('lib/features/membership/presentation/widgets');
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
