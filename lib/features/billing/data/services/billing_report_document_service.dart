import 'dart:ui' show Color;

import 'package:document_engine/document_engine.dart';
import 'package:netsales/core/services/document_engine_brand_asset_service.dart';
import 'package:netsales/core/services/document_engine_font_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// Branded Arabic executive PDF summaries for Billing reports.
/// Financial totals are consumed from the API response and never recalculated here.
class BillingReportDocumentService {
  BillingReportDocumentService._();
  static final BillingReportDocumentService instance=BillingReportDocumentService._();

  Future<FileExportResult> exportSummary({
    required String reportType,
    required String reportLabel,
    required Map<String,dynamic> summary,
    required List<Map<String,dynamic>> rows,
    required List<Map<String,dynamic>> columns,
    required String localeTag,
    required String? fromDate,
    required String? toDate,
    required String? status,
    required String? search,
  }) async {
    final generatedAt=DateTime.now();
    final logo=await DocumentEngineBrandAssetService.instance.resolveLogoBytes(null);
    final fonts=DocumentEngineFontService.instance;
    final branding=DocumentBranding(
      organizationName:'NetSales',
      tagline:'تقارير الاشتراكات والفوترة',
      primaryColor:_hex(AppColors.lightColors.primary),
      secondaryColor:_hex(AppColors.lightColors.secondary),
      accentColor:_hex(AppColors.lightColors.tertiary),
      surfaceColor:_hex(AppColors.lightColors.surface),
      textColor:_hex(AppColors.lightColors.onSurface),
      mutedTextColor:_hex(AppColors.lightColors.onSurfaceVariant),
      logoBytes:logo,
      fonts:await fonts.loadArabicBrandingFonts(),
    );
    if(rows.length>1500)throw StateError('يتجاوز التقرير الحد الآمن لملف PDF؛ استخدم تصدير CSV الكامل.');
    final metricRows=<DocumentTableRow>[];
    void addValue(String label,dynamic value){
      if(value is Map<String,dynamic>){
        for(final entry in value.entries){addValue(label+' / '+entry.key.replaceAll('_',' '),entry.value);}
      }else if(value is List<dynamic>){
        for(var index=0;index<value.length;index++){
          addValue(label+' '+(index+1).toString(),value[index]);
        }
      }else{
        if(metricRows.length>=300)throw StateError('يتجاوز ملخص التقرير الحد الآمن لعناصر PDF.');
        metricRows.add(DocumentTableRow(
          id:'billing-summary-'+(metricRows.length+1).toString(),
          cells:[
            DocumentTableCell(value:DocumentTextValue(label),direction:DocumentTextDirection.rightToLeft),
            DocumentTableCell(value:_documentValue(value),direction:DocumentTextDirection.leftToRight),
          ],
        ));
      }
    }
    for(final entry in summary.entries){addValue(entry.key.replaceAll('_',' '),entry.value);}
    if(metricRows.isEmpty){
      metricRows.add(DocumentTableRow(id:'billing-summary-empty',cells:[
        const DocumentTableCell(value:DocumentTextValue('النتيجة')),
        const DocumentTableCell(value:DocumentTextValue('لا توجد مؤشرات متاحة')),
      ]));
    }
    final info=<DocumentInfoItem>[
      DocumentInfoItem(label:'التقرير',value:DocumentTextValue(reportLabel),direction:DocumentTextDirection.rightToLeft),
      DocumentInfoItem(label:'النطاق',value:const DocumentTextValue('حساب فوترة الشبكة'),direction:DocumentTextDirection.rightToLeft),
      DocumentInfoItem(label:'تاريخ الإنشاء',value:DocumentTextValue(_date(generatedAt)),direction:DocumentTextDirection.leftToRight),
      if(fromDate!=null)DocumentInfoItem(label:'من تاريخ',value:DocumentTextValue(fromDate),direction:DocumentTextDirection.leftToRight),
      if(toDate!=null)DocumentInfoItem(label:'إلى تاريخ',value:DocumentTextValue(toDate),direction:DocumentTextDirection.leftToRight),
      if(status!=null&&status.isNotEmpty)DocumentInfoItem(label:'الحالة',value:DocumentTextValue(status),direction:DocumentTextDirection.leftToRight),
      if(search!=null&&search.isNotEmpty)DocumentInfoItem(label:'بحث',value:DocumentTextValue(search),direction:DocumentTextDirection.rightToLeft),
    ];
    final snapshot=DocumentSnapshot(
      metadata:DocumentMetadata(
        id:DocumentId('billing-report-'+reportType+'-'+generatedAt.microsecondsSinceEpoch.toString()),
        documentTypeId:const DocumentTypeId('netsales.billing-report'),
        title:reportLabel,
        subtitle:'ملخص تنفيذي لتقارير الاشتراكات والفوترة',
        locale:DocumentLocale(languageTag:localeTag,direction:localeTag.toLowerCase().startsWith('ar')?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight),
        createdAt:generatedAt,
        timeZoneId:'Asia/Aden',
      ),
      sections:[
        DocumentSection(id:'billing-report-summary',nodes:[
          DocumentHeading(text:reportLabel,level:1,direction:DocumentTextDirection.rightToLeft,weight:DocumentTextWeight.bold),
          const DocumentStatusBanner(label:'ملخص محسوب على الخادم',tone:DocumentStatusTone.success,detail:'لم يُجرِ التطبيق أي إعادة احتساب للمؤشرات المالية أو الأرصدة.'),
          DocumentInfoGrid(items:info,columns:3,compact:true),
          DocumentHeading(text:'المؤشرات والنتائج',level:2,direction:DocumentTextDirection.rightToLeft),
          DocumentTable(
            columns:[
              DocumentTableColumn(id:'metric',label:'المؤشر',alignment:DocumentCellAlignment.leading),
              DocumentTableColumn(id:'value',label:'القيمة',alignment:DocumentCellAlignment.trailing),
            ],
            rows:metricRows,
            style:DocumentTableStyle(stripedRows:true,compact:true),
          ),
          if(rows.isNotEmpty)...[
            DocumentHeading(text:'تفاصيل السجلات',level:2,direction:DocumentTextDirection.rightToLeft),
            DocumentTable(
              columns:columns.take(10).map((column)=>DocumentTableColumn(
                id:(column['id']??column['key']??'column').toString().replaceAll(RegExp(r'[^A-Za-z0-9_-]'),'_'),
                label:(column['label']??column['id']??column['key']??'').toString(),
              )).toList(),
              rows:rows.asMap().entries.map((entry)=>DocumentTableRow(
                id:'billing-detail-'+entry.key.toString(),
                cells:columns.take(10).map((column){
                  final key=(column['key']??column['id']??'').toString();
                  return DocumentTableCell(
                    value:_documentValue(entry.value[key]),
                    direction:DocumentTextDirection.leftToRight,
                  );
                }).toList(),
              )).toList(),
              style:DocumentTableStyle(stripedRows:true,compact:true),
            ),
          ],
          const DocumentParagraph(text:'المبالغ محفوظة كما وردت من الخادم وبوحداتها الأصلية. لا تجمع القيم بين عملات مختلفة.',direction:DocumentTextDirection.rightToLeft),
        ]),
      ],
    );
    final template=DocumentTemplateDefinition(
      id:TemplateId('netsales.billing-report.'+reportType+'.executive'),
      version:TemplateVersion(major:1,minor:0,patch:0),
      documentTypeId:const DocumentTypeId('netsales.billing-report'),
      displayName:'NetSales '+reportLabel+' Executive',
      supportedLocaleTags:[localeTag,'ar-YE','en'],
      capabilities:TemplateCapabilities([
        TemplateCapability.coverPage,TemplateCapability.repeatingHeader,
        TemplateCapability.repeatingFooter,TemplateCapability.pageNumbering,
        TemplateCapability.tables,TemplateCapability.metrics,
        TemplateCapability.watermark,TemplateCapability.portraitPage,
      ]),
      isDefault:true,
      layout:DocumentTemplateLayout.executive,
    );
    final result=await PdfDocumentRenderer(
      textShapingProvider:await fonts.arabicTextShapingProvider(),
    ).render(
      snapshot:snapshot,
      template:template,
      options:DocumentRenderOptions(
        pageProfile:DocumentPageProfile.a4Portrait(marginTop:38,marginRight:36,marginBottom:42,marginLeft:36),
        generatedAt:generatedAt,
        headerText:'NetSales · '+reportLabel,
        footerText:'تقرير فوترة — بيانات معتمدة من الخادم',
        watermark:DocumentWatermark(imageBytes:logo,opacity:0.075,angleRadians:-0.6108652381980153,widthFactor:0.58,heightFactor:0.46),
        branding:branding,
        maxPages:100,
      ),
    );
    if(result is DocumentRenderFailure)throw StateError(result.message);
    if(result is! DocumentRenderSuccess)throw StateError('تعذر إنشاء PDF لتقرير الفوترة.');
    return FileExportService.instance.saveFile(
      bytes:result.artifact.bytes,
      fileName:'Billing-'+reportType+'-Summary',
      extension:'pdf',
      folderName:'Reports',
      namingStrategy:FileNamingStrategy.report,
      autoOpen:true,
      showFeedback:false,
    );
  }

  DocumentValue _documentValue(dynamic value){
    if(value is int)return DocumentIntegerValue(value);
    if(value is double&&value.isFinite)return DocumentDecimalValue(value.toString());
    if(value is bool)return DocumentTextValue(value?'نعم':'لا');
    return DocumentTextValue(value?.toString()??'—');
  }
  String _date(DateTime value)=>value.year.toString().padLeft(4,'0')+'-'+value.month.toString().padLeft(2,'0')+'-'+value.day.toString().padLeft(2,'0');
  String _hex(Color color)=>color.value.toRadixString(16).substring(2).toUpperCase();
}
