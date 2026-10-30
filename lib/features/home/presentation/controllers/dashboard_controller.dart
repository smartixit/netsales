import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/home/domain/entities/dashboard_overview_entity.dart';
import 'package:netsales/features/home/domain/usecases/get_dashboard_overview_use_case.dart';
import 'package:netsales/features/operations/domain/entities/sales_trend_point_entity.dart';
import 'package:netsales/features/operations/domain/usecases/get_sales_trend_use_case.dart';
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';

/// ============================================================================
/// متحكم شاشة لوحة القيادة التجميعية (DashboardController)
/// ============================================================================
/// يدير حالة العرض، استقبال مدخلات المستخدم، استدعاء حالة الاستخدام حصراً،
/// ومعالجة أخطاء الواجهة والتحميل وحالة الفراغ وفق معايير Clean Architecture.
class DashboardController extends GetxController {
  final GetDashboardOverviewUseCase getDashboardOverviewUseCase;
  final GetSalesTrendUseCase getSalesTrendUseCase;

  DashboardController({
    required this.getDashboardOverviewUseCase,
    required this.getSalesTrendUseCase,
  });

  // ── الحالات التفاعلية المراقبة (Observable States) ──
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<DashboardOverviewEntity> overview = Rxn<DashboardOverviewEntity>();
  final RxString selectedPeriod = 'today'.obs;

  /// سلسلة مبيعات حقيقية (من الخادم) — display-only.
  final RxList<SalesTrendPointEntity> trendPoints =
      <SalesTrendPointEntity>[].obs;

  /// مؤشر بطاقة الشبكة المحددة في لوحة القيادة المستقلة
  final RxInt selectedNetworkIndex = 0.obs;
  final RxnInt selectedNetworkId = RxnInt();

  /// وضع حجب الأرقام المالية الحساسة لخصوصية التاجر (Privacy Mask)
  final RxBool isPrivacyMasked = false.obs;

  // ── الفترات الزمنية المعتمدة في النظام ──
  static const List<Map<String, String>> periods = [
    {'key': 'today', 'label': 'اليوم'},
    {'key': 'yesterday', 'label': 'الأمس'},
    {'key': 'this_week', 'label': 'هذا الأسبوع'},
    {'key': 'this_month', 'label': 'هذا الشهر'},
    {'key': 'this_year', 'label': 'هذا العام'},
  ];

  /// ذاكرة تخزين مؤقتة سريعة لكل شبكة لتفادي إعادة التحميل (Instant In-Memory Cache)
  final Map<int, DashboardOverviewEntity> _networkCache = {};

  /// مؤشر خلفي هادئ لتحديث بيانات الشبكة دون مساس بالشاشة أو الهيكل البصري
  final RxBool isSwitchingNetwork = false.obs;

  /// متحكم تقليب بطاقات الشبكات المستقلة المدار مركزياً
  late final PageController networkPageController;

  @override
  void onInit() {
    super.onInit();
    networkPageController = PageController(
      initialPage: selectedNetworkIndex.value,
      viewportFraction: 0.92,
    );
    loadDashboard();
  }

  @override
  void onClose() {
    networkPageController.dispose();
    super.onClose();
  }

  /// تبديل حالة حجب الأرقام المالية للخصوصية
  void togglePrivacyMask() {
    isPrivacyMasked.toggle();
  }

