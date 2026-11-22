import 'package:flutter/material.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// عرض ثابت لطريقة التسوية الوحيدة المدعومة في طلبات التوريد.
class ProcurementSaleTypeSelector extends StatelessWidget {
  const ProcurementSaleTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final presentation = EnumPresentationRegistry.resolveSaleType(
      SaleType.cash,
    );
    return CustomStatusBadge.fromPresentation(presentation);
  }
}
