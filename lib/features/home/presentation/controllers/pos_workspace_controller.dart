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
/// متحكم مساحة عمل نقطة البيع والوكيل (POS Workspace Controller)
/// ============================================================================
class PosWorkspaceController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isOnline = true.obs;
  final RxInt unreadNotificationsCount = 0.obs;

  StreamSubscription<bool>? _networkSubscription;

  /// عناصر شريط التنقل السفلي الخاص بنقطة البيع
  List<CustomFloatingNavItem> get navItems => const [
    CustomFloatingNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'الرئيسية',
      tooltip: 'لوحة قيادة ومشتريات الوكيل (POS-01)',
    ),
    CustomFloatingNavItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart_rounded,
      label: 'التوريد',
      tooltip: 'طلبات التوريد وفواتير الشراء المستلمة (POS-02 / POS-04)',
    ),
    CustomFloatingNavItem(
      icon: Icons.hub_outlined,
      activeIcon: Icons.hub_rounded,
      label: 'الشبكات',
      tooltip: 'دليل الشبكات المزودة المعتمدة والأسعار (POS-06)',
    ),
    CustomFloatingNavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'الحساب',
      tooltip: 'الحساب الجاري والمديونية وموظفو النقطة (POS-07 / POS-08)',
    ),
  ];

  /// الإجراءات السريعة الخاصة بنقطة البيع
  List<HomeQuickActionEntity> get quickActions {
    return [
      HomeQuickActionEntity(
        id: 'new_procurement_order',
        title: 'طلب توريد باقات كروت',
        description: 'إرسال طلب شراء كروت جديدة لمزود الشبكة',
        icon: Icons.add_shopping_cart_rounded,
        requiredPermission: AppPermissions.requestsCreate,
        targetRoute: AppRoutes.newProcurementOrder,
      ),
      HomeQuickActionEntity(
        id: 'view_pos_statement',
        title: 'كشف الحساب الجاري والمديونية',
        description: 'متابعة الرصيد المتاح والمديونية المستحقة للشبكات',
        icon: Icons.account_balance_rounded,
        requiredPermission: AppPermissions.posWalletsView,
        targetRoute: AppRoutes.posWalletStatement,
      ),
      HomeQuickActionEntity(
        id: 'pos_staff_management',
        title: 'إدارة موظفي نقطة البيع',
        description: 'إضافة وتعيين صلاحيات موظفي ومحاسبي النقطة',
        icon: Icons.badge_outlined,
        requiredPermission: AppPermissions.usersView,
        targetRoute: AppRoutes.posStaffManagement,
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
        if (action.id == 'new_procurement_order') {
          if (!IntegrationGateService.to.isLiveMutationEnabled(ControlledMutation.creditProcurementApproval)) {
            CustomSnackbar.show(
              title: 'بوابة تكامل مشروطة',
              message: IntegrationGateService.to.getGateExplanation(ControlledMutation.creditProcurementApproval),
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

