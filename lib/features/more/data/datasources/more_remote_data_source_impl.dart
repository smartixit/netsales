import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/more/data/datasources/more_remote_data_source.dart';
import 'package:netsales/features/more/data/models/bank_account_model.dart';
import 'package:netsales/features/more/data/models/expense_model.dart';
import 'package:netsales/features/more/data/models/more_overview_model.dart';
import 'package:netsales/features/more/data/models/more_subscription_model.dart';
import 'package:netsales/features/more/data/models/more_wallet_model.dart';
import 'package:netsales/features/more/data/models/user_session_model.dart';

/// ============================================================================
/// تطبيق مصدر البيانات البعيد لقطاع المزيد (MoreRemoteDataSourceImpl)
/// ============================================================================
class MoreRemoteDataSourceImpl implements MoreRemoteDataSource {
  const MoreRemoteDataSourceImpl();

  @override
  Future<ApiResponse<MoreOverviewModel>> getMoreOverview() async {
    return ApiService.instance.get<MoreOverviewModel>(
      ApiConstants.dashboardOverview,
      fromJson: (json) => MoreOverviewModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ApiResponse<MoreWalletModel>> getWalletSummary() async {
    return ApiService.instance.get<MoreWalletModel>(
      ApiConstants.networkWallets,
      fromJson: (json) => MoreWalletModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ApiResponse<MoreSubscriptionModel>> getActiveSubscription() async {
    return ApiService.instance.get<MoreSubscriptionModel>(
      ApiConstants.providerSubscriptions,
      fromJson: (json) => MoreSubscriptionModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ApiResponse<void>> logout() async {
    return ApiService.instance.post<void>(
      ApiConstants.logout,
    );
  }

  @override
  Future<ApiResponse<List<BankAccountModel>>> getBankAccounts() async {
    return ApiService.instance.getList<BankAccountModel>(
      ApiConstants.bankAccounts,
      fromJson: (json) => BankAccountModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ApiResponse<BankAccountModel>> toggleBankAccountStatus(
      int accountId) async {
    return ApiService.instance.post<BankAccountModel>(
      ApiConstants.bankAccountToggleStatus(accountId),
      fromJson: (json) => BankAccountModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ApiResponse<List<ExpenseModel>>> getExpenses({
    int page = 1,
    int perPage = 20,
  }) async {
    return ApiService.instance.getList<ExpenseModel>(
      ApiConstants.expenses,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (json) => ExpenseModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ApiResponse<ExpenseModel>> createExpense({
    required int networkId,
    required double totalAmount,
    String? expenseDate,
    String? notes,
  }) async {
    return ApiService.instance.post<ExpenseModel>(
      ApiConstants.expenses,
      data: {
        'network_id': networkId,
        'expense_total_amount': totalAmount,
        if (expenseDate != null) 'expense_date': expenseDate,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
      fromJson: (json) => ExpenseModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ApiResponse<List<UserSessionModel>>> getUserSessions(
      int userId) async {
    return ApiService.instance.getList<UserSessionModel>(
      ApiConstants.securityUserSessions(userId),
      fromJson: (json) => UserSessionModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ApiResponse<void>> terminateSession(int sessionId) async {
    return ApiService.instance.post<void>(
      ApiConstants.securityTerminateSession(sessionId),
    );
  }
}

