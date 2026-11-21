import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card_actions.dart';
import 'package:netsales/widgets/cards/custom_executive_transaction_card.dart';

/// بطاقة باقة كروت الإنترنت بنظام الأكورديون القيادي (Package Card - Executive Edition)
///
/// تلتزم بالمعايير المؤسسية والنظام البصري الموحد:
/// - استهلاك المكون القيادي الموحد [CustomExecutiveTransactionCard] بحواف 24.r وظلال مزدوجة.
/// - تفويض حالة الباقة حصرياً للسجل المركزي [EnumPresentationRegistry].
/// - تفويض تنسيق المبالغ المالية حصرياً لـ [AmountFormatter.formatValue].
/// - أكورديون تفاعلي يعرض المواصفات الفنية المعتمدة للكرت.
/// - شريط إجراءات ذكي يلتزم بصلاحيات المستخدم في مساحة عمل الشبكة.
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
    this.actions,
  });

  final PackageEntity package;
  final VoidCallback onDetails;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // استهلاك السجل المركزي الموحد للحالات عبر الـ Enum المعتمد
    final statusPresentation = EnumPresentationRegistry.resolvePackageStatus(
      package.packageStatus,
    );

    final dateLabel = package.createdAt != null
        ? DateFormatter.fullDate(package.createdAt!)
        : '';

    // بنود التعرفة والخصومات المدمجة داخل أكورديون البطاقة
    final items = <ExecutiveCardItemData>[
      ExecutiveCardItemData(
        title: 'السعر الفعلي نقداً',
        subtitle:
            'بعد الخصم النقدي (${package.packageDefaultCashDiscount.toStringAsFixed(0)}%) - ${package.packageVoucherCount} كرت',
        colorHex: package.packageColor,
        totalAmount: package.effectiveCashPrice,
        discountAmount: package.cashDiscountAmount,
        badgeText: 'نقداً',
      ),
      ExecutiveCardItemData(
        title: 'السعر الفعلي آجلاً',
        subtitle:
            'بعد الخصم الآجل (${package.packageDefaultCreditDiscount.toStringAsFixed(0)}%) - ${package.packageVoucherCount} كرت',
        colorHex: package.packageColor,
        totalAmount: package.effectiveCreditPrice,
        discountAmount: package.creditDiscountAmount,
        badgeText: 'آجلاً',
      ),
    ];

    final specTags = <String>[
      '${package.packageVoucherCount} كرت',
      if (package.packageBalance > 0)
        PackageSpecFormatter.formatData(package.packageBalance),
      if (package.packageUptime != null && package.packageUptime! > 0)
        PackageSpecFormatter.formatDuration(package.packageUptime!),
      if (package.packageValidity != null && package.packageValidity! > 0)
        PackageSpecFormatter.formatDuration(package.packageValidity!),
    ];

    return CustomExecutiveTransactionCard(
      reference: 'باقة #${package.packageId}',
      dateLabel: dateLabel,
      partyName: package.packageName,
      statusPresentation: statusPresentation,
      typePresentation: null,
      secondaryReference: package.networkName != null
          ? 'شبكة ${package.networkName}'
          : null,
      items: items,
      itemsHeaderTitle: 'التعرفة والخصومات التعاقدية',
      visibleItemNames: specTags,
      metrics: [
        ExecutiveCardMetricData(
          label: 'السعر الأساسي',
          value: AmountFormatter.formatValue(package.packageVoucherPrice),
          isEmphasized: true,
          textColor: colors.primary,
        ),
        ExecutiveCardMetricData(
          label: 'الخصم النقدي',
          value: '${package.packageDefaultCashDiscount.toStringAsFixed(0)}%',
          textColor: colors.success,
        ),
        ExecutiveCardMetricData(
          label: 'الخصم الآجل',
          value: '${package.packageDefaultCreditDiscount.toStringAsFixed(0)}%',
          textColor: colors.secondary,
        ),
      ],
      actions:
          actions ??
          PackageCardActions(
            package: package,
            onDetails: onDetails,
            onEdit: onEdit,
            onToggleStatus: onToggleStatus,
            onDelete: onDelete,
          ),
      onTap: onDetails,
      isExpanded: isExpanded,
      onToggleExpand: onToggleExpand,
    );
  }
}
