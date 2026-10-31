import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';

/// Centralized service for sharing text, links, files and binary data.
class ShareService {
  ShareService._();

  static final ShareService instance = ShareService._();

  /// Share plain text.
  Future shareText({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    return _share(
      ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Share a URL.
  Future shareLink({
    required String url,
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    return _share(
      ShareParams(
        text: text == null ? url : '$text\n$url',
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Share a file from device storage.
  Future shareFile({
    required String filePath,
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw FileSystemException('File does not exist', filePath);
    }

    return _share(
      ShareParams(
        text: text,
        subject: subject,
        files: [XFile(filePath)],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Share multiple files from device storage.
  Future shareFiles({
    required List filePaths,
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    if (filePaths.isEmpty) {
      throw ArgumentError('At least one file is required.');
    }

    List<XFile>? files = [];

    for (final path in filePaths) {
      final file = File(path);

      if (!await file.exists()) {
        throw FileSystemException('File does not exist', path);
      }

      files.add(XFile(path));
    }

    return _share(
      ShareParams(
        text: text,
        subject: subject,
        files: files,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Share binary data directly without saving it first.
  Future shareBytes({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError('File data cannot be empty.');
    }

    return _share(
      ShareParams(
        text: text,
        subject: subject,
        files: [XFile.fromData(bytes, mimeType: mimeType, name: fileName)],
        fileNameOverrides: [fileName],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Internal sharing handler.
  Future _share(ShareParams params) async {
    return SharePlus.instance.share(params);
  }
}
