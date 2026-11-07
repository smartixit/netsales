import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/charts/showcase/charts_showcase_controller.dart';

void main() {
  group('ChartsShowcaseController labels', () {
    test('formats initial and live point labels without interpolation leaks', () {
      expect(ChartsShowcaseController.pointLabel(1), 'نقطة 1');
      expect(ChartsShowcaseController.pointLabel(13), 'نقطة 13');
    });
  });
}
