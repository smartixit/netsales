import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_preview_model.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_link_confirm_sheet.dart';
import 'package:netsales/widgets/qr/custom_qr_scanner_overlay.dart';
import 'package:netsales/widgets/qr/qr_scan_result.dart';

void main() {
  group('Network–POS QR Linking & Scanner Tests', () {
    test('NetworkPosLinkChallengeModel fromJson parses backend response', () {
      final json = {
        'challenge_id': 10,
        'challenge_uuid': '68f5ca2e-5b9a-45c2-aae6-33a40967f3f7',
        'network_id': 15,
        'pos_id': 25,
        'created_by_user_id': 85,
        'payload_token': 'NTS_LINK_V1_TEST_TOKEN',
        'status': 'PENDING',
        'status_label': 'قيد الانتظار',
        'expires_at': '2026-11-04 16:30:00',
        'consumed_at': null,
        'network': {'network_id': 15, 'network_name': 'شبكة الأمل للاختبار'},
        'pos': {'pos_id': 25, 'pos_name': 'نقطة السعادة'},
        'created_at': '2026-11-04 16:00:00',
        'updated_at': '2026-11-04 16:00:00',
      };

      final model = NetworkPosLinkChallengeModel.fromJson(json);

      expect(model.challengeUuid, '68f5ca2e-5b9a-45c2-aae6-33a40967f3f7');
      expect(model.networkId, 15);
      expect(model.networkName, 'شبكة الأمل للاختبار');
      expect(model.posId, 25);
      expect(model.posName, 'نقطة السعادة');
      expect(model.payloadToken, 'NTS_LINK_V1_TEST_TOKEN');
      expect(model.status, LinkingChallengeStatus.pending);
      expect(model.statusLabel, 'قيد الانتظار');
      expect(model.isPending, isTrue);
    });

    test(
      'NetworkPosLinkPreviewModel fromJson parses server preview payload',
      () {
        final json = {
          'challenge_uuid': '68f5ca2e-5b9a-45c2-aae6-33a40967f3f7',
          'network': {
            'network_id': 15,
            'network_name': 'شبكة الأمل المركزية',
            'network_phone_number': '771100000',
            'governorate': 'عدن',
            'directorate': 'كريتر',
            'status': 'ACTIVE',
          },
          'pos': {
            'pos_id': 25,
            'pos_name': 'نقطة السعادة',
            'pos_phone_number': '773300000',
          },
          'already_linked': false,
          'expires_at': '2026-11-04 17:00:00',
        };

        final model = NetworkPosLinkPreviewModel.fromJson(json);

        expect(model.challengeUuid, '68f5ca2e-5b9a-45c2-aae6-33a40967f3f7');
        expect(model.networkId, 15);
        expect(model.networkName, 'شبكة الأمل المركزية');
        expect(model.networkPhone, '771100000');
        expect(model.governorateName, 'عدن');
        expect(model.directorateName, 'كريتر');
        expect(model.posId, 25);
        expect(model.posName, 'نقطة السعادة');
        expect(model.alreadyLinked, isFalse);
      },
    );

    test('QrScanResult values and equality', () {
      final now = DateTime.now();
      final result1 = QrScanResult(
        rawValue: 'NTS_LINK_V1_ABC',
        format: 'qrCode',
        scannedAt: now,
      );
      final result2 = QrScanResult(
        rawValue: 'NTS_LINK_V1_ABC',
        format: 'qrCode',
        scannedAt: now,
      );

      expect(result1.isNotEmpty, isTrue);
      expect(result1.isEmpty, isFalse);
      expect(result1, equals(result2));
    });

    testWidgets('CustomQrScannerOverlay renders without layout exceptions', (
      tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: CustomQrScannerOverlay(
                scanBoxSize: 240,
                cornerColor: Colors.teal,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomQrScannerOverlay), findsOneWidget);
    });

    testWidgets(
      'NetworkPosLinkConfirmSheet displays network info and triggers confirm',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        bool confirmed = false;
        bool cancelled = false;

        final preview = NetworkPosLinkPreviewModel(
          challengeUuid: 'test-uuid-1234',
          networkId: 10,
          networkName: 'شبكة السرعة العالية',
          networkPhone: '770000000',
          governorateName: 'صنعاء',
          directorateName: 'التحرير',
          posId: 5,
          posName: 'نقطة النور',
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
          alreadyLinked: false,
        );

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              home: Scaffold(
                body: NetworkPosLinkConfirmSheet(
                  preview: preview,
                  onConfirm: () => confirmed = true,
                  onCancel: () => cancelled = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('تأكيد الربط مع مزود شبكة'), findsOneWidget);
        expect(find.text('شبكة السرعة العالية'), findsOneWidget);
        expect(find.text('صنعاء - التحرير'), findsOneWidget);

        await tester.ensureVisible(find.text('تأكيد وإتمام الربط'));
        await tester.tap(find.text('تأكيد وإتمام الربط'));
        await tester.pumpAndSettle();

        expect(confirmed, isTrue);
        expect(cancelled, isFalse);
      },
    );
  });
}
