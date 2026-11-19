import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_details/invoice_details_party_tile.dart';

/// بطاقة أطراف المعاملة المالية (المزود ونقطة البيع) في شاشة تفاصيل الفاتورة
class InvoiceDetailsPartiesCard extends StatelessWidget {
  const InvoiceDetailsPartiesCard({super.key, required this.invoice});

  final InvoiceEntity invoice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .30),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.handshake_outlined,
                size: 18.r,
                color: colors.primary,
              ),
              AppSpacing.hXs,
              Text(
                'أطراف المعاملة التجارية',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 1. المزود (الشبكة)
          InvoiceDetailsPartyTile(
            roleLabel: 'الطرف المورّد (شبكة التوزيع)',
            name: invoice.displayNetworkName,
            logoUrl: invoice.networkLogoUrl,
            phoneNumber: invoice.networkPhoneNumber,
            address: invoice.networkAddress,
            accentColor: colors.primary,
          ),
          SizedBox(height: 8.h),

          // 2. العميل (نقطة البيع)
          InvoiceDetailsPartyTile(
            roleLabel: 'الطرف المشتري (نقطة البيع المعتمدة)',
            name: invoice.displayPosName,
            logoUrl: invoice.posLogoUrl,
            phoneNumber: invoice.posPhoneNumber,
            address: invoice.posAddress,
            accentColor: colors.secondary,
          ),
        ],
      ),
    );
  }
}
