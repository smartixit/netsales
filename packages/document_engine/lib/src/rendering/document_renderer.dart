import '../document/document_snapshot.dart';
import '../templates/document_template_definition.dart';
import 'document_render_options.dart';
import 'document_render_result.dart';

/// Renderer port implemented by concrete output backends.
abstract interface class DocumentRenderer {
  String get rendererId;

  String get rendererVersion;

  Future<DocumentRenderResult> render({
    required DocumentSnapshot snapshot,
    required DocumentTemplateDefinition template,
    required DocumentRenderOptions options,
  });
}
