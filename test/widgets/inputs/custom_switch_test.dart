import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';
import 'package:netsales/widgets/inputs/custom_switch_list_tile.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(
        home: Scaffold(
          body: Center(child: child),
        ),
      ),
    );
  }

  group('CustomSwitch Widget Tests', () {
    testWidgets('renders CustomSwitch with correct initial value and toggles on tap', (tester) async {
      bool isToggled = false;

      await tester.pumpWidget(
        wrapWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return CustomSwitch(
                value: isToggled,
                onChanged: (val) {
                  setState(() {
                    isToggled = val;
                  });
                },
              );
            },
          ),
        ),
      );

      expect(find.byType(CustomSwitch), findsOneWidget);
      expect(isToggled, isFalse);

      await tester.tap(find.byType(CustomSwitch));
      await tester.pumpAndSettle();

      expect(isToggled, isTrue);
    });

    testWidgets('CustomSwitchListTile renders title, subtitle, and toggles switch', (tester) async {
      bool isToggled = false;

      await tester.pumpWidget(
        wrapWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return CustomSwitchListTile(
                title: 'تفعيل الإشعارات',
                subtitle: 'استلام تنبيهات فورية بالطلبات',
                value: isToggled,
                onChanged: (val) {
                  setState(() {
                    isToggled = val;
                  });
                },
              );
            },
          ),
        ),
      );

      expect(find.text('تفعيل الإشعارات'), findsOneWidget);
      expect(find.text('استلام تنبيهات فورية بالطلبات'), findsOneWidget);
      expect(find.byType(CustomSwitch), findsOneWidget);

      await tester.tap(find.text('تفعيل الإشعارات'));
      await tester.pumpAndSettle();

      expect(isToggled, isTrue);
    });
  });
}

