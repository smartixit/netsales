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
import 'package:netsales/features/operations/presentation/widgets/sheets/create_sale_invoice_sheet.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_entity.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/widgets/sheets/reject_partner_sheet.dart';
import 'package:netsales/features/partners/presentation/widgets/sheets/link_partner_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// ورقة الفحص المعمقة لبيانات الشريك (PartnerDetailsSheet)
/// ============================================================================
/// تعرض كافة التفاصيل الإدارية، الجغرافية، والتشغيلية لمزود الشبكة أو نقطة البيع
/// مع توفير إجراءات القرار اللحظي والاتصال والربط، ومطابقة بالكامل لـ AGENTS.md.
class PartnerDetailsSheet extends StatelessWidget {
  final NetworkEntity? network;
  final PosEntity? pos;
  final PartnersController controller;

  const PartnerDetailsSheet({
    super.key,
    this.network,
    this.pos,
    required this.controller,
  }) : assert(network != null || pos != null, 'يجب توفير شبكة أو نقطة بيع');

  static Future<void> show(
    BuildContext context, {
    NetworkEntity? network,
    PosEntity? pos,
    required PartnersController controller,
  }) {
    final title = network != null ? 'تفاصيل مزود الشبكة' : 'تفاصيل نقطة البيع';
    final subtitle = network?.networkName ?? pos?.posName ?? '';
    final icon = network != null
        ? Icons.wifi_tethering_rounded
        : Icons.storefront_rounded;

    return CustomBottomSheet.show<void>(
      title: title,
      subtitle: subtitle,
      leadingIcon: icon,
      scrollable: true,
      child: PartnerDetailsSheet(
        network: network,
        pos: pos,
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PartnerHeaderBadge(network: network, pos: pos),
          AppSpacing.vMd,
          _PartnerMetricsRow(network: network, pos: pos),
          AppSpacing.vMd,
          _PartnerContactSection(network: network, pos: pos),
          AppSpacing.vMd,
          _PartnerMetaSection(network: network, pos: pos),
          AppSpacing.vLg,
          _PartnerActionSection(
            network: network,
            pos: pos,
            controller: controller,
          ),
          AppSpacing.vMd,
        ],
      ),
    );
  }
}

/// ترويسة الشريك الفاخرة مع شارات التعريف والحالة
class _PartnerHeaderBadge extends StatelessWidget {
  final NetworkEntity? network;
  final PosEntity? pos;

  const _PartnerHeaderBadge({this.network, this.pos});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNetwork = network != null;
    final name = isNetwork ? network!.networkName : pos!.posName;
    final isActive = isNetwork ? network!.isActive : pos!.isActive;
    final isPending = isNetwork ? network!.isPending : pos!.isPending;
    final isRejected = isNetwork ? network!.isRejected : pos!.isRejected;
    final statusLabel = isNetwork ? network!.statusLabel : pos!.statusLabel;

    final statusColor = isActive
        ? colors.success
        : (isPending
            ? colors.warning
            : (isRejected ? colors.error : colors.onSurfaceVariant));

    final statusBgColor = isActive
        ? colors.successContainer
        : (isPending
            ? colors.warningContainer
            : (isRejected
                ? colors.errorContainer
                : colors.surfaceContainerHighest));

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 0.8.w,
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: isNetwork
                  ? colors.primary.withValues(alpha: 0.12)
                  : colors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: (isNetwork ? colors.primary : colors.secondary)
                    .withValues(alpha: 0.3),
                width: 1.w,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              isNetwork
                  ? Icons.wifi_tethering_rounded
                  : Icons.storefront_rounded,
              color: isNetwork ? colors.primary : colors.secondary,
              size: 26.r,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vXxs,
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: (isNetwork ? colors.primary : colors.secondary)
                            .withValues(alpha: 0.12),
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Text(
                        isNetwork ? 'مزود شبكة إنترنت' : 'نقطة بيع ووكيل',
                        style: AppTypography.labelSmall.copyWith(
                          color: isNetwork ? colors.primary : colors.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.sp,
                        ),
                      ),
                    ),
                    AppSpacing.hSm,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: AppRadius.fullRadius,
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 0.8.w,
                        ),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط المؤشرات الحيوية السريعة للشريك
class _PartnerMetricsRow extends StatelessWidget {
  final NetworkEntity? network;
  final PosEntity? pos;

  const _PartnerMetricsRow({this.network, this.pos});

