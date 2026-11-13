import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

class BillingReportsScreen extends GetView<BillingReportsController>{
 const BillingReportsScreen({super.key});
 @override Widget build(BuildContext context)=>Obx((){
  final items=controller.catalog.map((e)=>DropdownItem<String>(value:e['id'].toString(),child:Text(e['label']?.toString()??e['id'].toString()))).toList();
  final summary=controller.summary.value;
  final statusChoices=controller.statusChoices;
  return ListView(padding:const EdgeInsets.all(20),children:[
   Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('تقارير الاشتراكات',style:TextStyle(fontSize:24,fontWeight:FontWeight.w700)),Text('تقارير Billing مستقلة عن تقارير المبيعات والتشغيل.') ])),CustomButton.outline(text:'PDF تنفيذي',prefix:Icons.picture_as_pdf_outlined,loading:controller.isExportingPdf.value,onPressed:controller.isExportingPdf.value?null:controller.exportPdfSummary),CustomButton.outline(text:'تصدير CSV',prefix:Icons.download_rounded,onPressed:controller.isLoading.value?null:controller.exportCsv),CustomButton.outline(text:'تحديث',prefix:Icons.refresh_rounded,onPressed:controller.isLoading.value?null:controller.loadCatalog)]),
   const SizedBox(height:16),
   if(items.isNotEmpty)CustomDropdown<String>(items:items,rxValue:controller.selectedType,onChanged:controller.selectReport,label:'نوع التقرير',hint:'اختر تقريراً'),
   const SizedBox(height:12),
   if(controller.hasSearchFilter)CustomTextField(controller:controller.searchController,label:'بحث',hint:'ابحث في سجلات التقرير',prefixIcon:const Icon(Icons.search),isRequired:false,onChanged:(v)=>controller.searchQuery.value=v),
   if(controller.hasStatusFilter)const SizedBox(height:10),
   if(controller.hasStatusFilter&&statusChoices.isNotEmpty)CustomDropdown<String>(
    items:statusChoices.map((choice){
      final value=choice['value']?.toString()??'';
      return DropdownItem<String>(value:value,child:Text(_statusLabel(value)));
    }).toList(),
    rxValue:controller.selectedStatus,
    onChanged:controller.setStatus,
    label:'الحالة',
    hint:'كل الحالات',
   ),
   if(controller.hasStatusFilter&&statusChoices.isEmpty)CustomTextField(controller:controller.statusController,label:'الحالة',hint:'أدخل الحالة',isRequired:false,onFieldSubmitted:(_)=>controller.applyFilters()),
   if(controller.hasDateFilters)const SizedBox(height:10),
   if(controller.hasDateFilters)Wrap(spacing:8,runSpacing:8,children:[
    CustomButton.outline(text:controller.fromDate.value==null?'من تاريخ':'من '+controller.fromDate.value!.toIso8601String().substring(0,10),prefix:Icons.calendar_today,onPressed:()=>_pickDate(context,true)),
    CustomButton.outline(text:controller.toDate.value==null?'إلى تاريخ':'إلى '+controller.toDate.value!.toIso8601String().substring(0,10),prefix:Icons.event,onPressed:()=>_pickDate(context,false)),
    CustomButton.text(text:'مسح الفلاتر',onPressed:controller.clearFilters),
   ]),
   if(controller.errorMessage.value!=null)Card(child:Padding(padding:const EdgeInsets.all(14),child:Text(controller.errorMessage.value!))),
   if(controller.isLoading.value)const Padding(padding:EdgeInsets.all(24),child:Center(child:CircularProgressIndicator())),
   if(summary!=null)Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('ملخص التقرير',style:TextStyle(fontWeight:FontWeight.w700)),
    ..._summaryWidgets(summary),
   ]))),
   if(controller.rows.isEmpty&&!controller.isLoading.value)const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('لا توجد سجلات مطابقة للفلاتر الحالية.'))),
   ...controller.rows.map((row)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:row.entries.take(8).map((e)=>Padding(padding:const EdgeInsets.symmetric(vertical:2),child:Text(e.key.replaceAll('_',' ')+': '+(e.value?.toString()??'—'))).toList())))),
   if(controller.isLoadingMore.value)const Padding(padding:EdgeInsets.all(12),child:Center(child:CircularProgressIndicator())),
   if(controller.report.value?['next_page_url']!=null||controller.report.value?['links'] is Map<String,dynamic>&&controller.report.value?['links']['next']!=null)
    CustomButton.outline(text:'تحميل المزيد',loading:controller.isLoadingMore.value,onPressed:controller.isLoadingMore.value?null:controller.loadMore),
  ]);
 });


 String _statusLabel(String value)=>const {
  'INCOMPLETE':'غير مكتمل','TRIALING':'تجريبي','ACTIVE':'نشط','PAST_DUE':'متأخر السداد',
  'PAUSED':'متوقف مؤقتاً','SUSPENDED':'معلق','CANCELED':'ملغي','ENDED':'منتهي',
  'RESERVED':'محجوز','PENDING_APPROVAL':'بانتظار الموافقة','COMPLETED':'مكتمل',
  'EXPIRED':'منتهي','REJECTED':'مرفوض','REVOKED':'مسحوب','DRAFT':'مسودة',
  'OPEN':'مفتوح','PARTIALLY_PAID':'مدفوع جزئياً','PARTIALLY_CREDITED':'عليه إشعار دائن جزئي',
  'PAID':'مدفوع','CREDITED':'مغطى بإشعار دائن','UNCOLLECTIBLE':'متعذر التحصيل','VOID':'ملغى',
  'PENDING_REVIEW':'بانتظار المراجعة','VERIFIED':'معتمد','FAILED':'فاشل',
  'REFUNDED':'مسترد','PARTIALLY_REFUNDED':'مسترد جزئياً','PENDING':'معلق','QUEUED':'في قائمة الانتظار',
  'CANCELLED':'ملغي',
 }[value]??value;
 List<Widget> _summaryWidgets(Map<String,dynamic> summary){
  final widgets=<Widget>[];
  for(final entry in summary.entries){
   final value=entry.value;
   final label=entry.key.replaceAll('_',' ');
   if(value is Map<String,dynamic>){
    widgets.add(Padding(padding:const EdgeInsets.only(top:8),child:Text(label,style:const TextStyle(fontWeight:FontWeight.w700))));
    for(final nested in value.entries){widgets.add(Text(nested.key.replaceAll('_',' ')+': '+(nested.value?.toString()??'—')));}
   }else if(value is List<dynamic>){
    widgets.add(Padding(padding:const EdgeInsets.only(top:8),child:Text(label,style:const TextStyle(fontWeight:FontWeight.w700))));
    for(final item in value.whereType<Map<String,dynamic>>()){
      widgets.add(Text(item.entries.map((e)=>e.key.replaceAll('_',' ')+': '+(e.value?.toString()??'—')).join(' • ')));
    }
   }else{
    widgets.add(Text(label+': '+(value?.toString()??'—')));
   }
  }
  return widgets;
 }
 Future<void> _pickDate(BuildContext context,bool isFrom)async{
  final current=isFrom?controller.fromDate.value:controller.toDate.value;
  final value=await showDatePicker(context:context,initialDate:current??DateTime.now(),firstDate:DateTime(2020),lastDate:DateTime(2100));
  if(value==null)return;
  if(isFrom)await controller.setFromDate(value);else await controller.setToDate(value);
 }
}