import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// نافذة تأكيد ربط نقطة البيع بالشبكة بعد مسح رمز QR (Link Confirmation Sheet)
class NetworkPosLinkConfirmSheet extends StatelessWidget {
  final NetworkPosLinkPreviewEntity preview;
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const NetworkPosLinkConfirmSheet({
    super.key,
    required this.preview,
    this.isLoading = false,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('yyyy/MM/dd hh:mm a');

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // مقبض السحب
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),

            // ترويسة النافذة
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.link_rounded,
                    color: colors.primary,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تأكيد الربط مع مزود شبكة',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'تم التحقق من صحة التحدي المشفر بنجاح',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            // بطاقة بيانات الشبكة المعاينة
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    icon: Icons.cell_tower_rounded,
                    label: 'اسم الشبكة:',
                    value: preview.networkName,
                    isBold: true,
                  ),
                  if (preview.networkPhone != null &&
                      preview.networkPhone!.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.sm),
                    _buildInfoRow(
                      context,
                      icon: Icons.phone_outlined,
                      label: 'رقم هاتف الشبكة:',
                      value: preview.networkPhone!,
                    ),
                  ],
                  if (preview.governorateName != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'المحافظة والمديرية:',
                      value:
                          '${preview.governorateName} - ${preview.directorateName ?? ""}',
                    ),
                  ],
                  SizedBox(height: AppSpacing.sm),
                  _buildInfoRow(
                    context,
                    icon: Icons.timer_outlined,
                    label: 'صلاحية الدعوة:',
                    value: dateFormat.format(preview.expiresAt),
                  ),
                ],
              ),
            ),

            // تنبيه في حال الارتباط المسبق
            if (preview.alreadyLinked) ...[
              SizedBox(height: AppSpacing.md),
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colors.warning.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: colors.warning,
                      size: 20.r,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'نقطة البيع مرتبطة بالفعل بهذه الشبكة سابقاً.',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: AppSpacing.xl),

            // أزرار التأكيد والإلغاء
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'إلغاء',
                    variant: AppButtonVariant.outline,
                    onPressed: isLoading ? null : onCancel,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'تأكيد وإتمام الربط',
                    icon: Icons.check_circle_outline_rounded,
                    variant: AppButtonVariant.primary,
                    loading: isLoading,
                    onPressed: preview.alreadyLinked ? null : onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isBold = false,
  }) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 18.r, color: colors.primary),
        SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
