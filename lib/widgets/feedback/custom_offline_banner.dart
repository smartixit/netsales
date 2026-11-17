import 'package:flutter/material.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// شريط موحّد وغير معرقل لحالة فقد الاتصال.
class CustomOfflineBanner extends StatelessWidget {
  const CustomOfflineBanner({super.key, required this.isOffline});

  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return const CustomStateView.offline(
      presentation: CustomStatePresentation.banner,
      title: 'أنت غير متصل بالإنترنت حالياً',
    );
  }
}
