import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم قطاع المزيد والمركز المالي (MoreController)
/// ============================================================================
/// يدير حالة شاشة المزيد، ملخص المحفظة، بيانات المستخدم، الحسابات المصرفية،
/// النفقات التشغيلية، الجلسات المصرح بها، وإجراء تسجيل الخروج الآمن.
class MoreController extends GetxController {
  final GetMoreOverviewUseCase _getMoreOverviewUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetBankAccountsUseCase _getBankAccountsUseCase;
  final ToggleBankAccountStatusUseCase _toggleBankAccountStatusUseCase;
  final GetExpensesUseCase _getExpensesUseCase;
  final CreateExpenseUseCase _createExpenseUseCase;
  final GetUserSessionsUseCase _getUserSessionsUseCase;
  final TerminateSessionUseCase _terminateSessionUseCase;

  MoreController({
    required GetMoreOverviewUseCase getMoreOverviewUseCase,
    required LogoutUseCase logoutUseCase,
    required GetBankAccountsUseCase getBankAccountsUseCase,
    required ToggleBankAccountStatusUseCase toggleBankAccountStatusUseCase,
    required GetExpensesUseCase getExpensesUseCase,
    required CreateExpenseUseCase createExpenseUseCase,
    required GetUserSessionsUseCase getUserSessionsUseCase,
    required TerminateSessionUseCase terminateSessionUseCase,
  })  : _getMoreOverviewUseCase = getMoreOverviewUseCase,
        _logoutUseCase = logoutUseCase,
        _getBankAccountsUseCase = getBankAccountsUseCase,
        _toggleBankAccountStatusUseCase = toggleBankAccountStatusUseCase,
        _getExpensesUseCase = getExpensesUseCase,
        _createExpenseUseCase = createExpenseUseCase,
        _getUserSessionsUseCase = getUserSessionsUseCase,
        _terminateSessionUseCase = terminateSessionUseCase;

  final Rxn<MoreOverviewEntity> overview = Rxn<MoreOverviewEntity>();
  final RxBool isLoading = false.obs;
  final RxBool isBalanceHidden = false.obs;

  // الحسابات المصرفية
  final RxList<BankAccountEntity> bankAccounts = <BankAccountEntity>[].obs;
  final RxBool isLoadingBankAccounts = false.obs;

  // المصروفات التشغيلية
  final RxList<ExpenseEntity> expenses = <ExpenseEntity>[].obs;
  final RxBool isLoadingExpenses = false.obs;
  final RxBool isCreatingExpense = false.obs;

  // الجلسات والأجهزة المصرح بها
  final RxList<UserSessionEntity> userSessions = <UserSessionEntity>[].obs;
  final RxBool isLoadingSessions = false.obs;

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

  /// جلب الحسابات المصرفية المعتمدة للمنشأة
  Future<void> loadBankAccounts() async {
    isLoadingBankAccounts.value = true;
    try {
      final result = await _getBankAccountsUseCase();
      bankAccounts.assignAll(result);
    } catch (e) {
      CustomSnackbar.showError(
        title: 'الحسابات المصرفية',
        message: 'تعذر جلب قائمة الحسابات المصرفية: ${e.toString()}',
      );
    } finally {
      isLoadingBankAccounts.value = false;
    }
  }

  /// تفعيل أو تعطيل حساب مصرفي
  Future<void> toggleBankAccountStatus(int bankAccountId) async {
    try {
      final updated = await _toggleBankAccountStatusUseCase(bankAccountId);
      final index = bankAccounts.indexWhere((a) => a.id == bankAccountId);
      if (index != -1) {
        bankAccounts[index] = updated;
      }
      CustomSnackbar.showSuccess(
        title: 'الحسابات المصرفية',
        message: 'تم تحديث حالة الحساب المصرفي بنجاح',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'الحساب المصرفي',
        message: 'فشل تغيير حالة الحساب: ${e.toString()}',
      );
    }
  }

  /// جلب المصروفات التشغيلية
  Future<void> loadExpenses() async {
    isLoadingExpenses.value = true;
    try {
      final result = await _getExpensesUseCase();
      expenses.assignAll(result);
    } catch (e) {
      CustomSnackbar.showError(
        title: 'المصروفات التشغيلية',
        message: 'تعذر جلب سجل النفقات: ${e.toString()}',
      );
    } finally {
      isLoadingExpenses.value = false;
    }
  }

  /// قيد وتسجيل مصروف تشغيلي جديد
  Future<bool> createExpense({
    required String title,
    required double amount,
    required String category,
    String? notes,
  }) async {
    isCreatingExpense.value = true;
    try {
      final newExpense = await _createExpenseUseCase(
        title: title,
        amount: amount,
        category: category,
        notes: notes,
      );
      expenses.insert(0, newExpense);
      loadOverview(isRefresh: true);
      CustomSnackbar.showSuccess(
        title: 'المصروفات التشغيلية',
        message: 'تم تسجيل المصروف التشغيلي بنجاح',
      );
      return true;
    } catch (e) {
      CustomSnackbar.showError(
        title: 'قيد المصروف',
        message: 'تعذر حفظ المصروف: ${e.toString()}',
      );
      return false;
    } finally {
      isCreatingExpense.value = false;
    }
  }

  /// جلب قائمة الجلسات والأجهزة المصرح بها
  Future<void> loadUserSessions() async {
    isLoadingSessions.value = true;
    try {
      final result = await _getUserSessionsUseCase();
      userSessions.assignAll(result);
    } catch (e) {
      CustomSnackbar.showError(
        title: 'إدارة الجلسات',
        message: 'تعذر استعراض الجلسات النشطة: ${e.toString()}',
      );
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
      CustomAnimationOverlay.showLoading(message: 'جارٍ إنهاء الجلسة...');
      try {
        final success = await _terminateSessionUseCase(sessionId);
        await CustomAnimationOverlay.hide();
        if (success) {
          userSessions.removeWhere((s) => s.sessionId == sessionId);
          loadOverview(isRefresh: true);
          CustomSnackbar.showSuccess(
            title: 'إدارة الجلسات',
            message: 'تم إلغاء صلاحية الجلسة وإخراج الجهاز بنجاح',
          );
        }
      } catch (e) {
        await CustomAnimationOverlay.hide();
        CustomSnackbar.showError(
          title: 'إنهاء الجلسة',
          message: 'تعذر إنهاء الجلسة: ${e.toString()}',
        );
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
