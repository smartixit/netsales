import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
class BillingWorkspaceScreen extends GetView<BillingController>{
 const BillingWorkspaceScreen({super.key});
 @override Widget build(BuildContext context)=>Obx((){
  final a=controller.account.value;
  return RefreshIndicator(onRefresh:controller.load,child:ListView(padding:const EdgeInsets.all(20),children:[
   Row(children:[const Expanded(child:Text('الاشتراك والفوترة',style:TextStyle(fontSize:24,fontWeight:FontWeight.w700))),CustomButton.outline(text:'تحديث',prefix:Icons.refresh_rounded,onPressed:controller.isLoading.value?null:controller.load)]),
   if(controller.errorMessage.value!=null)Card(child:Padding(padding:const EdgeInsets.all(14),child:Text(controller.errorMessage.value!))),
   if(controller.isLoading.value&&a==null)const Center(child:CircularProgressIndicator()),
   if(!controller.isLoading.value&&controller.accounts.isEmpty) Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('إنشاء حساب فوترة',style:TextStyle(fontWeight:FontWeight.w700)),
      const Text('اختر العملة التعاقدية لحساب الشبكة. لا يمكن تغييرها بعد تسجيل أول اشتراك أو فاتورة.'),
      const SizedBox(height:12),
      CustomDropdown<int>(
        items: controller.currencies.map((e)=>DropdownItem<int>(
          value:(e['currency_id'] as num).toInt(),
          child:Text((e['code']?.toString()??'')+' — '+(e['name']?.toString()??'')),
        )).toList(),
        rxValue:controller.selectedCurrencyId,
        onChanged:(id)=>controller.selectedCurrencyId.value=id,
        label:'العملة',
        hint:'اختر عملة الحساب',
      ),
      const SizedBox(height:12),
      CustomButton.primary(text:'إنشاء حساب الفوترة',loading:controller.isMutating.value,onPressed:controller.selectedCurrencyId.value==null?null:controller.createAccount),
    ]))),
   if(a!=null)...[
    Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('حساب الفوترة',style:TextStyle(fontWeight:FontWeight.w700)),if(controller.accounts.length>1) CustomDropdown<int>(
      items: controller.accounts.map((e)=>DropdownItem<int>(
        value: (e['billing_account_id'] as num).toInt(),
        child: Text((e['default_currency'] is Map ? e['default_currency']['code']?.toString() : null) ?? e['legal_name']?.toString() ?? 'حساب فوترة'),
      )).toList(),
      rxValue: controller.selectedAccountId,
      onChanged: controller.selectAccount,
      label: 'حساب الفوترة',
      hint: 'اختر حساب الفوترة',
    ),
    Text(a['legal_name']?.toString()??'حساب الشبكة'),Text('رقم الحساب: '+(a['account_number']?.toString()??'—')),Text('البريد: '+(a['billing_email']?.toString()??'—'))]))),
    const _Header('الخطط المتاحة'),
    ...controller.plans.map((p){final v=p['current_version'];final ps=v is Map&&v['prices'] is List?v['prices'] as List:const [];final price=ps.isNotEmpty&&ps.first is Map?ps.first as Map:const {};final id=(price['price_id'] as num?)?.toInt();return Card(child:ListTile(title:Text(p['name']?.toString()??'خطة اشتراك'),subtitle:Text('السعر: '+(price['unit_amount']?.toString()??price['unit_amount_minor']?.toString()??'—')),trailing:CustomButton.primary(text:'اختيار',loading:controller.isMutating.value,onPressed:id==null?null:()=>_purchase(context,id))));}),
    const _Header('الاشتراك الحالي'),
    ...controller.subscriptions.map((s){final id=(s['billing_subscription_id'] as num?)?.toInt();return Card(child:ListTile(title:Text(s['plan'] is Map?s['plan']['name']?.toString()??'اشتراك':'اشتراك'),subtitle:Text('الحالة: '+(s['status_label']?.toString()??s['status']?.toString()??'—')+'\nنهاية الفترة: '+(s['current_period_end']?.toString()??'—')),isThreeLine:true,trailing:Wrap(spacing:6,children:[CustomButton.text(text:'التفاصيل',onPressed:id==null?null:()=>_details(context,id)),CustomButton.outline(text:'إلغاء',onPressed:id==null?null:()=>_cancel(context,id))])));}),
    const _Header('الفواتير'),
    ...controller.invoices.map((e)=>Card(child:ListTile(title:Text(e['invoice_number']?.toString()??'فاتورة'),subtitle:Text(e['status']?.toString()??'—'),trailing:Text(e['total']?.toString()??'—')))),
    const _Header('المدفوعات'),
    ...controller.payments.map((e)=>Card(child:ListTile(title:Text(e['payment_reference']?.toString()??'دفعة'),subtitle:Text(e['status']?.toString()??'—'),trailing:Text(e['amount']?.toString()??'—')))),
   ]
  ]));
 });
 Future<void> _details(BuildContext c,int id)async{
  await controller.loadSubscriptionDetails(id);
  if(!c.mounted)return;
  final detail=controller.subscriptionDetails.value;
  if(detail==null)return;
  final trial=detail['trial_redemption'];
  await showDialog<void>(context:c,builder:(d)=>AlertDialog(
   title:const Text('تفاصيل الاشتراك'),
   content:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
    Text('الحالة: '+(detail['status_label']?.toString()??detail['status']?.toString()??'—')),
    Text('بداية الفترة: '+(detail['current_period_start']?.toString()??'—')),
    Text('نهاية الفترة: '+(detail['current_period_end']?.toString()??'—')),
    if(trial is Map)...[const SizedBox(height:8),const Text('الفترة التجريبية',style:TextStyle(fontWeight:FontWeight.w700)),Text('الحالة: '+(trial['status']?.toString()??'—')),Text('تاريخ البدء: '+(trial['started_at']?.toString()??'—'))],
    const SizedBox(height:10),const Text('الاستخدام المسجل',style:TextStyle(fontWeight:FontWeight.w700)),
    ...controller.usageRows.map((row)=>Text((row['meter'] is Map?row['meter']['name']?.toString()??'عداد':'عداد')+': '+(row['quantity']?.toString()??'0'))),
    const SizedBox(height:10),const Text('سجل الأحداث',style:TextStyle(fontWeight:FontWeight.w700)),
    ...controller.eventRows.map((row)=>Text((row['event_type']?.toString()??'حدث')+' — '+(row['occurred_at']?.toString()??''))),
   ])),
   actions:[CustomButton.primary(text:'إغلاق',onPressed:()=>Navigator.pop(d))]
  ));
 }
 Future<void> _purchase(BuildContext c,int id)async{
  final eligibility=await controller.checkTrial(id);
  if(eligibility==null||!c.mounted)return;
  final ready=eligibility['purchase_ready']==true;
  final trial=eligibility['trial'];
  final trialEligible=trial is Map&&trial['eligible']==true;
  final blockers=(eligibility['purchase_blockers'] as List? ?? const []).join('، ');
  final ok=await showDialog<bool>(context:c,builder:(d)=>AlertDialog(
   title:const Text('تأكيد الاشتراك'),
   content:Text(!ready?'لا يمكن الشراء حالياً: '+blockers:(trialEligible?'السعر مؤهل لفترة تجريبية وفق سياسة المنصة.':'سيُنشأ طلب الاشتراك والفاتورة وفق شروط الخطة.')+' لن تُفعّل الاستحقاقات قبل اعتماد الدفع.'),
   actions:[CustomButton.text(text:'رجوع',onPressed:()=>Navigator.pop(d,false)),if(ready)CustomButton.primary(text:'متابعة',onPressed:()=>Navigator.pop(d,true))]
  ));
  if(ok==true)await controller.purchase(id);
 }
 Future<void> _cancel(BuildContext c,int id)async{final ok=await showDialog<bool>(context:c,builder:(d)=>AlertDialog(title:const Text('جدولة الإلغاء'),content:const Text('سيتم الإلغاء في نهاية فترة الخدمة الحالية.'),actions:[CustomButton.text(text:'رجوع',onPressed:()=>Navigator.pop(d,false)),CustomButton.danger(text:'تأكيد',onPressed:()=>Navigator.pop(d,true))]));if(ok==true)await controller.cancel(id);}
}
class _Header extends StatelessWidget{const _Header(this.value);final String value;@override Widget build(BuildContext c)=>Padding(padding:const EdgeInsets.only(top:18,bottom:8),child:Text(value,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w700)));}
