/// Content-shaped skeleton layouts shared by lists, cards, grids and details.
enum CustomStateSkeletonLayout { list, cards, grid, detail, text }

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
