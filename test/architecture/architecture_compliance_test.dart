import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetSales Architecture Compliance Invariants (Universal Features Audit)', () {
    final featuresDir = Directory('lib/features');

    test('lib/features directory must exist', () {
      expect(featuresDir.existsSync(), isTrue);
    });

    final featureSubDirs = featuresDir
        .listSync()
        .whereType<Directory>()
        .toList(growable: false);

    test('Zero StatefulWidget or setState in ALL lib/features/', () {
      final violations = <String>[];

      for (final featureDir in featureSubDirs) {
        final dartFiles = featureDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          if (content.contains('extends StatefulWidget') ||
              content.contains('State<') ||
              content.contains('setState(')) {
            violations.add(file.path);
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'StatefulWidget and setState are strictly prohibited in feature code. '
            'Violations found in: $violations',
      );
    });

    test('Zero ApiService or direct HTTP primitives in presentation layers across all features', () {
      final violations = <String>[];

      for (final featureDir in featureSubDirs) {
        final presentationDir = Directory('${featureDir.path}/presentation');
        if (!presentationDir.existsSync()) continue;

        final dartFiles = presentationDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          if (content.contains('ApiService') ||
              content.contains('package:http/') ||
              content.contains('package:dio/')) {
            violations.add(file.path);
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Controllers and presentation components must delegate to Use Cases and never import ApiService directly. '
            'Violations found in: $violations',
      );
    });

    test('Dependency Rule: Domain layers across all features must be pure and independent', () {
      final violations = <String>[];

      for (final featureDir in featureSubDirs) {
        final domainDir = Directory('${featureDir.path}/domain');
        if (!domainDir.existsSync()) continue;

        final dartFiles = domainDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          if (content.contains('/data/') ||
              content.contains('/presentation/') ||
              content.contains('package:get/get.dart') ||
              content.contains('package:flutter/material.dart')) {
            violations.add(file.path);
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Domain layer must be completely pure and independent of Data, Presentation, Flutter UI, and GetX. '
            'Violations found in: $violations',
      );
    });

    test('Component Placement Rule: presentation/screens/ across features must contain only *_screen.dart', () {
      final violations = <String>[];

      for (final featureDir in featureSubDirs) {
        final screensDir = Directory('${featureDir.path}/presentation/screens');
        if (!screensDir.existsSync()) continue;

        final nonScreenFiles = screensDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .where((f) => !f.path.endsWith('_screen.dart'))
            .map((f) => f.path)
            .toList();

        violations.addAll(nonScreenFiles);
      }

      expect(
        violations,
        isEmpty,
        reason:
            'presentation/screens/ must contain only page-level screen files ending in _screen.dart. '
            'Dialogs, bottom sheets, cards, and sections must be in presentation/widgets/. '
            'Violations found: $violations',
      );
    });

    test('Zero raw Switch or Switch.adaptive in lib/ (must use CustomSwitch)', () {
      final libDir = Directory('lib');
      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.endsWith('custom_switch.dart'));

      final violations = <String>[];

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        if (content.contains('Switch.adaptive(') ||
            RegExp(r'\bSwitch\(').hasMatch(content)) {
          violations.add(file.path);
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'All switch controls must use CustomSwitch from lib/widgets/inputs/custom_switch.dart. '
            'Violations found in: $violations',
      );
    });

    test('Zero client-side filteredLinks getter in CommercialDirectoryController', () {
      final controllerFile = File(
        'lib/features/commercial/presentation/controllers/commercial_directory_controller.dart',
      );
      expect(controllerFile.existsSync(), isTrue);

      final content = controllerFile.readAsStringSync();
      expect(
        content.contains('get filteredLinks'),
        isFalse,
        reason: 'CommercialDirectoryController must use server-side search and cursor pagination, not in-memory filteredLinks getter.',
      );
    });
  });
}
