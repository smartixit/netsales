import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../src/models/chart_data_point.dart';
import '../src/realtime/chart_live_data_source.dart';

/// Local-only data and presentation controls for the developer chart lab.
class ChartsShowcaseController extends GetxController {
  final isDarkMode = false.obs;
  final isRtl = false.obs;
  final liveTick = 0.obs;
  late final ChartLiveDataSource<ChartDataPoint> liveSales =
      ChartLiveDataSource<ChartDataPoint>(
        initialData: List<ChartDataPoint>.generate(
          12,
          (index) => ChartDataPoint(x: 'نقطة \${index + 1}', y: 30 + index * 2),
        ),
        maxDataPoints: 24,
      );
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      final tick = liveTick.value + 1;
      liveTick.value = tick;
      final random = math.Random(tick);
      liveSales.append(
        ChartDataPoint(x: 'نقطة \${tick + 12}', y: 30 + random.nextInt(55)),
      );
    });
  }

  void setDarkMode(bool value) => isDarkMode.value = value;
  void setRtl(bool value) => isRtl.value = value;

  @override
  void onClose() {
    _timer?.cancel();
    liveSales.dispose();
    super.onClose();
  }
}
