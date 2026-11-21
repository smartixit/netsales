import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';

class PosActiveSupplyOrderViewModel {
  const PosActiveSupplyOrderViewModel({
    required this.request,
    required this.reference,
    required this.statusPresentation,
    required this.formattedAmount,
  });

  final RequestEntity request;
  final String reference;
  final EnumPresentation statusPresentation;
  final String formattedAmount;
}
