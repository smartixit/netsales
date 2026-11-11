import 'package:document_engine/document_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final invoiceType = DocumentTypeId('sales.invoice');
  final invoiceTemplate = TemplateId('sales.invoice.standard');

  DocumentTemplateDefinition definition({
    TemplateId? id,
    TemplateVersion? version,
    bool isDefault = false,
    Iterable<String> locales = const ['ar', 'en'],
  }) {
    return DocumentTemplateDefinition(
      id: id ?? invoiceTemplate,
      version: version ?? TemplateVersion(major: 1, minor: 0, patch: 0),
      documentTypeId: invoiceType,
      displayName: 'Standard invoice',
      supportedLocaleTags: locales,
      capabilities: TemplateCapabilities({
        TemplateCapability.tables,
        TemplateCapability.pageNumbering,
        TemplateCapability.portraitPage,
      }),
      isDefault: isDefault,
    );
  }

  test('registers and resolves exact template versions', () {
    final registry = TemplateRegistry();
    final v1 = definition(isDefault: true);
    final v2 = definition(
      version: TemplateVersion(major: 2, minor: 0, patch: 0),
    );
    registry
      ..register(v1)
      ..register(v2);

    expect(
      registry.require(
        id: invoiceTemplate,
        version: TemplateVersion(major: 1, minor: 0, patch: 0),
      ),
      same(v1),
    );
    expect(registry.versionsOf(invoiceTemplate), [v1, v2]);
    expect(registry.findDefault(documentTypeId: invoiceType), same(v1));
  });

  test(
    'rejects duplicate versions and duplicate defaults per document type',
    () {
      final registry = TemplateRegistry()
        ..register(definition(isDefault: true));

      expect(
        () => registry.register(definition(isDefault: true)),
        throwsStateError,
      );
      expect(
        () => registry.register(
          definition(id: TemplateId('sales.invoice.compact'), isDefault: true),
        ),
        throwsStateError,
      );
    },
  );

  test(
    'does not silently choose latest version when exact version is absent',
    () {
      final registry = TemplateRegistry()..register(definition());

      expect(
        registry.find(
          id: invoiceTemplate,
          version: TemplateVersion(major: 2, minor: 0, patch: 0),
        ),
        isNull,
      );
      expect(
        () => registry.require(
          id: invoiceTemplate,
          version: TemplateVersion(major: 2, minor: 0, patch: 0),
        ),
        throwsStateError,
      );
    },
  );

  test('filters by document type and locale', () {
    final registry = TemplateRegistry()..register(definition());
    final registered = registry.forDocumentType(invoiceType).single;

    expect(registered.supportsLocale('ar-YE'), isTrue);
    expect(registered.supportsLocale('en-US'), isTrue);
    expect(registered.supportsLocale('fr'), isFalse);
  });

  test('rejects malformed locale tags', () {
    expect(
      () => definition(locales: const ['not a locale']),
      throwsArgumentError,
    );
  });
}
