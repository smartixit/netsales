import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Search and status criteria owned by one cursor collection only.
class BillingCollectionFilterState {
  BillingCollectionFilterState({
    required this.statusValues,
  });

  final List<String> statusValues;
  final TextEditingController searchController = TextEditingController();
  final RxnString selectedStatus = RxnString();

  Timer? _debounce;
  String _search = '';

  String get search => _search;

  Map<String, dynamic> get queryParameters => {
        if (_search.isNotEmpty) 'search': _search,
        if ((selectedStatus.value ?? '').isNotEmpty)
          'status': selectedStatus.value,
      };

  void onSearchChanged(
    String value,
    Future<void> Function() reload,
  ) {
    _search = value.trim();
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => unawaited(reload()),
    );
  }

  Future<void> onStatusChanged(
    String? value,
    Future<void> Function() reload,
  ) async {
    _debounce?.cancel();
    selectedStatus.value =
        value == null || value.isEmpty ? null : value;
    await reload();
  }

  void reset({bool clearStatus = true}) {
    _debounce?.cancel();
    _search = '';
    searchController.clear();
    if (clearStatus) selectedStatus.value = null;
  }

  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    selectedStatus.close();
  }
}
