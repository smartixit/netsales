import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/document_details/models/document_timeline_node_data.dart';

/// ويدجيت عقدة التسلسل الزمني والمسار الإجرائي (CustomDocumentTimelineNode)
///
/// صُممت العقدة بتدرج هرمي رأسي أنيق يمنع أي تكدس أو اختفاء للنصوص:
/// - أيقونة المرحلة وخط الربط الرأسي التفاعلي.
/// - عنوان المرحلة بكامل نصه وانسيابيته بدون اقتطاع.
/// - الوصف الإجرائي أو المنفذ للعملية.
/// - التاريخ والوقت المستقل مع أيقونة الساعة لتنظيم القراءة البصرية.
class CustomDocumentTimelineNode extends StatelessWidget {
  const CustomDocumentTimelineNode({super.key, required this.node});

  final DocumentTimelineNodeData node;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = node.iconColor ??
        (node.isCompleted ? colors.success : colors.onSurfaceVariant);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. العمود الرأسي: الأيقونة الدلالية والخط الرابط
          Column(
            children: [
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                child: Icon(node.icon, size: 14.r, color: color),
              ),
              if (!node.isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: colors.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
            ],
          ),
          AppSpacing.hSm,

          // 2. محتوى العقدة بتدرج رأسي مريح يمنع التكدس واختفاء النصوص
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: node.isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // عنوان المرحلة / الإجراء بالكامل دون اقتطاع
                  Text(
                    node.title,
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  if (node.subtitle.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      node.subtitle,
                      style: AppTypography.caption.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 10.5.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (node.timestamp != null &&
                      node.timestamp!.trim().isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11.r,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          node.timestamp!,
                          style: AppTypography.caption.copyWith(
                            color: colors.onSurfaceVariant
                                .withValues(alpha: 0.85),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
