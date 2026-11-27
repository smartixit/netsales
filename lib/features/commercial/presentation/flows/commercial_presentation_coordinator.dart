import 'package:flutter/material.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/base_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_action_dialogs.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/commercial_partner_details_sheet.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// تنسيق الحوارات وشيتات الشريك التجاري خارج Controllers.
class CommercialPresentationCoordinator {
  const CommercialPresentationCoordinator(this.controller);

  final BaseCommercialDirectoryController controller;

  void showPartnerActions({
    required NetworkPosLinkEntity link,
    required VoidCallback onViewDetails,
    VoidCallback? onToggleStatus,
    VoidCallback? onDelete,
    VoidCallback? onViewWallet,
    VoidCallback? onViewLifecycle,
  }) {
    final isNetworkView = controller.isNetworkView;
    final partnerName = isNetworkView
        ? link.displayPosName
        : link.displayNetworkName;
    final actions = <CustomBottomSheetActionItem>[
      CustomBottomSheetActionItem(
        title: isNetworkView
            ? 'عرض ملف نقطة البيع المعتمد'
            : 'عرض ملف مزود الشبكة المعتمد',
        icon: isNetworkView ? Icons.storefront_outlined : Icons.hub_outlined,
        onTap: onViewDetails,
      ),
      if (onViewLifecycle != null)
        CustomBottomSheetActionItem(
          title: 'الاتفاقيات وسجل أحداث العلاقة',
          subtitle: 'إصدارات الاتفاقيات والتغييرات التاريخية',
          icon: Icons.history_edu_rounded,
          onTap: onViewLifecycle,
        ),
      if (isNetworkView) ...[
        if (onViewWallet != null)
          CustomBottomSheetActionItem(
            title: 'دفتر أستاذ المحفظة',
            subtitle: 'عرض الحركات المالية والعمليات لنقطة البيع',
            icon: Icons.account_balance_wallet_outlined,
            onTap: onViewWallet,
          ),
        if (onToggleStatus != null)
          CustomBottomSheetActionItem(
            title: link.isActive
                ? 'تجميد الارتباط التجاري'
                : 'تنشيط الارتباط التجاري',
            icon: link.isActive
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            onTap: onToggleStatus,
          ),
        if (onDelete != null)
          CustomBottomSheetActionItem(
            title: 'فك الارتباط التجاري',
            icon: Icons.link_off_rounded,
            isDestructive: true,
            onTap: onDelete,
          ),
      ] else ...[
        if (onViewWallet != null)
          CustomBottomSheetActionItem(
            title: 'دفتر أستاذ المحفظة',
            subtitle: 'عرض الرصيد والحركات المالية ضمن هذه العلاقة',
            icon: Icons.account_balance_wallet_outlined,
            onTap: onViewWallet,
          ),
        if (onDelete != null)
          CustomBottomSheetActionItem(
            title: 'فك الارتباط بمزود الشبكة',
            icon: Icons.link_off_rounded,
            isDestructive: true,
            onTap: onDelete,
          ),
      ],
    ];

    CustomBottomSheet.showActions<void>(
      title: 'إجراءات الشريك: $partnerName',
      leadingIcon: isNetworkView ? Icons.storefront_rounded : Icons.hub_rounded,
      items: actions,
    );
  }

  void openPartnerDetails(NetworkPosLinkEntity link) {
    CustomBottomSheet.show<void>(
      title: controller.isNetworkView ? 'ملف نقطة البيع' : 'ملف مزود الشبكة',
      subtitle: 'البيانات التجارية المعتمدة للشريك',
      leadingIcon: controller.isNetworkView
          ? Icons.storefront_rounded
          : Icons.hub_rounded,
      child: CommercialPartnerDetailsSheet(
        link: link,
        isNetworkView: controller.isNetworkView,
      ),
    );
  }

