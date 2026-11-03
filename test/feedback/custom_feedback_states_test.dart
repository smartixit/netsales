import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';

void main() {
  Widget buildTestableWidget({required Widget child}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        theme: AppThemes.light,
        home: Scaffold(body: child),
      ),
    );
  }

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(500 * 2, 1100 * 2);
    tester.view.devicePixelRatio = 2.0;
  }

  group('CustomEmptyState Widget Tests', () {
    testWidgets(
      'renders full empty state with badge, title, subtitle, and action',
      (tester) async {
        configureViewport(tester);
        addTearDown(() => tester.view.resetPhysicalSize());

        bool actionTapped = false;

        await tester.pumpWidget(
          buildTestableWidget(
            child: CustomEmptyState(
              title: 'لا توجد طلبات توريد',
              subtitle: 'لم يتم تقديم أي طلب توريد حتى الآن',
              badgeText: 'الطلبات',
              badgeIcon: Icons.receipt_rounded,
              icon: Icons.receipt_long_rounded,
              animationPath: null, // Test icon fallback
              actionLabel: 'طلب جديد',
              onAction: () => actionTapped = true,
            ),
          ),
        );

        expect(find.text('لا توجد طلبات توريد'), findsOneWidget);
        expect(find.text('لم يتم تقديم أي طلب توريد حتى الآن'), findsOneWidget);
        expect(find.text('الطلبات'), findsOneWidget);
        expect(find.text('طلب جديد'), findsOneWidget);

        await tester.tap(find.text('طلب جديد'));
        await tester.pumpAndSettle();
        expect(actionTapped, isTrue);
      },
    );

    testWidgets('renders compact empty state', (tester) async {
      configureViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          child: const CustomEmptyState.compact(
            title: 'القائمة فارغة',
            subtitle: 'لا توجد بيانات للعرض',
          ),
        ),
      );

      expect(find.text('القائمة فارغة'), findsOneWidget);
      expect(find.text('لا توجد بيانات للعرض'), findsOneWidget);
    });

    testWidgets('renders search zero results factory', (tester) async {
      configureViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      bool cleared = false;
      await tester.pumpWidget(
        buildTestableWidget(
          child: CustomEmptyState.search(
            query: 'باقة مجهولة',
            onClearSearch: () => cleared = true,
          ),
        ),
      );

      expect(find.text('لم يتم العثور على أي نتائج'), findsOneWidget);
      expect(find.text('نتائج البحث'), findsOneWidget);
      expect(find.text('مسح البحث'), findsOneWidget);

      await tester.tap(find.text('مسح البحث'));
      await tester.pumpAndSettle();
      expect(cleared, isTrue);
    });
  });

  group('CustomErrorState Widget Tests', () {
    testWidgets(
      'renders full error state with title, subtitle, and retry action',
      (tester) async {
        configureViewport(tester);
        addTearDown(() => tester.view.resetPhysicalSize());

        bool retried = false;

        await tester.pumpWidget(
          buildTestableWidget(
            child: CustomErrorState(
              title: 'تعذر الاتصال بالخادم',
              subtitle: 'يرجى التحقق من الشبكة ثم إعادة المحاولة',
              retryLabel: 'إعادة المحاولة الآن',
              onRetry: () => retried = true,
              icon: Icons.error_outline_rounded,
              animationPath: null,
              errorCode: 'ERR_500',
            ),
          ),
        );

        expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);
        expect(
          find.text('يرجى التحقق من الشبكة ثم إعادة المحاولة'),
          findsOneWidget,
        );
        expect(find.text('ERR_500'), findsOneWidget);
        expect(find.text('إعادة المحاولة الآن'), findsOneWidget);

        await tester.tap(find.text('إعادة المحاولة الآن'));
        await tester.pumpAndSettle();
        expect(retried, isTrue);
      },
    );

    testWidgets('renders technical details accordion when expanded', (
      tester,
    ) async {
      configureViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          child: const CustomErrorState(
            title: 'خطأ برمجي',
            subtitle: 'حدث خطأ استثنائي',
            technicalDetails:
                'DioException [badResponse]: 500 Internal Server Error',
            icon: Icons.error_outline_rounded,
            animationPath: null,
          ),
        ),
      );

      expect(find.text('التفاصيل الفنية والدعم التقني'), findsOneWidget);
      expect(
        find.text('DioException [badResponse]: 500 Internal Server Error'),
        findsNothing,
      );

      // Tap to expand accordion
      await tester.tap(find.text('التفاصيل الفنية والدعم التقني'));
      await tester.pumpAndSettle();

      expect(
        find.text('DioException [badResponse]: 500 Internal Server Error'),
        findsOneWidget,
      );
      expect(find.text('نسخ تفاصيل الخطأ'), findsOneWidget);
    });

    testWidgets('renders connection error factory constructor', (tester) async {
      configureViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      bool retried = false;
      await tester.pumpWidget(
        buildTestableWidget(
          child: CustomErrorState.connection(onRetry: () => retried = true),
        ),
      );

      expect(find.text('تعذر الاتصال بالشبكة'), findsOneWidget);
      expect(find.text('OFFLINE'), findsOneWidget);
      expect(find.text('إعادة فحص الاتصال'), findsOneWidget);

      await tester.tap(find.text('إعادة فحص الاتصال'));
      await tester.pumpAndSettle();
      expect(retried, isTrue);
    });
  });
}
