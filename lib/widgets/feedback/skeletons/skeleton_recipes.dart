import 'package:netsales/widgets/feedback/skeletons/custom_state_skeleton.dart';

/// Named recipes keep call sites concise and prevent layout-specific widgets.
abstract final class SkeletonRecipes {
  static CustomStateSkeleton list({
    int itemCount = 4,
    double cardHeight = 88,
    bool hasLeading = true,
    bool hasTrailing = false,
    int lineCount = 2,
  }) => CustomStateSkeleton(
    layout: CustomStateSkeletonLayout.list,
    itemCount: itemCount,
    cardHeight: cardHeight,
    hasLeading: hasLeading,
    hasTrailing: hasTrailing,
    lineCount: lineCount,
  );

  static CustomStateSkeleton cards({
    int itemCount = 4,
    double cardHeight = 140,
    double minItemWidth = 220,
    int maxColumns = 2,
  }) => CustomStateSkeleton(
    layout: CustomStateSkeletonLayout.cards,
    itemCount: itemCount,
    cardHeight: cardHeight,
    minItemWidth: minItemWidth,
    maxColumns: maxColumns,
  );

  static CustomStateSkeleton grid({
    int itemCount = 6,
    double cardHeight = 116,
    double minItemWidth = 180,
    int maxColumns = 3,
  }) => CustomStateSkeleton(
    layout: CustomStateSkeletonLayout.grid,
    itemCount: itemCount,
    cardHeight: cardHeight,
    minItemWidth: minItemWidth,
    maxColumns: maxColumns,
  );

  static CustomStateSkeleton detail({
    int itemCount = 3,
    double cardHeight = 64,
  }) => CustomStateSkeleton(
    layout: CustomStateSkeletonLayout.detail,
    itemCount: itemCount,
    cardHeight: cardHeight,
  );
}
