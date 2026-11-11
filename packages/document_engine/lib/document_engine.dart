/// Framework-agnostic document contracts and template registry.
library;

export 'src/core/document_id.dart';
export 'src/core/document_type_id.dart';
export 'src/core/template_id.dart';
export 'src/core/template_version.dart';
export 'src/document/document_locale.dart';
export 'src/document/document_branding.dart';
export 'src/document/document_metadata.dart';
export 'src/document/document_node.dart';
export 'src/document/document_section.dart';
export 'src/document/document_snapshot.dart';
export 'src/document/document_value.dart';
export 'src/templates/document_template_definition.dart';
export 'src/templates/template_capabilities.dart';
export 'src/templates/template_registry.dart';
export 'src/rendering/document_page_profile.dart';
export 'src/rendering/document_render_options.dart';
export 'src/rendering/document_render_result.dart';
export 'src/output/document_output.dart';
export 'src/rendering/document_renderer.dart';
export 'src/rendering/pdf/pdf_document_renderer.dart';

export 'src/reports/report_id.dart';
export 'src/reports/report_filter_value.dart';
export 'src/reports/report_definition.dart';
export 'src/reports/report_definition_registry.dart';
export 'src/reports/report_criteria.dart';
export 'src/reports/report_presentation_options.dart';
export 'src/reports/saved_report_preset.dart';
export 'src/widgets/report_configuration_studio.dart';

export 'src/remote/remote_document_job.dart';
