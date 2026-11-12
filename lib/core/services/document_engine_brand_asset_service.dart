import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/services/api_service.dart';

/// Resolves tenant branding images for generated business documents.
///
/// Tenant image requests are restricted to the configured API origin so that
/// authenticated Dio headers are never forwarded to arbitrary hosts. A
/// bundled application mark is used only when a valid tenant image is absent.
class DocumentEngineBrandAssetService {
  DocumentEngineBrandAssetService._();

  static final DocumentEngineBrandAssetService instance =
      DocumentEngineBrandAssetService._();

  static const int _maxLogoBytes = 2 * 1024 * 1024;

  Future<Uint8List>? _applicationIconFuture;

  Future<Uint8List> resolveLogoBytes(String? rawUrl) async {
    final tenantLogo = await _downloadTenantLogo(rawUrl);
    if (tenantLogo != null) return tenantLogo;
    return _loadApplicationIcon();
  }

  Future<Uint8List?> _downloadTenantLogo(String? rawUrl) async {
    final source = rawUrl?.trim();
    if (source == null || source.isEmpty) return null;

    final resolved = ApiService.resolveStorageUrl(source);
    final uri = Uri.tryParse(resolved);
    final apiUri = Uri.tryParse(ApiConstants.baseUrl);

    // Do not send the authenticated API client's headers to another origin.
    if (uri == null ||
        apiUri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.origin != apiUri.origin) {
      return null;
    }

    try {
      final response = await ApiService.instance.dio.get<List<int>>(
        uri.toString(),
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: const Duration(seconds: 12),
          headers: const {'Accept': 'image/png,image/jpeg'},
        ),
      );
      final bytes = response.data;
      if (response.statusCode != 200 ||
          bytes == null ||
          bytes.isEmpty ||
          bytes.length > _maxLogoBytes ||
          !_isPngOrJpeg(bytes)) {
        return null;
      }
      return Uint8List.fromList(bytes);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _loadApplicationIcon() async {
    final future = _applicationIconFuture ??= _readApplicationIcon();
    return Uint8List.fromList(await future);
  }

  Future<Uint8List> _readApplicationIcon() async {
    final data = await rootBundle.load('assets/images/brand_icon.png');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  static bool _isPngOrJpeg(List<int> bytes) {
    final png = bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
    final jpeg = bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
    return png || jpeg;
  }
}
