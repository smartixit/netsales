import 'dart:convert';
import 'dart:typed_data';

import 'package:document_engine/document_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const b64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j5ZkAAAAASUVORK5CYII=';
  test('QR payload is opaque and bounded', () {
    final qr = DocumentQrCode(payload: 'https://verify.example/d/opaque-id');
    expect(qr.payload, 'https://verify.example/d/opaque-id');
    expect(qr.sizePoints, 96);
    expect(() => DocumentQrCode(payload: ' '), throwsArgumentError);
    expect(
      () => DocumentQrCode(payload: List<String>.filled(2049, 'x').join()),
      throwsArgumentError,
    );
  });

  test('signature image bytes are defensively copied', () {
    final expected = Uint8List.fromList(
      base64.decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j5ZkAAAAASUVORK5CYII=',
      ),
    );
    final source = Uint8List.fromList(expected);
    final signature = DocumentSignatureArea(
      label: 'Authorized by',
      signerName: 'Example User',
      roleLabel: 'Finance Manager',
      approvalReference: 'APR-2026-01',
      approvedAt: DateTime.utc(2026),
      visualSignatureBytes: source,
    );
    source[0] = 99;
    expect(signature.visualSignatureBytes, expected);
    final copy = signature.visualSignatureBytes!;
    copy[1] = 99;
    expect(signature.visualSignatureBytes, expected);
  });

  test('Cartesian chart series enforce the documented 24-point limit', () {
    List<DocumentChartPoint> points(int count) => [
      for (var index = 0; index < count; index++)
        DocumentChartPoint(label: 'P$index', value: index.toDouble()),
    ];

    expect(
      () => DocumentChart(
        title: 'Within limit',
        type: DocumentChartType.line,
        series: [
          DocumentChartSeries(
            id: 'series',
            label: 'Series',
            points: points(24),
          ),
        ],
      ),
      returnsNormally,
    );
    expect(
      () => DocumentChart(
        title: 'Over limit',
        type: DocumentChartType.line,
        series: [
          DocumentChartSeries(
            id: 'series',
            label: 'Series',
            points: points(25),
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('watermark uses bounded defensive-copied PNG/JPEG image bytes', () {
    final source = Uint8List.fromList(base64.decode('$b64'));
    final watermark = DocumentWatermark(imageBytes: source, opacity: 0.1);
    source[0] = 0;
    expect(watermark.imageBytes.first, 0x89);
    final returned = watermark.imageBytes;
    returned[0] = 0;
    expect(watermark.imageBytes.first, 0x89);
    expect(
      () => DocumentWatermark(imageBytes: Uint8List(0)),
      throwsArgumentError,
    );
    expect(
      () => DocumentWatermark(
        imageBytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsArgumentError,
    );
    expect(
      () => DocumentWatermark(
        imageBytes: Uint8List.fromList(base64.decode('$b64')),
        opacity: 0.9,
      ),
      throwsArgumentError,
    );
  });

  test('receipt profiles express explicit fixed-height PDF geometry', () {
    final narrow = DocumentPageProfile.receipt58mm(heightPoints: 420);
    final wide = DocumentPageProfile.receipt80mm(heightPoints: 500);
    expect(narrow.widthPoints, closeTo(164.4, 0.2));
    expect(wide.widthPoints, closeTo(226.8, 0.2));
    expect(narrow.heightPoints, 420);
    expect(
      () => DocumentPageProfile.receipt58mm(heightPoints: 100),
      throwsArgumentError,
    );
  });
}
