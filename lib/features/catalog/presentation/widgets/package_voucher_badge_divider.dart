import 'package:flutter/material.dart';

/// فاصل رأسي شفاف بين شارات الكرت الرقمي (Package Voucher Badge Divider)
class PackageVoucherBadgeDivider extends StatelessWidget {
  const PackageVoucherBadgeDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}
