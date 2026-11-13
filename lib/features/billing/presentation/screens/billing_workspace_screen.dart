import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
class BillingWorkspaceScreen extends GetView<BillingController>{
 const BillingWorkspaceScreen({super.key});
 @override Widget build(BuildContext context)=>Obx((){
  final a=controller.account.value;
  return RefreshIndicator(onRefresh:controller.load,child:ListView(padding:const EdgeInsets.all(20),children:[
   Row(children:[const Expanded(child:Text('الاشتراك والفوترة',style:TextStyle(fontSize:24,fontWeight:FontWeight.w700))),CustomButton.outline(text:'تحديث',prefix:Icons.refresh_rounded,onPressed:controller.isLoading.value?null:controller.load)]),
   if(controller.errorMessage.value!=null)Card(child:Padding(padding:const EdgeInsets.all(14),child:Text(controller.errorMessage.value!))),
   if(controller.isLoading.value&&a==null)const Center(child:CircularProgressIndicator()),
   if(!controller.isLoading.value&&controller.accounts.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('لا يوجد حساب فوترة لهذه الشبكة بعد.'))),
   if(a!=null)...[
    Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('حساب الفوترة',style:TextStyle(fontWeight:FontWeight.w700)),Text(a['legal_name']?.toString()??'حساب الشبكة'),Text('رقم الحساب: '+(a['account_number']?.toString()??'—')),Text('البريد: '+(a['billing_email']?.toString()??'—'))]))),
    const _Header('الخطط المتاحة'),
    ...controller.plans.map((p){final v=p['current_version'];final ps=v is Map&&v['prices'] is List?v['prices'] as List:const [];final price=ps.isNotEmpty&&ps.first is Map?ps.first as Map:const {};final id=(price['price_id'] as num?)?.toInt();return Card(child:ListTile(title:Text(p['name']?.toString()??'خطة اشتراك'),subtitle:Text('السعر: '+(price['unit_amount']?.toString()??price['unit_amount_minor']?.toString()??'—')),trailing:CustomButton.primary(text:'اختيار',loading:controller.isMutating.value,onPressed:id==null?null:()=>_purchase(context,id))));}),
    const _Header('الاشتراك الحالي'),
    ...controller.subscriptions.map((s){final id=(s['billing_subscription_id'] as num?)?.toInt();return Card(child:ListTile(title:Text(s['plan'] is Map?s['plan']['name']?.toString()??'اشتراك':'اشتراك'),subtitle:Text('الحالة: '+(s['status_label']?.toString()??s['status']?.toString()??'—')+'\nنهاية الفترة: '+(s['current_period_end']?.toString()??'—')),isThreeLine:true,trailing:CustomButton.outline(text:'إلغاء',onPressed:id==null?null:()=>_cancel(context,id))));}),
    const _Header('الفواتير'),
    ...controller.invoices.map((e)=>Card(child:ListTile(title:Text(e['invoice_number']?.toString()??'فاتورة'),subtitle:Text(e['status']?.toString()??'—'),trailing:Text(e['total']?.toString()??'—')))),
    const _Header('المدفوعات'),
    ...controller.payments.map((e)=>Card(child:ListTile(title:Text(e['payment_reference']?.toString()??'دفعة'),subtitle:Text(e['status']?.toString()??'—'),trailing:Text(e['amount']?.toString()??'—')))),
   ]
  ]));
 });
 Future<void> _purchase(BuildContext c,int id)async{final ok=await showDialog<bool>(context:c,builder:(d)=>AlertDialog(title:const Text('تأكيد الاشتراك'),content:const Text('سيُنشأ طلب الاشتراك والفاتورة. لن تُفعّل الاستحقاقات قبل اعتماد الدفع.'),actions:[CustomButton.text(text:'رجوع',onPressed:()=>Navigator.pop(d,false)),CustomButton.primary(text:'متابعة',onPressed:()=>Navigator.pop(d,true))]));if(ok==true)await controller.purchase(id);}
 Future<void> _cancel(BuildContext c,int id)async{final ok=await showDialog<bool>(context:c,builder:(d)=>AlertDialog(title:const Text('جدولة الإلغاء'),content:const Text('سيتم الإلغاء في نهاية فترة الخدمة الحالية.'),actions:[CustomButton.text(text:'رجوع',onPressed:()=>Navigator.pop(d,false)),CustomButton.danger(text:'تأكيد',onPressed:()=>Navigator.pop(d,true))]));if(ok==true)await controller.cancel(id);}
}
class _Header extends StatelessWidget{const _Header(this.value);final String value;@override Widget build(BuildContext c)=>Padding(padding:const EdgeInsets.only(top:18,bottom:8),child:Text(value,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w700)));}
