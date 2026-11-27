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
        bool previewTapped = false;

        await tester.pumpWidget(
          createTestApp(
            NotificationItemCard(
              notification: sampleUnreadWithImage,
              onTap: () => tapped = true,
              onPreviewImage: () => previewTapped = true,
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
        expect(find.text('عرض الصورة المرفقة'), findsOneWidget);

        // Tap on Mark as read
        await tester.tap(find.text('تعليم كمقروء'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(markReadTapped, isTrue);

        // Tap on card title and the attached-image action.
        await tester.tap(find.text('تم إصدار فاتورة مبيعات جديدة #9901'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tapped, isTrue);

        await tester.tap(find.text('عرض الصورة المرفقة'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(previewTapped, isTrue);
      },
    );

    testWidgets(
      'renders the attachment preview action without introducing local expansion state',
      (tester) async {
        var previewTapped = false;
        await tester.pumpWidget(
          createTestApp(
            NotificationItemCard(
              notification: sampleUnreadWithImage,
              onTap: () {},
              onPreviewImage: () => previewTapped = true,
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(NotificationCardMedia), findsOneWidget);
        await tester.tap(find.byType(NotificationCardMedia));
        await tester.pump();

        expect(previewTapped, isTrue);
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
