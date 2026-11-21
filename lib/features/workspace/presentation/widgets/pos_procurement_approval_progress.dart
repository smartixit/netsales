import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

class _ProcurementApprovalProgress extends StatelessWidget {
  const _ProcurementApprovalProgress({required this.presentation});

  final EnumPresentation presentation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusColor = presentation.tone.resolveColor(colors);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ProgressStep(
            label: 'تم الإرسال',
            icon: Icons.check_rounded,
            color: colors.success,
            isCurrent: false,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 11.h),
          child: Container(
            height: 2.h,
            width: 20.w,
            color: statusColor.withValues(alpha: 0.72),
          ),
        ),
        Expanded(
          child: _ProgressStep(
            label: presentation.label,
            icon: presentation.icon ?? Icons.help_outline_rounded,
            color: statusColor,
            isCurrent: true,
          ),
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.label,
    required this.icon,
    required this.color,
    required this.isCurrent,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 23.r,
          height: 23.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isCurrent ? 0.16 : 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.68)),
          ),
          child: Icon(icon, size: 13.r, color: color),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: isCurrent ? color : context.colors.onSurfaceVariant,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
