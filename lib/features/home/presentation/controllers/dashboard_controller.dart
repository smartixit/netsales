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

  // ── الفترات الزمنية المعتمدة في النظام ──
  static const List<Map<String, String>> periods = [
    {'key': 'today', 'label': 'اليوم'},
    {'key': 'yesterday', 'label': 'الأمس'},
    {'key': 'this_week', 'label': 'هذا الأسبوع'},
    {'key': 'this_month', 'label': 'هذا الشهر'},
    {'key': 'this_year', 'label': 'هذا العام'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  /// جلب بيانات لوحة القيادة
  Future<void> loadDashboard({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final result = await _getDashboardOverviewUseCase(
        period: selectedPeriod.value,
        refresh: isRefresh,
      );
      overview.value = result;
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(e);
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// تبديل الفترة الزمنية وإعادة الجلب التلقائي
  void changePeriod(String period) {
    if (selectedPeriod.value == period) return;
    selectedPeriod.value = period;
    loadDashboard();
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
