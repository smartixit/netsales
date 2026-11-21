import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/commercial/data/models/network_linkable_pos_model.dart';

void main() {
  group('NetworkLinkablePosModel', () {
    test('parses only the minimal exact POS identity projection', () {
      final model = NetworkLinkablePosModel.fromJson({
        'pos_id': 31,
        'pos_uuid': 'POS-2611-00031-A1B2',
        'pos_name': 'نقطة الاختبار',
      });

      expect(model.posId, 31);
      expect(model.posUuid, 'POS-2611-00031-A1B2');
      expect(model.posName, 'نقطة الاختبار');
      expect(model.props, [31, 'POS-2611-00031-A1B2', 'نقطة الاختبار']);
    });
  });
}
