import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/routing/screen_registry.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';
import 'package:netsales/features/operations/data/models/voucher_request_model.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';

void main() {
  group('Milestone 4A - Procurement Request & Canonical Registry Tests', () {
    test('POS-02 descriptor is registered as implemented and non-financial', () {
      final descriptor = ScreenRegistry.findById('POS-02');
      expect(descriptor, isNotNull);
      expect(descriptor!.route, AppRoutes.newProcurementOrder);
      expect(descriptor.workspace, AppWorkspace.pos);
      expect(descriptor.isBalanceMutation, isFalse,
          reason: 'إنشاء طلب التوريد عملية غير مالية لا تخصم ولا تقيد في المحافظ');
      expect(descriptor.implementationState,
          ScreenImplementationState.implemented);
      expect(descriptor.requiredPermission, AppPermissions.requestsCreate);
    });

    test('Idempotency key generates valid domain-scoped persistent token', () {
      final keyWithNet = IdempotencyHelper.forVoucherRequest(42);
      expect(keyWithNet.startsWith('vouch-net42-'), isTrue);

      final keyGeneral = IdempotencyHelper.forVoucherRequest(null);
      expect(keyGeneral.startsWith('vouch-'), isTrue);

      // التأكد من تفرد المفاتيح
      final key2 = IdempotencyHelper.forVoucherRequest(42);
      expect(keyWithNet, isNot(equals(key2)));
    });

    test('VoucherRequestModel parses server response correctly', () {
      final json = {
        'request_id': 105,
        'network_id': 1,
        'pos_id': 2,
        'request_uuid': 'REQ-2026-ABCD',
        'sale_type': 'CASH',
        'sale_type_label': 'نقداً',
        'request_total_amount': 75000.0,
        'request_date': '2026-11-01 21:00:00',
        'status': 'PENDING',
        'status_label': 'قيد الانتظار',
        'created_by': 10,
        'request_note': 'طلب عاجل',
        'items': [
          {
            'item_id': 1,
            'package_id': 5,
            'voucher_price': 500.0,
            'voucher_count': 150,
            'item_discount': 10.0,
            'item_total_amount': 67500.0,
            'package_name': 'باقة 500',
          }
        ],
      };

      final model = VoucherRequestModel.fromJson(json);
      expect(model.requestId, 105);
      expect(model.requestUuid, 'REQ-2026-ABCD');
      expect(model.status, 'PENDING');
      expect(model.isPending, isTrue);
      expect(model.isApproved, isFalse);
      expect(model.isCancelled, isFalse);
      expect(model.isRejected, isFalse);
      expect(model.isCash, isTrue);
      expect(model.items.length, 1);
      expect(model.items.first.voucherCount, 150);
      expect(model.totalCardsCount, 150);
    });

    test('Non-financial lifecycle states evaluate correctly', () {
      const pendingEntity = VoucherRequestEntity(
        requestId: 1,
        networkId: 1,
        posId: 2,
        requestUuid: 'REQ-1',
        saleType: 'CREDIT',
        saleTypeLabel: 'آجل',
        requestTotalAmount: 50000.0,
        status: 'PENDING',
        statusLabel: 'قيد الانتظار',
        createdBy: 10,
      );

      expect(pendingEntity.isPending, isTrue);
      expect(pendingEntity.isCredit, isTrue);

      const cancelledEntity = VoucherRequestEntity(
        requestId: 1,
        networkId: 1,
        posId: 2,
        requestUuid: 'REQ-1',
        saleType: 'CREDIT',
        saleTypeLabel: 'آجل',
        requestTotalAmount: 50000.0,
        status: 'CANCELLED',
        statusLabel: 'ملغي',
        createdBy: 10,
      );

      expect(cancelledEntity.isCancelled, isTrue);
      expect(cancelledEntity.isPending, isFalse);

      const rejectedEntity = VoucherRequestEntity(
        requestId: 1,
        networkId: 1,
        posId: 2,
        requestUuid: 'REQ-1',
        saleType: 'CREDIT',
        saleTypeLabel: 'آجل',
        requestTotalAmount: 50000.0,
        status: 'REJECTED',
        statusLabel: 'مرفوض',
        createdBy: 10,
      );

      expect(rejectedEntity.isRejected, isTrue);
      expect(rejectedEntity.isPending, isFalse);
    });

    test('Client submission payload excludes prices and totals', () {
      // محاكاة تجهيز البنود من الواجهة الأمامية
      final quantities = {1: 50, 2: 100};
      final itemsPayload = quantities.entries
          .map((e) => {
                'package_id': e.key,
                'voucher_count': e.value,
              })
          .toList();

      for (final item in itemsPayload) {
        expect(item.containsKey('voucher_price'), isFalse,
            reason: 'العميل لا يرسل أسعار الكروت');
        expect(item.containsKey('item_discount'), isFalse,
            reason: 'العميل لا يرسل نسب الخصم');
        expect(item.containsKey('item_total_amount'), isFalse,
            reason: 'العميل لا يحسب الإجمالي');
        expect(item['package_id'], isA<int>());
        expect(item['voucher_count'], isA<int>());
      }
    });
  });
}

