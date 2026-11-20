import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/document_details/models/document_timeline_node_data.dart';

export 'package:netsales/widgets/document_details/models/document_timeline_node_data.dart';

/// مسار التدقيق والتسلسل الزمني لمراحل دورة حياة المعاملة (CustomDocumentTimeline)
///
/// المرجع الموحد لتوثيق التسلسل الإجرائي والمالي في شاشات تفاصيل النظام:
/// - بطاقة بحواف AppRadius.card مع حدود ناعمة وظلال خفيفة.
/// - ترويسة بأيقونة التدقيق الزمني وعنوان القسم.
/// - مسار من العقد المترابطة رأسياً بخطوط واصلة وأيقونات دلالية ملونة.
class CustomDocumentTimeline extends StatelessWidget {
  const CustomDocumentTimeline({
    super.key,
    this.title = 'مسار دورة حياة المعاملة والتدقيق',
    required this.nodes,
  });

  final String title;
  final List<DocumentTimelineNodeData> nodes;

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: 16.r, color: colors.primary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
          AppSpacing.vMd,

          for (var i = 0; i < nodes.length; i++)
            _TimelineNodeWidget(node: nodes[i]),
        ],
      ),
    );
  }
}

class _TimelineNodeWidget extends StatelessWidget {
  const _TimelineNodeWidget({required this.node});

  final DocumentTimelineNodeData node;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color =
        node.iconColor ??
        (node.isCompleted ? colors.success : colors.onSurfaceVariant);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العمود الرأسي: الأيقونة والخط الواصل
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

          // محتوى العقدة: العنوان، الوصف الفرعي، والوقت
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: node.isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          node.title,
                          style: AppTypography.labelMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (node.timestamp != null &&
                          node.timestamp!.isNotEmpty) ...[
                        AppSpacing.hXs,
                        Text(
                          node.timestamp!,
                          style: AppTypography.caption.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    node.subtitle,
                    style: AppTypography.caption.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10.5.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
