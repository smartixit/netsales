import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';

void main() {
  testWidgets('embedded page reserves the complete workspace app bar extent', (
    tester,
  ) async {
    EdgeInsets? resolvedPadding;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 812),
            padding: EdgeInsets.only(top: 24, bottom: 24),
          ),
          child: Builder(
            builder: (context) {
              resolvedPadding = CustomRefreshablePage.resolvePagePadding(
                context,
                embedded: true,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(
      resolvedPadding!.top,
      24 + AppSpacing.appBarHeight + AppSpacing.sm + AppSpacing.md,
    );
    expect(resolvedPadding!.bottom, greaterThan(AppSpacing.bottomNavHeight));
  });

  testWidgets('standalone page keeps its regular top spacing', (tester) async {
    EdgeInsets? resolvedPadding;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 812),
            padding: EdgeInsets.only(top: 24, bottom: 24),
          ),
          child: Builder(
            builder: (context) {
              resolvedPadding = CustomRefreshablePage.resolvePagePadding(
                context,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(resolvedPadding!.top, AppSpacing.md);
  });
}
