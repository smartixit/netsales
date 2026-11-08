import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

void main() {
  group('RxValueListenable', () {
    test('reflects GetX changes and writes selections back to Rx', () async {
      final selectedValue = RxnInt();
      final valueListenable = RxValueListenable<int?>(selectedValue);
      var notifications = 0;

      void listener() {
        notifications++;
      }

      valueListenable.addListener(listener);

      selectedValue.value = 12;
      await Future<void>.delayed(Duration.zero);

      expect(valueListenable.value, 12);
      expect(notifications, 1);

      valueListenable.value = 24;
      await Future<void>.delayed(Duration.zero);

      expect(selectedValue.value, 24);
      expect(notifications, 2);

      valueListenable.removeListener(listener);
      valueListenable.dispose();

      selectedValue.value = 36;
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 2);
      expect(valueListenable.value, 36);
    });
  });
}
