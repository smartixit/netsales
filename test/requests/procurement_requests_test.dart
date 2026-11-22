import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/requests/data/models/request_item_model.dart';
import 'package:netsales/features/requests/data/models/request_model.dart';
import 'package:netsales/features/requests/data/models/request_modification_summary_model.dart';
import 'package:netsales/features/requests/data/models/request_approval_result_model.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_item_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/approve_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/reject_request_use_case.dart';

class MockRequestRepository implements RequestRepository {
  final List<RequestEntity> _requests = [];

  MockRequestRepository(List<RequestEntity> initial) {
    _requests.addAll(initial);
  }

  @override
  Future<RequestStatusSummaryEntity> getRequestStatusSummary({
    int? networkId,
    int? posId,
  }) async {
    final filtered = _requests.where((r) {
      if (networkId != null && r.networkId != networkId) return false;
      if (posId != null && r.posId != posId) return false;
      return true;
    }).toList();

    return RequestStatusSummaryEntity(
      total: filtered.length,
      pending: filtered.where((r) => r.isPending).length,
      approved: filtered.where((r) => r.isApproved).length,
      rejected: filtered.where((r) => r.isRejected).length,
      cancelled: filtered.where((r) => r.isCancelled).length,
    );
  }

  @override
  Future<PaginatedList<RequestEntity>> getRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final filtered = _requests.where((r) {
      if (networkId != null && r.networkId != networkId) return false;
      if (posId != null && r.posId != posId) return false;
      if (status != null && status.isNotEmpty && r.statusRaw != status) {
        return false;
      }
      if (search != null && search.isNotEmpty) {
        if (!r.requestId.toString().contains(search) &&
            !(r.networkName?.toLowerCase().contains(search.toLowerCase()) ??
                false) &&
            !(r.posName?.toLowerCase().contains(search.toLowerCase()) ??
                false)) {
          return false;
        }
      }
      return true;
    }).toList();

