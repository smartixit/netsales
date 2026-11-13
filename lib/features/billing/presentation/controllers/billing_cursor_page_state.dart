import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Cursor-backed state for one independently pageable billing collection.
class BillingCursorPageState {
  BillingCursorPageState({required this.identityKey});

  final String identityKey;
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString loadMoreError = RxnString();
  String? nextCursor;
  int _revision = 0;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  int beginRefresh({bool clearItems = false}) {
    _revision++;
    if (clearItems) items.clear();
    nextCursor = null;
    isLoadingMore.value = false;
    loadMoreError.value = null;
    return _revision;
  }

  int reset() => beginRefresh(clearItems: true);

  int replace(Map<String, dynamic> page) {
    final revision = beginRefresh(clearItems: true);
    final rows = _extractRows(page);
    items.assignAll(_deduplicate(rows));
    nextCursor = _extractNextCursor(page);
    return revision;
  }

  void append(Map<String, dynamic> page, {required int revision}) {
    if (revision != _revision) return;
    final known = items
        .map((row) => row[identityKey]?.toString())
        .whereType<String>()
        .toSet();
    for (final row in _extractRows(page)) {
      final identity = row[identityKey]?.toString();
      if (identity == null || known.add(identity)) {
        items.add(row);
      }
    }
    nextCursor = _extractNextCursor(page);
    loadMoreError.value = null;
  }

  int get revision => _revision;

  static List<Map<String, dynamic>> _extractRows(
    Map<String, dynamic> page,
  ) {
    dynamic raw = page['data'] ?? page['items'];
    if (raw is Map<String, dynamic>) {
      raw = raw['data'] ?? raw['items'];
    }
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _deduplicate(
    List<Map<String, dynamic>> rows,
  ) {
    final seen = <String>{};
    return rows.where((row) {
      final identity = row[identityKey]?.toString();
      return identity == null || seen.add(identity);
    }).toList(growable: false);
  }

  static String? _extractNextCursor(Map<String, dynamic> page) {
    dynamic next = page['next_page_url'];
    dynamic links = page['links'];
    if (next == null && links is Map) next = links['next'];
    if (next == null && page['data'] is Map) {
      final nested = Map<String, dynamic>.from(page['data'] as Map);
      next = nested['next_page_url'];
      final nestedLinks = nested['links'];
      if (next == null && nestedLinks is Map) next = nestedLinks['next'];
    }
    if (next is! String || next.isEmpty) return null;
    return Uri.tryParse(next)?.queryParameters['cursor'];
  }

  @visibleForTesting
  void dispose() {
    items.close();
    isLoadingMore.close();
    loadMoreError.close();
  }
}
