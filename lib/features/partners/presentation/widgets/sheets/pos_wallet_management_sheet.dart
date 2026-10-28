import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/partners/presentation/controllers/pos_wallet_sheet_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// نافذة المحفظة التوزيعية الثنائية وسجل القيود المالية (PosWalletManagementSheet)
/// ============================================================================
/// تعرض البيانات المالية المشتركة بين الشبكة ونقطة البيع بدقة مطلقة، وتتيح إجراء
/// التحويل المالي البيني. خالية تماماً من أي حسابات مالية أو مقارنات، وتعتمد 100%
/// على البيانات المحسوبة من الخادم.
class PosWalletManagementSheet extends StatelessWidget {
  final int networkId;
  final int posId;
  final String posName;
  final String? networkName;

  const PosWalletManagementSheet({
    super.key,
    required this.networkId,
    required this.posId,
    required this.posName,
    this.networkName,
  });

  /// فتح النافذة السفلية المنبثقة
  static Future<void> show(
    BuildContext context, {
    required int networkId,
    required int posId,
    required String posName,
    String? networkName,
  }) {
    final controller = Get.find<PosWalletSheetController>();
    controller.init(
      networkId: networkId,
      posId: posId,
    );

    return CustomBottomSheet.show<void>(
      title: 'محفظة الوكيل التوزيعية المشتركة',
      subtitle: '$posName • الحساب المالي الجاري والائتماني',
      leadingIcon: Icons.account_balance_wallet_rounded,
      scrollable: true,
      child: PosWalletManagementSheet(
        networkId: networkId,
        posId: posId,
        posName: posName,
        networkName: networkName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = Get.find<PosWalletSheetController>();

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final errorMessage = controller.errorMessage.value;
      final wallet = controller.posWallet.value;
      final logs = controller.logs;
      final selectedTab = controller.selectedTab.value;

      if (isLoading) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: const CustomSkeletonFeed(
            itemCount: 3,
            cardHeight: 80,
            shrinkWrap: true,
          ),
        );
      }

      if (errorMessage.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
          child: Column(
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48.r, color: colors.error),
              AppSpacing.vMd,
              Text(
                errorMessage,
                style: AppTypography.bodyMedium
                    .copyWith(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vLg,
              CustomButton.outline(
                text: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                onPressed: () => controller.loadWalletData(),
              ),
            ],
          ),
        );
      }

      if (wallet == null) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Center(
            child: Text(
              'لا توجد بيانات محفظة مسجلة لهذا العقد حالياً.',
              style: AppTypography.bodyMedium
                  .copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط التبديل بين الحساب والتحويل
          CustomSegmentedBar(
            selectedIndex: selectedTab,
            onSegmentChanged: (idx) => controller.selectedTab.value = idx,
            items: const [
              CustomSegmentItem(
                label: 'دفتر الأستاذ والحساب',
                icon: Icons.account_balance_rounded,
              ),
              CustomSegmentItem(
                label: 'التحويل المالي البيني',
                icon: Icons.swap_horizontal_circle_rounded,
              ),
            ],
          ),
          AppSpacing.vLg,

          if (selectedTab == 0) ...[
            // 1. بطاقة المحفظة المالية التنفيذية
            _WalletFinancialCard(
              wallet: wallet,
              posName: posName,
              networkName: networkName,
            ),
            AppSpacing.vLg,

            // 2. ترويسة سجل العمليات
            Row(
              children: [
                Icon(Icons.history_rounded,
                    size: 18.r, color: colors.onSurfaceVariant),
                SizedBox(width: 6.w),
                Text(
                  'سجل دفتر الأستاذ للحركات البينية',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${logs.length} عملية مسجلة',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            AppSpacing.vMd,

            // 3. قائمة سجل الحركات
            if (logs.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Text(
                    'لا توجد حركات مالية مسجلة حتى الآن.',
                    style: AppTypography.bodySmall
                        .copyWith(color: colors.onSurfaceVariant),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (_, __) => AppSpacing.vSm,
                itemBuilder: (context, idx) {
                  final log = logs[idx];
                  return _WalletLogTile(log: log);
                },
              ),
          ] else ...[
            // تبويب التحويل المالي المشترك
            _TransferSection(
              controller: controller,
              wallet: wallet,
              posName: posName,
              networkName: networkName,
            ),
          ],
        ],
      );
    });
  }
}

/// ============================================================================
/// بطاقة المركز المالي لمحفظة نقطة البيع
/// ============================================================================
class _WalletFinancialCard extends StatelessWidget {
  final PosWalletEntity wallet;
  final String posName;
  final String? networkName;

