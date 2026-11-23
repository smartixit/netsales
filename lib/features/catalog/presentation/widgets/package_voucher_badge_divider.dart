import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// فاصل رأسي شفاف بين شارات الكرت الرقمي (Package Voucher Badge Divider)
class PackageVoucherBadgeDivider extends StatelessWidget {
  const PackageVoucherBadgeDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 16.h,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}
