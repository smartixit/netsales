import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_pos_discount_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';

class PackagePosDiscountCard extends StatelessWidget {
  const PackagePosDiscountCard({super.key,required this.agreement});
  final PackagePosDiscountEntity agreement;
  String _price(double? value)=>value==null?'غير متاح':'${AmountFormatter.formatValue(value)} ر.ي';
  @override
  Widget build(BuildContext context) {
    final colors=context.colors;
    final validityPresentation =
        EnumPresentationRegistry.resolvePackageDiscountValidityState(
      agreement.validityState,
    );
    final activationPresentation =
        EnumPresentationRegistry.resolvePackageDiscountActivationStatus(
      agreement.activationStatus,
    );
    return Container(
      padding:EdgeInsets.all(AppSpacing.md),
      decoration:BoxDecoration(
        color:colors.surfaceContainerHighest.withValues(alpha:.28),
        borderRadius:AppRadius.lgRadius,
        border:Border.all(color:colors.outlineVariant.withValues(alpha:.45)),
      ),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Row(children:[
          Container(width:42.r,height:42.r,decoration:BoxDecoration(
            color:colors.primary.withValues(alpha:.1),borderRadius:AppRadius.mdRadius,
          ),child:Icon(Icons.storefront_outlined,color:colors.primary)),
          AppSpacing.hSm,
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(agreement.posName?.trim().isNotEmpty==true?agreement.posName!:'نقطة بيع #${agreement.posId}',
              style:AppTypography.titleSmall.copyWith(fontWeight:FontWeight.bold,color:colors.onSurface)),
            Text('معرّف نقطة البيع: ${agreement.posId}',style:AppTypography.labelSmall.copyWith(color:colors.onSurfaceVariant)),
          ])),
          Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
            CustomStatusBadge.fromPresentation(validityPresentation,isCompact:true),
            AppSpacing.vXxs,
            CustomStatusBadge.fromPresentation(
              activationPresentation,isCompact:true,
            ),
          ]),
        ]),
        AppSpacing.vMd,
        Row(children:[
          Expanded(child:_pricePanel(context,'خصم نقدي','${AmountFormatter.formatValue(agreement.discountCash,decimalPlaces:0)}%',_price(agreement.cashPrice),colors.success)),
          AppSpacing.hSm,
          Expanded(child:_pricePanel(context,'خصم آجل','${AmountFormatter.formatValue(agreement.discountCredit,decimalPlaces:0)}%',_price(agreement.creditPrice),colors.info)),
        ]),
        AppSpacing.vMd,
        Wrap(spacing:AppSpacing.lg,runSpacing:AppSpacing.sm,children:[
          _date(context,Icons.event_available_outlined,'بداية السريان',agreement.startDate),
          _date(context,Icons.event_busy_outlined,'نهاية السريان',agreement.endDate),
        ]),
      ]),
    );
  }
  Widget _pricePanel(BuildContext context,String title,String discount,String price,Color accent) {
    final colors=context.colors;
    return Container(padding:EdgeInsets.all(AppSpacing.sm),decoration:BoxDecoration(
      color:colors.surface.withValues(alpha:.8),borderRadius:AppRadius.mdRadius,
    ),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(title,style:AppTypography.labelSmall.copyWith(color:colors.onSurfaceVariant)),
      Text(discount,style:AppTypography.titleMedium.copyWith(color:accent,fontWeight:FontWeight.bold)),
      Text('السعر المعتمد: $price',maxLines:2,overflow:TextOverflow.ellipsis,
        style:AppTypography.labelSmall.copyWith(color:colors.onSurface,fontWeight:FontWeight.w700)),
    ]));
  }
  Widget _date(BuildContext context,IconData icon,String title,DateTime? value) {
    final colors=context.colors;
    return Row(mainAxisSize:MainAxisSize.min,children:[
      Icon(icon,size:15.r,color:colors.onSurfaceVariant),AppSpacing.hXs,
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(title,style:AppTypography.labelSmall.copyWith(color:colors.onSurfaceVariant)),
        Text(value==null?'غير محدد':DateFormatter.longDate(value),
          style:AppTypography.labelMedium.copyWith(color:colors.onSurface,fontWeight:FontWeight.w600)),
      ]),
    ]);
  }
}
