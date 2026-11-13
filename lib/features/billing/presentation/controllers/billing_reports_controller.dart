import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/billing/domain/usecases/billing_use_cases.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/features/billing/data/services/billing_report_document_service.dart';

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
  final isExportingPdf=false.obs;
  final errorMessage=RxnString();
  final searchController=TextEditingController();
  final statusController=TextEditingController();
  final fromDate=Rxn<DateTime>();
  final toDate=Rxn<DateTime>();
  final searchQuery=''.obs;
  final selectedStatus=RxnString();
  Worker? _searchWorker;
  int _revision=0;
  String? _nextCursor;

  List<Map<String,dynamic>> _list(dynamic value)=>value is List?value.whereType<Map<String,dynamic>>().map((e)=>Map<String,dynamic>.from(e)).toList():const [];
  Map<String,dynamic> _map(BillingPayload p){final d=p.data['data']??p.data;return d is Map?Map<String,dynamic>.from(d):p.data;}
  String _date(DateTime? value)=>value==null?'':value.toIso8601String().substring(0,10);
  Map<String,dynamic>? get selectedDefinition => catalog.firstWhereOrNull((e)=>e['id']==selectedType.value);
  List<String> get _filterIds => (selectedDefinition?['filters'] is List<dynamic>)
      ? (selectedDefinition!['filters'] as List<dynamic>).whereType<Map<String,dynamic>>().map((e)=>e['id']?.toString()??'').toList()
      : const ['from_date','to_date','status','search'];
  bool get hasDateFilters => _filterIds.contains('from_date') || _filterIds.contains('to_date');
  bool get hasStatusFilter => _filterIds.contains('status');
  bool get hasSearchFilter => _filterIds.contains('search');
  List<Map<String,dynamic>> get statusChoices {
    final filters=selectedDefinition?['filters'];
    if(filters is! List<dynamic>)return const [];
    final filter=filters.whereType<Map<String,dynamic>>().firstWhereOrNull((e)=>e['id']=='status');
    final choices=filter?['choices'];
    return choices is List<dynamic>?choices.whereType<Map<String,dynamic>>().toList():const [];
  }

  Map<String,dynamic> get _filters=>{
    'per_page':25,
    if(hasDateFilters&&fromDate.value!=null)'from_date':_date(fromDate.value),
    if(hasDateFilters&&toDate.value!=null)'to_date':_date(toDate.value),
    if(hasStatusFilter&&(selectedStatus.value?.isNotEmpty??false))'status':selectedStatus.value,
    if(hasStatusFilter&&statusChoices.isEmpty&&statusController.text.trim().isNotEmpty)'status':statusController.text.trim(),
    if(hasSearchFilter&&searchQuery.value.trim().isNotEmpty)'search':searchQuery.value.trim(),
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
  Future<void> setStatus(String? value)async{selectedStatus.value=value;await loadReport();}
  Future<void> setFromDate(DateTime? value)async{fromDate.value=value;await loadReport();}
  Future<void> setToDate(DateTime? value)async{toDate.value=value;await loadReport();}
  Future<void> clearFilters()async{
    searchController.clear();statusController.clear();searchQuery.value='';selectedStatus.value=null;fromDate.value=null;toDate.value=null;await loadReport();
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

  Future<void> exportPdfSummary() async {
    final type=selectedType.value;
    final metrics=summary.value;
    if(type==null||metrics==null||isExportingPdf.value)return;
    final definition=catalog.firstWhereOrNull((e)=>e['id']==type);
    final label=definition?['label']?.toString()??type;
    isExportingPdf.value=true;
    try {
      final network=networkId();
      if(network==null)throw StateError('حدد الشبكة أولاً.');
      final total=int.tryParse(metrics['record_count']?.toString()??'')??0;
      if(total>1500)throw StateError('يتجاوز عدد السجلات 1500؛ استخدم تصدير CSV للحصول على الملف الكامل دون اقتطاع.');
      final allRows=<Map<String,dynamic>>[];
      String? cursor;
      do{
        final query=<String,dynamic>{..._filters,'per_page':100,if(cursor!=null)'cursor':cursor};
        final page=_map(await useCases.billingReport(network,type,query));
        allRows.addAll(_list(page['data']??page['items']));
        cursor=_cursorFrom(page['next_page_url']??(page['links'] is Map<String,dynamic>?page['links']['next']:null));
        if(allRows.length>1500)throw StateError('يتجاوز عدد السجلات الحد الآمن لملف PDF.');
      }while(cursor!=null);
      if(allRows.length<total)throw StateError('لم تكتمل قراءة جميع صفحات التقرير؛ أُوقف إنشاء PDF الجزئي.');
      final rawColumns=definition?['columns'];
      final columns=rawColumns is List<dynamic>?rawColumns.whereType<Map<String,dynamic>>().toList():<Map<String,dynamic>>[];
      if(columns.isEmpty)throw StateError('تعريف أعمدة التقرير غير متاح لإنشاء PDF.');
      final result=await BillingReportDocumentService.instance.exportSummary(
        reportType:type,
        reportLabel:label,
        summary:metrics,
        rows:allRows,
        columns:columns,
        localeTag:'ar-YE',
        fromDate:fromDate.value==null?null:_date(fromDate.value),
        toDate:toDate.value==null?null:_date(toDate.value),
        status:statusController.text.trim().isEmpty?null:statusController.text.trim(),
        search:searchQuery.value.trim().isEmpty?null:searchQuery.value.trim(),
      );
      if(!result.isSuccess)errorMessage.value=result.errorMessage??'تعذر حفظ ملف PDF.';
    }catch(error){
      errorMessage.value=AppException.sanitizeMessage(error,fallback:'تعذر إنشاء ملخص PDF.');
    }finally{isExportingPdf.value=false;}
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