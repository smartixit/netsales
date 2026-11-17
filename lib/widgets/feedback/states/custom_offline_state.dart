import 'package:flutter/material.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// Full-content offline state used when connectivity prevents initial loading.
/// For connectivity loss after content is available, use CustomOfflineBanner.
class CustomOfflineState extends StatelessWidget {
  const CustomOfflineState({
    super.key,
    this.title = 'الاتصال غير متاح',
    this.subtitle = 'تحقق من اتصال الإنترنت ثم أعد المحاولة.',
    this.onRetry,
    this.onOpenSettings,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return CustomStateView.offline(
      title: title,
      subtitle: subtitle,
      presentation: CustomStatePresentation.fullscreen,
      actionLabel: 'إعادة فحص الاتصال',
      onAction: onRetry,
      secondaryActionLabel: onOpenSettings == null ? null : 'إعدادات الشبكة',
      secondaryActionIcon: Icons.settings_outlined,
      onSecondaryAction: onOpenSettings,
    );
  }
}
