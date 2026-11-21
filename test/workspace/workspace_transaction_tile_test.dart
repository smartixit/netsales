import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_tile.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('WorkspaceTransactionTile Widget Tests', () {
    const dummyPresentation = EnumPresentation(
      label: 'معتمدة',
      tone: SemanticTone.success,
      icon: Icons.check_circle_rounded,
    );

    testWidgets('renders title, reference, subtitle, formattedAmount and status',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const WorkspaceTransactionTile(
            title: 'فاتورة توريد #105',
            reference: 'INV-105',
            subtitle: 'شراء آجل • منذ 10 دقائق',
            formattedAmount: '15,000 ر.ي',
            statusPresentation: dummyPresentation,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('فاتورة توريد #105'), findsOneWidget);
      expect(find.text('INV-105'), findsOneWidget);
      expect(find.text('شراء آجل • منذ 10 دقائق'), findsOneWidget);
      expect(find.text('15,000 ر.ي'), findsOneWidget);
      expect(find.byType(CustomStatusBadge), findsOneWidget);
      expect(find.text('معتمدة'), findsOneWidget);
    });

    testWidgets(
      'keeps long Arabic transaction content inside narrow and wide cards',
      (tester) async {
        for (final width in [320.0, 375.0, 600.0]) {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          await tester.pumpWidget(
            buildTestableWidget(
              const Padding(
                padding: EdgeInsets.all(12),
                child: WorkspaceTransactionTile(
                  title: 'فاتورة توريد من نقطة البيع الرئيسية',
                  reference: 'INV-2026-00000000125',
                  subtitle: 'شراء نقدي • 77 كرت • منذ 10 دقائق • نقطة بيع صنعاء',
                  formattedAmount: '- 125,000,000 ر.ي',
                  statusPresentation: EnumPresentation(
                    label: 'بانتظار مراجعة واعتماد الشبكة',
                    tone: SemanticTone.warning,
                    icon: Icons.hourglass_top_rounded,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull, reason: 'width: $width');
          expect(find.text('فاتورة توريد من نقطة البيع الرئيسية'), findsOneWidget);
          expect(find.text('بانتظار مراجعة واعتماد الشبكة'), findsOneWidget);
          expect(find.text('- 125,000,000 ر.ي'), findsOneWidget);

          final tileRect = tester.getRect(find.byType(WorkspaceTransactionTile));
          for (final target in [
            find.text('فاتورة توريد من نقطة البيع الرئيسية'),
            find.text('بانتظار مراجعة واعتماد الشبكة'),
            find.text('- 125,000,000 ر.ي'),
          ]) {
            expect(
              tileRect.contains(tester.getRect(target).topLeft) &&
                  tileRect.contains(tester.getRect(target).bottomRight),
              isTrue,
              reason: 'content must remain inside tile at width $width',
            );
          }
        }
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      },
    );

    testWidgets('triggers onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          WorkspaceTransactionTile(
            title: 'طلب توريد #55',
            formattedAmount: '20,000 ر.ي',
            statusPresentation: dummyPresentation,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('طلب توريد #55'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders custom trailingAction when provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const WorkspaceTransactionTile(
            title: 'طلب اعتماد #88',
            formattedAmount: '5,000 ر.ي',
            statusPresentation: dummyPresentation,
            trailingAction: Text('زر اعتماد خاص'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('زر اعتماد خاص'), findsOneWidget);
      expect(find.byType(CustomStatusBadge), findsNothing);
    });
  });
}
