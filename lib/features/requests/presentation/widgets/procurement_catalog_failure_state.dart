import 'package:flutter/material.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

class ProcurementCatalogFailureState extends StatelessWidget {
  const ProcurementCatalogFailureState({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  final String errorMessage;
  final VoidCallback? onRetry;

  bool get _isOffline {
    final normalized = errorMessage.toLowerCase();
    return normalized.contains('socket') ||
        normalized.contains('network') ||
        normalized.contains('connection') ||
        normalized.contains('internet') ||
        errorMessage.contains('الاتصال') ||
        errorMessage.contains('الإنترنت');
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      return CustomStateView.offline(
        title: 'تعذر الاتصال بكتالوج الشبكة',
        subtitle: 'تحقق من اتصال الإنترنت ثم أعد المحاولة لتحميل الباقات.',
        presentation: CustomStatePresentation.compact,
        onAction: onRetry,
      );
    }

    return CustomStateView.error(
      title: 'تعذر تحميل كتالوج الباقات',
      subtitle: errorMessage,
      presentation: CustomStatePresentation.compact,
      onAction: onRetry,
    );
  }
}
