import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ============================================================================
/// صف حدود خطة الاشتراك (SubscriptionLimitRow)
/// ============================================================================
/// صف للقراءة فقط يعرض عنواناً وقيمة ضمن قائمة حدود الخطة (UI-only،
/// القيم مصدرها الخادم).
class SubscriptionLimitRow extends StatelessWidget {
  const SubscriptionLimitRow({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 22.r),
        AppSpacing.hMd,
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
      ],
    );
  }
}
