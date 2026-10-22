import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/internet_connection_service.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/features/home/presentation/models/home_quick_action.dart';
import 'package:netsales/features/home/presentation/widgets/home_quick_actions_sheet.dart';
import 'package:netsales/widgets/navigations/custom_floating_bottom_nav_bar.dart';

/// ============================================================================
/// متحكم الواجهة الرئيسية والتنقل المؤسسي (HomeLayoutController)
/// ============================================================================
/// يدير حالة التبويبات، سياق الاتصال بالشبكة، وتوزيع الإجراءات السريعة
/// اللحظية بالاستناد التام إلى منظومة الصلاحيات (Permission-Driven).
class HomeLayoutController extends GetxController {
  /// مؤشر التبويب النشط حالياً
  final RxInt selectedIndex = 0.obs;

  /// حالة الاتصال بالإنترنت اللحظية
  final RxBool isOnline = true.obs;

  /// عداد الإشعارات غير المقروءة
  final RxInt unreadNotificationsCount = 0.obs;

  /// اشتراك متابعة حالة الشبكة
  StreamSubscription<bool>? _networkSubscription;

  /// عناصر شريط التنقل السفلي الموحد
  List<CustomFloatingNavItem> get navItems => const [
        CustomFloatingNavItem(
          icon: Icons.grid_view_outlined,
          activeIcon: Icons.grid_view_rounded,
          label: 'الرئيسية',
          tooltip: 'لوحة المؤشرات وإحصائيات التوزيع',
        ),
        CustomFloatingNavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          label: 'العمليات',
          tooltip: 'فواتير مبيعات وطلبات توريد الكروت',
        ),
        CustomFloatingNavItem(
          icon: Icons.hub_outlined,
          activeIcon: Icons.hub_rounded,
          label: 'الشركاء',
          tooltip: 'إدارة الشبكات ونقاط البيع وباقات التوزيع',
        ),
        CustomFloatingNavItem(
          icon: Icons.widgets_outlined,
          activeIcon: Icons.widgets_rounded,
          label: 'المزيد',
          tooltip: 'المحافظ والمصروفات والدعم الفني والإعدادات',
        ),
      ];

  /// قائمة الإجراءات السريعة المتاحة للمستخدم بناءً على صلاحياته الحالية
  List<HomeQuickAction> get availableQuickActions {
    final permissionService = PermissionService.to;

    final catalog = <HomeQuickAction>[
      // 1. إصدار فاتورة مبيعات لنقطة بيع (sales.create)
      HomeQuickAction(
        id: 'create_sale_invoice',
        title: 'إصدار فاتورة مبيعات',
        description: 'توزيع وتوريد باقات كروت لنقطة بيع',
        icon: Icons.receipt_long_rounded,
        requiredPermission: AppPermissions.salesCreate,
        targetRoute: AppRoutes.sales,
      ),

      // 2. طلب توريد باقات كروت من الشبكة (requests.create)
      HomeQuickAction(
        id: 'create_voucher_request',
        title: 'طلب توريد كروت',
        description: 'إرسال طلب باقات كروت جديدة لمزود الشبكة',
        icon: Icons.add_shopping_cart_rounded,
        requiredPermission: AppPermissions.requestsCreate,
        targetRoute: AppRoutes.requests,
      ),

      // 3. مراجعة واعتماد طلبات نقاط البيع (requests.approve)
      HomeQuickAction(
        id: 'approve_voucher_requests',
        title: 'اعتماد طلبات الكروت',
        description: 'مراجعة وتوريد طلبات الكروت لنقاط البيع',
        icon: Icons.fact_check_outlined,
        requiredPermission: AppPermissions.requestsApprove,
        targetRoute: AppRoutes.requests,
      ),

      // 4. تعريف باقة كروت للشبكة (voucher_packages.create)
      HomeQuickAction(
        id: 'create_voucher_package',
        title: 'إضافة باقة كروت',
        description: 'تعريف باقة كروت جديدة وأسعار توزيعها',
        icon: Icons.wifi_tethering_rounded,
        requiredPermission: AppPermissions.voucherPackagesCreate,
        targetRoute: AppRoutes.voucherPackages,
      ),

      // 5. تغذية ومقاصة محفظة نقطة بيع (pos_wallets.manage)
      HomeQuickAction(
        id: 'manage_pos_wallet',
        title: 'شحن رصيد محفظة',
        description: 'تغذية رصيد أو تسوية حساب نقطة بيع',
        icon: Icons.account_balance_wallet_rounded,
        requiredPermission: AppPermissions.posWalletsManage,
        targetRoute: AppRoutes.posWallets,
      ),

      // 6. تسجيل سند مصروف تشغيلي (expenses.create)
      HomeQuickAction(
        id: 'create_expense',
        title: 'تسجيل سند مصروف',
        description: 'إضافة بند مصروفات تشغيلية أو صيانة للشبكة',
        icon: Icons.payments_outlined,
        requiredPermission: AppPermissions.expensesCreate,
        targetRoute: AppRoutes.expenses,
      ),
    ];

    return catalog
        .where((action) => permissionService.can(action.requiredPermission))
        .toList();
  }

  /// هل يمتلك المستخدم أي إجراءات سريعة مصرح بها
  bool get hasQuickActions => availableQuickActions.isNotEmpty;

  /// هل يمتلك المستخدم إجراءً وحيداً فقط (لتنفيذه فوراً بنقرة واحدة دون نافذة منبثقة)
  bool get isSingleAction => availableQuickActions.length == 1;

  /// الإجراء الرئيسي الوحيد إن وجد
  HomeQuickAction? get primaryQuickAction =>
      hasQuickActions ? availableQuickActions.first : null;

  /// اسم المستخدم الحالي الكامل
  String get userFullName =>
      SessionService.to.currentUser?.userFullName ?? 'المستخدم';

  /// رقم هاتف المستخدم الحالي
  String get userPhoneNumber =>
      SessionService.to.currentUser?.userPhoneNumber ?? '';

  /// المسمى الوظيفي أو دور المستخدم
  String get userRoleLabel =>
      SessionService.to.currentUser?.role?.roleName ??
      SessionService.to.currentUser?.statusLabel ??
      'عضو معتمد';

  /// مسار صورة الملف الشخصي أو الشعار
  String? get userProfileLogo =>
      SessionService.to.currentUser?.userProfileLogo;

  @override
  void onInit() {
    super.onInit();
    _initNetworkMonitoring();
  }

  @override
  void onClose() {
    _networkSubscription?.cancel();
    super.onClose();
  }

  /// متابعة حالة الاتصال بالإنترنت لحظياً
  void _initNetworkMonitoring() {
    isOnline.value = InternetConnectionService.instance.isConnected;
    _networkSubscription =
        InternetConnectionService.instance.statusStream.listen((connected) {
      isOnline.value = connected;
    });
  }

  /// تغيير التبويب النشط
  void changeTab(int index) {
    if (index >= 0 && index < navItems.length) {
      selectedIndex.value = index;
    }
  }

  /// معالجة النقر على الزر المركزي العائم (Center Action FAB)
  void onCenterFabPressed(BuildContext context) {
    if (!hasQuickActions) return;

    if (isSingleAction) {
      // إجراء وحيد مهيمن -> تنفيذ مباشر بنقرة واحدة لمنع الاحتكاك الزائد (Zero Friction)
      executeQuickAction(primaryQuickAction!);
    } else {
      // تعدد الإجراءات المصرح بها -> فتح ورقة الإجراءات السريعة
      HomeQuickActionsSheet.show(
        context,
        actions: availableQuickActions,
        onActionTap: executeQuickAction,
      );
    }
  }

  /// تنفيذ الإجراء السريع المحدد
  void executeQuickAction(HomeQuickAction action) {
    if (action.onExecute != null) {
      action.onExecute!();
      return;
    }

    if (action.targetRoute != null) {
      Get.toNamed(action.targetRoute!);
    }
  }

  /// التحقق مما إذا كان بالإمكان الرجوع للتبويب الرئيسي (التبويب 0)
  ///
  /// يرجع [false] إذا تم التراجع من تبويب فرعي إلى التبويب الرئيسي 0 لمنع الخروج،
  /// ويرجع [true] إذا كان المستخدم بالفعل في التبويب الرئيسي ليتولى [DoubleBackExitScope] الخروج الآمن.
  bool canPopTab() {
    if (selectedIndex.value != 0) {
      selectedIndex.value = 0;
      return false;
    }
    return true;
  }
}