  void showPartnerActions(NetworkPosLinkEntity link) {
    final isNetworkView = controller.isNetworkView;
    final partnerName = isNetworkView
        ? link.displayPosName
        : link.displayNetworkName;
    final items = <CustomBottomSheetActionItem>[
      CustomBottomSheetActionItem(
        title: isNetworkView
            ? 'عرض ملف نقطة البيع المعتمد'
            : 'عرض ملف مزود الشبكة المعتمد',
        icon: isNetworkView ? Icons.storefront_outlined : Icons.hub_outlined,
        onTap: () => openPartnerDetails(link),
      ),
      if (controller.canViewRelationshipLifecycle)
        CustomBottomSheetActionItem(
          title: 'الاتفاقيات وسجل أحداث العلاقة',
          subtitle: 'إصدارات الاتفاقيات والتغييرات التاريخية',
          icon: Icons.history_edu_rounded,
          onTap: () => controller.openRelationshipLifecycle(link),
        ),
      if (controller.canViewPartnerWallet)
        CustomBottomSheetActionItem(
          title: 'دفتر أستاذ المحفظة',
          subtitle: isNetworkView
              ? 'عرض الحركات المالية والعمليات لنقطة البيع'
              : 'عرض الرصيد والحركات المالية ضمن هذه العلاقة',
          icon: Icons.account_balance_wallet_outlined,
          onTap: () => controller.openPosWalletStatement(link),
        ),
      if (isNetworkView && controller.canTogglePartnerLink)
        CustomBottomSheetActionItem(
          title: link.isActive
              ? 'تجميد الارتباط التجاري'
              : 'تنشيط الارتباط التجاري',
          icon: link.isActive
              ? Icons.pause_circle_outline_rounded
              : Icons.play_circle_outline_rounded,
          onTap: () => togglePartnerStatus(link),
        ),
      if (controller.canDeletePartnerLink)
        CustomBottomSheetActionItem(
          title: isNetworkView
              ? 'فك الارتباط التجاري'
              : 'فك الارتباط بمزود الشبكة',
          icon: Icons.link_off_rounded,
          isDestructive: true,
          onTap: () => unlinkPartner(link),
        ),
    ];

    CustomBottomSheet.showActions<void>(
      title: 'إجراءات الشريك: $partnerName',
      leadingIcon: isNetworkView
          ? Icons.storefront_rounded
          : Icons.hub_rounded,
      items: items,
    );
  }

  Future<void> togglePartnerStatus(NetworkPosLinkEntity link) async {
    if (!controller.canTogglePartnerLink) return;
    final partnerName = controller.isNetworkView
        ? link.displayPosName
        : link.displayNetworkName;

    await CommercialActionDialogs.showToggleStatusDialog(
      partnerName: partnerName,
      willDeactivate: link.isActive,
      onConfirm: () async {
        try {
          await controller.togglePartnerLink(link);
          await CustomAnimationOverlay.showSuccess(
            message: link.isActive
                ? 'تم تجميد الارتباط بنجاح'
                : 'تم تنشيط الارتباط بنجاح',
          );
        } catch (error) {
          CustomSnackbar.show(
            title: 'تعذر تحديث الارتباط',
            message: AppException.sanitizeMessage(error),
            type: SnackType.error,
          );
        }
      },
    );
  }

  Future<void> unlinkPartner(NetworkPosLinkEntity link) async {
    if (!controller.canDeletePartnerLink) return;
    final partnerName = controller.isNetworkView
        ? link.displayPosName
        : link.displayNetworkName;

    await CommercialActionDialogs.showUnlinkDialog(
      partnerName: partnerName,
      onConfirm: () async {
        try {
          await controller.deletePartnerLink(link);
          await CustomAnimationOverlay.showSuccess(
            message: 'تم فك الارتباط التجاري بنجاح',
          );
        } catch (error) {
          CustomSnackbar.show(
            title: 'تعذر فك الارتباط',
            message: AppException.sanitizeMessage(error),
            type: SnackType.error,
          );
        }
      },
    );
  }
}