    return PaginatedList<RequestEntity>(
      items: filtered,
      nextCursor: filtered.length > 5 ? 'cursor_token_next' : null,
      prevCursor: cursor != null ? 'cursor_token_prev' : null,
    );
  }

  @override
  Future<ProcurementQuoteEntity> getQuote(Map<String, dynamic> payload) async {
    return const ProcurementQuoteEntity(
      networkId: 1,
      posId: 1,
      saleType: SaleType.cash,
      saleTypeLabel: 'نقدي',
      grossTotal: 5000.0,
      discountTotal: 500.0,
      netTotal: 4500.0,
      currency: 'YER',
      pricingToken: 'quote_mock_token_test',
      items: [],
    );
  }

  @override
  Future<RequestEntity> getRequestDetails(int requestId) async {
    final found = _requests.cast<RequestEntity?>().firstWhere(
      (r) => r?.requestId == requestId,
      orElse: () => null,
    );
    if (found == null) {
      throw const AppException('الطلب غير موجود', code: '404');
    }
    return found;
  }

  @override
  Future<RequestEntity> createRequest(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  }) async {
    final req = RequestEntity(
      requestId: _requests.length + 1,
      networkId: data['network_id'] as int? ?? 1,
      posId: data['pos_id'] as int? ?? 1,
      saleTypeRaw: data['sale_type'] as String? ?? 'CASH',
      saleTypeLabel: 'نقدي',
      requestTotalAmount: 5000.0,
      statusRaw: 'PENDING',
      statusLabel: 'قيد الانتظار',
      requestNote: data['request_note'] as String?,
      requestDate: '2026-11-07 10:00:00',
    );
    _requests.insert(0, req);
    return req;
  }

  @override
  Future<RequestEntity> cancelRequest(int requestId) async {
    final index = _requests.indexWhere((r) => r.requestId == requestId);
    if (index >= 0) {
      final existing = _requests[index];
      final updated = RequestEntity(
        requestId: existing.requestId,
        networkId: existing.networkId,
        posId: existing.posId,
        saleTypeRaw: existing.saleTypeRaw,
        saleTypeLabel: existing.saleTypeLabel,
        requestTotalAmount: existing.requestTotalAmount,
        statusRaw: 'CANCELLED',
        statusLabel: 'ملغي',
        requestDate: existing.requestDate,
        networkName: existing.networkName,
        posName: existing.posName,
      );
      _requests[index] = updated;
      return updated;
    }
    throw const AppException('الطلب غير موجود', code: '404');
  }

  @override
  Future<RequestModificationPreviewEntity> previewRequestModification(
    int requestId,
    List<RequestModificationLineEntity> items,
  ) async {
    return RequestModificationPreviewEntity(
      requestId: requestId,
      originalTotalAmount: 10000,
      previewTotalAmount: 9000,
      grossTotalAmount: 10000,
      totalDiscountAmount: 1000,
      saleType: 'CASH',
      saleTypeLabel: 'نقدي',
      hasModifications: true,
      items: items
          .map(
            (item) => RequestModificationPreviewItemEntity(
              packageId: item.packageId,
              packageName: 'باقة اختبار',
              voucherCount: item.voucherCount,
              voucherPrice: 1000,
              itemDiscount: 10,
              itemTotalAmount: item.voucherCount * 900,
              grossTotalAmount: item.voucherCount * 1000,
              discountAmount: item.voucherCount * 100,
              source: 'ORIGINAL',
              pricingToken: item.pricingToken,
              changeType: 'QUANTITY_CHANGED',
              originalVoucherCount: item.voucherCount - 1,
            ),
          )
          .toList(growable: false),
      removedItems: const [],
    );
  }

  @override
  Future<RequestApprovalResultEntity> approveRequest(
    int requestId, {
    String? requestNote,
    List<RequestModificationLineEntity>? items,
  }) async {
    final index = _requests.indexWhere((r) => r.requestId == requestId);
    if (index >= 0) {
      final existing = _requests[index];
      final updated = RequestEntity(
        requestId: existing.requestId,
        networkId: existing.networkId,
        posId: existing.posId,
        saleTypeRaw: existing.saleTypeRaw,
        saleTypeLabel: existing.saleTypeLabel,
        requestTotalAmount: existing.requestTotalAmount,
        statusRaw: 'APPROVED',
        statusLabel: 'تمت الموافقة',
        requestDate: existing.requestDate,
        reviewDate: '2026-11-07 12:00:00',
        invoiceId: 901,
        networkName: existing.networkName,
        posName: existing.posName,
      );
      _requests[index] = updated;
      return RequestApprovalResultEntity(
        request: updated,
        invoice: InvoiceEntity(
          invoiceId: 901,
          networkId: updated.networkId,
          posId: updated.posId,
          requestId: updated.requestId,
          invoiceTotalAmount: updated.requestTotalAmount,
          remainingAmount: 0,
          paymentStatusRaw: 'PAID',
          isFullyPaid: true,
        ),
      );
    }
    throw const AppException('الطلب غير موجود', code: '404');
  }

  @override
  Future<RequestEntity> rejectRequest(
    int requestId,
    String rejectionReason,
  ) async {
    final index = _requests.indexWhere((r) => r.requestId == requestId);
    if (index >= 0) {
      final existing = _requests[index];
      final updated = RequestEntity(
        requestId: existing.requestId,
        networkId: existing.networkId,
        posId: existing.posId,
        saleTypeRaw: existing.saleTypeRaw,
        saleTypeLabel: existing.saleTypeLabel,
        requestTotalAmount: existing.requestTotalAmount,
        statusRaw: 'REJECTED',
        statusLabel: 'مرفوض',
        requestDate: existing.requestDate,
        reviewDate: '2026-11-07 12:00:00',
        requestNote: 'سبب الرفض: $rejectionReason',
        networkName: existing.networkName,
        posName: existing.posName,
      );
      _requests[index] = updated;
      return updated;
    }
    throw const AppException('الطلب غير موجود', code: '404');
  }

  @override
  Future<RequestEntity> updateRequest(
    int requestId,
    Map<String, dynamic> data,
  ) async {
    final index = _requests.indexWhere((r) => r.requestId == requestId);
    if (index >= 0) {
      final existing = _requests[index];
      final updated = RequestEntity(
        requestId: existing.requestId,
        networkId: existing.networkId,
        posId: existing.posId,
        requestUuid: existing.requestUuid,
        saleTypeRaw: data['sale_type'] as String? ?? existing.saleTypeRaw,
        requestTotalAmount: existing.requestTotalAmount,
        statusRaw: existing.statusRaw,
        statusLabel: existing.statusLabel,
        requestNote: data['request_note'] as String? ?? existing.requestNote,
      );
      _requests[index] = updated;
      return updated;
    }
    throw const AppException('الطلب غير موجود', code: '404');
  }

  @override
  Future<bool> deleteRequest(int requestId) async {
    _requests.removeWhere((r) => r.requestId == requestId);
    return true;
  }
}

