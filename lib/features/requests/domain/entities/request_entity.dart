import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_summary_entity.dart';

/// كيان دورة حياة طلب الكروت والتوريد (Procurement Request Entity)
class RequestEntity {
  final int requestId;
  final int networkId;
  final int posId;
  final String? requestUuid;
  final String? saleTypeRaw;
  final String? saleTypeLabel;
  final double requestTotalAmount;
  final String? requestDate;
  final String? statusRaw;
  final String? statusLabel;
  final int? createdBy;
  final String? reviewedBy;
  final String? reviewDate;
  final String? requestNote;
  final int? invoiceId;
  final String? invoiceUuid;
  final String? networkName;
  final String? networkPhone;
  final String? networkLogo;
  final String? posName;
  final String? posPhone;
  final String? posLogo;
  final String? createdByName;
  final String? reviewedByName;
  final List<RequestItemEntity> items;
  final RequestModificationSummaryEntity? modificationSummary;
  final String? createdAt;
  final String? updatedAt;

  const RequestEntity({
    required this.requestId,
    required this.networkId,
    required this.posId,
    this.requestUuid,
    this.saleTypeRaw,
    this.saleTypeLabel,
    required this.requestTotalAmount,
    this.requestDate,
    this.statusRaw,
    this.statusLabel,
    this.createdBy,
    this.reviewedBy,
    this.reviewDate,
    this.requestNote,
    this.invoiceId,
    this.invoiceUuid,
    this.networkName,
    this.networkPhone,
    this.networkLogo,
    this.posName,
    this.posPhone,
    this.posLogo,
    this.createdByName,
    this.reviewedByName,
    this.items = const [],
    this.modificationSummary,
    this.createdAt,
    this.updatedAt,
  });

  RequestStatus get status => RequestStatus.fromWire(statusRaw);
  SaleType get saleType => SaleType.fromWire(saleTypeRaw);

  bool get isPending => status == RequestStatus.pending;
  bool get isApproved => status == RequestStatus.approved;
  bool get isRejected => status == RequestStatus.rejected;
  bool get isCancelled => status == RequestStatus.cancelled;

  /// إجمالي عدد الكروت لكافة بنود الطلب
  int get totalVouchers =>
      items.fold<int>(0, (sum, item) => sum + item.voucherCount);

  /// إجمالي عدد الأوراق المقابلة لكافة بنود الطلب
  double get totalSheets => items.fold<double>(0.0, (sum, item) {
    final sheetSize = item.sheetSize;
    return sum + (sheetSize > 0 ? item.voucherCount / sheetSize : 0.0);
  });

  /// صيغة نصية منسقة لعدد الأوراق الكلية للطلب
  String get formattedTotalSheets =>
      totalSheets.truncateToDouble() == totalSheets
      ? totalSheets.toInt().toString()
      : totalSheets.toStringAsFixed(1);

  /// معرف العرض السيادي للطلب
  String get displayReference =>
      requestUuid != null && requestUuid!.trim().isNotEmpty
      ? requestUuid!.trim()
      : '#$requestId';

  /// تاريخ تقديم الطلب المحول
  DateTime? get parsedRequestDate =>
      DateTime.tryParse(requestDate ?? createdAt ?? '');

  /// تاريخ المراجعة والتدقيق المحول
  DateTime? get parsedReviewDate =>
      DateTime.tryParse(reviewDate ?? updatedAt ?? '');

  /// صيغة تاريخ تقديم الطلب المنسقة
  String get formattedRequestDate => parsedRequestDate != null
      ? DateFormatter.dateTime(parsedRequestDate!)
      : (requestDate ?? createdAt ?? 'التاريخ غير متاح');

  /// صيغة تاريخ المراجعة المنسقة
  String get formattedReviewDate => parsedReviewDate != null
      ? DateFormatter.dateTime(parsedReviewDate!)
      : (reviewDate ?? updatedAt ?? '');

  /// اسم نقطة البيع المنسق للعرض
  String get displayPosName => posName != null && posName!.trim().isNotEmpty
      ? posName!.trim()
      : 'نقطة بيع #$posId';

  /// اسم الشبكة المنسق للعرض
  String get displayNetworkName =>
      networkName != null && networkName!.trim().isNotEmpty
      ? networkName!.trim()
      : 'شبكة #$networkId';

  /// هل الطلب يتضمن ملاحظات؟
  bool get hasNote => requestNote != null && requestNote!.trim().isNotEmpty;

  /// هل الطلب يتضمن ملخص تعديلات؟
  bool get hasModificationSummary => isApproved && modificationSummary != null;

  /// هل الطلب معتمد ومرتبط بفاتورة صادرة؟
  bool get hasInvoice => isApproved && invoiceId != null && invoiceId! > 0;

  /// عنوان عقدة القرار والفوترة في المسار الزمني
  String get timelineDecisionTitle {
    switch (status) {
      case RequestStatus.approved:
        return 'تم الاعتماد وإصدار الفاتورة';
      case RequestStatus.rejected:
        return 'تم رفض الطلب';
      case RequestStatus.cancelled:
        return 'تم إلغاء الطلب';
      case RequestStatus.pending:
      case RequestStatus.unknown:
        return 'في انتظار القرار النهائي';
    }
  }

  /// تفاصيل عقدة القرار والفوترة في المسار الزمني
  String get timelineDecisionSubtitle {
    switch (status) {
      case RequestStatus.approved:
        final approver = reviewedByName != null && reviewedByName!.isNotEmpty
            ? 'بواسطة $reviewedByName'
            : '';
        return invoiceUuid != null && invoiceUuid!.isNotEmpty
            ? 'تم الاعتماد $approver وإصدار الفاتورة المعتمدة #$invoiceUuid'
            : 'تمت المصادقة $approver على الكميات وتوليد الفاتورة آلياً';
      case RequestStatus.rejected:
        final hasRejector =
            reviewedByName != null && reviewedByName!.isNotEmpty;
        final rejectorPrefix = hasRejector ? 'بواسطة $reviewedByName • ' : '';
        return requestNote != null && requestNote!.isNotEmpty
            ? '$rejectorPrefixالسبب: $requestNote'
            : '$rejectorPrefixتم رفض الطلب وتوثيق السبب';
      case RequestStatus.cancelled:
        return requestNote != null && requestNote!.isNotEmpty
            ? 'السبب: $requestNote'
            : 'تم إلغاء الطلب من قبل نقطة البيع';
      case RequestStatus.pending:
      case RequestStatus.unknown:
        return 'الطلب بانتظار مراجعة وقرار إدارة الشبكة المورّدة';
    }
  }
}
