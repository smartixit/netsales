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

    test('Zero client-side filteredLinks getter in Commercial directory controllers', () {
      const controllerPaths = [
        'lib/features/commercial/presentation/controllers/network_pos_directory_controller.dart',
        'lib/features/commercial/presentation/controllers/pos_linked_networks_controller.dart',
      ];

      for (final path in controllerPaths) {
        final controllerFile = File(path);
        expect(controllerFile.existsSync(), isTrue, reason: 'Missing Commercial controller: $path');

        final content = controllerFile.readAsStringSync();
        expect(
          content.contains('get filteredLinks'),
          isFalse,
          reason: '$path must use server-side search and cursor pagination, not an in-memory filteredLinks getter.',
        );
      }
    });

    test('Public settings GetX lifecycle loads cache without starting a request', () {
      final serviceFile = File(
        'lib/core/services/public_settings_service.dart',
      );
      expect(serviceFile.existsSync(), isTrue);

      final content = serviceFile.readAsStringSync();
      final onInit = RegExp(
        r'void onInit\(\)\s*\{([\s\S]*?)\n  \}',
      ).firstMatch(content);

      expect(onInit, isNotNull);
      expect(onInit!.group(1), contains('_loadFromLocalCache();'));
      expect(onInit.group(1), isNot(contains('fetchSettings')));
    });

    test('Splash refreshes public settings only after connectivity initialization', () {
      final splashFile = File(
        'lib/features/splash/data/datasources/splash_local_data_source_impl.dart',
      );
      expect(splashFile.existsSync(), isTrue);

      final content = splashFile.readAsStringSync();
      final parallelInitialization = RegExp(
        r'await Future\.wait\(\s*\[([\s\S]*?)\]\s*\);',
      ).firstMatch(content);

      expect(parallelInitialization, isNotNull);
      expect(
        parallelInitialization!.group(1),
        isNot(contains('InternetConnectionService')),
      );
      expect(
        parallelInitialization.group(1),
        isNot(contains('PublicSettingsService')),
      );

      final connectivityInitialization = content.indexOf(
        'await InternetConnectionService.instance.initialize();',
      );
      final connectivityGuard = content.indexOf(
        'if (InternetConnectionService.instance.isConnected)',
      );
      final settingsRefresh = content.indexOf(
        'PublicSettingsService.instance.fetchSettings()',
      );

      expect(connectivityInitialization, greaterThanOrEqualTo(0));
      expect(connectivityGuard, greaterThan(connectivityInitialization));
      expect(settingsRefresh, greaterThan(connectivityGuard));
    });

    test('Bootstrap restores the device before the local session and connectivity before optional network services', () {
      final file = File('lib/features/splash/data/datasources/splash_local_data_source_impl.dart');
      final content = file.readAsStringSync();
      final deviceInit = content.indexOf('DeviceService.instance.init()');
      final sessionInit = content.indexOf('SessionService.instance.init()');
      final workspaceInit = content.indexOf('WorkspaceService.instance.init()');
      final connectivityInit = content.indexOf('InternetConnectionService.instance.initialize()');
      final pushInit = content.indexOf('PushNotificationService.instance.init()');

      expect(deviceInit, greaterThanOrEqualTo(0));
      expect(sessionInit, greaterThan(deviceInit));
      expect(workspaceInit, greaterThan(sessionInit));
      expect(connectivityInit, greaterThan(workspaceInit));
      expect(pushInit, greaterThan(connectivityInit));
      expect(content, isNot(contains('ServerTaskRunnerService.to.runCatchupTasks')));
      expect(content, isNot(contains('ServerTaskRunnerService.to.startForegroundHeartbeat')));
    });

    test('Session verification preserves the distinction between 401, 403, and temporary failures', () {
      final file = File('lib/features/splash/data/datasources/splash_local_data_source_impl.dart');
      final content = file.readAsStringSync();
      final validationStart = content.indexOf('Future<SessionValidationResult> validateSessionWithServer()');
      final validation = content.substring(validationStart);

      expect(validation, contains('response.statusCode == 401'));
      expect(validation, contains('response.statusCode == 403'));
      expect(validation, contains('SessionValidationResult.unavailable'));
      expect(validation, contains('SessionService.to.terminateSession()'));
      expect(validation, isNot(contains('if (!response.success)')));
    });

    test('Protected routes require a server-verified session', () {
      final authGuard = File('lib/core/routing/middlewares/auth_guard.dart').readAsStringSync();
      final workspaceGuard = File('lib/core/routing/middlewares/workspace_guard.dart').readAsStringSync();
      expect(authGuard, contains('!SessionService.to.isSessionVerified'));
      expect(workspaceGuard, contains('!SessionService.to.isSessionVerified'));
    });

    test('Restored sessions do not synchronize FCM until server verification', () {
      final session = File('lib/core/services/session_service.dart').readAsStringSync();
      final initStart = session.indexOf('Future<SessionService> init()');
      final startSession = session.indexOf('Future<void> startSession');
      final initBody = session.substring(initStart, startSession);
      expect(initBody, isNot(contains('syncTokenWithBackend')));
      expect(session, contains('bool get isSessionVerified'));
      expect(session, contains('void markSessionVerified()'));
    });

  });
}
