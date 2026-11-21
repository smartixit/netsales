import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/document_details/custom_document_timeline_node.dart';
import 'package:netsales/widgets/document_details/models/document_timeline_node_data.dart';

export 'package:netsales/widgets/document_details/custom_document_timeline_node.dart';
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
            CustomDocumentTimelineNode(node: nodes[i]),
        ],
      ),
    );
  }
}
