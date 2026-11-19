import 'package:flutter/material.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/mappers/procurement_status_style_data.dart';

/// محول التنسيق اللوني والظلال والأيقونات المتكيفة مع حالة طلب التوريد
class ProcurementStatusStyleMapper {
  const ProcurementStatusStyleMapper._();

  static ProcurementStatusStyleData resolve(RequestEntity request) {
    if (request.isPending) {
      return ProcurementStatusStyleData(
        iconGradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFD97706), Color(0xFFB45309)],
        ),
        iconBorderColor: const Color(0xFFFFE082).withValues(alpha: .55),
        iconShadowColor: const Color(0xFFD97706).withValues(alpha: .28),
        statusIcon: Icons.hourglass_top_rounded,
      );
    }

    if (request.isApproved) {
      return ProcurementStatusStyleData(
        iconGradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF087F68), Color(0xFF075B55)],
        ),
        iconBorderColor: const Color(0xFFFFD98A).withValues(alpha: .40),
        iconShadowColor: const Color(0xFF087F68).withValues(alpha: .22),
        statusIcon: Icons.check_circle_rounded,
      );
    }

    if (request.isRejected) {
      return ProcurementStatusStyleData(
        iconGradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
        ),
        iconBorderColor: const Color(0xFFFCA5A5).withValues(alpha: .50),
        iconShadowColor: const Color(0xFFDC2626).withValues(alpha: .25),
        statusIcon: Icons.cancel_rounded,
      );
    }

    return ProcurementStatusStyleData(
      iconGradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF475569), Color(0xFF334155)],
      ),
      iconBorderColor: const Color(0xFFCBD5E1).withValues(alpha: .40),
      iconShadowColor: const Color(0xFF475569).withValues(alpha: .20),
      statusIcon: Icons.block_rounded,
    );
  }
}
