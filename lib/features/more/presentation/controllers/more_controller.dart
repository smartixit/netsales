import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/features/more/domain/entities/bank_account_entity.dart';
import 'package:netsales/features/more/domain/entities/expense_entity.dart';
import 'package:netsales/features/more/domain/entities/more_overview_entity.dart';
import 'package:netsales/features/more/domain/entities/more_subscription_entity.dart';
import 'package:netsales/features/more/domain/entities/more_support_summary_entity.dart';
import 'package:netsales/features/more/domain/entities/more_wallet_entity.dart';
import 'package:netsales/features/more/domain/entities/user_session_entity.dart';
import 'package:netsales/features/more/domain/usecases/create_expense_use_case.dart';
import 'package:netsales/features/more/domain/usecases/get_bank_accounts_use_case.dart';
import 'package:netsales/features/more/domain/usecases/get_expenses_use_case.dart';
import 'package:netsales/features/more/domain/usecases/get_more_overview_use_case.dart';
import 'package:netsales/features/more/domain/usecases/get_user_sessions_use_case.dart';
import 'package:netsales/features/more/domain/usecases/logout_use_case.dart';
import 'package:netsales/features/more/domain/usecases/terminate_session_use_case.dart';
import 'package:netsales/features/more/domain/usecases/toggle_bank_account_status_use_case.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/domain/usecases/get_networks_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم قطاع المزيد والمركز المالي (MoreController)
/// ============================================================================
/// يدير حالة شاشة المزيد، ملخص المحفظة، بيانات المستخدم، الحسابات المصرفية،
/// النفقات التشغيلية، الجلسات المصرح بها، وإجراء تسجيل الخروج الآمن
/// مصاغ وفق النمط المعماري القياسي الموحد المعتمد في OperationsController.
class MoreController extends GetxController {
  final GetMoreOverviewUseCase getMoreOverviewUseCase;
  final LogoutUseCase logoutUseCase;
  final GetBankAccountsUseCase getBankAccountsUseCase;
  final ToggleBankAccountStatusUseCase toggleBankAccountStatusUseCase;
  final GetExpensesUseCase getExpensesUseCase;
  final CreateExpenseUseCase createExpenseUseCase;
  final GetUserSessionsUseCase getUserSessionsUseCase;
  final TerminateSessionUseCase terminateSessionUseCase;
  final GetNetworksUseCase getNetworksUseCase;

  MoreController({
    required this.getMoreOverviewUseCase,
    required this.logoutUseCase,
    required this.getBankAccountsUseCase,
    required this.toggleBankAccountStatusUseCase,
    required this.getExpensesUseCase,
    required this.createExpenseUseCase,
    required this.getUserSessionsUseCase,
    required this.terminateSessionUseCase,
    required this.getNetworksUseCase,
  });

  /// الحالات المراقبة للنظرة التجميعية
  final Rxn<MoreOverviewEntity> overview = Rxn<MoreOverviewEntity>();
  final RxBool isLoading = false.obs;
  final RxString overviewErrorMessage = ''.obs;
  final RxBool isBalanceHidden = false.obs;

  /// الحسابات المصرفية
  final RxList<BankAccountEntity> bankAccounts = <BankAccountEntity>[].obs;
  final RxBool isLoadingBankAccounts = false.obs;
  final RxString bankAccountsErrorMessage = ''.obs;

  /// المصروفات التشغيلية
  final RxList<ExpenseEntity> expenses = <ExpenseEntity>[].obs;
  final RxBool isLoadingExpenses = false.obs;
  final RxString expensesErrorMessage = ''.obs;

  /// شبكات المنشأة المتاحة لقيد النفقات واختيار الشبكة المحددة عبر ValueNotifier
  final RxList<NetworkEntity> availableNetworks = <NetworkEntity>[].obs;
  final RxBool isLoadingNetworks = false.obs;
  final ValueNotifier<int?> selectedExpenseNetworkId = ValueNotifier<int?>(null);

  /// الجلسات والأجهزة المصرح بها
  final RxList<UserSessionEntity> userSessions = <UserSessionEntity>[].obs;
  final RxBool isLoadingSessions = false.obs;
  final RxString sessionsErrorMessage = ''.obs;

  /// حالة تنفيذ إجراء متزامن
  final RxBool isSubmittingAction = false.obs;

  void toggleBalanceVisibility() {
    isBalanceHidden.value = !isBalanceHidden.value;
  }

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

  @override
  void onClose() {
    selectedExpenseNetworkId.dispose();
    super.onClose();
  }

