import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/features/more/domain/entities/more_overview_entity.dart';
import 'package:netsales/features/more/domain/entities/more_subscription_entity.dart';
import 'package:netsales/features/more/domain/entities/more_support_summary_entity.dart';
import 'package:netsales/features/more/domain/entities/more_wallet_entity.dart';
import 'package:netsales/features/more/domain/usecases/get_more_overview_use_case.dart';
import 'package:netsales/features/more/domain/usecases/logout_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';

/// ============================================================================
/// متحكم قطاع المزيد والمركز المالي (MoreController)
/// ============================================================================
/// يدير حالة شاشة المزيد، ملخص المحفظة، بيانات المستخدم، وإجراء تسجيل الخروج الآمن.
class MoreController extends GetxController {
  final GetMoreOverviewUseCase _getMoreOverviewUseCase;
  final LogoutUseCase _logoutUseCase;

  MoreController({
    required GetMoreOverviewUseCase getMoreOverviewUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _getMoreOverviewUseCase = getMoreOverviewUseCase,
        _logoutUseCase = logoutUseCase;

  final Rxn<MoreOverviewEntity> overview = Rxn<MoreOverviewEntity>();
  final RxBool isLoading = false.obs;

  /// بيانات المستخدم الحالي المسجل من خدمة الجلسات المعتمدة
  UserModel? get currentUser => SessionService.to.currentUser;

  /// ملخص المحفظة المالية
  MoreWalletEntity? get wallet => overview.value?.wallet;

  /// اشتراك النظام السحابي
  MoreSubscriptionEntity? get subscription => overview.value?.subscription;

  /// ملخص تذاكر الدعم الفني
  MoreSupportSummaryEntity? get support => overview.value?.supportSummary;

  /// إجمالي المصروفات التشغيلية للشهر الحالي
  double get totalExpenses => overview.value?.totalExpensesThisMonth ?? 0.0;

  /// عدد الأجهزة والجلسات النشطة
  int get activeSessionsCount => overview.value?.activeSessionsCount ?? 1;

  @override
  void onInit() {
    super.onInit();
    loadOverview();
  }

  /// جلب وتحديث النظرة المالية والتشغيلية المجمعة
  Future<void> loadOverview({bool isRefresh = false}) async {
    if (!isRefresh) isLoading.value = true;
    try {
      final result = await _getMoreOverviewUseCase();
      overview.value = result;
    } catch (_) {
      // إخفاق صامت والاعتماد على الحالة الافتراضية
    } finally {
      isLoading.value = false;
    }
  }

  /// تأكيد وتنفيذ تسجيل الخروج الرسمي والآمن
  Future<void> confirmLogout(BuildContext context) async {
    final confirmed = await CustomDialog.showDanger(
      title: 'تسجيل الخروج',
      message: 'هل أنت متأكد من رغبتك في إنهاء الجلسة وتسجيل الخروج من هذا الجهاز؟ سيتم قفل البيانات محلياً لحماية الحساب.',
      confirmLabel: 'تسجيل الخروج',
      cancelLabel: 'إلغاء',
    );

    if (confirmed == true) {
      CustomAnimationOverlay.showLoading(message: 'جارٍ إنهاء الجلسة بأمان...');
      try {
        await _logoutUseCase();
        await CustomAnimationOverlay.showSuccess(
          message: 'تم تسجيل الخروج بنجاح. نراك قريباً!',
        );
      } catch (_) {
        await CustomAnimationOverlay.hide();
      } finally {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }
}
