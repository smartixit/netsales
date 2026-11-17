import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';
import 'package:netsales/widgets/feedback/skeletons/custom_state_skeleton.dart';

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
    final skeletonContent = builder?.call(context) ??
        switch (recipe.layout) {
          CustomStateSkeletonLayout.list => _buildList(context),
          CustomStateSkeletonLayout.cards => _buildResponsiveCollection(context),
          CustomStateSkeletonLayout.grid => _buildResponsiveCollection(context),
          CustomStateSkeletonLayout.detail => _buildDetail(context),
        };

    return CustomSkeletonShimmer(child: skeletonContent);
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
            .clamp(1, recipe.maxColumns)
            .toInt();
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
