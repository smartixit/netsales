import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Workspace architecture guardrails', () {
    test('domain source remains independent from Flutter and presentation', () {
      final domainDirectory = Directory('lib/features/workspace/domain');
      expect(domainDirectory.existsSync(), isTrue);

      final violations = <String>[];
      for (final entity in domainDirectory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        final forbiddenImports = RegExp(
          r'''import\s+['"](?:package:flutter/|dart:ui|package:netsales/(?:widgets|features/.*/presentation)/)''',
        );
        final forbiddenUiTypes = RegExp(
          r'\b(?:BuildContext|Color|IconData|VoidCallback|Widget)\b',
        );
        if (forbiddenImports.hasMatch(source) ||
            forbiddenUiTypes.hasMatch(source)) {
          violations.add(entity.path);
        }
      }

      expect(violations, isEmpty, reason: 'Domain must not depend on UI frameworks or presentation code.');
    });

    test('workspace screens do not own navigation or application use cases', () {
      final directory = Directory('lib/features/workspace/presentation/screens');
      expect(directory.existsSync(), isTrue);

      final violations = <String>[];
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (source.contains('Get.toNamed') ||
            source.contains('UseCase(') ||
            source.contains('.execute(')) {
          violations.add(entity.path);
        }
      }

      expect(violations, isEmpty, reason: 'Screens should compose presentation and delegate actions.');
    });

    test('workspace widgets do not perform route navigation or invoke use cases', () {
      final directory = Directory('lib/features/workspace/presentation/widgets');
      expect(directory.existsSync(), isTrue);

      final violations = <String>[];
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (source.contains('Get.toNamed') ||
            source.contains('UseCase(') ||
            source.contains('.execute(') ||
            source.contains('AmountFormatter.') ||
            source.contains('TextFormatter.') ||
            RegExp(
              r'''import\\s+['"]package:netsales/features/.*/domain/entities/''',
            ).hasMatch(source)) {
          violations.add(entity.path);
        }
      }

      expect(violations, isEmpty, reason: 'Widgets must not navigate, execute use cases, or map business data.');
    });

    test('workspace controllers do not depend on presentation widgets', () {
      final directory = Directory('lib/features/workspace/presentation/controllers');
      expect(directory.existsSync(), isTrue);

      final violations = <String>[];
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (RegExp(
          r'''import\s+['"]package:netsales/features/.*/presentation/widgets/''',
        ).hasMatch(source)) {
          violations.add(entity.path);
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Controllers coordinate presentation state and must not own or import widget flows.',
      );
    });

    test('workspace screens remain composition-only', () {
      final directory = Directory('lib/features/workspace/presentation/screens');
      final forbiddenImports = RegExp(
        r'''import\s+['"](?:package:netsales/core/services/|package:netsales/features/.*/domain/usecases/)''',
      );
      final forbiddenCalls = RegExp(
        r'\b(?:Get\.(?:to|toNamed|offAll|offAllNamed|back)|\.execute\()',
      );
      final violations = <String>[];

      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (forbiddenImports.hasMatch(source) ||
            forbiddenCalls.hasMatch(source)) {
          violations.add(entity.path);
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Screens compose widgets; navigation and session actions belong to controllers.',
      );
    });

    test('workspace widgets use project button components instead of raw Material buttons', () {
      final directory = Directory('lib/features/workspace/presentation/widgets');
      final forbidden = RegExp(
        r'\b(?:TextButton|ElevatedButton|OutlinedButton|IconButton|FloatingActionButton)\s*\(',
      );
      final violations = <String>[];

      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (forbidden.hasMatch(entity.readAsStringSync())) {
          violations.add(entity.path);
        }
      }

      expect(violations, isEmpty, reason: 'Use the shared components from lib/widgets.');
    });
  });
}
