import 'package:flutter/material.dart';
import 'package:netsales/widgets/qr/custom_qr_code.dart';

/// بطاقة دعوة قابلة للتصدير، لا تعرض أي بيانات تعريفية أو أمنية عن التحدي.
class CustomQrShareCard extends StatelessWidget {
  const CustomQrShareCard({
    super.key,
    required this.payload,
  });

  final String payload;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: const Color(0xFFF3F7F5),
        child: SizedBox(
          width: 1080,
          height: 1350,
          child: Padding(
            padding: const EdgeInsets.all(64),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(42),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x160B3328),
                    blurRadius: 36,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 190,
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    decoration: const BoxDecoration(
                      color: Color(0xFF103F35),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(42),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Image.asset(
                            'assets/images/brand_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 28),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NetSales',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'NETWORK SALES MANAGEMENT',
                                style: TextStyle(
                                  color: Color(0xFFD6E9E1),
                                  fontSize: 16,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'دعوة ربط تجارية',
                    style: TextStyle(
                      color: Color(0xFF173F35),
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'امسح الرمز من داخل تطبيق NetSales لإتمام عملية الربط',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF62746D),
                      fontSize: 20,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFE3ECE7),
                        width: 2,
                      ),
                    ),
                    child: CustomQrCode(
                      data: payload,
                      size: 440,
                      decoration: QrCodeService.brandDecoration,
                    ),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60),
                    child: Text(
                      'افتح ماسح QR داخل التطبيق ووجّه الكاميرا نحو الرمز',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF52665D),
                        fontSize: 22,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 120,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF103F35),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(42),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'NetSales',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'إدارة أعمال الشبكات ونقاط البيع بذكاء',
                          style: TextStyle(
                            color: Color(0xFFD6E9E1),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
