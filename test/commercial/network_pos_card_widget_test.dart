import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_card/network_pos_card.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        theme: AppThemes.light,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  group('NetworkPosCard Widget Tests', () {
    const link = NetworkPosLinkEntity(
      networkPosId: 1,
      networkId: 10,
      posId: 20,
      status: true,
      createdAt: '2026-01-10T12:00:00Z',
      pos: PosEntity(
        posId: 20,
        ownerId: 5,
        posUuid: 'POS-2026-SOVEREIGN-999',
        posName: 'مركز المدينة للاتصالات',
        posPhoneNumber: '777112233',
        ownerName: 'محمد أحمد',
        posAddress: 'شارع حدة',
        governorateName: 'صنعاء',
      ),
    );

    testWidgets('Renders partner name, raw UUID, and status badge', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          NetworkPosCard(
            link: link,
            onTap: () {},
            onToggleStatus: () {},
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مركز المدينة للاتصالات'), findsOneWidget);
      expect(find.text('POS-2026-SOVEREIGN-999'), findsOneWidget);
      expect(find.text('نشط'), findsOneWidget);
      expect(find.text('التفاصيل'), findsOneWidget);
      expect(find.text('تجميد'), findsOneWidget);
    });

    testWidgets('Triggers callbacks when buttons are tapped', (tester) async {
      bool detailsTapped = false;
      bool toggleTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          NetworkPosCard(
            link: link,
            onTap: () => detailsTapped = true,
            onToggleStatus: () => toggleTapped = true,
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('التفاصيل'));
      await tester.pumpAndSettle();
      expect(detailsTapped, isTrue);

      await tester.tap(find.text('تجميد'));
      await tester.pumpAndSettle();
      expect(toggleTapped, isTrue);
    });
  });
}
