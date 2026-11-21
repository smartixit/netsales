import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/qr_code_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_invitation_share_card.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/qr/custom_qr_code.dart';

/// عرض دعوة الربط؛ دورة الحياة والتحديث والتصدير مملوكة لمتحكم GetX.
class NetworkPosQrInvitationSheet extends StatelessWidget {
  const NetworkPosQrInvitationSheet({
    super.key,
    required this.controller,
    required this.challenge,
    required this.networkName,
    required this.posName,
  });

  final NetworkCommercialDirectoryController controller;
  final NetworkPosLinkChallengeEntity challenge;
  final String networkName;
  final String posName;

  Future<Uint8List> _captureShareCard(BuildContext context) async {
    await precacheImage(
      const AssetImage('assets/images/brand_icon.png'),
      context,
    );
    await WidgetsBinding.instance.endOfFrame;
    final renderObject =
        controller.invitationShareCardKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw const AppException('تعذر تجهيز بطاقة الدعوة للتصدير.');
    }

    final image = await renderObject.toImage(pixelRatio: 1);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw const AppException('تعذر تحويل بطاقة الدعوة إلى صورة.');
      }
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      if (bytes.isEmpty) {
        throw const AppException('الصورة الناتجة لبطاقة الدعوة فارغة.');
      }
      return bytes;
    } finally {
      image.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.hub_rounded, color: colors.primary, size: 26.r),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الجهة المرتبطة بالدعوة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'الشبكة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        networkName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'نقطة البيع المستهدفة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        posName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded, color: colors.primary),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: colors.primary.withValues(alpha: .2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: CustomQrCode(
                data: challenge.payload,
                size: 224.r,
                decoration: QrCodeService.brandDecoration,
                semanticsLabel: 'رمز دعوة ربط تجارية',
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Obx(() {
            final status = controller.invitationStatus.value;
            final presentation =
                EnumPresentationRegistry.resolveLinkingChallengeStatus(status);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomStatusBadge(
                  label: presentation.label,
                  tone: presentation.tone,
                  icon: presentation.icon,
                ),
                SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    controller.invitationRemainingLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: AppSpacing.xs),
          Obx(
            () => Text(
              'ينتهي في: ${controller.invitationExpiresAtLabel}',
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Obx(() {
            final error = controller.invitationStatusRefreshError.value;
            if (error == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            );
          }),
          SizedBox(height: AppSpacing.sm),
          Text(
            'اطلب من نقطة البيع فتح ماسح QR داخل تطبيق NetSales ومسح الرمز لإتمام الربط.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Obx(() {
            final isActive = controller.isInvitationActive;
            final isExporting = controller.isExportingInvitation.value;
            return Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: 'مشاركة البطاقة',
                    icon: Icons.share_rounded,
                    size: AppButtonSize.medium,
                    loading: isExporting,
                    onPressed: isActive && !isExporting
                        ? () => controller.shareInvitation(
                            () => _captureShareCard(context),
                          )
                        : null,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: CustomButton.outline(
                    text: 'حفظ الصورة',
                    icon: Icons.download_rounded,
                    size: AppButtonSize.medium,
                    loading: isExporting,
                    onPressed: isActive && !isExporting
                        ? () => controller.saveInvitation(
                            () => _captureShareCard(context),
                          )
                        : null,
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: AppSpacing.sm),
          Obx(() {
            if (controller.isInvitationActive) {
              return CustomButton.outline(
                text: 'إلغاء الدعوة',
                icon: Icons.block_rounded,
                size: AppButtonSize.medium,
                onPressed: controller.revokeActiveInvitation,
              );
            }
            return Text(
              controller.invitationStatus.value.name == 'consumed'
                  ? 'تم استخدام الدعوة وإتمام الارتباط.'
                  : 'هذه الدعوة لم تعد صالحة للمشاركة أو الحفظ.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            );
          }),
          SizedBox(height: AppSpacing.md),
          Obx(
            () => Transform.translate(
              offset: const Offset(-2000, 0),
              child: UnconstrainedBox(
                alignment: Alignment.topLeft,
                child: RepaintBoundary(
                  key: controller.invitationShareCardKey,
                  child: CommercialInvitationShareCard(
                    payload: challenge.payload,
                    networkName: networkName,
                    posName: posName,
                    expiresAtLabel: controller.invitationExpiresAtLabel,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
