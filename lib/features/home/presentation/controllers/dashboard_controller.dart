import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/home/domain/entities/dashboard_overview_entity.dart';
import 'package:netsales/features/home/domain/usecases/get_dashboard_overview_use_case.dart';

/// ============================================================================
/// متحكم شاشة لوحة القيادة التجميعية (DashboardController)
/// ============================================================================
/// يدير حالة العرض، استقبال مدخلات المستخدم، استدعاء حالة الاستخدام حصراً،
/// ومعالجة أخطاء الواجهة والتحميل وحالة الفراغ وفق معايير Clean Architecture.
class DashboardController extends GetxController {
  final GetDashboardOverviewUseCase _getDashboardOverviewUseCase;

  DashboardController({
    required GetDashboardOverviewUseCase getDashboardOverviewUseCase,
  }) : _getDashboardOverviewUseCase = getDashboardOverviewUseCase;

  // ── الحالات التفاعلية المراقبة (Observable States) ──
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<DashboardOverviewEntity> overview = Rxn<DashboardOverviewEntity>();
  final RxString selectedPeriod = 'today'.obs;

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

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
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
      final result = await _getDashboardOverviewUseCase(
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
    } catch (e) {
      log(e.toString());
      if (overview.value == null) {
        errorMessage.value = AppException.sanitizeMessage(e);
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isSwitchingNetwork.value = false;
    }
  }

  /// تبديل الفترة الزمنية وإعادة الجلب التلقائي بهدوء
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
}