  /// جلب بيانات لوحة القيادة للشبكة المحددة أو الافتراضية
  Future<void> loadDashboard({
    bool isRefresh = false,
    int? networkId,
    bool silent = false,
  }) async {
    if (isRefresh) {
      isRefreshing.value = true;
      // مسح الكاش المحلي لإجبار جلب بيانات حية وطازجة 100% من الباكيند
      _networkCache.clear();
    } else if (!silent && overview.value == null) {
      isLoading.value = true;
    }

    if (silent) {
      isSwitchingNetwork.value = true;
    }
    errorMessage.value = '';

    final targetNetworkId = networkId ?? selectedNetworkId.value;

    try {
      final result = await getDashboardOverviewUseCase(
        period: selectedPeriod.value,
        networkId: targetNetworkId,
        refresh: isRefresh,
      );

      // حفظ النتيجة في الذاكرة السريعة
      if (result.context.networkId != null) {
        _networkCache[result.context.networkId!] = result;
      } else if (targetNetworkId != null) {
        _networkCache[targetNetworkId] = result;
      }

      overview.value = result;

      // ضبط المعرف المختار تلقائياً إن لم يكن محدداً مسبقاً
      if (selectedNetworkId.value == null && result.context.networkId != null) {
        selectedNetworkId.value = result.context.networkId;
      }
    } catch (error) {
      final cleanMessage = AppException.sanitizeMessage(error);
      if (overview.value == null) {
        errorMessage.value = cleanMessage;
      }
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: cleanMessage,
          type: SnackType.error,
        );
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isSwitchingNetwork.value = false;
    }
  }

  /// تبديل الفترة الزمنية وإعادة الجلب التلقائي بهدوء
  /// جلب سلسلة مبيعات حقيقية (من الخادم) للرسم البياني.
  /// نمط موحد: try/catch مع AppException.sanitizeMessage (display-only، غير حرج).
  Future<void> loadTrend({String period = 'daily'}) async {
    try {
      final result = await getSalesTrendUseCase(period: period);
      trendPoints.assignAll(result);
    } catch (error) {
      // سلسلة المبيعات غير حرجية (عرض فقط) — لا نُعطل الواجهة.
      // نظّف رسالة الخطأ وفق الميثاق (AppException.sanitizeMessage) دون إظهار Snackbar.
      AppException.sanitizeMessage(error);
    }
  }

  void changePeriod(String period) {
    if (selectedPeriod.value == period) return;
    selectedPeriod.value = period;
    loadDashboard(networkId: selectedNetworkId.value, silent: true);
  }

  /// التفاعل مع تحريك بطاقة الكيان الشبكي المستقل (Multi-Entity Horizon Deck)
  /// انتقال حركي لحظي (Instant Client-Side Transition) بدون وميض أو إعادة تحميل كاملة
  void onNetworkCardChanged(int index) {
    final list = networks;
    if (index < 0 || index >= list.length) return;
    if (selectedNetworkIndex.value == index &&
        selectedNetworkId.value == list[index].networkId) {
      return;
    }

    selectedNetworkIndex.value = index;
    final targetId = list[index].networkId;
    selectedNetworkId.value = targetId;

    // 1. في حال توفر البيانات في الكاش السريع، يتم تطبيقها فوراً (0ms)
    if (_networkCache.containsKey(targetId)) {
      overview.value = _networkCache[targetId];
      // تحديث هادئ في الخلفية لمزامنة أي عمليات جديدة
      loadDashboard(networkId: targetId, silent: true);
    } else {
      // 2. جلب هادئ في الخلفية مع بقاء الشاشة والبطاقات ثابتة دون أي وميض
      loadDashboard(networkId: targetId, silent: true);
    }
  }

  /// قائمة الشبكات المستقلة ضمن المحفظة
  List<DashboardNetworkSummaryEntity> get networks =>
      overview.value?.networks ?? [];

  /// هل يمتلك المستخدم أكثر من شبكة مستقلة في محفظته
  bool get hasMultipleNetworks => networks.length > 1;

  /// الكيان الشبكي المعروض حالياً
  DashboardNetworkSummaryEntity? get currentNetworkSummary {
    if (networks.isEmpty) return null;
    if (selectedNetworkIndex.value < networks.length) {
      return networks[selectedNetworkIndex.value];
    }
    return networks.first;
  }

  /// التحقق من صلاحيات ودور لوحة القيادة النشطة
  bool get isSuperAdmin => overview.value?.roleKey == 'SUPER_ADMIN';
  bool get isNetworkOwner => overview.value?.roleKey == 'NETWORK_OWNER';
  bool get isPosAgent => overview.value?.roleKey == 'POS_AGENT';

  /// مؤشرات سريعة
  DashboardLiquidityEntity? get liquidity => overview.value?.liquidity;
  DashboardContextEntity? get contextData => overview.value?.context;
  List<DashboardAlertEntity> get alerts => overview.value?.alerts ?? [];
  List<DashboardActivityEntity> get recentActivities =>
      overview.value?.recentActivities ?? [];
  Map<String, dynamic> get kpis => overview.value?.kpis ?? {};
  Map<String, dynamic> get salesKpi =>
      (kpis['sales'] as Map<String, dynamic>?) ?? const {};
  double get cashSalesAmount =>
      (salesKpi['cash_sales_amount'] as num?)?.toDouble() ?? 0.0;
  double get creditSalesAmount =>
      (salesKpi['credit_sales_amount'] as num?)?.toDouble() ?? 0.0;
  // DISPLAY-ONLY fallback sum of backend-fetched amounts (not authoritative).
  double get totalSalesAmount =>
      (salesKpi['current_amount'] as num?)?.toDouble() ??
      (cashSalesAmount + creditSalesAmount);
  // DISPLAY-ONLY ratio (inputs backend-provided; not sent).
  double get cashRatio => totalSalesAmount > 0
      ? (cashSalesAmount / totalSalesAmount).clamp(0.0, 1.0)
      : 0.0;

  /// مؤشرات شبكات التوزيع (Super Admin)
  Map<String, dynamic> get networksKpi =>
      (kpis['networks'] as Map<String, dynamic>?) ?? const {};
  int get totalNetworksCount => (networksKpi['total'] as num?)?.toInt() ?? 0;
  int get approvedNetworksCount =>
      (networksKpi['approved'] as num?)?.toInt() ?? 0;
  int get pendingNetworksCount =>
      (networksKpi['pending'] as num?)?.toInt() ?? 0;

  /// مؤشرات أسطول نقاط البيع الميدانية (Super Admin / Network Owner)
  Map<String, dynamic> get posKpi =>
      (kpis['pos'] as Map<String, dynamic>?) ?? const {};
  int get totalPosCount => (posKpi['total'] as num?)?.toInt() ?? 0;
  int get approvedPosCount => (posKpi['approved'] as num?)?.toInt() ?? 0;
  int get pendingPosCount => (posKpi['pending'] as num?)?.toInt() ?? 0;

  /// مؤشرات تغطية ونشاط نقاط بيع الشبكة (POS Coverage)
  Map<String, dynamic> get posNetworkKpi =>
      (kpis['pos_network'] as Map<String, dynamic>?) ?? const {};
  int get activeNetworkPosCount =>
      (posNetworkKpi['active_count'] as num?)?.toInt() ?? 0;
  int get totalNetworkPosCount =>
      (posNetworkKpi['total_count'] as num?)?.toInt() ?? 0;
  // DISPLAY-ONLY ratio (inputs backend-provided; not sent).
  double get posCoverageRatio => totalNetworkPosCount > 0
      ? (activeNetworkPosCount / totalNetworkPosCount).clamp(0.0, 1.0)
      : 0.0;

  /// مؤشرات الباقة الأكثر طلباً في السوق
  Map<String, dynamic>? get topPackageKpi =>
      (kpis['top_package'] as Map<String, dynamic>?);
  String get topPackageName =>
      topPackageKpi?['package_name'] as String? ?? 'لا توجد مبيعات';
  int get topPackageVouchersSoldCount =>
      (topPackageKpi?['vouchers_sold_count'] as num?)?.toInt() ?? 0;
  double get topPackageRevenue =>
      (topPackageKpi?['revenue'] as num?)?.toDouble() ?? 0.0;

  // ── دوال التنقل المركزية الآمنة (Centralized Navigation Dispatchers) ──

  /// التوجيه السلس إلى شاشات المحافظ والحسابات المالية
  void navigateToWallets() {
    if (isNetworkOwner) {
      Get.toNamed(AppRoutes.networkWallets);
    } else if (isPosAgent) {
      Get.toNamed(AppRoutes.posWallets);
    } else if (Get.isRegistered<HomeLayoutController>()) {
      Get.find<HomeLayoutController>().changeTab(3);
    }
  }

  /// التوجيه إلى تبويب إدارة الشركاء ونقاط البيع
  void navigateToPartners() {
    if (Get.isRegistered<HomeLayoutController>()) {
      Get.find<HomeLayoutController>().changeTab(2);
    }
  }

  /// التوجيه إلى تبويب فواتير المبيعات وطلبات التوريد
  void navigateToOperations() {
    if (Get.isRegistered<HomeLayoutController>()) {
      Get.find<HomeLayoutController>().changeTab(1);
    }
  }
}
