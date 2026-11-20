import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/api_response.dart';

void main() {
  group('ApiResponse HTTP status preservation', () {
    test('fromJson keeps the HTTP status code', () {
      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        {'success': true, 'message': 'ok', 'data': {'id': 1}},
        (value) => Map<String, dynamic>.from(value! as Map),
        statusCode: 200,
      );

      expect(response.success, isTrue);
      expect(response.statusCode, 200);
      expect(response.data?['id'], 1);
    });

    test('fromSimpleJson keeps an authorization rejection status', () {
      final response = ApiResponse<void>.fromSimpleJson(
        {'success': false, 'message': 'Unauthorized'},
        statusCode: 401,
      );

      expect(response.success, isFalse);
      expect(response.statusCode, 401);
    });
  });
}
