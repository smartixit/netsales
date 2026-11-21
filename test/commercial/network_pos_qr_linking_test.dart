import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_preview_model.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/network_pos_link_confirm_sheet.dart';

void main() {
  group('Network–POS QR Linking & Challenge Tests', () {
    test('NetworkPosLinkChallengeModel fromJson parses backend response', () {
      final json = {
        'challenge_id': 10,
        'challenge_uuid': '68f5ca2e-5b9a-45c2-aae6-33a40967f3f7',
        'network_id': 15,
        'pos_id': 25,
        'payload': 'NTS_LINK_V1_TEST_TOKEN',
        'status': 'PENDING',
        'status_label': 'قيد الانتظار',
        'expires_at': DateTime.now()
            .add(const Duration(minutes: 30))
            .toIso8601String(),
        'consumed_at': null,
        'network': {
          'network_id': 15,
          'owner_id': 1,
          'network_name': 'شبكة الأمل للاختبار',
          'network_phone_number': '771100000',
        },
        'pos': {
          'pos_id': 25,
          'owner_id': 2,
          'pos_name': 'نقطة السعادة',
          'pos_phone_number': '772200000',
        },
        'created_at': '2026-11-04 16:00:00',
        'updated_at': '2026-11-04 16:00:00',
      };

      final model = NetworkPosLinkChallengeModel.fromJson(json);

      expect(model.challengeId, 10);
      expect(model.challengeUuid, '68f5ca2e-5b9a-45c2-aae6-33a40967f3f7');
      expect(model.networkId, 15);
      expect(model.posId, 25);
      expect(model.payload, 'NTS_LINK_V1_TEST_TOKEN');
      expect(model.status, 'PENDING');
      expect(model.isPending, isTrue);
      expect(model.network?.networkName, 'شبكة الأمل للاختبار');
      expect(model.pos?.posName, 'نقطة السعادة');
    });

    test('NetworkPosLinkPreviewModel fromJson parses network details', () {
      final json = {
        'challenge_uuid': 'test-challenge-uuid',
        'is_targeted': false,
        'network': {
          'network_id': 10,
          'owner_id': 1,
          'network_name': 'شبكة النجوم',
          'network_phone_number': '770000000',
          'network_address': 'شارع الزبيري',
        },
      };

      final preview = NetworkPosLinkPreviewModel.fromJson(json);
      expect(preview.challengeUuid, equals('test-challenge-uuid'));
      expect(preview.network.networkName, equals('شبكة النجوم'));
      expect(preview.network.networkPhoneNumber, equals('770000000'));
      expect(preview.isTargeted, isFalse);
    });

    testWidgets('NetworkPosLinkConfirmSheet renders preview network details',
        (tester) async {
      final preview = NetworkPosLinkPreviewModel.fromJson({
        'challenge_uuid': 'test-challenge-uuid',
        'is_targeted': false,
        'network': {
          'network_id': 10,
          'owner_id': 1,
          'network_name': 'شبكة النجوم',
          'network_phone_number': '770000000',
          'network_address': 'شارع الزبيري',
        },
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            theme: AppThemes.light,
            home: Scaffold(
              body: NetworkPosLinkConfirmSheet(
                preview: preview,
                onConfirm: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('شبكة النجوم'), findsOneWidget);
      expect(find.text('تأكيد وإتمام الارتباط'), findsOneWidget);
    });

    testWidgets('NetworkPosLinkConfirmSheet fits compact mobile widths', (tester) async {
      final preview = NetworkPosLinkPreviewModel.fromJson({
        'challenge_uuid': 'test-challenge-uuid',
        'is_targeted': false,
        'network': {
          'network_id': 10,
          'owner_id': 1,
          'network_name': 'شبكة النجوم',
          'network_phone_number': '770000000',
          'network_address': 'شارع الزبيري',
        },
      });

      for (final width in [320.0, 375.0]) {
        tester.view.physicalSize = Size(width, 812);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, _) => MaterialApp(
              theme: AppThemes.light,
              home: Scaffold(
                body: NetworkPosLinkConfirmSheet(
                  preview: preview,
                  onConfirm: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'width: $width');
        expect(find.text('شبكة النجوم'), findsOneWidget);
      }
    });
  });
}
