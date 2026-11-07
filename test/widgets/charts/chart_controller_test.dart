import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/charts/charting.dart';

void main() {
  test('detaches only the controller owner currently attached', () {
    final controller = ChartController();
    final firstOwner = Object();
    final secondOwner = Object();
    var firstReset = 0;
    var secondReset = 0;

    controller.attach(
      owner: firstOwner,
      reset: () => firstReset++,
      zoomIn: () {},
      zoomOut: () {},
      pan: (_) {},
    );
    controller.attach(
      owner: secondOwner,
      reset: () => secondReset++,
      zoomIn: () {},
      zoomOut: () {},
      pan: (_) {},
    );

    controller.detach(firstOwner);
    controller.resetZoom();

    expect(firstReset, 0);
    expect(secondReset, 1);
    expect(controller.isAttached, isTrue);

    controller.detach(secondOwner);
    expect(controller.isAttached, isFalse);
    controller.resetZoom();
    expect(secondReset, 1);
  });
}
