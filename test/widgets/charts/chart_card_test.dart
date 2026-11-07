import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/charts/charting.dart';

void main() {
  testWidgets('shows and invokes only configured export actions', (tester) async {
    var pngExports = 0;
    var csvShares = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartCard(
            title: 'Sales',
            chart: const SizedBox.expand(),
            onExportPng: () => pngExports++,
            onShareCsv: () => csvShares++,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('تصدير ومشاركة'));
    await tester.pumpAndSettle();
    expect(find.text('حفظ كصورة PNG'), findsOneWidget);
    expect(find.text('مشاركة CSV'), findsOneWidget);
    expect(find.text('حفظ كملف PDF'), findsNothing);

    await tester.tap(find.text('حفظ كصورة PNG'));
    await tester.pumpAndSettle();
    expect(pngExports, 1);

    await tester.tap(find.byTooltip('تصدير ومشاركة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مشاركة CSV'));
    await tester.pumpAndSettle();
    expect(csvShares, 1);
  });

  testWidgets('uses ChartController for reset and zoom toolbar actions',
      (tester) async {
    final controller = ChartController();
    final owner = Object();
    var resets = 0;
    var zoomIns = 0;
    var zoomOuts = 0;
    controller.attach(
      owner: owner,
      reset: () => resets++,
      zoomIn: () => zoomIns++,
      zoomOut: () => zoomOuts++,
      pan: (_) {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartCard(
            title: 'Sales',
            chart: const SizedBox.expand(),
            chartController: controller,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('إعادة ضبط التكبير'));
    await tester.tap(find.byTooltip('تكبير المخطط'));
    await tester.tap(find.byTooltip('تصغير المخطط'));

    expect(resets, 1);
    expect(zoomIns, 1);
    expect(zoomOuts, 1);
    controller.detach(owner);
  });
}
