import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/billing/domain/usecases/billing_use_cases.dart';
import 'package:netsales/core/services/file_export_service.dart';

class BillingReportsController extends GetxController {
  BillingReportsController({required this.useCases, required this.networkId});
  final BillingUseCases useCases;
  final int? Function() networkId;
  final catalog=<Map<String,dynamic>>[].obs;
  final rows=<Map<String,dynamic>>[].obs;
  final selectedType=RxnString();
  final summary=Rxn<Map<String,dynamic>>();
  final isLoading=false.obs;
  final isLoadingMore=false.obs;
  final errorMessage=RxnString();
  final searchController=TextEditingController();
  final statusController=TextEditingController();
  final fromDate=Rxn<DateTime>();
  final toDate=Rxn<DateTime>();
  final searchQuery=''.obs;
  Worker? _searchWorker;
  int _revision=0;
  String? _nextCursor;

  List<Map<String,dynamic>> _list(dynamic value)=>value is List?value.whereType<Map<String,dynamic>>().map((e)=>Map<String,dynamic>.from(e)).toList():const [];
  Map<String,dynamic> _map(BillingPayload p){final d=p.data['data']??p.data;return d is Map?Map<String,dynamic>.from(d):p.data;}
  String _date(DateTime? value)=>value==null?'':value.toIso8601String().substring(0,10);
  Map<String,dynamic> get _filters=>{
    'per_page':25,
    if(fromDate.value!=null)'from_date':_date(fromDate.value),
    if(toDate.value!=null)'to_date':_date(toDate.value),
    if(statusController.text.trim().isNotEmpty)'status':statusController.text.trim(),
    if(searchQuery.value.trim().isNotEmpty)'search':searchQuery.value.trim(),
  };

  @override void onInit(){
    super.onInit();
    _searchWorker=debounce(searchQuery,(_)=>loadReport(),time:const Duration(milliseconds:400));
    unawaited(loadCatalog());
  }
  @override void onClose(){
    _searchWorker?.dispose();searchController.dispose();statusController.dispose();super.onClose();
  }

  Future<void> loadCatalog()async{
    final n=networkId();if(n==null){errorMessage.value='حدد الشبكة أولاً.';return;}
    final rev=++_revision;isLoading.value=true;errorMessage.value=null;
    try{
      final result=_map(await useCases.reportsCatalog(n));
      catalog.assignAll(_list(result['reports']));
      if(rev!=_revision)return;
      if(catalog.isEmpty){selectedType.value=null;rows.clear();return;}
      final chosen=catalog.firstWhereOrNull((e)=>e['id']==selectedType.value)??catalog.first;
      selectedType.value=chosen['id']?.toString();
      await loadReport(revision:rev);
    }catch(e){if(rev==_revision)errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحميل كتالوج تقارير الاشتراكات.');}
    finally{if(rev==_revision)isLoading.value=false;}
  }
  Future<void> selectReport(String? type)async{
    if(type==null||type==selectedType.value)return;selectedType.value=type;await loadReport();
  }
  Future<void> applyFilters()=>loadReport();
  Future<void> setFromDate(DateTime? value)async{fromDate.value=value;await loadReport();}
  Future<void> setToDate(DateTime? value)async{toDate.value=value;await loadReport();}
  Future<void> clearFilters()async{
    searchController.clear();statusController.clear();searchQuery.value='';fromDate.value=null;toDate.value=null;await loadReport();
  }

  Future<void> loadReport({int? revision})async{
    final n=networkId(),type=selectedType.value;if(n==null||type==null)return;
    final rev=revision??++_revision;isLoading.value=true;isLoadingMore.value=false;errorMessage.value=null;_nextCursor=null;
    try{
      final query=_filters;
      final values=await Future.wait([useCases.billingReport(n,type,query),useCases.billingReportSummary(n,type,query)]);
      if(rev!=_revision)return;
      final data=_map(values[0]);
      rows.assignAll(_list(data['data']??data['items']));
      _nextCursor=_cursorFrom(data['next_page_url']??(data['links'] is Map<String,dynamic>?data['links']['next']:null));
      summary.value=_map(values[1]);
    }catch(e){if(rev==_revision)errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحميل تقرير الاشتراكات.');}
    finally{if(rev==_revision)isLoading.value=false;}
  }
  String? _cursorFrom(dynamic url){
    if(url is! String||url.isEmpty)return null;
    try{return Uri.parse(url).queryParameters['cursor'];}catch(_){return null;}
  }
  Future<void> exportCsv() async {
    final n=networkId(),type=selectedType.value;
    if(n==null||type==null||isLoading.value)return;
    try {
      final bytes=await useCases.exportBillingReport(n,type,_filters);
      final result=await FileExportService.instance.saveFile(
        bytes:bytes,fileName:'Billing-$type',extension:'csv',
        namingStrategy:FileNamingStrategy.report,autoOpen:false,
      );
      if(!result.isSuccess)errorMessage.value=result.errorMessage??'تعذر حفظ ملف التقرير.';
    } catch(error) {
      errorMessage.value=AppException.sanitizeMessage(error,fallback:'تعذر تصدير تقرير الاشتراكات.');
    }
  }

  Future<void> loadMore()async{
    final n=networkId(),type=selectedType.value,cursor=_nextCursor;
    if(n==null||type==null||cursor==null||isLoadingMore.value)return;
    final rev=_revision;isLoadingMore.value=true;
    try{
      final query={..._filters,'cursor':cursor};
      final data=_map(await useCases.billingReport(n,type,query));
      if(rev!=_revision)return;
      rows.addAll(_list(data['data']??data['items']));
      _nextCursor=_cursorFrom(data['next_page_url']??(data['links'] is Map<String,dynamic>?data['links']['next']:null));
    }catch(e){errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحميل بقية سجلات التقرير.');}
    finally{isLoadingMore.value=false;}
  }
}