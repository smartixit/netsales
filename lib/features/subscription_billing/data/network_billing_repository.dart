import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/subscription_billing/domain/entities/network_billing_record.dart';

class NetworkBillingRepository {
  const NetworkBillingRepository();

  Future<List<NetworkBillingRecord>> accounts(int networkId) async {
    final response = await ApiService.instance.get<List<NetworkBillingRecord>>(
      '/networks/$networkId/billing/accounts',
      fromJson: (data) => _records(data),
    );
    if (!response.success || response.data == null) {
      throw StateError(response.message.isEmpty ? 'تعذر تحميل حسابات الفوترة.' : response.message);
    }
    return response.data!;
  }

  Future<List<NetworkBillingRecord>> list({
    required int accountId,
    required String resource,
    Map<String, dynamic> filters = const {},
  }) async {
    final response = await ApiService.instance.get<List<NetworkBillingRecord>>(
      '/billing/accounts/$accountId/$resource',
      queryParameters: {'per_page': 50, ...filters},
      fromJson: (data) => _records(data),
    );
    if (!response.success || response.data == null) {
      throw StateError(response.message.isEmpty ? 'تعذر تحميل بيانات الفوترة.' : response.message);
    }
    return response.data!;
  }

  Future<Map<String, dynamic>> statement({
    required int accountId,
    Map<String, dynamic> filters = const {},
  }) async {
    final response = await ApiService.instance.get<Map<String, dynamic>>(
      '/billing/accounts/$accountId/statement',
      queryParameters: filters,
      fromJson: (data) => Map<String, dynamic>.from(data as Map),
    );
    if (!response.success || response.data == null) {
      throw StateError(response.message.isEmpty ? 'تعذر تحميل كشف الحساب.' : response.message);
    }
    return response.data!;
  }

  Future<List<NetworkBillingRecord>> invoice(int invoiceId) async {
    final response = await ApiService.instance.get<Map<String, dynamic>>(
      '/billing/invoices/$invoiceId',
      fromJson: (data) => Map<String, dynamic>.from(data as Map),
    );
    if (!response.success || response.data == null) {
      throw StateError(response.message.isEmpty ? 'تعذر تحميل الفاتورة.' : response.message);
    }
    return [NetworkBillingRecord(response.data!)];
  }

  static List<NetworkBillingRecord> _records(dynamic data) {
    if (data is List) {
      return data.whereType<Map>()
          .map((row) => NetworkBillingRecord(Map<String, dynamic>.from(row)))
          .toList(growable: false);
    }
    if (data is Map) {
      final rows = data['data'] ?? data['items'] ?? data['records'];
      if (rows is List) return _records(rows);
    }
    return const [];
  }
}
