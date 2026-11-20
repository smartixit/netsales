import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_detail_row.dart';
import 'package:netsales/widgets/cards/custom_card_accordion.dart';

/// أكورديون تفاصيل الشبكة المزودة مستنداً إلى [CustomCardAccordion] الموحد
class PosLinkedNetworkCardAccordion extends StatelessWidget {
  const PosLinkedNetworkCardAccordion({
    super.key,
    required this.link,
    required this.isExpanded,
    required this.onToggle,
  });

  final NetworkPosLinkEntity link;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomCardAccordion(
      title: 'بيانات التواصل والموقع الجغرافي للشبكة',
      count: 4,
      isExpanded: isExpanded,
      onToggle: onToggle,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          children: [
            CommercialDetailRow(
              icon: Icons.support_agent_rounded,
              label: 'هاتف خدمة العملاء',
              value: link.networkPhone,
              onTap: () => UrlLauncherService.callPhone(link.networkPhone),
            ),
            Divider(color: colors.outlineVariant.withValues(alpha: .5), height: 12.h),
            CommercialDetailRow(
              icon: Icons.business_rounded,
              label: 'مسؤول الشبكة',
              value: link.networkOwnerName,
            ),
            Divider(color: colors.outlineVariant.withValues(alpha: .5), height: 12.h),
            CommercialDetailRow(
              icon: Icons.place_outlined,
              label: 'المقر والفرع الرئيسي',
              value: link.networkLocation,
            ),
            Divider(color: colors.outlineVariant.withValues(alpha: .5), height: 12.h),
            CommercialDetailRow(
              icon: Icons.verified_user_outlined,
              label: 'تاريخ بدء التزويد المعتمد',
              value: link.formattedLinkedDate,
            ),
          ],
        ),
      ),
    );
  }
}
