import 'package:netsales/features/requests/domain/entities/procurement_quote_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// استخدام جلب واستعراض عرض الأسعار الرسمي المعتمد سيادياً من الخادم لطلب التوريد
class GetProcurementQuoteUseCase {
  final RequestRepository repository;

  const GetProcurementQuoteUseCase(this.repository);

  Future<ProcurementQuoteEntity> call(Map<String, dynamic> payload) {
    return repository.getQuote(payload);
  }
}

