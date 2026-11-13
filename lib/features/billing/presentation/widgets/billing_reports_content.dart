import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

import 'package:netsales/core/enums/billing_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/widgets/charts/charting.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_list_tile.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_modal.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_chart.dart';
class BillingReportsContent extends StatelessWidget {
 const BillingReportsContent({super.key, required this.controller});
 final BillingReportsController controller;

 @override
 Widget build(BuildContext context){
  final items=controller.catalog.map((e)=>DropdownItem<String>(
    value:e['id'].toString(),
    child:Text(e['label']?.toString()??e['id'].toString()),
  )).toList();
  final summary=controller.summary.value;
  final definition=controller.currentDefinition;
  return ListView(padding:const EdgeInsets.all(20),children:[
   Row(children:[
    const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('تقارير الاشتراكات',style:TextStyle(fontSize:24,fontWeight:FontWeight.w700)),
      Text('تقارير Billing مستقلة عن تقارير المبيعات والتشغيل.'),
    ])),
    CustomButton.outline(text:'PDF تفصيلي',prefix:Icons.picture_as_pdf_outlined,loading:controller.isExportingPdf.value,onPressed:controller.isExportingPdf.value?null:controller.exportPdfSummary),
    CustomButton.outline(text:'تصدير CSV',prefix:Icons.download_rounded,onPressed:controller.isLoading.value?null:controller.exportCsv),
    CustomButton.outline(text:'تحديث',prefix:Icons.refresh_rounded,onPressed:controller.isLoading.value?null:controller.loadCatalog),
   ]),
   const SizedBox(height:16),
   if(items.isNotEmpty)CustomDropdown<String>(
    items:items,rxValue:controller.selectedType,onChanged:controller.selectReport,
    label:'نوع التقرير',hint:'اختر تقريراً',
   ),
   if(definition!=null)ReportConfigurationStudio(
    definition:definition,
    criteria:controller.criteria.value,
    presentation:controller.presentation.value,
    resolveLabel:_resolveLabel,
    onCriteriaChanged:controller.setCriteria,
    onPresentationChanged:controller.setPresentation,
    onPreview:controller.applyFilters,
    isBusy:controller.isLoading.value,
    actionBuilder:(context,{required label,required icon,required onPressed,required secondary})=>
      secondary
       ?CustomButton.outline(text:label,prefix:icon,onPressed:onPressed)
       :CustomButton.primary(text:label,prefix:icon,onPressed:onPressed),
    filterSectionBuilder:_filterSection,
    presentationSectionBuilder:_presentationSection,
   ),
   if(controller.errorMessage.value!=null)CustomErrorState.compact(
    title:'تعذر تحميل بيانات التقرير',
    subtitle:controller.errorMessage.value,
    onRetry:controller.applyFilters,
   ),
   if(controller.isLoading.value&&controller.rows.isEmpty)const CustomSkeletonFeed(itemCount:3,shrinkWrap:true),
   if(summary!=null)Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('ملخص التقرير',style:TextStyle(fontWeight:FontWeight.w700)),
    ..._summaryWidgets(summary),
   ]))),
   ...controller.charts.map((chart)=>BillingReportChart(payload:chart)),
   if(controller.rows.isEmpty&&!controller.isLoading.value)const CustomEmptyState.boxed(title:'لا توجد سجلات مطابقة',subtitle:'غيّر معايير البحث أو الفلاتر ثم أعد تحميل التقرير.'),
   ...controller.rows.map((row)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:row.entries.take(8).map((e)=>Padding(padding:const EdgeInsets.symmetric(vertical:2),child:Text(_arabicLabel(e.key)+': '+(e.value?.toString()??'—'))).toList())))),
   if(controller.isLoadingMore.value)const CustomSkeletonListTile(hasLeading:false),
   if(controller.hasMore)
    CustomButton.outline(text:'تحميل المزيد',loading:controller.isLoadingMore.value,onPressed:controller.isLoadingMore.value?null:controller.loadMore),
  ]);
 }


 Widget _filterSection(BuildContext context,{
  required ReportDefinition definition,
  required ReportCriteria criteria,
  required ReportLabelResolver resolveLabel,
  required ValueChanged<ReportCriteria> onChanged,
 }){
  final widgets=<Widget>[];
  final searchFilter=definition.filter('search');
  if(searchFilter!=null){
   widgets.add(CustomTextField(
    controller:controller.searchController,
    label:resolveLabel(context,searchFilter.labelKey),
    hint:'ابحث في سجلات التقرير',
    prefixIcon:const Icon(Icons.search),
    isRequired:searchFilter.required,
    onChanged:(value){
      final next=Map<String,ReportFilterValue>.from(criteria.filters);
      if(value.trim().isEmpty){next.remove('search');}
      else{next['search']=ReportTextFilterValue(value.trim());}
      onChanged(ReportCriteria(filters:next));
    },
   ));
  }
  final statusFilter=definition.filter('status');
  if(statusFilter!=null){
   if(statusFilter.choices.isNotEmpty){
    widgets.add(const SizedBox(height:10));
    widgets.add(CustomDropdown<String>(
     items:statusFilter.choices.map((choice)=>DropdownItem<String>(
      value:choice.value,
      child:Text(resolveLabel(context,choice.labelKey)),
     )).toList(),
     rxValue:controller.selectedStatus,
     onChanged:(value){
      final next=Map<String,ReportFilterValue>.from(criteria.filters);
      if(value==null||value.isEmpty){next.remove('status');}
      else{next['status']=ReportChoiceFilterValue(value);}
      onChanged(ReportCriteria(filters:next));
     },
     label:resolveLabel(context,statusFilter.labelKey),
     hint:'كل الحالات',
    ));
   }else{
    widgets.add(const SizedBox(height:10));
    widgets.add(CustomTextField(
     controller:controller.statusController,
     label:resolveLabel(context,statusFilter.labelKey),
     hint:'أدخل الحالة',
     isRequired:statusFilter.required,
     onChanged:(value){
      final next=Map<String,ReportFilterValue>.from(criteria.filters);
      if(value.trim().isEmpty){next.remove('status');}
      else{next['status']=ReportTextFilterValue(value.trim());}
      onChanged(ReportCriteria(filters:next));
     },
    ));
   }
  }
  final fromFilter=definition.filter('from_date');
  final toFilter=definition.filter('to_date');
  if(fromFilter!=null||toFilter!=null){
   widgets.add(const SizedBox(height:10));
   widgets.add(Wrap(spacing:8,runSpacing:8,children:[
    if(fromFilter!=null)CustomButton.outline(
     text:_dateLabel('من تاريخ',criteria.filters['from_date']),
     prefix:Icons.calendar_today,
     onPressed:()=>_pickCriteriaDate(context,'from_date',criteria,onChanged),
    ),
    if(toFilter!=null)CustomButton.outline(
     text:_dateLabel('إلى تاريخ',criteria.filters['to_date']),
     prefix:Icons.event,
     onPressed:()=>_pickCriteriaDate(context,'to_date',criteria,onChanged),
    ),
    CustomButton.text(text:'مسح الفلاتر',onPressed:()=>onChanged(ReportCriteria())),
   ]));
  }
  return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:widgets);
 }

 Widget _presentationSection(BuildContext context,{
  required ReportDefinition definition,
  required ReportPresentationOptions presentation,
  required ReportLabelResolver resolveLabel,
  required ValueChanged<ReportPresentationOptions> onChanged,
 }){
  ReportTemplateSelection? templateFor(String? id){
   final chosen=definition.templates.firstWhereOrNull((item)=>item.id.value==id);
   if(chosen==null)return presentation.template;
   return ReportTemplateSelection(id:chosen.id,version:chosen.version);
  }
  ReportPresentationOptions copy({
   String? languageTag,
   String? pageProfileId,
   ReportTemplateSelection? template,
   List<String>? visibleColumnIds,
   bool? includeMetrics,
   bool? includeCharts,
  })=>ReportPresentationOptions(
    visibleColumnIds:visibleColumnIds??presentation.visibleColumnIds,
    sorts:presentation.sorts,
    groupByFieldId:presentation.groupByFieldId,
    template:template??presentation.template,
    languageTag:languageTag??presentation.languageTag,
    pageProfileId:pageProfileId??presentation.pageProfileId,
    includeMetrics:includeMetrics??presentation.includeMetrics,
    includeCharts:includeCharts??presentation.includeCharts,
  );
  return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
   if(definition.supportedLocaleTags.length>1)CustomDropdown<String>(
    items:definition.supportedLocaleTags.map((tag)=>DropdownItem<String>(value:tag,child:Text(tag=='ar-YE'?'العربية':'English'))).toList(),
    rxValue:controller.selectedLocale,
    onChanged:(value){if(value!=null)onChanged(copy(languageTag:value));},
    label:'لغة المستند',hint:'اختر اللغة',
   ),
   if(definition.pageProfileIds.length>1)CustomDropdown<String>(
    items:definition.pageProfileIds.map((id)=>DropdownItem<String>(value:id,child:Text(id=='a4-landscape'?'A4 أفقي':'A4 عمودي'))).toList(),
    rxValue:controller.selectedPageProfile,
    onChanged:(value){if(value!=null)onChanged(copy(pageProfileId:value));},
    label:'حجم الصفحة',hint:'اختر حجم الصفحة',
   ),
   if(definition.templates.length>1)CustomDropdown<String>(
    items:definition.templates.map((item)=>DropdownItem<String>(value:item.id.value,child:Text(item.id.value))).toList(),
    rxValue:controller.selectedTemplateId,
    onChanged:(value){if(value!=null)onChanged(copy(template:templateFor(value)));},
    label:'قالب المستند',hint:'اختر القالب',
   ),
   if(definition.templates.length==1)Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Text('القالب: '+definition.templates.first.id.value)),
   Row(children:[
    const Expanded(child:Text('إظهار مؤشرات الملخص')),
    CustomSwitch(value:presentation.includeMetrics,onChanged:(value)=>onChanged(copy(includeMetrics:value))),
   ]),
   if(definition.chartsAvailable)const Padding(padding:EdgeInsets.symmetric(vertical:8),child:Text('المخططات التفاعلية تظهر في شاشة التقرير؛ إدراج الرسوم داخل PDF سيُضاف ضمن مرحلة قوالب PDF المتقدمة.')),
   const SizedBox(height:8),
   const Text('الأعمدة الظاهرة في PDF',style:TextStyle(fontWeight:FontWeight.w700)),
   ...definition.columns.map((column)=>Row(children:[
    Expanded(child:Text(resolveLabel(context,column.labelKey))),
    CustomSwitch(
     value:presentation.visibleColumnIds.contains(column.id),
     onChanged:(value){
      final selected=List<String>.from(presentation.visibleColumnIds);
      if(value&&!selected.contains(column.id))selected.add(column.id);
      if(!value)selected.remove(column.id);
      onChanged(copy(visibleColumnIds:selected));
     },
    ),
   ])),
  ]);
 }

 Future<void> _pickCriteriaDate(BuildContext context,String id,ReportCriteria criteria,ValueChanged<ReportCriteria> onChanged)async{
  final current=criteria.filters[id];
  final initial=current is ReportDateFilterValue?current.value:DateTime.now();
  final selected=await CustomDatePickerModal.showDialog(
   context:context,
   initialValue:[initial],
   title:id=='from_date'?'اختر تاريخ البداية':'اختر تاريخ النهاية',
   firstDate:DateTime(2020),
   lastDate:DateTime(2100),
  );
  final value=selected?.firstOrNull;
  if(value==null)return;
  final next=Map<String,ReportFilterValue>.from(criteria.filters)..[id]=ReportDateFilterValue(value);
  onChanged(ReportCriteria(filters:next));
 }

 String _dateLabel(String label,ReportFilterValue? value){
  if(value is! ReportDateFilterValue)return label;
  final date=value.value;
  return label+' '+date.year.toString().padLeft(4,'0')+'-'+date.month.toString().padLeft(2,'0')+'-'+date.day.toString().padLeft(2,'0');
 }

 String _resolveLabel(BuildContext context,String key){
  final english=controller.selectedLocale.value=='en';
  if(key.startsWith('billing.status.'))return _statusLabel(key.substring('billing.status.'.length),english:english);
  if(key.startsWith('billing.report.column.')||key.startsWith('billing.report.metric.')){
    final id=key.substring(key.lastIndexOf('.')+1);
    return english?_englishLabel(id):_arabicLabel(id);
  }
  if(key==controller.selectedDefinition?['label']&&english)return _englishReportLabel(controller.selectedType.value??'');
  if(key=='من تاريخ'&&english)return 'From date';
  if(key=='إلى تاريخ'&&english)return 'To date';
  if(key=='الحالة'&&english)return 'Status';
  if(key=='بحث'&&english)return 'Search';
  return key;
 }

 String _statusLabel(String value,{bool english=false}) =>
  EnumPresentationRegistry.resolveBillingStatus(
   BillingStatus.fromWire(value),
   english:english,
  ).label;

 String _englishReportLabel(String type)=>const {'subscriptions':'Subscriptions','trials':'Trial usage','trial_conversion':'Trial conversion funnel','renewals':'Renewals','plan_performance':'Plan performance','invoices':'Invoices','collections':'Collections','receivables':'Accounts receivable','usage':'Usage','dunning':'Dunning','refunds':'Refunds','revenue_recognition':'Revenue recognition'}[type]??type;
 String _englishLabel(String key)=>const {'record_count':'Record count','active_subscriptions':'Active subscriptions','trialing_subscriptions':'Trial subscriptions','past_due_subscriptions':'Past-due subscriptions','canceled_subscriptions':'Canceled subscriptions','currency_code':'Currency code','invoice_number':'Invoice number','status':'Status','amount_minor':'Amount (minor units)','mrr_minor':'Monthly recurring revenue','arr_minor':'Annual recurring revenue','trial_eligible':'Eligible trials','trial_reserved':'Reserved trials','trial_started':'Started trials','trial_completed':'Completed trials','conversion_invoice_issued':'Conversion invoices issued','paid_conversion':'Paid conversions'}[key]??key.replaceAll('_',' ');
 String _arabicLabel(String key)=>const {
  'record_count':'عدد السجلات','active_subscriptions':'الاشتراكات النشطة',
  'trialing_subscriptions':'الاشتراكات التجريبية','past_due_subscriptions':'اشتراكات متأخرة السداد',
  'canceled_subscriptions':'الاشتراكات الملغاة','currency_code':'رمز العملة',
  'invoice_number':'رقم الفاتورة','status':'الحالة','amount_minor':'المبلغ (وحدة صغرى)',
  'mrr_minor':'الإيراد الشهري المتكرر','arr_minor':'الإيراد السنوي المتكرر',
  'trial_eligible':'التجارب المؤهلة','trial_reserved':'التجارب المحجوزة',
  'trial_started':'التجارب التي بدأت','trial_completed':'التجارب المكتملة',
  'conversion_invoice_issued':'فواتير التحويل الصادرة','paid_conversion':'التحويلات المدفوعة',
 }[key]??key.replaceAll('_',' ');

 List<Widget> _summaryWidgets(Map<String,dynamic> summary){
  final widgets=<Widget>[];
  for(final entry in summary.entries){
   final value=entry.value;
   final label=_arabicLabel(entry.key);
   if(value is Map<String,dynamic>){
    widgets.add(Padding(padding:const EdgeInsets.only(top:8),child:Text(label,style:const TextStyle(fontWeight:FontWeight.w700))));
    for(final nested in value.entries){widgets.add(Text(_arabicLabel(nested.key)+': '+(nested.value?.toString()??'—')));}
   }else if(value is List<dynamic>){
    widgets.add(Padding(padding:const EdgeInsets.only(top:8),child:Text(label,style:const TextStyle(fontWeight:FontWeight.w700))));
    for(final item in value.whereType<Map<String,dynamic>>()){
      widgets.add(Text(item.entries.map((e)=>_arabicLabel(e.key)+': '+(e.value?.toString()??'—')).join(' • ')));
    }
   }else{
    widgets.add(Text(label+': '+(value?.toString()??'—')));
   }
  }
  return widgets;
 }
}
