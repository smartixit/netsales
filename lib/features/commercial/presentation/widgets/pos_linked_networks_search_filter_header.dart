import 'package:flutter/material.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_search_filter_header.dart';

/// شريط البحث والفلترة العلوية للشبكات المزودة المرتبطة بنقطة البيع
class PosLinkedNetworksSearchFilterHeader extends StatelessWidget {
  const PosLinkedNetworksSearchFilterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommercialSearchFilterHeader(
      label: 'البحث عن شبكة مزودة',
      hint: 'ابحث باسم الشبكة أو هاتفها...',
    );
  }
}
