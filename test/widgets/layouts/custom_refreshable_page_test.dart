import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';

void main() {
  Future<EdgeInsets> resolvePadding(
    WidgetTester tester, {
    required Size size,
    required EdgeInsets safePadding,
    bool embedded = true,
  }) async {
    EdgeInsets? result;
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MediaQuery(
          data: MediaQueryData(size: size, padding: safePadding),
          child: Builder(
            builder: (context) {
              result = CustomRefreshablePage.resolvePagePadding(
                context,
                embedded: embedded,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    return result!;
  }

  testWidgets('portrait phone reserves both overlaid workspace bars', (
    tester,
  ) async {
    final padding = await resolvePadding(
      tester,
      size: const Size(375, 812),
      safePadding: const EdgeInsets.only(top: 24, bottom: 24),
    );

    expect(
      padding.top,
      24 + AppSpacing.appBarHeight + AppSpacing.sm + AppSpacing.md,
    );
    expect(padding.bottom, greaterThan(AppSpacing.bottomNavHeight));
  });

  testWidgets('tablet relies on Scaffold app bar and has no bottom bar inset', (
    tester,
  ) async {
    final padding = await resolvePadding(
      tester,
      size: const Size(800, 1024),
      safePadding: const EdgeInsets.only(top: 24, bottom: 24),
    );

    expect(padding.top, AppSpacing.md);
    expect(padding.bottom, 24 + AppSpacing.xl);
  });

  testWidgets('standalone page keeps regular spacing', (tester) async {
    final padding = await resolvePadding(
      tester,
      size: const Size(375, 812),
      safePadding: const EdgeInsets.only(top: 24, bottom: 24),
      embedded: false,
    );

    expect(padding.top, AppSpacing.md);
    expect(padding.bottom, 24 + AppSpacing.xl);
  });
}
