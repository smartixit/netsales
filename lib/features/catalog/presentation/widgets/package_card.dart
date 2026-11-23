import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/utils/color_resolver.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card_actions.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card_header.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card_pricing_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card_quota_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_ticket_notch_divider.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة باقة كروت الإنترنت التنفيذية الفاخرة (Executive Voucher Package Pass)
///
/// تجسد هوية القسيمة الشبكية الرقمية المشرقة (Light Mode Digital Telecom Pass):
/// - هيكل تذكرة ناصع متماسك بدون رص صناديق عشوائية.
/// - ترويسة شبكية رشيقة مع قائمة خيارات إدارية مدمجة.
/// - سعة رصيد بطلة تبرز هوية الباقة الأساسية.
/// - خط تخريم تذكرة (Ticket Notch Perforation) فاصل.
/// - لوحة تسعير وهوامش ناصعة ومقروءة للمقارنة بين الشراء النقدي والآجل.
/// - زر تفاعلي ناعم وتجربة لمسية مرنة.
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
    this.actions,
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
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accentColor = ColorResolver.resolve(
      package.packageColor,
      colors.primary,
    );

    return CustomInteractiveBounce(
      onTap: onDetails,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            ...AppElevation.level1(context),
            BoxShadow(
              color: accentColor.withValues(alpha: 0.05),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // الشريحة اللونية الجانبية الفاخرة (Color Spine)
                Container(
                  width: 5.w,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AppRadius.card),
                      bottomRight: Radius.circular(AppRadius.card),
                    ),
                  ),
                ),

                // المحتوى الداخلي لقسيمة الباقة
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. الترويسة وهوية الباقة وخيارات الإدارة
                        PackageCardHeader(
                          package: package,
                          accentColor: accentColor,
                          onEdit: onEdit,
                          onToggleStatus: onToggleStatus,
                          onDelete: onDelete,
                          canEdit: canEdit,
                          canDelete: canDelete,
                        ),

                        SizedBox(height: AppSpacing.xs),

                        // 2. سعة رصيد البيانات ومواصفات الحزمة
                        PackageCardQuotaSection(
                          package: package,
                          accentColor: accentColor,
                        ),

                        // 3. خط التخريم الفاصل للقسيمة الرقمية
                        const PackageTicketNotchDivider(),

                        // 4. لوحة التسعير وهوامش الربح
                        PackageCardPricingSection(package: package),

                        SizedBox(height: AppSpacing.sm),

                        // 5. زر تفاصيل الباقة
                        actions ??
                            PackageCardActions(
                              package: package,
                              onDetails: onDetails,
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
