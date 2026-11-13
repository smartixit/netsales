import 'dart:async';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/billing/domain/usecases/billing_use_cases.dart';

class BillingReportsController extends GetxController {
  BillingReportsController({required this.useCases, required this.networkId});
  final BillingUseCases useCases;
  final int? Function() networkId;
  final catalog = <Map<String,dynamic>>[].obs;
  final rows = <Map<String,dynamic>>[].obs;
  final selectedType = RxnString();
  final summary = Rxn<Map<String,dynamic>>();
  final report = Rxn<Map<String,dynamic>>();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  int _revision = 0;

  List<Map<String,dynamic>> _list(dynamic value) => value is List
      ? value.whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList()
      : const [];
  Map<String,dynamic> _map(BillingPayload value) {
    final data=value.data['data']??value.data;
    return data is Map?Map<String,dynamic>.from(data):value.data;
  }
  @override void onInit(){super.onInit();unawaited(loadCatalog());}

  Future<void> loadCatalog() async {
    final network=networkId();if(network==null){errorMessage.value='حدد الشبكة أولاً.';return;}
    final rev=++_revision;isLoading.value=true;errorMessage.value=null;
    try{
      final result=_map(await useCases.reportsCatalog(network));
      catalog.assignAll(_list(result['reports']));
      if(rev!=_revision)return;
      if(catalog.isEmpty){selectedType.value=null;rows.clear();return;}
      final current=catalog.firstWhereOrNull((e)=>e['id']==selectedType.value)??catalog.first;
      selectedType.value=current['id']?.toString();
      await loadReport(revision:rev);
    }catch(e){if(rev==_revision)errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحميل كتالوج تقارير الاشتراكات.');}
    finally{if(rev==_revision)isLoading.value=false;}
  }

  Future<void> selectReport(String? type) async {
    if(type==null||type==selectedType.value)return;
    selectedType.value=type;
    await loadReport();
  }

  Future<void> loadReport({int? revision}) async {
    final network=networkId(),type=selectedType.value;if(network==null||type==null)return;
    final rev=revision??++_revision;isLoading.value=true;errorMessage.value=null;
    try{
      final values=await Future.wait([
        useCases.billingReport(network,type,const {'per_page':25}),
        useCases.billingReportSummary(network,type,const {}),
      ]);
      if(rev!=_revision)return;
      final result=_map(values[0]);
      report.value=result;
      rows.assignAll(_list(result['data']??result['items']));
      summary.value=_map(values[1]);
    }catch(e){if(rev==_revision)errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحميل تقرير الاشتراكات.');}
    finally{if(rev==_revision)isLoading.value=false;}
  }
}