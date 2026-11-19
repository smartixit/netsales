import 'package:flutter/material.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';

/// محول بيانات عقدة القرار والفوترة في الخط الزمني لطلب التوريد
class ProcurementTimelineDecisionMapper {
  const ProcurementTimelineDecisionMapper._();

  static String resolveTitle(RequestEntity request) {
    switch (request.status) {
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

  static String resolveSubtitle(RequestEntity request) {
    switch (request.status) {
      case RequestStatus.approved:
        final approver = request.reviewedByName != null &&
                request.reviewedByName!.isNotEmpty
            ? 'بواسطة ${request.reviewedByName}'
            : '';
        return request.invoiceUuid != null && request.invoiceUuid!.isNotEmpty
            ? 'تم الاعتماد $approver وإصدار الفاتورة المعتمدة #${request.invoiceUuid}'
            : 'تمت المصادقة $approver على الكميات وتوليد الفاتورة آلياً';
      case RequestStatus.rejected:
        final hasRejector = request.reviewedByName != null &&
            request.reviewedByName!.isNotEmpty;
        final rejectorPrefix = hasRejector
            ? 'بواسطة ${request.reviewedByName} • '
            : '';
        return request.requestNote != null && request.requestNote!.isNotEmpty
            ? '$rejectorPrefixالسبب: ${request.requestNote}'
            : '$rejectorPrefixتم رفض الطلب وتوثيق السبب';
      case RequestStatus.cancelled:
        return request.requestNote != null && request.requestNote!.isNotEmpty
            ? 'السبب: ${request.requestNote}'
            : 'تم إلغاء الطلب من قبل نقطة البيع';
      case RequestStatus.pending:
      case RequestStatus.unknown:
        return 'الطلب بانتظار مراجعة وقرار إدارة الشبكة المورّدة';
    }
  }

  static IconData resolveIcon(RequestEntity request) {
    switch (request.status) {
      case RequestStatus.approved:
        return Icons.verified_rounded;
      case RequestStatus.rejected:
        return Icons.cancel_rounded;
      case RequestStatus.cancelled:
        return Icons.block_rounded;
      case RequestStatus.pending:
      case RequestStatus.unknown:
        return Icons.pending_actions_rounded;
    }
  }

  static Color resolveColor(RequestEntity request, BuildContext context) {
    final colors = context.colors;
    switch (request.status) {
      case RequestStatus.approved:
        return const Color(0xFF10B981);
      case RequestStatus.rejected:
        return colors.error;
      case RequestStatus.cancelled:
        return colors.onSurfaceVariant;
      case RequestStatus.pending:
      case RequestStatus.unknown:
        return const Color(0xFFD97706);
    }
  }
}
