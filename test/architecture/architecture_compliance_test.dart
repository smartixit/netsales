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
  });
}
