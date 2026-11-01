import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/integration_gate_service.dart';
import 'package:netsales/core/services/internet_connection_service.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/features/home/domain/entities/home_quick_action_entity.dart';
import 'package:netsales/features/home/presentation/widgets/home_quick_actions_sheet.dart';
import 'package:netsales/widgets/navigations/custom_floating_bottom_nav_bar.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم مساحة عمل مزود الشبكة (Network Workspace Controller)
/// ============================================================================
class NetworkWorkspaceController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isOnline = true.obs;
  final RxInt unreadNotificationsCount = 0.obs;

  StreamSubscription<bool>? _networkSubscription;

  /// عناصر شريط التنقل السفلي الخاص بمزود الشبكة
  List<CustomFloatingNavItem> get navItems => const [
    CustomFloatingNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'الرئيسية',
      tooltip: 'لوحة قيادة وتوزيع مزود الشبكة (NET-01)',
    ),
    CustomFloatingNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'المبيعات',
      tooltip: 'فواتير مبيعات الجملة وطلبات التوريد (NET-02 / NET-03)',
    ),
    CustomFloatingNavItem(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
      label: 'الوكلاء',
      tooltip: 'دليل نقاط البيع وباقات الكروت (NET-05 / NET-06)',
    ),
    CustomFloatingNavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'المالية',
      tooltip: 'المحافظ والمصروفات وفريق العمل (NET-04 / NET-07 / NET-08)',
    ),
  ];

  /// الإجراءات السريعة الخاصة بمزود الشبكة
  List<HomeQuickActionEntity> get quickActions {
    return [
      HomeQuickActionEntity(
        id: 'issue_wholesale_invoice',
        title: 'إصدار فاتورة مبيعات جملة',
        description: 'توزيع باقات كروت لنقطة بيع معتمدة',
        icon: Icons.post_add_rounded,
        requiredPermission: AppPermissions.salesCreate,
        targetRoute: AppRoutes.saleInvoices,
      ),
      HomeQuickActionEntity(
        id: 'review_supply_requests',
        title: 'مراجعة طلبات التوريد',
        description: 'فحص واعتماد طلبات الكروت الواردة من الوكلاء',
        icon: Icons.checklist_rtl_rounded,
        requiredPermission: AppPermissions.requestsApprove,
        targetRoute: AppRoutes.requests,
      ),
      HomeQuickActionEntity(
        id: 'topup_pos_account',
        title: 'سند قبض / تغذية حساب وكيل',
        description: 'تسجيل دفعة نقدية تخفض مديونية نقطة البيع',
        icon: Icons.add_card_rounded,
        requiredPermission: AppPermissions.posWalletsManage,
        targetRoute: AppRoutes.posWallets,
      ),
      HomeQuickActionEntity(
        id: 'view_network_statement',
        title: 'كشف حركات محفظة الشبكة',
        description: 'متابعة السيولة النقدية ودفتر الأستاذ والتحصيلات',
        icon: Icons.account_balance_wallet_rounded,
        requiredPermission: AppPermissions.networkWalletsView,
        targetRoute: AppRoutes.networkWalletStatement,
      ),
      HomeQuickActionEntity(
        id: 'manage_team',
        title: 'إدارة فريق عمل الشبكة',
        description: 'إضافة وتعيين صلاحيات موظفي ومحاسبي الشبكة',
        icon: Icons.group_add_rounded,
        requiredPermission: AppPermissions.usersView,
        targetRoute: AppRoutes.networkTeamManagement,
      ),
    ];
  }

  bool get hasQuickActions => quickActions.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    if (Get.isRegistered<InternetConnectionService>()) {
      isOnline.value = InternetConnectionService.to.isConnected;
      _networkSubscription =
          InternetConnectionService.to.onConnectionChanged.listen((status) {
        isOnline.value = status;
      });
    }
  }

  void changeTab(int index) {
    if (index >= 0 && index < navItems.length) {
      selectedIndex.value = index;
    }
  }

  bool canPopTab() {
    if (selectedIndex.value != 0) {
      selectedIndex.value = 0;
      return false;
    }
    return true;
  }

  void onCenterFabPressed(BuildContext context) {
    HomeQuickActionsSheet.show(
      context,
      actions: quickActions,
      onActionSelected: (action) {
        // التحقق من بوابات التكامل المعمارية المشروطة
        if (action.id == 'topup_pos_account') {
          if (!IntegrationGateService.to.isLiveMutationEnabled(ControlledMutation.walletDeposit)) {
            CustomSnackbar.show(
              title: 'بوابة تكامل مشروطة',
              message: IntegrationGateService.to.getGateExplanation(ControlledMutation.walletDeposit),
              type: SnackType.info,
            );
            return;
          }
        }
        Get.toNamed(action.targetRoute);
      },
    );
  }

  @override
  void onClose() {
    _networkSubscription?.cancel();
    super.onClose();
  }
}

