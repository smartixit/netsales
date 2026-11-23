import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/presentation/utils/package_color_resolver.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card_actions.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card_header.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card_micro_pod.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card_quota_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card_spine.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة باقة كروت الإنترنت الرقمية الفاخرة المخصصة للكتالوج (PackageCard)
///
/// تجسد تجربة بصرية مخصصة لمنتجات الاتصالات (Bespoke Product Identity):
/// - شريط جانبي متدرج بهوية لون الباقة [PackageCardSpine].
/// - ترويسة الباقة وشارة الحالة المركزية [PackageCardHeader].
/// - إبراز سعة البيانات الرقمية بخط عملاق [PackageCardQuotaSection].
/// - شبكة مكعبات بينتو المصغرة للمواصفات والربحية [PackageCardMicroPod].
/// - شريط الإجراءات والتحكم السريع [PackageCardActions].
/// - دعم التغذية اللمسية والانضغاط التفاعلي [CustomInteractiveBounce].
class PackageCard extends StatelessWidget {
  const PackageCard({
    super.key,
    required this.package,
    required this.onDetails,
    this.isExpanded = false,
    this.onToggleExpand,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
    this.canEdit = true,
    this.canDelete = true,
  });

  final PackageEntity package;
  final VoidCallback onDetails;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final bool canEdit;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accentColor = PackageColorResolver.resolve(
      package.packageColor,
      colors.primary,
    );

    return CustomInteractiveBounce(
      onTap: onDetails,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. شريط الهوية اللوني للباقة (Color Spine)
              PackageCardSpine(color: accentColor),

              // 2. المحتوى التفاعلي للبطاقة
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // رأس البطاقة: الاسم، المزود، وشارة الحالة
                      PackageCardHeader(package: package),

                      SizedBox(height: AppSpacing.sm),

                      // سعة البيانات والشارة الرقمية
                      PackageCardQuotaSection(
                        package: package,
                        accentColor: accentColor,
                      ),

                      SizedBox(height: AppSpacing.sm),

                      // شبكة مكعبات بينتو المصغرة للمواصفات والربحية
                      Row(
                        children: [
                          Expanded(
                            child: PackageCardMicroPod(
                              icon: Icons.payments_outlined,
                              title: 'تكلفة الكرت',
                              value: AmountFormatter.formatValue(
                                package.unitVoucherPrice,
                              ),
                              accentColor: colors.primary,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: PackageCardMicroPod(
                              icon: Icons.savings_outlined,
                              title: 'وفر الكرت نقداً',
                              value: AmountFormatter.formatValue(
                                package.unitCashPrice,
                              ),
                              badgeText:
                                  '${package.packageDefaultCashDiscount.toStringAsFixed(0)}%',
                              accentColor: colors.success,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: PackageCardMicroPod(
                              icon: Icons.event_available_outlined,
                              title: 'فترة الصلاحية',
                              value: package.validityDisplay,
                              accentColor: colors.purpleAccent,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: PackageCardMicroPod(
                              icon: Icons.timer_outlined,
                              title: 'وقت الاستخدام',
                              value: package.uptimeDisplay,
                              accentColor: colors.amberAccent,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppSpacing.sm),

                      Divider(
                        height: 1,
                        color: colors.outlineVariant.withValues(alpha: 0.35),
                      ),

                      SizedBox(height: AppSpacing.xs),

                      // شريط الإجراءات والتحكم
                      PackageCardActions(
                        package: package,
                        onDetails: onDetails,
                        onEdit: onEdit,
                        onToggleStatus: onToggleStatus,
                        onDelete: onDelete,
                        canEdit: canEdit,
                        canDelete: canDelete,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