  const _WalletFinancialCard({
    required this.wallet,
    required this.posName,
    this.networkName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // استخراج ألوان الحالة الدلالية بناء على حالة الباكيند الحصرية (لا مقارنات هنا)
    final Color badgeColor;
    final Color badgeBg;
    final IconData badgeIcon;

    if (wallet.isDebtor) {
      badgeColor = colors.error;
      badgeBg = colors.errorContainer.withValues(alpha: 0.35);
      badgeIcon = Icons.trending_down_rounded;
    } else if (wallet.isCreditor) {
      badgeColor = colors.success;
      badgeBg = colors.successContainer.withValues(alpha: 0.35);
      badgeIcon = Icons.trending_up_rounded;
    } else {
      badgeColor = colors.onSurfaceVariant;
      badgeBg = colors.surfaceContainerHighest;
      badgeIcon = Icons.balance_rounded;
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
          width: 1.w,
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // السطر الأول: أطراف المحفظة وشارة الحالة المحاسبية المعتمدة
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      posName,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (networkName != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'مرتبط بشبكة: $networkName',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.5.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.4),
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 13.r, color: badgeColor),
                    SizedBox(width: 4.w),
                    Text(
                      wallet.accountingStatusLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vLg,

          // السطر الأوسط: رصيد المحفظة الإجمالي كقيمة رقمية مباشرة من الخادم
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'رصيد الحساب الجاري:',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${AmountFormatter.format(wallet.walletBalance.toStringAsFixed(2))} ر.ي',
                  style: AppTypography.titleLarge.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vMd,

          // السطر السفلي: تفصيل الرصيد الدائن والمديونية كما يحسبها الباكيند
          Row(
            children: [
              Expanded(
                child: _MetricSubBox(
                  label: 'رصيد دائن متاح',
                  value:
                      '${AmountFormatter.format(wallet.creditAmount.toStringAsFixed(2))} ر.ي',
                  valueColor: colors.success,
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MetricSubBox(
                  label: 'مديونية مستحقة',
                  value:
                      '${AmountFormatter.format(wallet.debitAmount.toStringAsFixed(2))} ر.ي',
                  valueColor: colors.error,
                  icon: Icons.info_outline_rounded,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,

          // معرّف المحفظة العالمي مع النسخ
          CustomInteractiveBounce(
            onTap: () {
              Clipboard.setData(ClipboardData(text: wallet.walletUuid));
              CustomSnackbar.show(
                title: 'تم النسخ',
                message: 'تم نسخ معرّف المحفظة #${wallet.walletUuid} بنجاح.',
                type: SnackType.info,
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copy_rounded,
                      size: 11.r, color: colors.onSurfaceVariant),
                  SizedBox(width: 4.w),
                  Text(
                    'معرّف المحفظة: #${wallet.walletUuid}',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 9.5.sp,
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

/// صندوق إحصائي فرعي
class _MetricSubBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  const _MetricSubBox({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.18),
          width: 0.7.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12.r, color: valueColor),
              SizedBox(width: 4.w),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 9.5.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// عنصر قيد في دفتر الأستاذ
/// ============================================================================
class _WalletLogTile extends StatelessWidget {
  final PosWalletLogEntity log;

  const _WalletLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCredit = log.isCredit;

    final signColor = isCredit ? colors.success : colors.error;
    final signIcon =
        isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final prefix = isCredit ? '+' : '-';

    final dateStr = log.logDate != null
        ? DateFormat('yyyy/MM/dd • HH:mm', 'ar').format(log.logDate!)
        : (log.createdAt != null
            ? DateFormat('yyyy/MM/dd • HH:mm', 'ar').format(log.createdAt!)
            : '—');

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
          width: 0.8.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: signColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(signIcon, size: 16.r, color: signColor),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.logOperationTypeLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (log.logStatement != null &&
                    log.logStatement!.trim().isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    log.logStatement!,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 2.h),
                Text(
                  dateStr,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$prefix${AmountFormatter.format(log.logAmount.toStringAsFixed(2))} ر.ي',
            style: AppTypography.labelLarge.copyWith(
              color: signColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// واجهة إجراء التحويل المالي البيني
/// ============================================================================
class _TransferSection extends StatelessWidget {
  final PosWalletSheetController controller;
  final PosWalletEntity wallet;
  final String posName;
  final String? networkName;

  const _TransferSection({
    required this.controller,
    required this.wallet,
    required this.posName,
    this.networkName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final direction = controller.transferDirection.value;
      final isSubmitting = controller.isSubmittingAction.value;
      final isFeed = direction == 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط تحديد اتجاه التحويل
          CustomSegmentedBar(
            selectedIndex: direction,
            onSegmentChanged: (idx) => controller.transferDirection.value = idx,
            items: const [
              CustomSegmentItem(
                label: 'تغذية للوكيل (من الشبكة)',
                icon: Icons.send_to_mobile_rounded,
              ),
              CustomSegmentItem(
                label: 'توريد للشبكة (من الوكيل)',
                icon: Icons.call_received_rounded,
              ),
            ],
          ),
          AppSpacing.vLg,

          // تلميح توضيحي للعملية
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: AppRadius.mdRadius,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.25),
                width: 0.8.w,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isFeed
                      ? Icons.outbox_rounded
                      : Icons.move_to_inbox_rounded,
                  size: 20.r,
                  color: isFeed ? colors.primary : colors.secondary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    isFeed
                        ? 'سيتم تحويل المبلغ من محفظة الشبكة وإضافته فوراً إلى محفظة الوكيل ($posName).'
                        : 'سيتم خصم المبلغ المورّد من محفظة الوكيل ($posName) وإعادته إلى محفظة الشبكة.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10.5.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vLg,

          // حقل إدخال المبلغ
          CustomTextField(
            controller: controller.amountController,
            label: 'مبلغ التحويل المالي',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(Icons.payments_outlined),
            suffixIcon: Padding(
              padding: EdgeInsetsDirectional.only(end: 12.w, top: 12.h),
              child: Text(
                'ر.ي',
                style: AppTypography.labelMedium.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AppSpacing.vMd,

          // حقل إدخال البيان
          CustomTextField(
            controller: controller.statementController,
            label: 'بيان القيد / ملاحظات العملية',
            hint: isFeed
                ? 'مثال: تغذية رصيد بيع كروت فورية'
                : 'مثال: توريد مبيعات نقدية دورية',
            prefixIcon: const Icon(Icons.notes_rounded),
            isRequired: false,
          ),
          AppSpacing.vXl,

          // زر تنفيذ العملية
          CustomButton.primary(
            text: isFeed ? 'تأكيد تحويل الرصيد للوكيل' : 'تأكيد توريد واسترجاع الرصيد',
            icon: isFeed
                ? Icons.check_circle_outline_rounded
                : Icons.download_done_rounded,
            loading: isSubmitting,
            onPressed: isSubmitting ? null : controller.executeTransfer,
          ),
        ],
      );
    });
  }
}
