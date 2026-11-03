import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetSales Architecture Compliance Invariants', () {
    test('Zero StatefulWidget or setState in lib/features/commercial/', () {
      final commercialDir = Directory('lib/features/commercial');
      expect(
        commercialDir.existsSync(),
        isTrue,
        reason: 'Commercial directory must exist',
      );

      final dartFiles = commercialDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      final violations = <String>[];

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        if (content.contains('extends StatefulWidget') ||
            content.contains('State<') ||
            content.contains('setState(')) {
          violations.add(file.path);
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'StatefulWidget and setState are strictly prohibited in feature presentation code. '
            'Violations found in: $violations',
      );
    });

    test(
      'Zero ApiService or HTTP primitives in lib/features/commercial/presentation/',
      () {
        final presentationDir = Directory(
          'lib/features/commercial/presentation',
        );
        expect(
          presentationDir.existsSync(),
          isTrue,
          reason: 'Presentation directory must exist',
        );

        final dartFiles = presentationDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        final violations = <String>[];

        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          if (content.contains('ApiService') ||
              content.contains('package:http/') ||
              content.contains('package:dio/')) {
            violations.add(file.path);
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Controllers and presentation components must delegate to Use Cases and never import ApiService directly. '
              'Violations found in: $violations',
        );
      },
    );

    test(
      'Dependency Rule: Presentation depends on Domain, Domain depends on nothing external',
      () {
        final domainDir = Directory('lib/features/commercial/domain');
        expect(domainDir.existsSync(), isTrue);

        final dartFiles = domainDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        final violations = <String>[];

        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          if (content.contains('package:netsales/features/commercial/data/') ||
              content.contains(
                'package:netsales/features/commercial/presentation/',
              ) ||
              content.contains('package:get/get.dart') ||
              content.contains('package:flutter/material.dart')) {
            violations.add(file.path);
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Domain layer must be completely pure and independent of Data, Presentation, Flutter UI, and GetX. '
              'Violations found in: $violations',
        );
      },
    );

    test(
      'Component Placement Rule: Screens directory contains only page-level screens (*_screen.dart)',
      () {
        final screensDir = Directory(
          'lib/features/commercial/presentation/screens',
        );
        expect(screensDir.existsSync(), isTrue);

        final nonScreenFiles = screensDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .where((f) => !f.path.endsWith('_screen.dart'))
            .map((f) => f.path)
            .toList();

        expect(
          nonScreenFiles,
          isEmpty,
          reason:
              'presentation/screens/ must contain only page-level screen files ending in _screen.dart. '
              'Dialogs, bottom sheets, cards, and sections must be in presentation/widgets/. '
              'Violations found: $nonScreenFiles',
        );
      },
    );

    test(
      'Component Decomposition Rule: Feature widgets directory exists and screens remain focused page composition',
      () {
        final widgetsDir = Directory(
          'lib/features/commercial/presentation/widgets',
        );
        expect(
          widgetsDir.existsSync(),
          isTrue,
          reason:
              'presentation/widgets/ directory must exist for decomposed components',
        );

        final widgetFiles = widgetsDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .toList();

        expect(
          widgetFiles.length,
          greaterThanOrEqualTo(3),
          reason:
              'Feature presentation components (cards, headers, sheets) must be decomposed into presentation/widgets/',
        );

        // Screens should not be monolithic (each screen file <= 160 lines)
        final screensDir = Directory(
          'lib/features/commercial/presentation/screens',
        );
        final oversizedScreens = <String>[];

        for (final file in screensDir.listSync().whereType<File>().where(
          (f) => f.path.endsWith('.dart'),
        )) {
          final lines = file.readAsLinesSync().length;
          if (lines > 160) {
            oversizedScreens.add('${file.path} ($lines lines)');
          }
        }

        expect(
          oversizedScreens,
          isEmpty,
          reason:
              'Screen files must be focused on page composition and not contain monolithic embedded widget definitions. '
              'Oversized screens: $oversizedScreens',
        );
      },
    );
  });
}
