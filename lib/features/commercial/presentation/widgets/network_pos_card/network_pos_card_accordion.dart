import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_detail_row.dart';
import 'package:netsales/widgets/cards/custom_card_accordion.dart';

/// أكورديون تفاصيل نقطة البيع المرتبطة مستنداً إلى [CustomCardAccordion] الموحد
class NetworkPosCardAccordion extends StatelessWidget {
  const NetworkPosCardAccordion({
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
      title: 'بيانات الاتصال والموقع الجغرافي',
      itemCount: 4,
      isExpanded: isExpanded,
      onToggle: onToggle,
      expandedContent: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          children: [
            CommercialDetailRow(
              icon: Icons.phone_android_rounded,
              label: 'رقم الهاتف',
              value: link.posPhone,
              onTap: () => UrlLauncherService.openDialer(link.posPhone),
            ),
            Divider(color: colors.outlineVariant.withValues(alpha: .5), height: 12.h),
            CommercialDetailRow(
              icon: Icons.person_outline_rounded,
              label: 'المسؤول / المالك',
              value: link.posOwnerName,
            ),
            Divider(color: colors.outlineVariant.withValues(alpha: .5), height: 12.h),
            CommercialDetailRow(
              icon: Icons.place_outlined,
              label: 'الموقع / العنوان',
              value: link.posLocation,
            ),
            Divider(color: colors.outlineVariant.withValues(alpha: .5), height: 12.h),
            CommercialDetailRow(
              icon: Icons.calendar_today_rounded,
              label: 'تاريخ الارتباط التجاري',
              value: link.formattedLinkedDate,
            ),
          ],
        ),
      ),
    );
  }
}
