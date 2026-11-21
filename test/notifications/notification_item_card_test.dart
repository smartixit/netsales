import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/notification_type.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_card_media.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_item_card.dart';

Widget createTestApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      theme: AppThemes.dark,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DateFormatter.ensureInitialized();

  final sampleUnreadWithImage = NotificationItemEntity(
    notificationId: 201,
    userId: 1,
    notificationType: NotificationType.saleInvoiceCreated,
    notificationTypeLabel: 'فاتورة جديدة',
    notificationTitle: 'تم إصدار فاتورة مبيعات جديدة #9901',
    notificationMessage: 'قام العميل بطلب توريد كروت شبكة إنترنت بقيمة إجمالية قدرها 150,000 ريال يمني مع تخفيض تجاري بنسبة 10%، يرجى مراجعة التفاصيل واعتماد الفاتورة في أقرب وقت.',
    notificationImage: 'https://example.com/invoice_preview.jpg',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
  );

  final sampleReadNoImage = NotificationItemEntity(
    notificationId: 202,
    userId: 1,
    notificationType: NotificationType.securityLoginAlert,
    notificationTypeLabel: 'تنبيه أمان',
    notificationTitle: 'تسجيل دخول جديد',
    notificationMessage: 'تم تسجيل دخول من جهاز جديد بنجاح',
    isRead: true,
    readAt: DateTime.now().subtract(const Duration(hours: 1)),
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  );

  group('VIP NotificationItemCard Widget Tests', () {
    testWidgets(
      'renders unread card with title, label, media thumbnail and action buttons',
      (tester) async {
        bool tapped = false;
        bool markReadTapped = false;

        await tester.pumpWidget(
          createTestApp(
            NotificationItemCard(
              notification: sampleUnreadWithImage,
              onTap: () => tapped = true,
              onMarkAsRead: () => markReadTapped = true,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Title & Label rendered
        expect(find.text('تم إصدار فاتورة مبيعات جديدة #9901'), findsOneWidget);
        expect(find.text('فاتورة جديدة'), findsOneWidget);

        // Media thumbnail present
        expect(find.byType(NotificationCardMedia), findsOneWidget);

        // Action buttons rendered
        expect(find.text('تعليم كمقروء'), findsOneWidget);
        expect(find.text('عرض الإجراء'), findsOneWidget);

        // Tap on Mark as read
        await tester.tap(find.text('تعليم كمقروء'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(markReadTapped, isTrue);

        // Tap on card
        await tester.tap(find.text('عرض الإجراء'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'toggles expansion between collapsed thumbnail and expanded wide banner',
      (tester) async {
        await tester.pumpWidget(
          createTestApp(
            NotificationItemCard(
              notification: sampleUnreadWithImage,
              onTap: () {},
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Initially collapsed, "قراءة المزيد..." button visible
        expect(find.text('قراءة المزيد...'), findsOneWidget);

        // Tap to expand
        await tester.tap(find.text('قراءة المزيد...'));
        await tester.pump(const Duration(milliseconds: 300));

        // In expanded state: "إخفاء التفاصيل" visible
        expect(find.text('إخفاء التفاصيل'), findsOneWidget);

        // Tap to collapse again
        await tester.tap(find.text('إخفاء التفاصيل'));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('قراءة المزيد...'), findsOneWidget);
      },
    );

    testWidgets('renders read card without mark as read button', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          NotificationItemCard(notification: sampleReadNoImage, onTap: () {}),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('تسجيل دخول جديد'), findsOneWidget);
      expect(find.text('تعليم كمقروء'), findsNothing);
      expect(find.byType(NotificationCardMedia), findsNothing);
    });
  });
}
