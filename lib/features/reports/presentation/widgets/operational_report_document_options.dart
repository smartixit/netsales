import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/reports/presentation/widgets/report_presentation_options_update.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// Document template, locale, and page-profile options.
class OperationalReportDocumentOptions extends StatelessWidget {
  const OperationalReportDocumentOptions({
    required this.definition,
    required this.presentation,
    required this.onChanged,
    super.key,
  });

  final ReportDefinition definition;
  final ReportPresentationOptions presentation;
  final ValueChanged<ReportPresentationOptions> onChanged;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (definition.templates.isNotEmpty) {
      children.add(
        CustomDropdown<String>(
          label: 'قالب التقرير',
          rxValue: RxnString(presentation.template?.reference.key ?? ''),
          items: [
            const DropdownItem<String>(
              value: '',
              child: Text('القالب الافتراضي'),
            ),
            ...definition.templates.map(
              (item) => DropdownItem<String>(
                value: item.key,
                child: Text(item.key),
              ),
            ),
          ],
          onChanged: (key) {
            final selected = definition.templates
                .where((item) => item.key == key)
                .firstOrNull;
            onChanged(
              copyReportPresentationOptions(
                presentation,
                template: selected == null
                    ? null
                    : ReportTemplateSelection(
                        id: selected.id,
                        version: selected.version,
                      ),
                clearTemplate: selected == null,
              ),
            );
          },
        ),
      );
    }

    if (definition.supportedLocaleTags.isNotEmpty) {
      children.add(
        CustomDropdown<String>(
          label: 'لغة المستند',
          rxValue: RxnString(
            presentation.languageTag ??
                definition.supportedLocaleTags.first,
          ),
          items: definition.supportedLocaleTags
              .map(
                (tag) => DropdownItem<String>(
                  value: tag,
                  child: Text(tag),
                ),
              )
              .toList(growable: false),
          onChanged: (tag) {
            if (tag != null) {
              onChanged(
                copyReportPresentationOptions(
                  presentation,
                  languageTag: tag,
                ),
              );
            }
          },
        ),
      );
    }

    if (definition.pageProfileIds.isNotEmpty) {
      children.add(
        CustomDropdown<String>(
          label: 'حجم الصفحة',
          rxValue: RxnString(
            presentation.pageProfileId ?? definition.pageProfileIds.first,
          ),
          items: definition.pageProfileIds
              .map(
                (id) => DropdownItem<String>(
                  value: id,
                  child: Text(id),
                ),
              )
              .toList(growable: false),
          onChanged: (id) {
            if (id != null) {
              onChanged(
                copyReportPresentationOptions(
                  presentation,
                  pageProfileId: id,
                ),
              );
            }
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
