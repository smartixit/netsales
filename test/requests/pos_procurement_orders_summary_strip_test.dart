import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/pos_procurement_orders_summary_strip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows server-provided lifecycle totals without inventing completed state', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => MaterialApp(
          theme: AppThemes.light,
          home: Scaffold(
            body: PosProcurementOrdersSummaryStrip(
              summary: const RequestStatusSummaryEntity(
                total: 142,
                pending: 18,
                approved: 124,
                rejected: 3,
                cancelled: 2,
              ),
              isLoading: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('142'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('124'), findsOneWidget);
    expect(find.text('إجمالي الطلبات'), findsOneWidget);
    expect(find.text('قيد المراجعة'), findsOneWidget);
    expect(find.text('معتمدة'), findsOneWidget);
    expect(find.text('مكتملة'), findsNothing);

    final summaryRow = tester.getSize(find.byType(Row));
    expect(summaryRow.height.isFinite, isTrue);
    expect(summaryRow.width.isFinite, isTrue);
    final cardSlots = find.byType(Expanded);
    expect(cardSlots, findsNWidgets(3));
    final firstCardSize = tester.getSize(cardSlots.first);
    final lastCardSize = tester.getSize(cardSlots.last);
    expect(firstCardSize.height, lastCardSize.height);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps summary placeholders stable while loading in dark mode', (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => MaterialApp(
          theme: AppThemes.dark,
          home: const Scaffold(
            body: PosProcurementOrdersSummaryStrip(
              summary: null,
              isLoading: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('إجمالي الطلبات'), findsOneWidget);
    expect(find.text('قيد المراجعة'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
