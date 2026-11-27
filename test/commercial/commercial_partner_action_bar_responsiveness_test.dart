import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_partner_action_bar.dart';

void main() {
  for (final width in [320.0, 360.0, 375.0, 430.0]) {
    testWidgets('Network partner actions fit ${width.toInt()}dp', (tester) async {
      tester.view.physicalSize = Size(width * 2, 812 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            theme: AppThemes.light,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CommercialPartnerActionBar(
                      isNetworkView: true,
                      isActive: true,
                      onViewDetails: () {},
                      onToggleStatus: () {},
                      onDelete: () {},
                      onMoreActions: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('ملف نقطة البيع'), findsOneWidget);
      expect(find.byTooltip('تجميد الارتباط التجاري'), findsOneWidget);
    });
  }

  testWidgets('POS partner action bar fits narrow dark surface', (tester) async {
    tester.view.physicalSize = const Size(320 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          theme: AppThemes.dark,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CommercialPartnerActionBar(
                    isNetworkView: false,
                    isActive: true,
                    onViewDetails: () {},
                    onMoreActions: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('ملف المزود'), findsOneWidget);
  });
}
