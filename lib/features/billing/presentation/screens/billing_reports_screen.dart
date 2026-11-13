import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class BillingReportsScreen extends GetView<BillingReportsController>{
 const BillingReportsScreen({super.key});
 @override Widget build(BuildContext context)=>Obx((){
  final selected=controller.selectedType.value;
  final items=controller.catalog.map((e)=>DropdownItem<String>(value:e['id'].toString(),child:Text(e['label']?.toString()??e['id'].toString()))).toList();
  return ListView(padding:const EdgeInsets.all(20),children:[
   Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('تقارير الاشتراكات',style:TextStyle(fontSize:24,fontWeight:FontWeight.w700)),Text('تقارير Billing مستقلة عن تقارير المبيعات والتشغيل.') ])),CustomButton.outline(text:'تحديث',prefix:Icons.refresh_rounded,onPressed:controller.isLoading.value?null:controller.loadCatalog)]),
   const SizedBox(height:16),
   if(items.isNotEmpty)CustomDropdown<String>(items:items,rxValue:controller.selectedType,onChanged:controller.selectReport,label:'نوع التقرير',hint:'اختر تقريراً'),
   if(controller.errorMessage.value!=null)Card(child:Padding(padding:const EdgeInsets.all(14),child:Text(controller.errorMessage.value!))),
   if(controller.isLoading.value)const Padding(padding:EdgeInsets.all(24),child:Center(child:CircularProgressIndicator())),
   if(controller.summary.value!=null)...[
    Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('ملخص التقرير',style:TextStyle(fontWeight:FontWeight.w700)),
      Text('عدد السجلات: '+(controller.summary.value!['record_count']?.toString()??'0')),
      if(controller.summary.value!['amounts_by_currency'] is List)
        ...(controller.summary.value!['amounts_by_currency'] as List).whereType<Map>().map((e)=>Text('إجمالي العملة #'+(e['currency_id']?.toString()??'')+': '+(e['amount_minor']?.toString()??'0')+' وحدة صغرى')),
    ]))),
   ],
   if(controller.rows.isEmpty&&!controller.isLoading.value)const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('لا توجد سجلات مطابقة للفلاتر الحالية.'))),
   ...controller.rows.map((row)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:row.entries.take(8).map((e)=>Padding(padding:const EdgeInsets.symmetric(vertical:2),child:Text(e.key.replaceAll('_',' ')+': '+(e.value?.toString()??'—'))).toList())))),
  ]);
 });
}