void main() {
  group('Procurement Request Models and Serialization Tests', () {
    test(
      'RequestModel fromJson deserializes full backend resource correctly',
      () {
        final json = {
          'request_id': 101,
          'network_id': 5,
          'pos_id': 12,
          'request_uuid': 'req-uuid-12345',
          'sale_type': 'CASH',
          'sale_type_label': 'نقدي',
          'request_total_amount': 25000.0,
          'request_date': '2026-11-07 10:00:00',
          'status': 'PENDING',
          'status_label': 'قيد الانتظار',
          'created_by': 1,
          'reviewed_by': null,
          'review_date': null,
          'request_note': 'طلب عاجل للأسبوع القادم',
          'invoice_id': null,
          'invoice_uuid': null,
          'network': {'network_name': 'شبكة يمن نت'},
          'pos': {'pos_name': 'نقطة الأمل للمبيعات'},
          'items': [
            {
              'item_id': 1,
              'request_id': 101,
              'package_id': 3,
              'voucher_price': 1000.0,
              'voucher_count': 25,
              'item_discount': 100.0,
              'item_total_amount': 22500.0,
            },
          ],
        };

        final model = RequestModel.fromJson(json);

        expect(model.requestId, 101);
        expect(model.networkId, 5);
        expect(model.posId, 12);
        expect(model.requestUuid, 'req-uuid-12345');
        expect(model.saleType, SaleType.cash);
        expect(model.requestTotalAmount, 25000.0);
        expect(model.status, RequestStatus.pending);
        expect(model.isPending, true);
        expect(model.networkName, 'شبكة يمن نت');
        expect(model.posName, 'نقطة الأمل للمبيعات');
        expect(model.items.length, 1);
        expect(model.items.first.voucherCount, 25);
      },
    );

    test('RequestModel maps the server modification summary without recomputing values', () {
      final model = RequestModel.fromJson({
        'request_id': 102,
        'network_id': 5,
        'pos_id': 12,
        'request_total_amount': 25000.0,
        'status': 'APPROVED',
        'modifications_summary': {
          'has_modifications': true,
          'original_total': 25000.0,
          'approved_total': 27000.0,
          'original_items_count': 2,
          'approved_items_count': 3,
        },
      });

      expect(model.modificationSummary, isA<RequestModificationSummaryModel>());
      expect(model.modificationSummary?.hasModifications, isTrue);
      expect(model.modificationSummary?.originalTotal, 25000.0);
      expect(model.modificationSummary?.approvedTotal, 27000.0);
      expect(model.modificationSummary?.originalItemsCount, 2);
      expect(model.modificationSummary?.approvedItemsCount, 3);
    });

    test('RequestModel rejects incomplete modification summary instead of showing zero values', () {
      expect(
        () => RequestModificationSummaryModel.fromJson({
          'has_modifications': true,
          'original_total': 25000.0,
        }),
        throwsFormatException,
      );
    });

    test('approval result preserves the approved request and authoritative invoice', () {
      final result = RequestApprovalResultModel.fromJson({
        'request': {
          'request_id': 101,
          'network_id': 5,
          'pos_id': 12,
          'request_uuid': 'req-uuid-12345',
          'sale_type': 'CREDIT',
          'request_total_amount': 25000.0,
          'status': 'APPROVED',
          'invoice_id': 901,
          'invoice_uuid': 'inv-uuid-901',
        },
        'invoice': {
          'invoice_id': 901,
          'network_id': 5,
          'pos_id': 12,
          'request_id': 101,
          'request_uuid': 'req-uuid-12345',
          'invoice_uuid': 'inv-uuid-901',
          'sale_type': 'CREDIT',
          'invoice_total_amount': 27000.0,
          'paid_amount': 27000.0,
          'remaining_amount': 0.0,
          'payment_status': 'PAID',
          'payment_status_label': 'مسددة بالكامل',
          'is_fully_paid': true,
          'items': <Map<String, dynamic>>[],
        },
      });

      expect(result.request.requestId, 101);
      expect(result.request.status, RequestStatus.approved);
      expect(result.invoice.invoiceId, 901);
      expect(result.invoice.invoiceTotalAmount, 27000.0);
      expect(result.invoice.paidAmount, 27000.0);
      expect(result.invoice.remainingAmount, 0.0);
      expect(result.invoice.isFullyPaid, isTrue);
    });

    test('RequestModel toJson serializes accurately without currency keys', () {
      final model = RequestModel(
        requestId: 101,
        networkId: 5,
        posId: 12,
        saleTypeRaw: 'CREDIT',
        requestTotalAmount: 5000.0,
        items: const [
          RequestItemModel(
            itemId: 1,
            requestId: 101,
            packageId: 4,
            voucherPrice: 500.0,
            voucherCount: 10,
            itemTotalAmount: 5000.0,
          ),
        ],
      );

      final json = model.toJson();

      expect(json['network_id'], 5);
      expect(json['pos_id'], 12);
      expect(json['sale_type'], 'CREDIT');
      expect(json.containsKey('currency'), false);
    });
  });

  group('Procurement Request Domain UseCases Tests', () {
    late MockRequestRepository mockRepo;
    late GetRequestsUseCase getRequestsUseCase;
    late GetRequestDetailsUseCase getRequestDetailsUseCase;
    late CreateRequestUseCase createRequestUseCase;
    late CancelRequestUseCase cancelRequestUseCase;
    late ApproveRequestUseCase approveRequestUseCase;
    late RejectRequestUseCase rejectRequestUseCase;

    const sampleRequest = RequestEntity(
      requestId: 1,
      networkId: 10,
      posId: 20,
      saleTypeRaw: 'CASH',
      saleTypeLabel: 'نقدي',
      requestTotalAmount: 10000.0,
      statusRaw: 'PENDING',
      statusLabel: 'قيد الانتظار',
      networkName: 'شبكة صنعاء',
      posName: 'مركز المدينة',
    );

    setUp(() {
      mockRepo = MockRequestRepository([sampleRequest]);
      getRequestsUseCase = GetRequestsUseCase(mockRepo);
      getRequestDetailsUseCase = GetRequestDetailsUseCase(mockRepo);
      createRequestUseCase = CreateRequestUseCase(mockRepo);
      cancelRequestUseCase = CancelRequestUseCase(mockRepo);
      approveRequestUseCase = ApproveRequestUseCase(mockRepo);
      rejectRequestUseCase = RejectRequestUseCase(mockRepo);
    });

    test('GetRequestsUseCase returns paginated list of requests', () async {
      final list = await getRequestsUseCase(posId: 20);
      expect(list.items.length, 1);
      expect(list.items.first.requestId, 1);
    });

    test('GetRequestDetailsUseCase returns request entity', () async {
      final details = await getRequestDetailsUseCase(1);
      expect(details.requestId, 1);
      expect(details.requestTotalAmount, 10000.0);
    });

    test('CreateRequestUseCase creates new pending request', () async {
      final created = await createRequestUseCase({
        'network_id': 10,
        'pos_id': 20,
        'sale_type': 'CASH',
        'request_note': 'طلب اختبار',
      });
      expect(created.requestId, 2);
      expect(created.isPending, true);
    });

    test('CancelRequestUseCase updates status to CANCELLED', () async {
      final cancelled = await cancelRequestUseCase(1);
      expect(cancelled.isCancelled, true);
      expect(cancelled.status, RequestStatus.cancelled);
    });

    test(
      'ApproveRequestUseCase updates status to APPROVED and sets invoice',
      () async {
        final approved = await approveRequestUseCase(1);
        expect(approved.request.isApproved, true);
        expect(approved.request.status, RequestStatus.approved);
        expect(approved.invoice.invoiceId, 901);
      },
    );

    test(
      'RejectRequestUseCase updates status to REJECTED with reason',
      () async {
        final rejected = await rejectRequestUseCase(1, 'الرصيد غير كافٍ');
        expect(rejected.isRejected, true);
        expect(rejected.status, RequestStatus.rejected);
        expect(rejected.requestNote, contains('الرصيد غير كافٍ'));
      },
    );
  });
}
