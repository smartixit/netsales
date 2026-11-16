import 'package:netsales/widgets/carousels/custom_carousel_card.dart';

class WorkspaceCarouselTheme {
  const WorkspaceCarouselTheme._();

  static CustomCarouselCardTheme resolve({
    required int index,
    required bool selected,
  }) {
    if (selected) return CustomCarouselCardTheme.emerald;

    switch (index % 3) {
      case 0:
        return CustomCarouselCardTheme.sapphire;
      case 1:
        return CustomCarouselCardTheme.amethyst;
      default:
        return CustomCarouselCardTheme.titanium;
    }
  }
}
