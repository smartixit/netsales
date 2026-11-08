import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expenses_use_case.dart';

class NetworkOperatingExpensesController extends GetxController {
  final GetExpensesUseCase getExpensesUseCase;

  NetworkOperatingExpensesController({required this.getExpensesUseCase});

  final expenses = <ExpenseEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final loadMoreErrorMessage = RxnString();
  final searchQuery = ''.obs;

  String? _nextCursor;
  int _requestGeneration = 0;
  bool _hasLoaded = false;

  bool get hasMore => _nextCursor?.isNotEmpty ?? false;

  @override
  void onInit() {
    super.onInit();
    loadExpenses(refresh: true);
  }

  Future<void> loadExpenses({bool refresh = false}) async {
    final generation = ++_requestGeneration;
    if (refresh) {
      _nextCursor = null;
      _hasLoaded = false;
      errorMessage.value = null;
      loadMoreErrorMessage.value = null;
      isLoading.value = true;
    } else if (isLoading.value || !_hasLoaded || !hasMore) {
      return;
    } else {
      isLoadingMore.value = true;
      loadMoreErrorMessage.value = null;
    }

    try {
      final page = await getExpensesUseCase(
        networkId: _networkId,
        search: searchQuery.value,
        cursor: refresh ? null : _nextCursor,
      );
      if (generation != _requestGeneration) return;
      if (refresh) {
        expenses.assignAll(page.items);
      } else {
        final ids = expenses.map((item) => item.expenseId).toSet();
        expenses.addAll(page.items.where((item) => ids.add(item.expenseId)));
      }
      _nextCursor = page.nextCursor;
      _hasLoaded = true;
    } catch (error) {
      if (generation != _requestGeneration) return;
      if (refresh) {
        errorMessage.value = error.toString();
      } else {
        loadMoreErrorMessage.value = error.toString();
      }
    } finally {
      if (generation == _requestGeneration) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  int get _networkId {
    // The screen must supply an explicitly selected network ID before this controller loads.
    return Get.arguments is Map<String, dynamic>
        ? (Get.arguments['networkId'] as int? ?? 0)
        : 0;
  }

  Future<void> search(String value) async {
    searchQuery.value = value;
    await loadExpenses(refresh: true);
  }

  Future<void> retry() => loadExpenses(refresh: true);
  Future<void> loadMore() => loadExpenses();
}
