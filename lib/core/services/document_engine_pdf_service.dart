import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:document_engine/document_engine.dart';
import 'package:netsales/core/services/document_engine_brand_asset_service.dart';
import 'package:netsales/core/services/document_engine_font_service.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// Shared application boundary for official PDFs.
///
/// Owns the approved IBM Plex Sans Arabic assets and Payv shaping provider;
/// feature services supply document meaning and never select a fallback font.
class DocumentEnginePdfService {
  DocumentEnginePdfService._();

  static final DocumentEnginePdfService instance = DocumentEnginePdfService._();

  Future<DocumentBranding> loadBranding({
    required String organizationName,
    required String tagline,
    String? logoUrl,
  }) async {
    final logo = await DocumentEngineBrandAssetService.instance
        .resolveLogoBytes(logoUrl);
    final fonts = DocumentEngineFontService.instance;

    return DocumentBranding(
      organizationName: organizationName,
      tagline: tagline,
      primaryColor: _hex(AppColors.lightColors.primary),
      secondaryColor: _hex(AppColors.lightColors.secondary),
      accentColor: _hex(AppColors.lightColors.tertiary),
      surfaceColor: _hex(AppColors.lightColors.surface),
      textColor: _hex(AppColors.lightColors.onSurface),
      mutedTextColor: _hex(AppColors.lightColors.onSurfaceVariant),
      logoBytes: logo,
      fonts: await fonts.loadArabicBrandingFonts(),
    );
  }

  Future<Uint8List> render({
    required DocumentSnapshot snapshot,
    required DocumentTemplateDefinition template,
    required DocumentRenderOptions options,
  }) async {
    final result = await PdfDocumentRenderer(
      textShapingProvider: await DocumentEngineFontService.instance
          .arabicTextShapingProvider(),
    ).render(
      snapshot: snapshot,
      template: template,
      options: options,
    );

    if (result is DocumentRenderSuccess) return result.artifact.bytes;
    if (result is DocumentRenderFailure) throw StateError(result.message);
    throw StateError('تعذر إنشاء مستند PDF.');
  }

  static String _hex(Color color) => (color.toARGB32() & 0x00FFFFFF)
      .toRadixString(16)
      .padLeft(6, '0')
      .toUpperCase();
}
