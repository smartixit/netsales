import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/billing/domain/usecases/billing_use_cases.dart';
class BillingController extends GetxController {
  BillingController({required this.useCases, required this.networkId});
  final BillingUseCases useCases;
  final int? Function() networkId;
  final accounts = <Map<String,dynamic>>[].obs;
  final currencies = <Map<String,dynamic>>[].obs;
  final selectedCurrencyId = RxnInt();
  final plans = <Map<String,dynamic>>[].obs;
  final subscriptions = <Map<String,dynamic>>[].obs;
  final invoices = <Map<String,dynamic>>[].obs;
  final creditNotes = <Map<String,dynamic>>[].obs;
  final refunds = <Map<String,dynamic>>[].obs;
  final payments = <Map<String,dynamic>>[].obs;
  final paymentMethods = <Map<String,dynamic>>[].obs;
  final selectedPaymentMethodId = RxnInt();
  final entitlements = Rxn<Map<String,dynamic>>();
  final account = Rxn<Map<String,dynamic>>();
  final errorMessage = RxnString();
  final isLoading = false.obs;
  final isMutating = false.obs;
  final selectedAccountId = RxnInt();
  int _revision = 0;
  List<Map<String,dynamic>> _rows(BillingPayload p) {
    final v=p.data['data']??p.data['items']??p.data;
    return v is List ? v.whereType<Map<String,dynamic>>().map((e)=>Map<String,dynamic>.from(e)).toList() : const [];
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
      final results = await Future.wait([useCases.accounts(n), useCases.currencies()]);
      accounts.assignAll(_rows(results[0]));
      currencies.assignAll(_rows(results[1]));
      if (selectedCurrencyId.value == null && currencies.isNotEmpty) selectedCurrencyId.value = (currencies.first['currency_id'] as num).toInt();
      if(rev!=_revision)return;
      if(accounts.isEmpty){account.value=null;selectedAccountId.value=null;return;}
      final chosen=accounts.firstWhereOrNull((e)=>e['billing_account_id']==selectedAccountId.value)??accounts.first;
      selectedAccountId.value=(chosen['billing_account_id'] as num).toInt();
      await loadAccountData(revision:rev);
    } catch(e){if(rev==_revision)errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحميل بيانات الفوترة.');}
    finally{if(rev==_revision)isLoading.value=false;}
  }
  Future<void> createAccount() async {
    final n = networkId();
    final currencyId = selectedCurrencyId.value;
    if (n == null || currencyId == null || isMutating.value) return;
    isMutating.value = true;
    try { await useCases.createAccount(n, currencyId); await load(); }
    catch (error) { errorMessage.value = AppException.sanitizeMessage(error, fallback: 'تعذر إنشاء حساب الفوترة.'); }
    finally { isMutating.value = false; }
  }

  Future<void> selectAccount(int? id) async {
    if (id == null || id == selectedAccountId.value) return;
    selectedAccountId.value = id;
    await loadAccountData();
  }

  Future<void> loadAccountData({int? revision}) async {
    final id=selectedAccountId.value;if(id==null)return;final rev=revision??++_revision;isLoading.value=true;
    try{
      final r=await Future.wait([useCases.account(id),useCases.plans(id,const {'per_page':50}),useCases.subscriptions(id,const {'per_page':25}),useCases.invoices(id,const {'per_page':25}),useCases.payments(id,const {'per_page':25}),useCases.entitlements(id),useCases.paymentMethods(id),useCases.creditNotes(id,const {'per_page':25}),useCases.refunds(id,const {'per_page':25})]);
      if(rev!=_revision||id!=selectedAccountId.value)return;
      account.value=_object(r[0]);plans.assignAll(_rows(r[1]));subscriptions.assignAll(_rows(r[2]));invoices.assignAll(_rows(r[3]));payments.assignAll(_rows(r[4]));entitlements.value=_object(r[5]);paymentMethods.assignAll(_rows(r[6]));creditNotes.assignAll(_rows(r[7]));refunds.assignAll(_rows(r[8]));
      if (selectedPaymentMethodId.value == null && paymentMethods.isNotEmpty) selectedPaymentMethodId.value = (paymentMethods.first['payment_method_id'] as num).toInt();
    }catch(e){if(rev==_revision)errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحميل تفاصيل حساب الفوترة.');}
    finally{if(rev==_revision)isLoading.value=false;}
  }
  Future<Map<String, dynamic>?> checkTrial(int priceId) async {
    final id = selectedAccountId.value;
    if (id == null) return null;
    try {
      final payload = await useCases.trialEligibility(id, priceId);
      final value = payload.data['data'] ?? payload.data;
      return value is Map ? Map<String, dynamic>.from(value) : null;
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر التحقق من أهلية الفترة التجريبية.',
      );
      return null;
    }
  }