  /// جلب وتحديث النظرة المالية والتشغيلية المجمعة
  Future<void> loadOverview({bool isRefresh = false}) async {
    if (!isRefresh) isLoading.value = true;
    overviewErrorMessage.value = '';

    try {
      final result = await getMoreOverviewUseCase();
      overview.value = result;
    } catch (e) {
      overviewErrorMessage.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: overviewErrorMessage.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب الحسابات المصرفية المعتمدة للمنشأة
  Future<void> loadBankAccounts({bool isRefresh = false}) async {
    isLoadingBankAccounts.value = true;
    bankAccountsErrorMessage.value = '';

    try {
      final result = await getBankAccountsUseCase();
      bankAccounts.assignAll(result);
    } catch (e) {
      bankAccountsErrorMessage.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: bankAccountsErrorMessage.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoadingBankAccounts.value = false;
    }
  }

  /// تفعيل أو تعطيل حساب مصرفي
  Future<void> toggleBankAccountStatus(int bankAccountId) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جارٍ تحديث حالة الحساب المصرفي...');
      final success = await toggleBankAccountStatusUseCase(bankAccountId);
      if (success) {
        await loadBankAccounts(isRefresh: true);
        await CustomAnimationOverlay.showSuccess(
          message: 'تم تحديث حالة الحساب المصرفي بنجاح.',
        );
      }
    } catch (e) {
      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تعذر تعديل الحساب',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// جلب شبكات المنشأة المتاحة لاختيار الشبكة بدقة عند قيد المصروف
  Future<void> loadNetworksForExpenses() async {
    isLoadingNetworks.value = true;
    try {
      final result = await getNetworksUseCase();
      availableNetworks.assignAll(result);
      if (selectedExpenseNetworkId.value == null && availableNetworks.isNotEmpty) {
        selectedExpenseNetworkId.value = availableNetworks.first.networkId;
      }
    } catch (_) {
      // إخفاق صامت والاعتماد على الاختيار اليدوي
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  /// تغيير الشبكة المحددة لقيد المصروف مطابق لنمط CreateSaleInvoiceController
  void onExpenseNetworkChanged(int? newNetId) {
    if (newNetId == null || newNetId == selectedExpenseNetworkId.value) return;
    selectedExpenseNetworkId.value = newNetId;
  }

  /// جلب المصروفات التشغيلية
  Future<void> loadExpenses({bool isRefresh = false}) async {
    isLoadingExpenses.value = true;
    expensesErrorMessage.value = '';

    try {
      final result = await getExpensesUseCase();
      expenses.assignAll(result);
    } catch (e) {
      expensesErrorMessage.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: expensesErrorMessage.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoadingExpenses.value = false;
    }
  }

  /// قيد وتسجيل مصروف تشغيلي جديد
  Future<bool> createExpense({
    required int networkId,
    required double totalAmount,
    String? expenseDate,
    String? notes,
  }) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جارٍ قيد المصروف التشغيلي...');
      final success = await createExpenseUseCase(
        networkId: networkId,
        totalAmount: totalAmount,
        expenseDate: expenseDate,
        notes: notes,
      );
      if (success) {
        await loadExpenses(isRefresh: true);
        loadOverview(isRefresh: true);
        await CustomAnimationOverlay.showSuccess(
          message: 'تم تسجيل المصروف التشغيلي بنجاح.',
        );
        return true;
      }
      return false;
    } catch (e) {
      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تعذر قيد المصروف',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
      return false;
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// جلب قائمة الجلسات والأجهزة المصرح بها
  Future<void> loadUserSessions({bool isRefresh = false}) async {
    isLoadingSessions.value = true;
    sessionsErrorMessage.value = '';

    try {
      final uid = currentUser?.userId ?? 0;
      final result = await getUserSessionsUseCase(uid);
      userSessions.assignAll(result);
    } catch (e) {
      sessionsErrorMessage.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: sessionsErrorMessage.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoadingSessions.value = false;
    }
  }

  /// إنهاء جلسة معينة
  Future<void> terminateSession(int sessionId) async {
    final confirmed = await CustomDialog.showDanger(
      title: 'إنهاء الجلسة',
      message: 'هل أنت متأكد من رغبتك في إلغاء صلاحية هذه الجلسة وإخراج الجهاز فوراً؟',
      confirmLabel: 'إنهاء الجلسة',
      cancelLabel: 'إلغاء',
    );

    if (confirmed == true) {
      isSubmittingAction.value = true;
      try {
        await CustomAnimationOverlay.showLoading(message: 'جارٍ إنهاء الجلسة...');
        final success = await terminateSessionUseCase(sessionId);
        if (success) {
          userSessions.removeWhere((s) => s.sessionId == sessionId);
          loadOverview(isRefresh: true);
          await CustomAnimationOverlay.showSuccess(
            message: 'تم إلغاء صلاحية الجلسة وإخراج الجهاز بنجاح.',
          );
        }
      } catch (e) {
        await CustomAnimationOverlay.hide();
        CustomSnackbar.show(
          title: 'تعذر إنهاء الجلسة',
          message: AppException.sanitizeMessage(e),
          type: SnackType.error,
        );
      } finally {
        isSubmittingAction.value = false;
        if (CustomAnimationOverlay.isShowing) {
          await CustomAnimationOverlay.hide();
        }
      }
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
        await logoutUseCase();
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
