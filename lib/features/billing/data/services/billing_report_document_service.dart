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
    required bool includeMetrics,
    required List<Map<String,dynamic>> rows,
    required List<Map<String,dynamic>> columns,
    required String localeTag,
    required String? fromDate,
    required String? toDate,
    required String? status,
    required String? search,
    required bool Function() isCurrent,
  }) async {
    final generatedAt=DateTime.now();
    final isArabic=localeTag.toLowerCase().startsWith('ar');
    final logo=await DocumentEngineBrandAssetService.instance.resolveLogoBytes(null);
    final fonts=DocumentEngineFontService.instance;
    final branding=DocumentBranding(
      organizationName:'NetSales',
      tagline:isArabic?'تقارير الاشتراكات والفوترة':'Subscription and Billing Reports',
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
        for(final entry in value.entries){addValue('$label / ${entry.key.replaceAll('_',' ')}',entry.value);}
      }else if(value is List<dynamic>){
        for(var index=0;index<value.length;index++){
          addValue('$label ${index+1}',value[index]);
        }
      }else{
        if(metricRows.length>=300)throw StateError('يتجاوز ملخص التقرير الحد الآمن لعناصر PDF.');
        metricRows.add(DocumentTableRow(
          id:'billing-summary-${metricRows.length+1}',
          cells:[
            DocumentTableCell(value:DocumentTextValue(label),direction:isArabic?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight),
            DocumentTableCell(value:_documentValue(value,localeTag),direction:_valueDirection(value,isArabic)),
          ],
        ));
      }
    }
    for(final entry in summary.entries){addValue(_label(entry.key,localeTag),entry.value);}
    if(metricRows.isEmpty){
      metricRows.add(DocumentTableRow(id:'billing-summary-empty',cells:[
        DocumentTableCell(value:DocumentTextValue(isArabic?'النتيجة':'Result'),direction:isArabic?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight),
        DocumentTableCell(value:DocumentTextValue(isArabic?'لا توجد مؤشرات متاحة':'No metrics available')),
      ]));
    }
    final info=<DocumentInfoItem>[
      DocumentInfoItem(label:isArabic?'التقرير':'Report',value:DocumentTextValue(reportLabel),direction:isArabic?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight),
      DocumentInfoItem(label:isArabic?'النطاق':'Scope',value:DocumentTextValue(isArabic?'حساب فوترة الشبكة':'Network billing account'),direction:isArabic?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight),
      DocumentInfoItem(label:isArabic?'تاريخ الإنشاء':'Generated at',value:DocumentTextValue(_date(generatedAt)),direction:DocumentTextDirection.leftToRight),
      if(fromDate!=null)DocumentInfoItem(label:isArabic?'من تاريخ':'From date',value:DocumentTextValue(fromDate),direction:DocumentTextDirection.leftToRight),
      if(toDate!=null)DocumentInfoItem(label:isArabic?'إلى تاريخ':'To date',value:DocumentTextValue(toDate),direction:DocumentTextDirection.leftToRight),
      if(status!=null&&status.isNotEmpty)DocumentInfoItem(label:isArabic?'الحالة':'Status',value:DocumentTextValue(status),direction:DocumentTextDirection.leftToRight),
      if(search!=null&&search.isNotEmpty)DocumentInfoItem(label:isArabic?'بحث':'Search',value:DocumentTextValue(search),direction:isArabic?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight),
    ];
    final snapshot=DocumentSnapshot(
      metadata:DocumentMetadata(
        id:DocumentId('billing-report-$reportType-${generatedAt.microsecondsSinceEpoch}'),
        documentTypeId:DocumentTypeId('netsales.billing-report'),
        title:reportLabel,
        subtitle:isArabic?'ملخص تنفيذي لتقارير الاشتراكات والفوترة':'Executive subscription and billing report',
        locale:DocumentLocale(languageTag:localeTag,direction:isArabic?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight),
        createdAt:generatedAt,
        timeZoneId:'Asia/Aden',
      ),
      sections:[
        DocumentSection(id:'billing-report-summary',nodes:[
          DocumentHeading(text:reportLabel,level:1,direction:isArabic?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight,weight:DocumentTextWeight.bold),
          DocumentStatusBanner(label:isArabic?'ملخص محسوب على الخادم':'Server-calculated summary',tone:DocumentStatusTone.success,detail:isArabic?'لم يُجرِ التطبيق أي إعادة احتساب للمؤشرات المالية أو الأرصدة.':'The client does not recalculate financial totals or balances.'),
          DocumentInfoGrid(items:info,columns:3,compact:true),
          if(includeMetrics)...[
            DocumentHeading(text:isArabic?'المؤشرات والنتائج':'Summary metrics',level:2,direction:isArabic?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight),
            DocumentTable(
              columns:[
                DocumentTableColumn(id:'metric',label:isArabic?'المؤشر':'Metric',alignment:DocumentCellAlignment.leading),
                DocumentTableColumn(id:'value',label:isArabic?'القيمة':'Value',alignment:DocumentCellAlignment.trailing),
              ],
              rows:metricRows,
              style:DocumentTableStyle(stripedRows:true,compact:true),
            ),
          ],
          if(rows.isNotEmpty)...[
            DocumentHeading(text:isArabic?'تفاصيل السجلات':'Detailed records',level:2,direction:isArabic?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight),
            DocumentTable(
              columns:columns.take(10).map((column)=>DocumentTableColumn(
                id:(column['id']??column['key']??'column').toString().replaceAll(RegExp(r'[^A-Za-z0-9_-]'),'_'),
                label:_label((column['id']??column['key']??column['label']??'').toString(),localeTag),
              )).toList(),
              rows:rows.asMap().entries.map((entry)=>DocumentTableRow(
                id:'billing-detail-'+entry.key.toString(),
                cells:columns.take(10).map((column){
                  final key=(column['key']??column['id']??'').toString();
                  return DocumentTableCell(
                    value:_documentValue(entry.value[key],localeTag),
                    direction:_valueDirection(entry.value[key],isArabic),
                  );
                }).toList(),
              )).toList(),
              style:DocumentTableStyle(stripedRows:true,compact:true),
            ),
          ],
          DocumentParagraph(text:isArabic?'المبالغ محفوظة كما وردت من الخادم وبوحداتها الأصلية. لا تجمع القيم بين عملات مختلفة.':'Amounts are presented in their original minor units. Values across currencies are never combined.',direction:isArabic?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight),
        ]),
      ],
    );
    final template=DocumentTemplateDefinition(
      id:TemplateId('netsales.billing-report.$reportType.executive'),
      version:TemplateVersion(major:1,minor:0,patch:0),
      documentTypeId:DocumentTypeId('netsales.billing-report'),
      displayName:'NetSales $reportLabel Executive',
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
        headerText:'NetSales · $reportLabel',
        footerText:isArabic?'تقرير فوترة — بيانات معتمدة من الخادم':'Billing report — server-authoritative data',
        watermark:DocumentWatermark(imageBytes:logo,opacity:0.075,angleRadians:-0.6108652381980153,widthFactor:0.58,heightFactor:0.46),
        branding:branding,
        maxPages:100,
      ),
    );
    if(result is DocumentRenderFailure)throw StateError(result.message);
    if(result is! DocumentRenderSuccess)throw StateError('تعذر إنشاء PDF لتقرير الفوترة.');
    if (!isCurrent()) {
      throw StateError('تغير نطاق التقرير أثناء تجهيز PDF؛ لم يتم حفظ المستند القديم.');
    }
    return FileExportService.instance.saveFile(
      bytes:result.artifact.bytes,
      fileName:'Billing-$reportType-Summary'',
      extension:'pdf',
      folderName:'Reports',
      namingStrategy:FileNamingStrategy.report,
      autoOpen:true,
      showFeedback:false,
    );
  }

  String _label(String key,String localeTag){
    if(!localeTag.toLowerCase().startsWith('ar'))return _englishLabel(key);
    const labels=<String,String>{
      'record_count':'عدد السجلات','active_subscriptions':'الاشتراكات النشطة',
      'trialing_subscriptions':'الاشتراكات التجريبية','past_due_subscriptions':'اشتراكات متأخرة السداد',
      'canceled_subscriptions':'الاشتراكات الملغاة','status_distribution':'توزيع الحالات',
      'subscriptions_by_currency':'الاشتراكات حسب العملة','trial_eligible':'التجارب المؤهلة',
      'trial_reserved':'التجارب المحجوزة','pending_approval':'بانتظار الموافقة',
      'trial_started':'التجارب التي بدأت','trial_completed':'التجارب المكتملة',
      'conversion_invoice_issued':'فواتير التحويل الصادرة','paid_conversion':'التحويلات المدفوعة',
      'expired_without_conversion':'تجارب منتهية دون تحويل','rejected':'مرفوضة','revoked':'مسحوبة',
      'eligible_to_reserved_percent':'نسبة الأهلية إلى الحجز','reserved_to_started_percent':'نسبة الحجز إلى البدء',
      'started_to_completed_percent':'نسبة البدء إلى الإكمال','completed_to_invoice_percent':'نسبة الإكمال إلى إصدار الفاتورة',
      'invoice_to_paid_percent':'نسبة الفاتورة إلى التحصيل','trial_conversion_percent':'معدل تحويل التجربة',
      'average_reservation_to_approval_hours':'متوسط الانتظار حتى الموافقة (ساعة)',
      'average_approval_to_start_hours':'متوسط الانتظار من الموافقة إلى البدء (ساعة)',
      'mrr_minor':'الإيراد الشهري المتكرر (وحدة صغرى)','arr_minor':'الإيراد السنوي المتكرر (وحدة صغرى)',
      'invoiced_minor':'إجمالي الفواتير (وحدة صغرى)','credited_minor':'الإشعارات الدائنة (وحدة صغرى)',
      'outstanding_minor':'الرصيد المستحق (وحدة صغرى)','gross_collected_minor':'إجمالي التحصيل (وحدة صغرى)',
      'refunded_minor':'المبالغ المستردة (وحدة صغرى)','net_collected_minor':'صافي التحصيل (وحدة صغرى)',
      'recognized_in_period_minor':'الإيراد المعترف به خلال الفترة (وحدة صغرى)',
      'recognized_to_date_minor':'الإيراد المعترف به حتى تاريخه (وحدة صغرى)',
      'deferred_revenue_minor':'الإيراد المؤجل (وحدة صغرى)',
      'current_minor':'غير متأخر (وحدة صغرى)','days_1_30_minor':'متأخر 1–30 يوماً (وحدة صغرى)',
      'days_31_60_minor':'متأخر 31–60 يوماً (وحدة صغرى)','days_61_90_minor':'متأخر 61–90 يوماً (وحدة صغرى)',
      'over_90_minor':'متأخر أكثر من 90 يوماً (وحدة صغرى)','currency_code':'رمز العملة',
      'currency_name':'اسم العملة','decimal_places':'المنازل العشرية','currency_id':'معرّف العملة',
      'invoice_count':'عدد الفواتير','status':'الحالة','event_type':'نوع الحدث',
      'plan_name':'الخطة','plan_key':'رمز الخطة',
      'trial_redemption_id':'معرّف استرداد التجربة','billing_subscription_id':'معرّف الاشتراك',
      'invoice_number':'رقم الفاتورة','payment_reference':'مرجع الدفع','refund_reference':'مرجع الاسترداد',
      'amount_minor':'المبلغ (وحدة صغرى)','quantity':'الكمية','period_start':'بداية الفترة',
      'period_end':'نهاية الفترة','current_period_start':'بداية فترة الاشتراك',
      'current_period_end':'نهاية فترة الاشتراك','reserved_at':'وقت الحجز','started_at':'وقت البدء',
      'completed_at':'وقت الإكمال','due_on':'تاريخ الاستحقاق','issued_on':'تاريخ الإصدار',
      'created_at':'تاريخ الإنشاء','occurred_at':'وقت الحدث','name':'الاسم','email':'البريد الإلكتروني',
    };
    return labels[key] ?? key.replaceAll('_', ' ');
  }

  DocumentValue _documentValue(dynamic value,String localeTag){
    if(value is int)return DocumentIntegerValue(value);
    if(value is double&&value.isFinite)return DocumentTextValue(value.toString());
    if(value is bool)return DocumentTextValue(localeTag.toLowerCase().startsWith('ar')?(value?'نعم':'لا'):(value?'Yes':'No'));
    if(value is String){
      final isArabic=localeTag.toLowerCase().startsWith('ar');
      final statuses=<String,String>{
        'ACTIVE':'نشط','TRIALING':'تجريبي','INCOMPLETE':'غير مكتمل','PAST_DUE':'متأخر السداد',
        'PAUSED':'متوقف مؤقتاً','SUSPENDED':'معلق','CANCELED':'ملغي','EXPIRED':'منتهي',
        'PAID':'مدفوعة','OPEN':'مفتوحة','PARTIALLY_PAID':'مدفوعة جزئياً','VOID':'ملغاة',
        'VERIFIED':'معتمدة','PENDING_REVIEW':'بانتظار المراجعة','FAILED':'فاشلة',
        'REJECTED':'مرفوضة','REFUNDED':'مستردة','PARTIALLY_REFUNDED':'مستردة جزئياً',
        'COMPLETED':'مكتملة','PENDING_APPROVAL':'بانتظار الموافقة','RESERVED':'محجوزة',
        'QUEUED':'في قائمة الانتظار','PENDING':'معلقة','CANCELLED':'ملغاة',
      };
      final englishStatuses=<String,String>{'ACTIVE':'Active','TRIALING':'Trial','INCOMPLETE':'Incomplete','PAST_DUE':'Past due','PAUSED':'Paused','SUSPENDED':'Suspended','CANCELED':'Canceled','EXPIRED':'Expired','PAID':'Paid','OPEN':'Open','PARTIALLY_PAID':'Partially paid','VOID':'Void','VERIFIED':'Verified','PENDING_REVIEW':'Pending review','FAILED':'Failed','REJECTED':'Rejected','REFUNDED':'Refunded','PARTIALLY_REFUNDED':'Partially refunded','COMPLETED':'Completed','PENDING_APPROVAL':'Pending approval','RESERVED':'Reserved','QUEUED':'Queued','PENDING':'Pending','CANCELLED':'Canceled'};
      return DocumentTextValue((isArabic?statuses:englishStatuses)[value]??value);
    }
    return DocumentTextValue(value?.toString()??'—');
  }
  String _englishLabel(String key)=>const <String,String>{
    'record_count':'Record count','active_subscriptions':'Active subscriptions','trialing_subscriptions':'Trial subscriptions',
    'past_due_subscriptions':'Past-due subscriptions','canceled_subscriptions':'Canceled subscriptions',
    'trial_eligible':'Eligible trials','trial_reserved':'Reserved trials','pending_approval':'Pending approval',
    'trial_started':'Started trials','trial_completed':'Completed trials','conversion_invoice_issued':'Conversion invoices issued',
    'paid_conversion':'Paid conversions','expired_without_conversion':'Expired without conversion','rejected':'Rejected','revoked':'Revoked',
    'eligible_to_reserved_percent':'Eligibility-to-reservation rate','reserved_to_started_percent':'Reservation-to-start rate',
    'started_to_completed_percent':'Start-to-completion rate','completed_to_invoice_percent':'Completion-to-invoice rate',
    'invoice_to_paid_percent':'Invoice-to-payment rate','trial_conversion_percent':'Trial conversion rate',
    'mrr_minor':'Monthly recurring revenue (minor units)','arr_minor':'Annual recurring revenue (minor units)',
    'invoiced_minor':'Invoiced amount (minor units)','credited_minor':'Credited amount (minor units)',
    'outstanding_minor':'Outstanding amount (minor units)','gross_collected_minor':'Gross collections (minor units)',
    'refunded_minor':'Refunded amount (minor units)','net_collected_minor':'Net collections (minor units)',
    'recognized_in_period_minor':'Revenue recognized in period (minor units)','recognized_to_date_minor':'Revenue recognized to date (minor units)',
    'deferred_revenue_minor':'Deferred revenue (minor units)','currency_code':'Currency code','currency_name':'Currency name',
    'invoice_count':'Invoice count','status':'Status','event_type':'Event type','plan_name':'Plan','plan_key':'Plan key',
    'invoice_number':'Invoice number','amount_minor':'Amount (minor units)','quantity':'Quantity','due_on':'Due date',
    'issued_on':'Issue date','created_at':'Created at','occurred_at':'Occurred at','reserved_at':'Reserved at',
    'started_at':'Started at','completed_at':'Completed at','name':'Name','email':'Email',
  }[key]??key.replaceAll('_',' ');
  DocumentTextDirection _valueDirection(dynamic value,bool isArabic)=>value is num?DocumentTextDirection.leftToRight:(isArabic?DocumentTextDirection.rightToLeft:DocumentTextDirection.leftToRight);
  String _date(DateTime value) => '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  String _hex(Color color)=>color.toARGB32().toRadixString(16).substring(2).toUpperCase();
}