  final subscriptionDetails = Rxn<Map<String, dynamic>>();
  final usageRows = <Map<String, dynamic>>[].obs;
  final eventRows = <Map<String, dynamic>>[].obs;

  Future<void> loadSubscriptionDetails(int id) async {
    try {
      final values = await Future.wait([
        useCases.subscription(id),
        useCases.events(id, const {'per_page': 30}),
        useCases.usage(id, const {'per_page': 30}),
      ]);
      final detail = _object(values[0]);
      final rawSubscription = detail['subscription'];
      subscriptionDetails.value = rawSubscription is Map<String,dynamic>
          ? Map<String, dynamic>.from(rawSubscription)
          : detail;
      final events = values[1].data['data'] ?? values[1].data['items'] ?? values[1].data;
      final usage = values[2].data['data'] ?? values[2].data['items'] ?? values[2].data;
      eventRows.assignAll(events is List ? events.whereType<Map<String,dynamic>>().map((e) => Map<String,dynamic>.from(e)).toList() : const []);
      usageRows.assignAll(usage is List ? usage.whereType<Map<String,dynamic>>().map((e) => Map<String,dynamic>.from(e)).toList() : const []);
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(error, fallback: 'تعذر تحميل تفاصيل الاشتراك والاستخدام.');
    }
  }

  Future<void> updateAccount(Map<String, dynamic> data) async {
    final id=selectedAccountId.value;if(id==null||isMutating.value)return;isMutating.value=true;
    try{await useCases.updateAccount(id,data);await loadAccountData();}
    catch(e){errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحديث حساب الفوترة.');}
    finally{isMutating.value=false;}
  }
  Future<void> createContact(Map<String,dynamic> data) async {
    final id=selectedAccountId.value;if(id==null||isMutating.value)return;isMutating.value=true;
    try{await useCases.createContact(id,data);await loadAccountData();}
    catch(e){errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر إضافة جهة الاتصال.');}
    finally{isMutating.value=false;}
  }
  Future<void> updateContact(int contactId,Map<String,dynamic> data) async {
    final id=selectedAccountId.value;if(id==null||isMutating.value)return;isMutating.value=true;
    try{await useCases.updateContact(id,contactId,data);await loadAccountData();}
    catch(e){errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحديث جهة الاتصال.');}
    finally{isMutating.value=false;}
  }
  Future<void> deleteContact(int contactId) async {
    final id=selectedAccountId.value;if(id==null||isMutating.value)return;isMutating.value=true;
    try{await useCases.deleteContact(id,contactId);await loadAccountData();}
    catch(e){errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر حذف جهة الاتصال.');}
    finally{isMutating.value=false;}
  }

  Future<void> purchase(int priceId) async {
    final id=selectedAccountId.value;if(id==null||isMutating.value)return;isMutating.value=true;
    try{await useCases.purchase(id,priceId);await loadAccountData();}
    catch(e){errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر إنشاء الاشتراك.');}
    finally{isMutating.value=false;}
  }
  Future<void> recordPayment(int invoiceId, int paymentMethodId, int amountMinor, String? externalReference, String? proofPath) async {
    if (isMutating.value) return;
    isMutating.value = true;
    try {
      final random = Random.secure();
      final key = List<int>.generate(16, (_) => random.nextInt(256))
          .map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
      await useCases.recordPayment(invoiceId, paymentMethodId, amountMinor, key, externalReference, proofPath);
      await loadAccountData();
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(error, fallback: 'تعذر تسجيل طلب الدفع.');
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> cancel(int id, {required bool atPeriodEnd}) async {
    if(isMutating.value)return;isMutating.value=true;
    try{await useCases.cancel(id,atPeriodEnd);await loadAccountData();}
    catch(e){errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر جدولة الإلغاء.');}
    finally{isMutating.value=false;}
  }
}