  @override
  Widget build(BuildContext context) {
    final isNetwork = network != null;

    return Row(
      children: [
        if (isNetwork) ...[
          Expanded(
            child: _MetricCard(
              title: 'نقاط البيع',
              value: '${network!.posCount ?? 0}',
              icon: Icons.storefront_rounded,
              color: context.colors.primary,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: _MetricCard(
              title: 'باقات الكروت',
              value: '${network!.packagesCount ?? 0}',
              icon: Icons.confirmation_number_rounded,
              color: context.colors.secondary,
            ),
          ),
        ] else ...[
          Expanded(
            child: _MetricCard(
              title: 'الشبكات المرتبطة',
              value: '${pos!.networksCount ?? 0}',
              icon: Icons.hub_rounded,
              color: context.colors.primary,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: _MetricCard(
              title: 'حالة الربط',
              value: pos!.isActive ? 'جاهز للتوزيع' : 'معلق',
              icon: Icons.link_rounded,
              color: pos!.isActive
                  ? context.colors.success
                  : context.colors.warning,
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
          width: 0.8.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.r, color: color),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 9.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// قسم بيانات الاتصال والموقع الجغرافي
class _PartnerContactSection extends StatelessWidget {
  final NetworkEntity? network;
  final PosEntity? pos;

  const _PartnerContactSection({this.network, this.pos});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNetwork = network != null;
    final phone = isNetwork ? network!.networkPhoneNumber : pos!.posPhoneNumber;
    final email = isNetwork ? network!.networkEmail : pos!.posEmail;
    final address = isNetwork ? network!.networkAddress : pos!.posAddress;
    final gov = isNetwork ? network!.governorateName : pos!.governorateName;
    final dir = isNetwork ? network!.directorateName : pos!.directorateName;
    final contactPerson = isNetwork ? network!.ownerName : pos!.agentName;
    final contactPersonPhone =
        isNetwork ? network!.ownerPhone : pos!.agentPhone;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
          width: 0.8.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_mail_outlined,
                size: 16.r,
                color: colors.primary,
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  'بيانات التواصل والموقع الجغرافي',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Divider(
            color: colors.outlineVariant.withValues(alpha: 0.2),
            height: 1.h,
          ),
          AppSpacing.vSm,
          _DetailRow(
            label: 'المحافظة والمديرية',
            value: (gov != null || dir != null)
                ? '${gov ?? ''} • ${dir ?? ''}'
                : 'غير محدد',
            icon: Icons.location_on_outlined,
          ),
          if (address != null && address.isNotEmpty) ...[
            AppSpacing.vXs,
            _DetailRow(
              label: 'العنوان التفصيلي',
              value: address,
              icon: Icons.map_outlined,
            ),
          ],
          if (phone != null && phone.isNotEmpty) ...[
            AppSpacing.vXs,
            _DetailRow(
              label: 'رقم الهاتف الرسمي',
              value: phone,
              icon: Icons.phone_outlined,
              isCopyable: true,
            ),
          ],
          if (email != null && email.isNotEmpty) ...[
            AppSpacing.vXs,
            _DetailRow(
              label: 'البريد الإلكتروني',
              value: email,
              icon: Icons.email_outlined,
              isCopyable: true,
            ),
          ],
          if (contactPerson != null && contactPerson.isNotEmpty) ...[
            AppSpacing.vXs,
            _DetailRow(
              label: isNetwork ? 'اسم المالك' : 'اسم الوكيل / المسؤول',
              value: contactPerson,
              icon: Icons.person_outline_rounded,
            ),
          ],
          if (contactPersonPhone != null &&
              contactPersonPhone.isNotEmpty &&
              contactPersonPhone != phone) ...[
            AppSpacing.vXs,
            _DetailRow(
              label: isNetwork ? 'هاتف المالك' : 'هاتف الوكيل',
              value: contactPersonPhone,
              icon: Icons.phone_android_outlined,
              isCopyable: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// قسم البيانات التوثيقية وسجل التدقيق
class _PartnerMetaSection extends StatelessWidget {
  final NetworkEntity? network;
  final PosEntity? pos;

  const _PartnerMetaSection({this.network, this.pos});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNetwork = network != null;
    final createdAt = isNetwork ? network!.createdAt : pos!.createdAt;
    final approvedAt = isNetwork ? network!.approvedAt : pos!.approvedAt;
    final rejectedAt = isNetwork ? network!.rejectedAt : pos!.rejectedAt;
    final rejectionReason =
        isNetwork ? network!.rejectionReason : pos!.rejectionReason;

    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a');

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
          width: 0.8.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 16.r,
                color: colors.secondary,
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  'سجل التوثيق والاعتماد',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Divider(
            color: colors.outlineVariant.withValues(alpha: 0.2),
            height: 1.h,
          ),
          AppSpacing.vSm,
          if (createdAt != null) ...[
            _DetailRow(
              label: 'تاريخ تقديم الطلب',
              value: dateFormat.format(createdAt),
              icon: Icons.calendar_today_outlined,
            ),
          ],
          if (approvedAt != null) ...[
            AppSpacing.vXs,
            _DetailRow(
              label: 'تاريخ الاعتماد الرسمي',
              value: dateFormat.format(approvedAt),
              icon: Icons.check_circle_outline_rounded,
            ),
          ],
          if (rejectedAt != null) ...[
            AppSpacing.vXs,
            _DetailRow(
              label: 'تاريخ الرفض',
              value: dateFormat.format(rejectedAt),
              icon: Icons.cancel_outlined,
            ),
          ],
          if (rejectionReason != null && rejectionReason.isNotEmpty) ...[
            AppSpacing.vSm,
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.errorContainer.withValues(alpha: 0.4),
                borderRadius: AppRadius.mdRadius,
                border: Border.all(
                  color: colors.error.withValues(alpha: 0.3),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16.r,
                    color: colors.error,
                  ),
                  AppSpacing.hXs,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سبب الرفض:',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.error,
                          ),
                        ),
                        Text(
                          rejectionReason,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// قسم الإجراءات والقرارات التشغيلية
class _PartnerActionSection extends StatelessWidget {
  final NetworkEntity? network;
  final PosEntity? pos;
  final PartnersController controller;

  const _PartnerActionSection({
    this.network,
    this.pos,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = network != null;
    final isPending = isNetwork ? network!.isPending : pos!.isPending;
    final isActive = isNetwork ? network!.isActive : pos!.isActive;

    if (isPending) {
      return Row(
        children: [
          Expanded(
            child: CustomButton.primary(
              text: 'اعتماد الطلب رسمياً',
              icon: Icons.verified_rounded,
              onPressed: () {
                Get.back();
                if (isNetwork) {
                  controller.confirmApproveNetwork(network!);
                } else {
                  controller.confirmApprovePos(pos!);
                }
              },
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: CustomButton.danger(
              text: 'رفض الطلب',
              icon: Icons.cancel_outlined,
              onPressed: () {
                Get.back();
                RejectPartnerSheet.show(
                  context,
                  isNetwork: isNetwork,
                  id: isNetwork ? network!.networkId : pos!.posId,
                  name: isNetwork ? network!.networkName : pos!.posName,
                  controller: controller,
                );
              },
            ),
          ),
        ],
      );
    }

    if (isActive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isNetwork) ...[
            CustomButton.primary(
              text: 'إصدار فاتورة مبيعات كروت',
              icon: Icons.receipt_long_rounded,
              onPressed: () {
                Get.back();
                CreateSaleInvoiceSheet.show(
                  context,
                  preselectedPosId: pos!.posId,
                  preselectedPosName: pos!.posName,
                );
              },
            ),
            AppSpacing.vSm,
          ],
          CustomButton.secondary(
            text: isNetwork ? 'ربط بنقطة بيع جديدة' : 'ربط بمزود شبكة جديد',
            icon: Icons.link_rounded,
            onPressed: () {
              Get.back();
              LinkPartnerSheet.show(
                context,
                controller: controller,
                preselectedNetworkId: isNetwork ? network!.networkId : null,
                preselectedPosUuid: !isNetwork ? pos!.posUuid : null,
              );
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

/// سطر تفصيلي مفرد مع زر النسخ الاختياري
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isCopyable;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isCopyable = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, size: 14.r, color: colors.onSurfaceVariant),
        AppSpacing.hXs,
        Text(
          '$label: ',
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isCopyable) ...[
          AppSpacing.hXs,
          CustomInteractiveBounce(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              CustomSnackbar.show(
                title: 'تم النسخ',
                message: 'تم نسخ "$value" إلى الحافظة بنجاح.',
                type: SnackType.info,
              );
            },
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.copy_rounded,
                size: 13.r,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

