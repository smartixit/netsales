import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/skeletons/custom_state_skeleton_view.dart';
import 'package:netsales/widgets/inputs/custom_context_option.dart';
import 'package:netsales/widgets/inputs/custom_context_selected_identity.dart';
import 'package:netsales/widgets/inputs/custom_context_selector.dart';

void main() {
  Widget testHarness({required Widget child}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        theme: AppThemes.light,
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  group('CustomContextSelector Loading State (Lines) Tests', () {
    testWidgets(
      'renders CustomStateView.loading of type text lines when isLoading is true',
      (tester) async {
        await tester.pumpWidget(
          testHarness(
            child: CustomContextSelector(
              title: 'الشبكة المورّدة',
              subtitle: 'الجهة التي ستوفر الباقات والأسعار لهذا الطلب',
              icon: Icons.cell_tower_rounded,
              accent: Colors.blue,
              selectedName: 'شبكة يمن واي فاي',
              selectedDetail: 'صنعاء - التحرير',
              selectedLogoUrl: null,
              selectedInitial: 'ش',
              isExpanded: false,
              canExpand: false,
              isLoading: true,
              onToggle: () {},
              options: const <CustomContextOption>[],
            ),
          ),
        );
        await tester.pump();

        // While loading, CustomStateView.loading should be visible
        expect(find.byType(CustomStateView), findsOneWidget);
        expect(find.byType(CustomStateSkeletonView), findsOneWidget);

        // CustomContextSelectedIdentity should NOT be rendered while loading
        expect(find.byType(CustomContextSelectedIdentity), findsNothing);
      },
    );

    testWidgets(
      'renders CustomContextSelectedIdentity when isLoading is false',
      (tester) async {
        await tester.pumpWidget(
          testHarness(
            child: CustomContextSelector(
              title: 'الشبكة المورّدة',
              subtitle: 'الجهة التي ستوفر الباقات والأسعار لهذا الطلب',
              icon: Icons.cell_tower_rounded,
              accent: Colors.blue,
              selectedName: 'شبكة يمن واي فاي',
              selectedDetail: 'صنعاء - التحرير',
              selectedLogoUrl: null,
              selectedInitial: 'ش',
              isExpanded: false,
              canExpand: false,
              isLoading: false,
              onToggle: () {},
              options: const <CustomContextOption>[],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // When loaded, CustomContextSelectedIdentity is visible with the entity data
        expect(find.byType(CustomContextSelectedIdentity), findsOneWidget);
        expect(find.text('شبكة يمن واي فاي'), findsOneWidget);
        expect(find.text('صنعاء - التحرير'), findsOneWidget);

        // No loading state should be present
        expect(find.byType(CustomStateView), findsNothing);
      },
    );
  });
}
