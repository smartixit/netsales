import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_pos_lifecycle_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/feedback/skeletons/custom_state_skeleton.dart';
import 'package:netsales/widgets/feedback/skeletons/custom_state_skeleton_view.dart';

class NetworkPosLifecycleScreen extends GetView<NetworkPosLifecycleController> {
  const NetworkPosLifecycleScreen({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[];
    final views = <Widget>[];
    if (controller.canViewAgreements) {
      tabs.add(const Tab(icon: Icon(Icons.description_outlined), text: 'الاتفاقيات'));
      views.add(_agreementsTab());
    }
    if (controller.canViewEvents) {
      tabs.add(const Tab(icon: Icon(Icons.history_rounded), text: 'سجل الأحداث'));
      views.add(_eventsTab());
    }
    if (controller.canViewCatalog) {
      tabs.add(const Tab(icon: Icon(Icons.inventory_2_outlined), text: 'الكتالوج والخصومات'));
      views.add(_catalogTab());
    }
    if (controller.canViewArchive) {
      tabs.add(const Tab(icon: Icon(Icons.archive_outlined), text: 'الأرشيف'));
      views.add(_archiveTab());
    }

    return DefaultTabController(
      length: tabs.length,
      child: CustomAppScaffold(
        appBarTitle: 'دورة حياة العلاقة التجارية',
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CustomPageHeroCard(
                title: 'إدارة العلاقة #${controller.networkPosId}',
                subtitle: controller.relationship == null
                    ? 'الاتفاقيات التجارية وسجل الأحداث والقرارات المرتبطة بالعلاقة.'
                    : '${controller.relationship!.displayNetworkName}  ↔  ${controller.relationship!.displayPosName}',
                icon: Icons.hub_rounded,
              ),
            ),
            if (controller.relationship != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: CustomSurfaceCard(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('بيانات العلاقة', style: const TextStyle(fontWeight: FontWeight.w700))),
                          CustomStatusBadge(
                            label: controller.relationship!.isActive ? 'نشطة' : 'معطّلة',
                            tone: controller.relationship!.isActive ? SemanticTone.success : SemanticTone.neutral,
                            isCompact: true,
                          ),
                        ],
                      ),
                      AppSpacing.vXs,
                      Text('الشبكة: ${controller.relationship!.displayNetworkName}'),
                      Text('نقطة البيع: ${controller.relationship!.displayPosName}'),
                      Text('تاريخ الربط: ${controller.relationship!.formattedLinkedDate}'),
                      if (controller.canViewRelationshipWallet) ...[
                        AppSpacing.vSm,
                        CustomButton.secondary(
                          text: 'دفتر أستاذ العلاقة والالتزامات المالية',
                          prefix: Icons.account_balance_wallet_outlined,
                          onPressed: () => Get.toNamed<void>(
                            AppRoutes.posWalletStatement,
                            arguments: {
                              'network_id': controller.networkId,
                              'pos_id': controller.posId,
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            if (tabs.isNotEmpty) TabBar(tabs: tabs),
            Expanded(
              child: tabs.isEmpty
                  ? const CustomEmptyState.compact(
                      title: 'لا تتوفر صلاحية العرض',
                      subtitle: 'لا تملك صلاحية لعرض بيانات دورة حياة هذه العلاقة.',
                      icon: Icons.lock_outline_rounded,
                    )
                  : TabBarView(children: views),
            ),
          ],
        ),
      ),
    );
  }

  Widget _agreementsTab() {
    return Obx(() {
      if (controller.isLoadingAgreements.value && controller.agreements.isEmpty) {
        return const CustomStateView.loading();
      }
      if (controller.errorMessage.value != null && controller.agreements.isEmpty) {
        return CustomErrorState(
          title: 'تعذر تحميل الاتفاقيات',
          subtitle: controller.errorMessage.value,
          onRetry: () => controller.loadAgreements(refresh: true),
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.loadAgreements(refresh: true),
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            if (controller.canManageAgreements) CustomButton.primary(
              text: 'إنشاء مسودة اتفاقية',
              prefix: Icons.add_rounded,
              onPressed: controller.isSaving.value ? null : controller.openDraftEditor,
            ),
            AppSpacing.vMd,
            if (controller.agreements.isEmpty)
              const CustomEmptyState(
                title: 'لا توجد اتفاقيات بعد',
                subtitle: 'أنشئ مسودة الاتفاقية الأولى لتوثيق الشروط التجارية بين الشبكة ونقطة البيع.',
                icon: Icons.description_outlined,
              ),
            ...controller.agreements.map(_agreementCard),
            if (controller.isLoadingMoreAgreements.value)
              const CustomStateSkeletonView(
                recipe: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.list,
                  itemCount: 2,
                  cardHeight: 92,
                ),
              )
            else if (controller.hasMoreAgreements)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: CustomButton.secondary(
                  text: 'تحميل المزيد',
                  onPressed: controller.loadMoreAgreements,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _agreementCard(NetworkPosAgreementEntity agreement) {
    final statusLabel = agreement.validityState == 'EXPIRED' ? 'منتهية الصلاحية' : switch (agreement.status) {
      'DRAFT' => 'مسودة',
      'ACTIVE' => 'نشطة',
      'TERMINATED' => 'منتهية',
      'EXPIRED' => 'منتهية الصلاحية',
      _ => agreement.status,
    };
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: CustomSurfaceCard(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    agreement.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                Text('الإصدار ${agreement.version}'),
              ],
            ),
            AppSpacing.vSm,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CustomStatusBadge(
                  label: statusLabel,
                  tone: agreement.validityState == 'EXPIRED' || agreement.status == 'TERMINATED'
                      ? SemanticTone.danger
                      : agreement.status == 'ACTIVE'
                          ? SemanticTone.success
                          : SemanticTone.warning,
                  isCompact: true,
                ),
                if (agreement.reference?.isNotEmpty == true)
                  Text('المرجع: ${agreement.reference}'),
              ],
            ),
            AppSpacing.vSm,
            Text(
              agreement.terms,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (agreement.startsAt != null || agreement.endsAt != null) ...[
              AppSpacing.vSm,
              Text('السريان: ${agreement.startsAt ?? 'مفتوح'} — ${agreement.endsAt ?? 'مفتوح'}'),
            ],
            if (agreement.isDraft && controller.canManageAgreements) ...[
              AppSpacing.vMd,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  CustomButton.secondary(
                    text: 'تعديل المسودة',
                    prefix: Icons.edit_outlined,
                    onPressed: () => controller.openDraftEditor(agreement: agreement),
                  ),
                  CustomButton.primary(
                    text: 'اعتماد',
                    prefix: Icons.verified_outlined,
                    onPressed: () => controller.activate(agreement),
                  ),
                ],
              ),
            ] else if (agreement.isActive && controller.canManageAgreements) ...[
              AppSpacing.vMd,
              CustomButton.secondary(
                text: 'إنهاء الاتفاقية',
                prefix: Icons.stop_circle_outlined,
                onPressed: () => controller.terminate(agreement),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _eventsTab() {
    return Obx(() {
      if (controller.isLoadingEvents.value && controller.events.isEmpty) {
        return const CustomStateView.loading();
      }
      if (controller.eventsErrorMessage.value != null && controller.events.isEmpty) {
        return CustomErrorState(
          title: 'تعذر تحميل سجل الأحداث',
          subtitle: controller.eventsErrorMessage.value,
          onRetry: () => controller.loadEvents(refresh: true),
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.loadEvents(refresh: true),
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            if (controller.events.isEmpty)
              const CustomEmptyState(
                title: 'لا توجد أحداث مسجلة',
                subtitle: 'ستظهر هنا عمليات الإنشاء والتفعيل والأرشفة والاستعادة وتغييرات الاتفاقيات.',
                icon: Icons.history_rounded,
              ),
            ...controller.events.map((event) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: CustomSurfaceCard(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.timeline_rounded),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_eventLabel(event.eventType), style: const TextStyle(fontWeight: FontWeight.w700)),
                          if (event.actorName != null) Text('بواسطة: ${event.actorName}'),
                          Text(event.createdAt),
                          if (event.payload.isNotEmpty)
                            Text(event.payload.entries.map((entry) => '${entry.key}: ${entry.value}').join(' • ')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
            if (controller.isLoadingMoreEvents.value)
              const CustomStateSkeletonView(
                recipe: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.list,
                  itemCount: 2,
                  cardHeight: 76,
                ),
              )
            else if (controller.hasMoreEvents)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: CustomButton.secondary(
                  text: 'تحميل المزيد',
                  onPressed: controller.loadMoreEvents,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _catalogTab() {
    return Obx(() => ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        if (controller.canViewPackageCatalog) ...[
          Text(
            'كتالوج الشبكة المتاح',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          AppSpacing.vSm,
          if (controller.isLoadingPackages.value && controller.packages.isEmpty)
            const CustomStateSkeletonView(
              recipe: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 3,
                cardHeight: 108,
              ),
            ),
          if (controller.packagesErrorMessage.value != null && controller.packages.isEmpty)
            CustomErrorState(
              title: 'تعذر تحميل كتالوج الشبكة',
              subtitle: controller.packagesErrorMessage.value,
              onRetry: controller.loadPackages,
            ),
          if (!controller.isLoadingPackages.value && controller.packages.isEmpty && controller.packagesErrorMessage.value == null)
            const CustomEmptyState.compact(
              title: 'لا توجد باقات متاحة',
              subtitle: 'لا توجد باقات نشطة في كتالوج الشبكة حالياً.',
              icon: Icons.inventory_2_outlined,
            ),
          ...controller.packages.map((package) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: CustomSurfaceCard(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(package.packageName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      CustomStatusBadge(
                        label: package.isActive ? 'متاحة' : 'غير متاحة',
                        tone: package.isActive ? SemanticTone.success : SemanticTone.neutral,
                        isCompact: true,
                      ),
                    ],
                  ),
                  AppSpacing.vXs,
                  Text('الباقة #${package.packageId} • عدد الكروت: ${package.packageVoucherCount}'),
                  Text('السعر الأساسي للكرت: ${AmountFormatter.formatValue(package.packageVoucherPrice)} ر.ي'),
                  AppSpacing.vSm,
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Text('خصم الشبكة نقداً: ${AmountFormatter.formatValue(package.packageDefaultCashDiscount)}%'),
                      Text('خصم الشبكة آجلاً: ${AmountFormatter.formatValue(package.packageDefaultCreditDiscount)}%'),
                    ],
                  ),
                  AppSpacing.vXs,
                  Text('السعر المرجعي نقداً: ${AmountFormatter.formatValue(package.effectiveCashPrice)} ر.ي'),
                  Text('السعر المرجعي آجلاً: ${AmountFormatter.formatValue(package.effectiveCreditPrice)} ر.ي'),
                ],
              ),
            ),
          )),
          if (controller.isLoadingMorePackages.value)
            const CustomStateSkeletonView(
              recipe: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 2,
                cardHeight: 108,
              ),
            )
          else if (controller.hasMorePackages)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: CustomButton.secondary(
                text: 'تحميل المزيد من الباقات',
                onPressed: controller.loadMorePackages,
              ),
            ),
        ],
        if (controller.canViewDiscounts) ...[
          AppSpacing.vLg,
          Text(
            'الخصومات المخصصة لهذه العلاقة',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          AppSpacing.vSm,
          if (controller.discountsErrorMessage.value != null && controller.packageDiscounts.isEmpty)
            CustomErrorState(
              title: 'تعذر تحميل خصومات العلاقة',
              subtitle: controller.discountsErrorMessage.value,
              onRetry: () => controller.loadPackageDiscounts(refresh: true),
            ),
          if (controller.canCreateDiscount)
            CustomButton.primary(
              text: 'تخصيص خصم لباقة',
              prefix: Icons.add_rounded,
              onPressed: controller.isSavingDiscount.value ||
                      controller.isLoadingPackages.value ||
                      controller.packages.isEmpty
                  ? null
                  : controller.openDiscountEditor,
            ),
          if (controller.packageDiscounts.isEmpty && controller.discountsErrorMessage.value == null)
            const CustomEmptyState.compact(
              title: 'لا توجد خصومات مخصصة',
              subtitle: 'يمكن إنشاء خصم خاص لهذه العلاقة دون تغيير أسعار الباقة العامة أو خصومات العلاقات الأخرى.',
              icon: Icons.local_offer_outlined,
            ),
          ...controller.packageDiscounts.map((discount) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: CustomSurfaceCard(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_offer_outlined),
                      AppSpacing.hSm,
                      Expanded(
                        child: Text(
                          controller.packageNameFor(discount.packageId),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      CustomStatusBadge(
                        label: discount.isEnabled ? 'مفعّل' : 'معطّل',
                        tone: discount.isEnabled ? SemanticTone.success : SemanticTone.neutral,
                        isCompact: true,
                      ),
                    ],
                  ),
                  AppSpacing.vSm,
                  CustomStatusBadge(
                    label: switch (discount.validityState.wireValue) {
                      'EFFECTIVE' => 'ساري الآن',
                      'SCHEDULED' => 'مجدول',
                      'EXPIRED' => 'منتهي',
                      'DISABLED' => 'معطّل',
                      _ => 'غير محدد',
                    },
                    tone: switch (discount.validityState.wireValue) {
                      'EFFECTIVE' => SemanticTone.success,
                      'SCHEDULED' => SemanticTone.warning,
                      'EXPIRED' => SemanticTone.danger,
                      _ => SemanticTone.neutral,
                    },
                    isCompact: true,
                  ),
                  AppSpacing.vSm,
                  Text('خصم نقدي: ${AmountFormatter.formatValue(discount.discountCash)}%'),
                  Text('خصم آجل: ${AmountFormatter.formatValue(discount.discountCredit)}%'),
                  Text('السعر النقدي المعتمد: ${discount.cashPrice == null ? 'غير متاح' : '${AmountFormatter.formatValue(discount.cashPrice!)} ر.ي'}'),
                  Text('السعر الآجل المعتمد: ${discount.creditPrice == null ? 'غير متاح' : '${AmountFormatter.formatValue(discount.creditPrice!)} ر.ي'}'),
                  if (discount.startDate != null || discount.endDate != null) ...[
                    AppSpacing.vXs,
                    Text('السريان: ${discount.startDate?.toString() ?? 'فوري'} — ${discount.displayEndDate ?? 'مفتوح'}'),
                  ],
                  if (controller.canEditDiscount || controller.canToggleDiscount || controller.canDeleteDiscount) ...[
                    AppSpacing.vMd,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (controller.canEditDiscount)
                          CustomButton.secondary(
                            text: 'تعديل',
                            prefix: Icons.edit_outlined,
                            onPressed: controller.isSavingDiscount.value
                                ? null
                                : () => controller.openDiscountEditor(discount: discount),
                          ),
                        if (controller.canToggleDiscount)
                          CustomButton.secondary(
                            text: discount.isEnabled ? 'تعطيل' : 'تفعيل',
                            prefix: discount.isEnabled ? Icons.pause_circle_outline : Icons.play_circle_outline,
                            onPressed: controller.isSavingDiscount.value
                                ? null
                                : () => controller.toggleDiscount(discount),
                          ),
                        if (controller.canDeleteDiscount)
                          CustomButton.secondary(
                            text: 'حذف',
                            prefix: Icons.delete_outline,
                            onPressed: controller.isSavingDiscount.value
                                ? null
                                : () => controller.deleteDiscount(discount),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          )),
          if (controller.isLoadingMoreDiscounts.value)
            const CustomStateSkeletonView(
              recipe: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 2,
                cardHeight: 76,
              ),
            )
          else if (controller.hasMorePackageDiscounts)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: CustomButton.secondary(
                text: 'تحميل المزيد',
                onPressed: controller.loadMorePackageDiscounts,
              ),
            ),
        ],
      ],
    ));
  }

  Widget _archiveTab() {
    return Obx(() {
      if (controller.isLoadingArchive.value && controller.archivedLinks.isEmpty) {
        return const CustomStateView.loading();
      }
      if (controller.archiveErrorMessage.value != null && controller.archivedLinks.isEmpty) {
        return CustomErrorState(
          title: 'تعذر تحميل العلاقات المؤرشفة',
          subtitle: controller.archiveErrorMessage.value,
          onRetry: () => controller.loadArchivedLinks(refresh: true),
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.loadArchivedLinks(refresh: true),
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            if (controller.archivedLinks.isEmpty)
              const CustomEmptyState.compact(
                title: 'الأرشيف فارغ',
                subtitle: 'العلاقات التي يتم فك ارتباطها مؤقتاً ستظهر هنا مع إمكانية استعادتها.',
                icon: Icons.archive_outlined,
              ),
            ...controller.archivedLinks.map((link) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: CustomSurfaceCard(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.isNetworkScope ? link.displayPosName : link.displayNetworkName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    AppSpacing.vXs,
                    Text('رقم العلاقة: #${link.networkPosId}'),
                    Text('تاريخ الارتباط: ${link.formattedLinkedDate}'),
                    AppSpacing.vSm,
                    if (controller.canRestoreLinks) CustomButton.secondary(
                      text: 'استعادة العلاقة',
                      prefix: Icons.restore_rounded,
                      onPressed: controller.isSaving.value ? null : () => controller.restoreLink(link),
                    ),
                  ],
                ),
              ),
            )),
            if (controller.isLoadingMoreArchive.value)
              const CustomStateSkeletonView(
                recipe: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.list,
                  itemCount: 2,
                  cardHeight: 76,
                ),
              )
            else if (controller.hasMoreArchive)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: CustomButton.secondary(
                  text: 'تحميل المزيد',
                  onPressed: controller.loadMoreArchivedLinks,
                ),
              ),
          ],
        ),
      );
    });
  }

  String _eventLabel(String type) => switch (type) {
    'CREATED' => 'إنشاء العلاقة',
    'ACTIVATED' => 'تفعيل العلاقة',
    'DEACTIVATED' => 'تعطيل العلاقة',
    'ARCHIVED' => 'أرشفة العلاقة',
    'RESTORED' => 'استعادة العلاقة',
    'AGREEMENT_DRAFT_CREATED' => 'إنشاء مسودة اتفاقية',
    'AGREEMENT_DRAFT_UPDATED' => 'تحديث مسودة اتفاقية',
    'AGREEMENT_ACTIVATED' => 'اعتماد اتفاقية',
    'AGREEMENT_TERMINATED' => 'إنهاء اتفاقية',
    'AGREEMENT_EXPIRED' => 'انتهاء صلاحية الاتفاقية',
    'DISCOUNT_CREATED' => 'إنشاء خصم مخصص لباقة',
    'DISCOUNT_UPDATED' => 'تعديل خصم مخصص',
    'DISCOUNT_ACTIVATED' => 'تفعيل خصم مخصص',
    'DISCOUNT_DEACTIVATED' => 'تعطيل خصم مخصص',
    'DISCOUNT_ARCHIVED' => 'أرشفة خصم مخصص',
    'DISCOUNT_RESTORED' => 'استعادة خصم مخصص',
    'DISCOUNT_FORCE_DELETED' => 'حذف خصم مخصص نهائياً',
    _ => type,
  };
}
