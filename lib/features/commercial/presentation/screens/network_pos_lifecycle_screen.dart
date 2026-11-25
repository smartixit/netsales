import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_pos_lifecycle_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
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
                subtitle: 'الاتفاقيات التجارية وسجل الأحداث والقرارات المرتبطة بالعلاقة.',
                icon: Icons.hub_rounded,
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
            if (controller.hasMoreAgreements)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: CustomButton.secondary(
                  text: controller.isLoadingMoreAgreements.value ? 'جارٍ تحميل المزيد' : 'تحميل المزيد',
                  onPressed: controller.isLoadingMoreAgreements.value ? null : controller.loadMoreAgreements,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _agreementCard(NetworkPosAgreementEntity agreement) {
    final statusLabel = switch (agreement.status) {
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
                Chip(label: Text(statusLabel)),
                if (agreement.reference?.isNotEmpty == true)
                  Chip(label: Text('مرجع: ${agreement.reference}')),
                if (agreement.validityState?.isNotEmpty == true)
                  Chip(label: Text(agreement.validityState!)),
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
            if (controller.hasMoreEvents)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: CustomButton.secondary(
                  text: controller.isLoadingMoreEvents.value ? 'جارٍ تحميل المزيد' : 'تحميل المزيد',
                  onPressed: controller.isLoadingMoreEvents.value ? null : controller.loadMoreEvents,
                ),
              ),
          ],
        ),
      );
    });
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
    _ => type,
  };
}
