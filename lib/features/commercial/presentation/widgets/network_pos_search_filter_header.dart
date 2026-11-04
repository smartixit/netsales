import 'package:flutter/material.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_search_filter_header.dart';

/// شريط البحث والفلترة العلوية لدليل نقاط البيع بمساحة عمل الشبكة
class NetworkPosSearchFilterHeader extends StatelessWidget {
  const NetworkPosSearchFilterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommercialSearchFilterHeader(
      label: 'البحث عن نقطة بيع',
      hint: 'ابحث بالاسم، المعرف UUID، أو رقم الهاتف...',
    );
  }
}
