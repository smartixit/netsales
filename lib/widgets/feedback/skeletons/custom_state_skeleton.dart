import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';

/// Content-shaped skeleton layouts shared by lists, cards, grids and details.
enum CustomStateSkeletonLayout { list, cards, grid, detail }

/// Immutable recipe describing the geometry of a loading placeholder.
///
/// This class contains configuration only. Rendering and animation are kept
/// in [CustomStateSkeletonView] and [CustomSkeletonShimmer], respectively.
class CustomStateSkeleton {
  const CustomStateSkeleton({
    this.layout = CustomStateSkeletonLayout.list,
    this.itemCount = 4,
    this.cardHeight = 88,
    this.minItemWidth = 180,
    this.maxColumns = 3,
    this.spacing = 12,
    this.lineCount = 2,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.showCardSurface = true,
  }) : assert(itemCount > 0),
       assert(cardHeight > 0),
       assert(minItemWidth > 0),
       assert(maxColumns > 0),
       assert(lineCount > 0);

  final CustomStateSkeletonLayout layout;
  final int itemCount;
  final double cardHeight;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;
  final int lineCount;
  final bool hasLeading;
  final bool hasTrailing;
  final bool showCardSurface;
}

/// Renders a skeleton recipe without owning the shimmer animation lifecycle.
class CustomStateSkeletonView extends StatelessWidget {
  const CustomStateSkeletonView({
    super.key,
    required this.recipe,
    this.builder,
  });

  final CustomStateSkeleton recipe;
  final WidgetBuilder? builder;

  @override
  Widget build(BuildContext context) {
    if (builder != null) return builder!(context);

    return CustomSkeletonShimmer(
      child: switch (recipe.layout) {
        CustomStateSkeletonLayout.list => _buildList(context),
        CustomStateSkeletonLayout.cards => _buildResponsiveCollection(context),
        CustomStateSkeletonLayout.grid => _buildResponsiveCollection(context),
        CustomStateSkeletonLayout.detail => _buildDetail(context),
      },
    );
  }

  Widget _buildList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        recipe.itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index == recipe.itemCount - 1 ? 0 : recipe.spacing.h,
          ),
          child: _buildItem(context, width: double.infinity),
        ),
      ),
    );
  }

  Widget _buildResponsiveCollection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : recipe.minItemWidth.w * recipe.maxColumns;
        final spacing = recipe.spacing.w;
        final minWidth = recipe.minItemWidth.w;
        final columns = ((availableWidth + spacing) / (minWidth + spacing))
            .floor()
            .clamp(1, recipe.maxColumns);
        final itemWidth =
            (availableWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(
            recipe.itemCount,
            (_) => _buildItem(context, width: itemWidth),
          ),
        );
      },
    );
  }

  Widget _buildDetail(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _placeholder(context, height: 24, widthFactor: .48),
        AppSpacing.vMd,
        _buildItem(context, width: double.infinity),
        AppSpacing.vSm,
        ...List.generate(
          recipe.itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index == recipe.itemCount - 1 ? 0 : recipe.spacing.h,
            ),
            child: _buildItem(
              context,
              width: double.infinity,
              compact: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required double width,
    bool compact = false,
  }) {
    final colors = context.colors;
    final content = Row(
      children: [
        if (recipe.hasLeading) ...[
          _placeholder(
            context,
            height: compact ? 34 : 44,
            width: compact ? 34 : 44,
            circular: true,
          ),
          AppSpacing.hSm,
        ],
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(recipe.lineCount, (index) {
              final factor = index == recipe.lineCount - 1 ? .52 : .88;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == recipe.lineCount - 1 ? 0 : 8.h,
                ),
                child: FractionallySizedBox(
                  widthFactor: factor,
                  alignment: AlignmentDirectional.centerStart,
                  child: _placeholder(
                    context,
                    height: index == 0 ? 11 : 8,
                  ),
                ),
              );
            }),
          ),
        ),
        if (recipe.hasTrailing) ...[
          AppSpacing.hSm,
          _placeholder(context, height: 28, width: 52),
        ],
      ],
    );

    return SizedBox(
      width: width,
      height: recipe.cardHeight.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: recipe.showCardSurface
              ? colors.surfaceContainerLow
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.card.r),
          border: recipe.showCardSurface
              ? Border.all(
                  color: colors.outlineVariant.withValues(alpha: .30),
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: content,
        ),
      ),
    );
  }

  Widget _placeholder(
    BuildContext context, {
    double height = 10,
    double? width,
    double? widthFactor,
    bool circular = false,
  }) {
    final colors = context.colors;
    final shape = BoxDecoration(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(
        circular ? AppRadius.full : AppRadius.xs,
      ),
    );
    final child = Container(height: height.h, width: width?.w, decoration: shape);
    if (widthFactor != null) {
      return FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: AlignmentDirectional.centerStart,
        child: child,
      );
    }
    return child;
  }
}

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
