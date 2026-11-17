import 'package:flutter/material.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// واجهة توافقية للتحميل؛ يمكن إبقاء Skeleton مخصص عند تحميل القوائم.
class CustomLoadingState extends StatelessWidget {
  const CustomLoadingState({
    super.key,
    this.message,
    this.useSkeleton = false,
    this.skeleton,
  });

  final String? message;
  final bool useSkeleton;
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) {
    if (useSkeleton && skeleton != null) return skeleton!;
    return CustomStateView.loading(
      title: message ?? 'جارٍ تحميل البيانات',
      subtitle: 'نجهّز المحتوى المطلوب، يرجى الانتظار.',
      presentation: CustomStatePresentation.fullscreen,
      showLoadingSkeleton: false,
    );
  }
}
