import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/membership/presentation/widgets/membership_card_action_bar.dart';

void main() {
  Widget harness({required double width, required ThemeData Function() themeBuilder}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp(
        theme: themeBuilder(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: MembershipCardActionBar(
                  isNetworkView: true,
                  isActive: true,
                  isOwner: false,
                  onDetails: () {},
                  onChangeRole: () {},
                  onToggleStatus: () {},
                  onRemove: () {},
                  onMoreActions: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  for (final width in [320.0, 360.0, 375.0, 430.0]) {
    testWidgets('Network action bar fits ${width.toInt()}dp viewport', (tester) async {
      tester.view.physicalSize = Size(width * 2, 812 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(harness(width: width, themeBuilder: () => ThemeData.light()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('تغيير الدور'), findsOneWidget);
      expect(find.byTooltip('تجميد العضوية'), findsOneWidget);
      expect(find.byTooltip('إزالة العضو'), findsOneWidget);
    });
  }

  testWidgets('POS action bar remains valid in dark theme', (tester) async {
    tester.view.physicalSize = const Size(320 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: MembershipCardActionBar(
                    isNetworkView: false,
                    isActive: false,
                    isOwner: false,
                    onDetails: () {},
                    onChangeRole: () {},
                    onToggleStatus: () {},
                    onRemove: () {},
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
    expect(find.text('تعديل الدور'), findsOneWidget);
    expect(find.byTooltip('تنشيط الحساب'), findsOneWidget);
  });
}
