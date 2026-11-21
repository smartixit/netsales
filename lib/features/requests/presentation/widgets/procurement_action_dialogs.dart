import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/requests/domain/entities/package_price_change_entity.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// نوافذ الحوار التفاعلية لقرارات اعتماد، رفض، وإلغاء طلبات التوريد
class ProcurementActionDialogs {
  ProcurementActionDialogs._();

  /// نافذة حوار اعتماد طلب التوريد مع ملاحظة اختيارية ودفعة نقدية كاش للطلبات الآجلة
  static Future<void> showApprovalDialog({
    required String requestUuid,
    required Future<void> Function(String? note, double? paidAmount) onConfirm,
    bool isCredit = false,
    double? maxAmount,
  }) async {
    final noteController = TextEditingController();
    final paidAmountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await CustomDialog.show(
      type: DialogType.confirmation,
      title: 'اعتماد طلب التوريد #$requestUuid',
      message: 'سيتم احتساب وتوليد فاتورة المبيعات آلياً عبر الخادم وتسوية الرصيد المالي.',
      confirmLabel: 'تأكيد الاعتماد',
      cancelLabel: 'تراجع',
      content: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isCredit) ...[
                CustomTextField(
                  controller: paidAmountController,
                  label: 'الدفعة النقدية المقبوضة كاش (اختياري)',
                  hint:
                      'أدخل المبلغ المسلَّم نقداً يداً بيد (0 إن لم يُدفع شيء)',
                  isRequired: false,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: const Icon(Icons.payments_outlined),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: FormValidators.amountValidator(
                    fieldName: 'المبلغ المقبوض كاش',
                    isRequired: false,
                    minValue: 0,
                    maxValue: maxAmount,
                  ),
                ),
                AppSpacing.vSm,
              ],
              CustomTextField(
                controller: noteController,
                label: 'ملاحظات الاعتماد (اختياري)',
                hint: 'أضف أي ملاحظات للوكيل بخصوص الفاتورة...',
                maxLines: 2,
                validator: FormValidators.descriptionValidator(
                  isRequired: false,
                ),
              ),
            ],
          ),
        ),
      ),
      onConfirm: () async {
        if (!formKey.currentState!.validate()) return;
        final note = noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim();
        final rawPaid = double.tryParse(paidAmountController.text.trim());
        final paid = (rawPaid != null && rawPaid > 0) ? rawPaid : null;
        await onConfirm(note, paid);
      },
    );
  }

  /// نافذة حوار رفض طلب التوريد مع بيان السبب الإلزامي
  static Future<void> showRejectionDialog({
    required String requestUuid,
    required Future<void> Function(String reason) onConfirm,
  }) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await CustomDialog.show(
      type: DialogType.custom,
      title: 'رفض طلب التوريد #$requestUuid',
      message: 'يرجى كتابة سبب الرفض المعتمد لتوثيقه في السجل وإشعار الوكيل.',
      confirmLabel: 'تأكيد الرفض',
      cancelLabel: 'إلغاء',
      content: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: CustomTextField(
            controller: reasonController,
            label: 'سبب الرفض الإلزامي',
            hint: 'مثال: الرصيد الائتماني غير كافٍ أو الكمية غير متوفرة...',
            maxLines: 2,
            isRequired: true,
            validator: FormValidators.descriptionValidator(
              fieldName: 'سبب الرفض',
            ),
          ),
        ),
      ),
      onConfirm: () async {
        if (!formKey.currentState!.validate()) return;
        await onConfirm(reasonController.text.trim());
      },
    );
  }

  /// نافذة حوار إلغاء طلب التوريد من قبل نقطة البيع
  static Future<void> showCancelDialog({
    required String requestUuid,
    required Future<void> Function() onConfirm,
  }) async {
    await CustomDialog.show(
      type: DialogType.warning,
      title: 'إلغاء طلب التوريد #$requestUuid',
      message:
          'هل أنت متأكد من رغبتك في إلغاء هذا الطلب قبل مراجعته من الشبكة؟',
      confirmLabel: 'نعم، إلغاء الطلب',
      cancelLabel: 'تراجع',
      onConfirm: () async {
        await onConfirm();
      },
    );
  }

  /// نافذة حوار حذف طلب التوريد (حذف ناعم للطلبات الملغية أو المعلقة)
  static Future<void> showDeleteDialog({
    required String requestUuid,
    required Future<void> Function() onConfirm,
  }) async {
    await CustomDialog.show(
      type: DialogType.error,
      title: 'حذف طلب التوريد $requestUuid',
      message: 'هل أنت متأكد من حذف هذا الطلب نهائياً من قائمة طلباتك؟ لن تظهر هذه المعاملة مجدداً.',
      confirmLabel: 'نعم، حذف الطلب',
      cancelLabel: 'تراجع',
      onConfirm: () async {
        await onConfirm();
      },
    );
  }

  /// نافذة حوار اعتراضية لإشعار المستخدم بتحديث أسعار الباقات ونيل موافقته الصريحة المستنيرة
  static Future<bool> showPriceChangeNoticeDialog({
    required BuildContext context,
    required List<PackagePriceChangeEntity> priceChanges,
    required double oldTotal,
    required double newTotal,
    required String currency,
  }) async {
    final colors = context.colors;

    final confirmed = await CustomDialog.show(
      type: DialogType.warning,
      title: 'تحديث في تعرفة الأسعار',
      message: 'قام مزود الشبكة بتحديث أسعار بعض الباقات المختارة أثناء إعدادك للطلب. يرجى مراجعة الفروقات قبل المتابعة:',
      confirmLabel: 'الموافقة والمتابعة',
      cancelLabel: 'مراجعة السلة',
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
      content: Container(
        margin: EdgeInsets.only(top: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < priceChanges.length; i++) ...[
              if (i > 0)
                Divider(
                  height: AppSpacing.md,
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              _PriceChangeItem(change: priceChanges[i], currency: currency),
            ],
            AppSpacing.vMd,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إجمالي الطلب بعد التحديث:',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  Text(
                    '${AmountFormatter.formatValue(newTotal)} $currency',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return confirmed ?? false;
  }
}

class _PriceChangeItem extends StatelessWidget {
  const _PriceChangeItem({required this.change, required this.currency});

  final PackagePriceChangeEntity change;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          change.package.packageName,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        AppSpacing.vXs,
        if (change.hasBasePriceChanged) ...[
          Row(
            children: [
              Text(
                'سعر الوحدة: ',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                '${AmountFormatter.formatValue(change.oldBaseUnitPrice)} $currency',
                style: AppTypography.bodySmall.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Icon(Icons.arrow_left_rounded, size: 16),
              Text(
                '${AmountFormatter.formatValue(change.newBaseUnitPrice)} $currency',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
        if (change.hasDiscountChanged) ...[
          Row(
            children: [
              Text(
                'نسبة الخصم: ',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                '${change.oldDiscountPercentage}%',
                style: AppTypography.bodySmall.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Icon(Icons.arrow_left_rounded, size: 16),
              Text(
                '${change.newDiscountPercentage}%',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
