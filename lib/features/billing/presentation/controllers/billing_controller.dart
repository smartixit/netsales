import 'dart:async';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/billing/domain/usecases/billing_use_cases.dart';
class BillingController extends GetxController {
  BillingController({required this.useCases, required this.networkId});
  final BillingUseCases useCases;
  final int? Function() networkId;
  final accounts = <Map<String,dynamic>>[].obs;
  final plans = <Map<String,dynamic>>[].obs;
  final subscriptions = <Map<String,dynamic>>[].obs;
  final invoices = <Map<String,dynamic>>[].obs;
  final payments = <Map<String,dynamic>>[].obs;
  final account = Rxn<Map<String,dynamic>>();
  final errorMessage = RxnString();
  final isLoading = false.obs;
  final isMutating = false.obs;
  final selectedAccountId = RxnInt();
  int _revision = 0;
  List<Map<String,dynamic>> _rows(BillingPayload p) {
    final v=p.data['data']??p.data['items']??p.data;
    return v is List ? v.whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList() : const [];
  }
  Map<String,dynamic> _object(BillingPayload p) {
    final v=p.data['data']??p.data;
    return v is Map ? Map<String,dynamic>.from(v) : p.data;
  }
  @override void onInit(){super.onInit();unawaited(load());}
  Future<void> load() async {
    final n=networkId(); if(n==null){errorMessage.value='حدد الشبكة أولاً.';return;}
    final rev=++_revision; isLoading.value=true; errorMessage.value=null;
    try {
      accounts.assignAll(_rows(await useCases.accounts(n)));
      if(rev!=_revision)return;
      if(accounts.isEmpty){account.value=null;selectedAccountId.value=null;return;}
      final chosen=accounts.firstWhereOrNull((e)=>e['billing_account_id']==selectedAccountId.value)??accounts.first;
      selectedAccountId.value=(chosen['billing_account_id'] as num).toInt();
      await loadAccountData(revision:rev);
    } catch(e){if(rev==_revision)errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحميل بيانات الفوترة.');}
    finally{if(rev==_revision)isLoading.value=false;}
  }
  Future<void> loadAccountData({int? revision}) async {
    final id=selectedAccountId.value;if(id==null)return;final rev=revision??++_revision;isLoading.value=true;
    try{
      final r=await Future.wait([useCases.account(id),useCases.plans(id,const {'per_page':50}),useCases.subscriptions(id,const {'per_page':25}),useCases.invoices(id,const {'per_page':25}),useCases.payments(id,const {'per_page':25})]);
      if(rev!=_revision||id!=selectedAccountId.value)return;
      account.value=_object(r[0]);plans.assignAll(_rows(r[1]));subscriptions.assignAll(_rows(r[2]));invoices.assignAll(_rows(r[3]));payments.assignAll(_rows(r[4]));
    }catch(e){if(rev==_revision)errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحميل تفاصيل حساب الفوترة.');}
    finally{if(rev==_revision)isLoading.value=false;}
  }
  Future<void> purchase(int priceId) async {
    final id=selectedAccountId.value;if(id==null||isMutating.value)return;isMutating.value=true;
    try{await useCases.purchase(id,priceId);await loadAccountData();}
    catch(e){errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر إنشاء الاشتراك.');}
    finally{isMutating.value=false;}
  }
  Future<void> cancel(int id) async {
    if(isMutating.value)return;isMutating.value=true;
    try{await useCases.cancel(id,true);await loadAccountData();}
    catch(e){errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر جدولة الإلغاء.');}
    finally{isMutating.value=false;}
  }
}