# premium_carousel_slider

A reusable Flutter carousel package built on top of `carousel_slider`.

## Install

Add the package from a local path, Git repository, or your package registry:

```yaml
dependencies:
  premium_carousel_slider:
    path: packages/premium_carousel_slider
```

## Basic usage

```dart
PremiumCarouselSlider<Product>(
  items: products,
  itemBuilder: (context, product, index) {
    return ProductCard(product: product);
  },
  options: const PremiumCarouselOptions(
    height: 184,
    viewportFraction: 0.86,
    enableInfiniteScroll: false,
    autoPlay: false,
    enlargeCenterPage: true,
  ),
  onPageChanged: (index) {
    // Update the selected item in your state management solution.
  },
)
```

## Cursor pagination

Use the trailing slot to keep the loading affordance inside the horizontal list:

```dart
PremiumCarouselSlider<Product>(
  items: products,
  itemBuilder: (context, product, index) => ProductCard(product: product),
  hasMoreItems: hasMore,
  loadingItemBuilder: (_) => const ProductCardSkeleton(),
  onLoadMore: loadNextCursorPage,
)
```

## Programmatic control

Create one `PremiumCarouselController` in your view/state controller and pass it
to the widget. Use `animateToPage`, `nextPage`, `previousPage`, or
`jumpToPage` to control the carousel.

The package is independent of GetX, NetSales design tokens, and any business
domain. Card presentation remains entirely owned by the consuming application.
