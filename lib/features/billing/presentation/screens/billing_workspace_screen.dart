import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
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
        child: Text((e['default_currency'] is Map<String,dynamic> ? e['default_currency']['code']?.toString() : null) ?? e['legal_name']?.toString() ?? 'حساب فوترة'),
      )).toList(),
      rxValue: controller.selectedAccountId,
      onChanged: controller.selectAccount,
      label: 'حساب الفوترة',
      hint: 'اختر حساب الفوترة',
    ),
    Text(a['legal_name']?.toString()??'حساب الشبكة'),Text('رقم الحساب: '+(a['account_number']?.toString()??'—')),Text('البريد: '+(a['billing_email']?.toString()??'—')),
    const SizedBox(height:10),
    Wrap(spacing:8,children:[
      CustomButton.outline(text:'تعديل البيانات',prefix:Icons.edit_outlined,onPressed:()=>_editAccount(context,a)),
      CustomButton.primary(text:'إضافة جهة اتصال',prefix:Icons.person_add_alt_1,onPressed:()=>_addContact(context)),
    ]),
    const SizedBox(height:8),
    const Text('جهات الاتصال',style:TextStyle(fontWeight:FontWeight.w700)),
    if(a['contacts'] is List)...(a['contacts'] as List<dynamic>).whereType<Map<String,dynamic>>().map((contact){
      final contactId=(contact['contact_id'] as num?)?.toInt();
      return ListTile(
        contentPadding:EdgeInsets.zero,
        title:Text(contact['name']?.toString()??'جهة اتصال'),
        subtitle:Text([contact['email'],contact['phone'],if(contact['is_primary']==true)'أساسية',if(contact['receives_invoices']==true)'تستقبل الفواتير'].where((v)=>v!=null&&v.toString().isNotEmpty).join(' • ')),
        trailing:Wrap(mainAxisSize:MainAxisSize.min,children:[
          CustomButton.text(text:'تعديل',onPressed:contactId==null?null:()=>_editContact(context,contact)),
          CustomButton.text(text:'حذف',foregroundColor:Theme.of(context).colorScheme.error,onPressed:contactId==null?null:()=>_deleteContact(context,contactId)),
        ]),
      );
    })]))),
    const _Header('الخطط المتاحة'),
    ...controller.plans.map((p){final v=p['current_version'];final ps=v is Map<String,dynamic>&&v['prices'] is List?v['prices'] as List<dynamic>:const <dynamic>[];final price=ps.isNotEmpty&&ps.first is Map<String,dynamic>?ps.first as Map<String,dynamic>:const <String,dynamic>{};final id=(price['price_id'] as num?)?.toInt();return Card(child:ListTile(title:Text(p['name']?.toString()??'خطة اشتراك'),subtitle:Text('السعر: '+(price['unit_amount']?.toString()??price['unit_amount_minor']?.toString()??'—')),trailing:CustomButton.primary(text:'اختيار',loading:controller.isMutating.value,onPressed:id==null?null:()=>_purchase(context,id))));}),
    const _Header('الاشتراك الحالي'),
    ...controller.subscriptions.map((s){final id=(s['billing_subscription_id'] as num?)?.toInt();return Card(child:ListTile(title:Text(s['plan'] is Map<String,dynamic>?s['plan']['name']?.toString()??'اشتراك':'اشتراك'),subtitle:Text('الحالة: '+(s['status_label']?.toString()??s['status']?.toString()??'—')+'\nنهاية الفترة: '+(s['current_period_end']?.toString()??'—')),isThreeLine:true,trailing:Wrap(spacing:6,children:[CustomButton.text(text:'التفاصيل',onPressed:id==null?null:()=>_details(context,id)),CustomButton.outline(text:'إلغاء',onPressed:id==null?null:()=>_cancel(context,id))])));}),
    const _Header('الاستحقاقات والمزايا'),
    if(controller.entitlements.value?['features'] is List)
      ...(controller.entitlements.value!['features'] as List<dynamic>).whereType<Map<String,dynamic>>().map((f)=>Card(child:ListTile(title:Text(f['name']?.toString()??f['feature_key']?.toString()??'ميزة'),subtitle:Text('القيمة: '+(f['configured_value']?.toString()??'—')),trailing:Icon(f['available']==true?Icons.check_circle_rounded:Icons.block_rounded,color:f['available']==true?Colors.green:Colors.red)))),
    if(controller.entitlements.value?['trial'] is Map<String,dynamic>)...[
      Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('حالة الفترة التجريبية',style:TextStyle(fontWeight:FontWeight.w700)),
        Text((controller.entitlements.value!['trial']['awaiting_first_activation']==true)
          ? 'التجربة معتمدة وتبدأ عند أول تفعيل تشغيلي؛ لم يبدأ عدادها بعد.'
          : 'الحالة: '+(controller.entitlements.value!['trial']['status']?.toString()??'قيد المعالجة')),
        Text('تاريخ البدء: '+(controller.entitlements.value!['trial']['start']?.toString()??'لم تبدأ')),
        Text('تاريخ الانتهاء: '+(controller.entitlements.value!['trial']['end']?.toString()??'—')),
      ]))),
    ],
    const _Header('الفواتير'),
    ...controller.invoices.map((e){
      final invoiceId=(e['invoice_id'] as num?)?.toInt();
      final remaining=int.tryParse(e['remaining_minor']?.toString()??'0')??0;
      final canPay=remaining>0&&e['status']!='PAID'&&e['status']!='VOID'&&invoiceId!=null;
      return Card(child:ListTile(
        title:Text(e['invoice_number']?.toString()??'فاتورة'),
        subtitle:Text('الحالة: '+(e['status']?.toString()??'—')+' • المتبقي: '+remaining.toString()),
        trailing:Wrap(mainAxisSize:MainAxisSize.min,spacing:8,children:[
          Text(e['total_minor']?.toString()??'—'),
          if(canPay)CustomButton.primary(text:'تسجيل دفعة',onPressed:()=>_payInvoice(context,e)),
        ]),
      ));
    }),
    const _Header('الإشعارات الدائنة'),
    ...controller.creditNotes.map((e)=>Card(child:ListTile(title:Text(e['credit_note_number']?.toString()??'إشعار دائن'),subtitle:Text(e['status']?.toString()??'—'),trailing:Text(e['total_minor']?.toString()??'—')))),
    const _Header('الاستردادات'),
    ...controller.refunds.map((e)=>Card(child:ListTile(title:Text(e['refund_reference']?.toString()??'استرداد'),subtitle:Text(e['status']?.toString()??'—'),trailing:Text(e['amount_minor']?.toString()??'—')))),
    const _Header('المدفوعات'),
    ...controller.payments.map((e)=>Card(child:ListTile(title:Text(e['payment_reference']?.toString()??'دفعة'),subtitle:Text(e['status']?.toString()??'—'),trailing:Text(e['amount']?.toString()??'—')))),
   ]
  ]));
 });
 Future<void> _editAccount(BuildContext context,Map<String,dynamic> account)async{
  final legal=TextEditingController(text:account['legal_name']?.toString()??'');
  final email=TextEditingController(text:account['billing_email']?.toString()??'');
  final tax=TextEditingController(text:account['tax_number']?.toString()??'');
  final address=TextEditingController(text:account['billing_address']?.toString()??'');
  final terms=TextEditingController(text:account['payment_terms_days']?.toString()??'0');
  try{
   final ok=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(
    title:const Text('تعديل حساب الفوترة'),
    content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      CustomTextField(controller:legal,label:'الاسم القانوني',isRequired:true),
      CustomTextField(controller:email,label:'البريد المحاسبي',keyboardType:TextInputType.emailAddress,isRequired:false),
      CustomTextField(controller:tax,label:'الرقم الضريبي',isRequired:false),
      CustomTextField(controller:address,label:'عنوان الفوترة',maxLines:2,isRequired:false),
      CustomTextField(controller:terms,label:'أيام السداد',keyboardType:TextInputType.number,isRequired:true),
    ])),
    actions:[CustomButton.text(text:'إلغاء',onPressed:()=>Navigator.pop(d,false)),CustomButton.primary(text:'حفظ',onPressed:()=>Navigator.pop(d,true))]
   ));
   if(ok==true)await controller.updateAccount({'legal_name':legal.text.trim(),'billing_email':email.text.trim().isEmpty?null:email.text.trim(),'tax_number':tax.text.trim().isEmpty?null:tax.text.trim(),'billing_address':address.text.trim().isEmpty?null:address.text.trim(),'payment_terms_days':int.tryParse(terms.text.trim())??0});
  }finally{legal.dispose();email.dispose();tax.dispose();address.dispose();terms.dispose();}
 }
 Future<void> _addContact(BuildContext context)async{
  final name=TextEditingController(),email=TextEditingController(),phone=TextEditingController();
  try{
   final ok=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(
    title:const Text('إضافة جهة اتصال'),
    content:Column(mainAxisSize:MainAxisSize.min,children:[
      CustomTextField(controller:name,label:'الاسم',isRequired:true),
      CustomTextField(controller:email,label:'البريد الإلكتروني',keyboardType:TextInputType.emailAddress,isRequired:false),
      CustomTextField(controller:phone,label:'رقم الهاتف',keyboardType:TextInputType.phone,isRequired:false),
    ]),
    actions:[CustomButton.text(text:'إلغاء',onPressed:()=>Navigator.pop(d,false)),CustomButton.primary(text:'إضافة',onPressed:()=>Navigator.pop(d,true))]
   ));
   if(ok==true&&name.text.trim().isNotEmpty)await controller.createContact({'name':name.text.trim(),'email':email.text.trim().isEmpty?null:email.text.trim(),'phone':phone.text.trim().isEmpty?null:phone.text.trim(),'is_primary':false,'receives_invoices':true});
  }finally{name.dispose();email.dispose();phone.dispose();}
 }
 Future<void> _editContact(BuildContext context,Map<String,dynamic> contact)async{
  final name=TextEditingController(text:contact['name']?.toString()??''),email=TextEditingController(text:contact['email']?.toString()??''),phone=TextEditingController(text:contact['phone']?.toString()??'');
  try{
   final ok=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(
    title:const Text('تعديل جهة الاتصال'),
    content:Column(mainAxisSize:MainAxisSize.min,children:[
      CustomTextField(controller:name,label:'الاسم',isRequired:true),
      CustomTextField(controller:email,label:'البريد الإلكتروني',isRequired:false),
      CustomTextField(controller:phone,label:'رقم الهاتف',isRequired:false),
    ]),
    actions:[CustomButton.text(text:'إلغاء',onPressed:()=>Navigator.pop(d,false)),CustomButton.primary(text:'حفظ',onPressed:()=>Navigator.pop(d,true))]
   ));
   final id=(contact['contact_id'] as num?)?.toInt();
   if(ok==true&&id!=null)await controller.updateContact(id,{'name':name.text.trim(),'email':email.text.trim().isEmpty?null:email.text.trim(),'phone':phone.text.trim().isEmpty?null:phone.text.trim()});
  }finally{name.dispose();email.dispose();phone.dispose();}
 }
 Future<void> _deleteContact(BuildContext context,int id)async{
  final ok=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:const Text('حذف جهة الاتصال'),content:const Text('هل تريد حذف جهة الاتصال المحددة؟'),actions:[CustomButton.text(text:'إلغاء',onPressed:()=>Navigator.pop(d,false)),CustomButton.danger(text:'حذف',onPressed:()=>Navigator.pop(d,true))]));
  if(ok==true)await controller.deleteContact(id);
 }
 Future<void> _payInvoice(BuildContext context,Map<String,dynamic> invoice)async{
  final invoiceId=(invoice['invoice_id'] as num?)?.toInt();
  final remaining=int.tryParse(invoice['remaining_minor']?.toString()??'0')??0;
  if(invoiceId==null||remaining<=0)return;
  final amount=TextEditingController(text:remaining.toString());
  final reference=TextEditingController();
  String? proofPath;
  try{
   final accepted=await showDialog<bool>(context:context,builder:(dialogContext)=>StatefulBuilder(builder:(dialogContext,setDialogState)=>AlertDialog(
    title:const Text('تسجيل دفعة على الفاتورة'),
    content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      Text('المبلغ المتبقي: '+remaining.toString()+' وحدة صغرى'),
      if(controller.paymentMethods.isNotEmpty)CustomDropdown<int>(
        items:controller.paymentMethods.map((m)=>DropdownItem<int>(
          value:(m['payment_method_id'] as num).toInt(),
          child:Text(m['name']?.toString()??m['code']?.toString()??'وسيلة دفع'),
        )).toList(),
        rxValue:controller.selectedPaymentMethodId,
        onChanged:(id)=>controller.selectedPaymentMethodId.value=id,
        label:'وسيلة الدفع',
        hint:'اختر وسيلة الدفع',
      ) else const Text('لا توجد وسيلة دفع مفعلة بهذه العملة.'),
      CustomTextField(controller:amount,label:'المبلغ بالوحدة الصغرى',keyboardType:TextInputType.number),
      CustomTextField(controller:reference,label:'مرجع التحويل',isRequired:false),
      const SizedBox(height:8),
      CustomButton.outline(text:proofPath==null?'إرفاق إثبات الدفع':proofPath!.split('/').last,prefix:Icons.attach_file,onPressed:()async{
        final result=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['pdf','jpg','jpeg','png'],withData:false);
        if(result!=null&&result.files.single.path!=null)setDialogState(()=>proofPath=result.files.single.path);
      }),
      const SizedBox(height:8),
      const Text('سيُسجل الطلب بانتظار مراجعة المنصة. لن يتفعل الاشتراك قبل اعتماد الدفع.'),
    ])),
    actions:[
      CustomButton.text(text:'إلغاء',onPressed:()=>Navigator.pop(dialogContext,false)),
      CustomButton.primary(text:'إرسال طلب الدفع',loading:controller.isMutating.value,onPressed:controller.selectedPaymentMethodId.value==null?null:()=>Navigator.pop(dialogContext,true)),
    ],
   )));
   final amountMinor=int.tryParse(amount.text.trim());
   if(accepted==true&&amountMinor!=null&&amountMinor>0&&amountMinor<=remaining&&controller.selectedPaymentMethodId.value!=null){
     await controller.recordPayment(invoiceId,controller.selectedPaymentMethodId.value!,amountMinor,reference.text.trim().isEmpty?null:reference.text.trim(),proofPath);
   }
  }finally{amount.dispose();reference.dispose();}
 }
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
    if(trial is Map<String,dynamic>)...[const SizedBox(height:8),const Text('الفترة التجريبية',style:TextStyle(fontWeight:FontWeight.w700)),Text('الحالة: '+(trial['status']?.toString()??'—')),Text('تاريخ البدء: '+(trial['started_at']?.toString()??'—')),Text('تاريخ الانتهاء: '+(trial['completed_at']?.toString()??'—'))],
    const SizedBox(height:10),const Text('الاستخدام المسجل',style:TextStyle(fontWeight:FontWeight.w700)),
    ...controller.usageRows.map((row)=>Text((row['meter'] is Map<String,dynamic>?row['meter']['name']?.toString()??'عداد':'عداد')+': '+(row['quantity']?.toString()??'0'))),
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
  final trialEligible=trial is Map<String,dynamic>&&trial['eligible']==true;
  final blockers=(eligibility['purchase_blockers'] as List<dynamic>? ?? const <dynamic>[]).join('، ');
  final ok=await showDialog<bool>(context:c,builder:(d)=>AlertDialog(
   title:const Text('تأكيد الاشتراك'),
   content:Text(!ready?'لا يمكن الشراء حالياً: '+blockers:(trialEligible?'السعر مؤهل لفترة تجريبية وفق سياسة المنصة.':'سيُنشأ طلب الاشتراك والفاتورة وفق شروط الخطة.')+' لن تُفعّل الاستحقاقات قبل اعتماد الدفع.'),
   actions:[CustomButton.text(text:'رجوع',onPressed:()=>Navigator.pop(d,false)),if(ready)CustomButton.primary(text:'متابعة',onPressed:()=>Navigator.pop(d,true))]
  ));
  if(ok==true)await controller.purchase(id);
 }
 Future<void> _cancel(BuildContext c,int id)async{
  final choice=await showDialog<bool?>(context:c,builder:(d)=>AlertDialog(
   title:const Text('إلغاء الاشتراك'),
   content:const Text('اختر توقيت الإلغاء. الإلغاء الفوري ينهي الاستحقاقات وفق سياسة الخادم ولا يمكن التراجع عنه من هذه الشاشة.'),
   actions:[
    CustomButton.text(text:'رجوع',onPressed:()=>Navigator.pop(d,null)),
    CustomButton.outline(text:'نهاية الفترة',onPressed:()=>Navigator.pop(d,true)),
    CustomButton.danger(text:'إلغاء فوري',onPressed:()=>Navigator.pop(d,false)),
   ],
  ));
  if(choice!=null)await controller.cancel(id,atPeriodEnd:choice);
 }
}
class _Header extends StatelessWidget{const _Header(this.value);final String value;@override Widget build(BuildContext c)=>Padding(padding:const EdgeInsets.only(top:18,bottom:8),child:Text(value,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w700)));}
