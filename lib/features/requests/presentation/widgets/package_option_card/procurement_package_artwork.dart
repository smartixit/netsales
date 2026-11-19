import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_network_artwork_painter.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_voucher_ticket_painter.dart';

/// بطاقة العمل الفني للباقة (Artwork Container with Painters)
class ProcurementPackageArtwork extends StatelessWidget {
  const ProcurementPackageArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124.r,
      height: 124.r,
      child: ClipRRect(
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(25.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF12B88A),
                    Color(0xFF087B61),
                    Color(0xFF03483E),
                  ],
                ),
              ),
            ),
            const CustomPaint(painter: ProcurementNetworkArtworkPainter()),
            Center(
              child: Transform.rotate(
                angle: -.20,
                child: Container(
                  width: 61.r,
                  height: 78.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFBCE9D9)],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .27),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    size: Size(61.r, 78.r),
                    painter: const ProcurementVoucherTicketPainter(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
