import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_tile.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

void main() {
  Widget testHarness(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }


  group('DashboardMetricGrid Uniform Height Tests', () {
    testWidgets(
      'DashboardMetricGrid assigns uniform height when cardHeight is specified',
      (tester) async {
        final metrics = [
          DashboardMetricData(
            id: '1',
            title: 'نقاط البيع',
            value: '42',
            unit: 'نقطة',
            variant: DashboardMetricVariant.standard,
            description: '35 نشطة · 7 غير نشطة',
          ),
          DashboardMetricData(
            id: '2',
            title: 'المبيعات',
            value: '1,200,000',
            unit: 'ر.ي',
            variant: DashboardMetricVariant.standard,
            description: '120 عملية هذا اليوم',
          ),
        ];

        await tester.pumpWidget(
          testHarness(
            DashboardMetricGrid(
              metrics: metrics,
              minimumCardWidth: 150,
              cardHeight: 130,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cardBoxes = tester
            .renderObjectList<RenderBox>(find.byType(DashboardMetricCard))
            .toList();

        expect(cardBoxes, hasLength(2));
        expect(cardBoxes[0].size.height, cardBoxes[1].size.height);
        expect(cardBoxes[0].size.height, greaterThan(100));
      },
    );
  });

  group('WorkspaceTransactionTile VIP Ledger Tests', () {
    testWidgets(
      'renders transaction tile with distinct card styling and tabular amount',
      (tester) async {
        const presentation = EnumPresentation(
          label: 'مكتملة',
          tone: SemanticTone.success,
        );

        await tester.pumpWidget(
          testHarness(
            const WorkspaceTransactionTile(
              title: 'فاتورة توريد #204',
              reference: 'INV-204',
              subtitle: 'شراء نقدي • ورقة ونصف • 77 كرت',
              formattedAmount: '- 350,000 ر.ي',
              amountColor: Color(0xFFDC2626),
              statusPresentation: presentation,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('فاتورة توريد #204'), findsOneWidget);
        expect(find.text('INV-204'), findsOneWidget);
        expect(find.text('شراء نقدي • ورقة ونصف • 77 كرت'), findsOneWidget);
        expect(find.text('- 350,000 ر.ي'), findsOneWidget);
      },
    );
  });
}
