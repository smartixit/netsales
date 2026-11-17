import 'package:flutter/material.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// Shared cursor-pagination tail: inline skeleton, retry state, or load action.
class CustomCursorLoadMore extends StatelessWidget {
  const CustomCursorLoadMore({
    required this.hasMore,
    required this.isLoading,
    required this.error,
    required this.onPressed,
    this.label = 'تحميل المزيد',
    this.retryLabel = 'إعادة المحاولة',
    this.errorTitle = 'تعذر تحميل بقية السجلات',
    super.key,
  });

  final bool hasMore;
  final bool isLoading;
  final String? error;
  final VoidCallback onPressed;
  final String label;
  final String retryLabel;
  final String errorTitle;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CustomStateView.loading(
        presentation: CustomStatePresentation.skeletonOnly,
        skeleton: CustomStateSkeleton(
          layout: CustomStateSkeletonLayout.list,
          itemCount: 1,
          cardHeight: 64,
          hasLeading: false,
          lineCount: 2,
          showCardSurface: false,
        ),
      );
    }
    if (error != null) {
      return CustomErrorState.compact(
        title: errorTitle,
        subtitle: error,
        retryLabel: retryLabel,
        onRetry: onPressed,
      );
    }
    if (!hasMore) return const SizedBox.shrink();
    return Center(
      child: CustomButton.outline(
        text: label,
        suffix: Icons.expand_more_rounded,
        onPressed: onPressed,
      ),
    );
  }
}
