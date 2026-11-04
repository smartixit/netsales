import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/share_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/qr/custom_qr_code.dart';

/// بطاقة دعوة ربط نقطة البيع بالشبكة عبر QR القابلة للمشاركة والتصدير
///
/// ويدجت مستقلة مبنية كـ StatelessWidget مدمجة بالكامل مع نظام المشاركة
/// والتصدير الصوري عالي الدقة (ShareService).
class NetworkPosQrShareCard extends StatelessWidget {
  final NetworkPosLinkChallengeEntity challenge;
  final String networkName;
  final String? networkPhone;
  final String? posName;
  final VoidCallback? onRevoke;

  final GlobalKey _cardKey = GlobalKey();

  NetworkPosQrShareCard({
    super.key,
    required this.challenge,
    required this.networkName,
    this.networkPhone,
    this.posName,
    this.onRevoke,
  });

  Future<void> _shareCardImage(BuildContext context) async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        Get.snackbar('تنبيه', 'تعذر التقاط صورة البطاقة');
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Get.snackbar('خطأ', 'فشل تحويل البطاقة إلى صورة');
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final shortId = challenge.challengeUuid.length > 8
          ? challenge.challengeUuid.substring(0, 8)
          : challenge.challengeUuid;

      await ShareService.instance.shareBytes(
        bytes: pngBytes,
        fileName: 'netsales_linking_invite_$shortId.png',
        text: 'دعوة ربط نقطة بيع مع شبكة $networkName عبر منصة NetSales',
      );
    } catch (e) {
      Get.snackbar('خطأ', 'تعذرت مشاركة بطاقة الدعوة: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('yyyy/MM/dd hh:mm a');
    final presentation = EnumPresentationRegistry.resolveLinkingChallengeStatus(
      challenge.status,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // الحاوية الملتقطة كصورة للمشاركة
        RepaintBoundary(
          key: _cardKey,
          child: Container(
            margin: EdgeInsets.all(AppSpacing.md),
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ترويسة البطاقة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.cell_tower_rounded,
                            color: Colors.white,
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              networkName,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (networkPhone != null &&
                                networkPhone!.isNotEmpty)
                              Text(
                                networkPhone!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    CustomStatusBadge.fromPresentation(
                      presentation,
                      isCompact: true,
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.md),
                Divider(color: colors.outlineVariant),
                SizedBox(height: AppSpacing.md),

                // تخصيص لنقطة محددة إن وُجدت
                if (posName != null && posName!.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.store_mall_directory_outlined,
                          size: 16.r,
                          color: colors.secondary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'دعوة مخصصة لنقطة: $posName',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                ],

                // رمز الـ QR الفعلي
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomQrCode(
                    data: challenge.payloadToken,
                    size: 190.r,
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // إرشادات المسح والانتهاء
                Text(
                  'امسح الرمز عبر تطبيق NetSales لإتمام الربط فورياً',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'تنتهي الصلاحية: ${dateFormat.format(challenge.expiresAt)}',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // أزرار التحكم: المشاركة والإلغاء
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'مشاركة كبطاقة دعوة',
                  icon: Icons.share_rounded,
                  variant: AppButtonVariant.primary,
                  onPressed: () => _shareCardImage(context),
                ),
              ),
              if (onRevoke != null && challenge.isPending) ...[
                SizedBox(width: AppSpacing.sm),
                CustomButton.icon(
                  icon: Icons.delete_outline_rounded,
                  backgroundColor: colors.error.withValues(alpha: 0.1),
                  foregroundColor: colors.error,
                  tooltip: 'إلغاء الدعوة',
                  onPressed: onRevoke,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
