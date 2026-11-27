import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_partner_card.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_partner_card_actions.dart';

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

  group('CommercialPartnerCard Widget Tests (Executive Edition)', () {
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

    testWidgets('Renders partner name, reference, and active status badge', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          CommercialPartnerCard(
            link: link,
            isNetworkView: true,
            onDetails: () {},
            onTap: () {},
            actions: CommercialPartnerCardActions(
              link: link,
              isNetworkView: true,
              onViewDetails: () {},
              onToggleStatus: () {},
              onDelete: () {},
              onMoreActions: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مركز المدينة للاتصالات'), findsOneWidget);
      expect(find.text('POS-2026-SOVEREIGN-999'), findsOneWidget);
      expect(find.text('نشط'), findsWidgets);
      expect(find.text('ملف نقطة البيع'), findsOneWidget);
    });

    testWidgets('Triggers callbacks when details action is tapped', (tester) async {
      bool detailsTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          CommercialPartnerCard(
            link: link,
            isNetworkView: true,
            onDetails: () => detailsTapped = true,
            onTap: () {},
            actions: CommercialPartnerCardActions(
              link: link,
              isNetworkView: true,
              onViewDetails: () => detailsTapped = true,
              onToggleStatus: () {},
              onDelete: () {},
              onMoreActions: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('ملف نقطة البيع'));
      await tester.pumpAndSettle();
      expect(detailsTapped, isTrue);
    });

    testWidgets('Triggers onTap callback when partner card body is tapped directly', (tester) async {
      bool cardBodyTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          CommercialPartnerCard(
            link: link,
            isNetworkView: true,
            onDetails: () {},
            onTap: () => cardBodyTapped = true,
            actions: CommercialPartnerCardActions(
              link: link,
              isNetworkView: true,
              onViewDetails: () {},
              onMoreActions: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('مركز المدينة للاتصالات'));
      await tester.pumpAndSettle();
      expect(cardBodyTapped, isTrue);
    });
  });
}
