import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_details_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_pos_discount_card.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_voucher_card_showcase.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/containers/custom_section_container.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';

class PackageDetailsContent extends StatelessWidget {
  const PackageDetailsContent({super.key, required this.package, required this.controller});
  final PackageEntity package;
  final PackageDetailsController controller;

  Widget _information(BuildContext context) {
    final colors=context.colors;
    final data=< (IconData,String,String)>[
      (Icons.hub_outlined,'الشبكة',package.networkName?.trim().isNotEmpty == true ? package.networkName! : 'غير متاح'),
      (Icons.tag_rounded,'معرّف الباقة',package.packageId.toString()),
      (Icons.calendar_today_outlined,'تاريخ إنشاء الباقة',package.createdAt == null ? 'غير محدد' : DateFormatter.fullDate(package.createdAt!)),
      (Icons.update_rounded,'آخر تحديث للسجل',package.updatedAt == null ? 'غير محدد' : DateFormatter.fullDate(package.updatedAt!)),
    ];
    return CustomSectionContainer(
      icon: Icons.info_outline_rounded, title: 'بيانات تعريف الباقة',
      child: LayoutBuilder(builder:(context,c) {
        final width=(c.maxWidth-AppSpacing.sm)/2;
        return Wrap(spacing:AppSpacing.sm,runSpacing:AppSpacing.sm,children:[
          for(final item in data) SizedBox(width:width,child:Container(
            constraints:BoxConstraints(minHeight:76.h),
            padding:EdgeInsets.all(AppSpacing.md),
            decoration:BoxDecoration(
              color:colors.surfaceContainerHighest.withValues(alpha:.35),
              borderRadius:BorderRadius.circular(12),
              border:Border.all(color:colors.outlineVariant.withValues(alpha:.4)),
            ),
            child:Row(children:[
              Icon(item.$1,color:colors.primary,size:19.r),
              AppSpacing.hSm,
              Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(item.$2,style:AppTypography.labelSmall.copyWith(color:colors.onSurfaceVariant)),
                AppSpacing.vXxs,
                Text(item.$3,maxLines:2,overflow:TextOverflow.ellipsis,style:AppTypography.titleSmall.copyWith(color:colors.onSurface,fontWeight:FontWeight.bold)),
              ])),
            ]),
          )),
        ]);
      }),
    );
  }

  Widget _agreements() => CustomSectionContainer(
    icon:Icons.handshake_outlined,title:'اتفاقيات الخصم الخاصة بنقاط البيع',
    child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      CustomTextField(
        controller:controller.posDiscountSearchController,label:'البحث عن نقطة بيع',
        hint:'اكتب اسم نقطة البيع...',isRequired:false,
        prefixIcon:const Icon(Icons.search_rounded),
        onChanged:controller.onPosDiscountSearchChanged,
      ),
      AppSpacing.vMd,
      Obx(() {
        final items=controller.posDiscounts.toList(growable:false);
        if(controller.isLoadingPosDiscounts.value && items.isEmpty) {
          return CustomStateView.loading(
            presentation:CustomStatePresentation.skeletonOnly,
            skeleton:CustomStateSkeleton(layout:CustomStateSkeletonLayout.list,itemCount:3,cardHeight:145.h,lineCount:3),
          );
        }
        if(controller.posDiscountsError.value != null && items.isEmpty) {
          return CustomErrorState.boxed(
            title:'تعذر تحميل اتفاقيات الخصم',
            subtitle:controller.posDiscountsError.value,
            onRetry:()=>controller.fetchPosDiscounts(refresh:true),
          );
        }
        if(items.isEmpty) {
          return const CustomEmptyState.boxed(
            icon:Icons.storefront_outlined,title:'لا توجد اتفاقيات خصم',
            subtitle:'لا توجد نقاط بيع مرتبطة بخصم خاص لهذه الباقة.',
          );
        }
        return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          for(var i=0;i<items.length;i++) ...[
            if(i>0) AppSpacing.vSm,
            PackagePosDiscountCard(agreement:items[i]),
          ],
          if(controller.isLoadingMorePosDiscounts.value)
            const CustomStateView.loading(
              presentation:CustomStatePresentation.skeletonOnly,
              skeleton:CustomStateSkeleton(layout:CustomStateSkeletonLayout.list,itemCount:1,cardHeight:64,lineCount:2,showCardSurface:false,hasLeading:false),
            )
          else if(controller.posDiscountsError.value != null)
            CustomErrorState.compact(
              title:'تعذر تحميل بقية الاتفاقيات',
              subtitle:controller.posDiscountsError.value!,
              onRetry:controller.loadMorePosDiscounts,
            )
          else if(controller.hasMorePosDiscounts)
            CustomButton.secondary(
              text:'تحميل المزيد',icon:Icons.expand_more_rounded,
              onPressed:controller.loadMorePosDiscounts,
            ),
        ]);
      }),
    ]),
  );

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding:EdgeInsets.all(AppSpacing.cardPadding),
    child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      PackageVoucherCardShowcase(package:package),
      AppSpacing.vLg,
      Obx(()=>CustomSegmentedBar(
        selectedIndex:controller.selectedDetailsTab.value,
        onSegmentChanged:controller.changeDetailsTab,
        items:const[
          CustomSegmentItem(label:'المعلومات',icon:Icons.info_outline_rounded),
          CustomSegmentItem(label:'اتفاقيات نقاط البيع',icon:Icons.handshake_outlined),
        ],
      )),
      AppSpacing.vMd,
      Obx(()=>controller.selectedDetailsTab.value==0
          ? _information(context) : _agreements()),
      AppSpacing.vXl,
    ]),
  );
}
