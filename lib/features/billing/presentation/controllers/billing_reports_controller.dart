import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:document_engine/document_engine.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/billing/domain/usecases/billing_use_cases.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/features/billing/data/services/billing_report_document_service.dart';

class BillingReportsController extends GetxController {
  BillingReportsController({
    required this.useCases,
    required this.networkId,
    this.networkIdSignal,
  });
  final BillingUseCases useCases;
  final int? Function() networkId;
  final RxnInt? networkIdSignal;
  Worker? _networkWorker;
  int? _loadedNetworkId;
  final catalog=<Map<String,dynamic>>[].obs;
  ReportDefinitionRegistry _definitionRegistry=ReportDefinitionRegistry();
  final criteria=ReportCriteria().obs;
  final presentation=ReportPresentationOptions().obs;
  final selectedLocale=RxnString('ar-YE');
  final selectedPageProfile=RxnString();
  final selectedTemplateId=RxnString();
  final rows=<Map<String,dynamic>>[].obs;
  final charts=<Map<String,dynamic>>[].obs;
  final selectedType=RxnString();
  final summary=Rxn<Map<String,dynamic>>();
  final isLoading=false.obs;
  final isLoadingMore=false.obs;
  final loadMoreError=RxnString();
  final isExportingPdf=false.obs;
  final errorMessage=RxnString();
  final searchController=TextEditingController();
  final statusController=TextEditingController();
  final fromDate=Rxn<DateTime>();
  final toDate=Rxn<DateTime>();
  final searchQuery=''.obs;
  final selectedStatus=RxnString();
  Worker? _searchWorker;
  bool _suppressSearchWorker=false;
  int _revision=0;
  String? _nextCursor;
  final Set<String> _seenCursors = <String>{};

  ReportDataType _parseDataType(String? value){
    return switch(value){
      'integer' || 'number' => ReportDataType.integer,
      'decimal' => ReportDataType.decimal,
      'date' => ReportDataType.date,
      'date_time' => ReportDataType.dateTime,
      'boolean' => ReportDataType.boolean,
      _ => ReportDataType.text,
    };
  }
  ReportFilterKind _parseFilterKind(String? value){
    return switch(value){
      'integer' => ReportFilterKind.integer,
      'decimal' => ReportFilterKind.decimal,
      'date' => ReportFilterKind.date,
      'date_range' => ReportFilterKind.dateRange,
      'boolean' => ReportFilterKind.boolean,
      'single_choice' => ReportFilterKind.singleChoice,
      'multi_choice' => ReportFilterKind.multiChoice,
      _ => ReportFilterKind.text,
    };
  }
  ReportDefinition _parseDefinition(Map<String,dynamic> raw){
    final filters=_list(raw['filters']).map((item)=>ReportFilterDefinition(
      id:item['id'].toString(),
      labelKey:item['label']?.toString()??item['id'].toString(),
      kind:_parseFilterKind(item['kind']?.toString()),
      required:item['required']==true,
      choices:_list(item['choices']).map((choice)=>ReportChoiceOption(
        value:choice['value'].toString(),
        labelKey:choice['label_key']?.toString()??choice['value'].toString(),
      )),
    ));
    final columns=_list(raw['columns']).map((item)=>ReportColumnDefinition(
      id:item['id']?.toString()??item['key'].toString(),
      labelKey:item['label_key']?.toString()??item['label']?.toString()??item['id'].toString(),
      dataType:_parseDataType(item['data_type']?.toString()),
      visibleByDefault:item['visible_by_default']!=false,
      hideable:item['hideable']!=false,
      sortable:item['sortable']==true,
      groupable:item['groupable']==true,
    ));
    final metrics=_list(raw['metric_slots']).map((item)=>ReportMetricSlotDefinition(
      id:item['id'].toString(),
      labelKey:item['label_key']?.toString()??item['id'].toString(),
      dataType:_parseDataType(item['data_type']?.toString()),
    ));
    final templates=_list(raw['templates']).map((item){
      final version=item['version'] is Map<String,dynamic>?item['version'] as Map<String,dynamic>:<String,dynamic>{};
      return ReportTemplateReference(
        id:TemplateId(item['id'].toString()),
        version:TemplateVersion(
          major:(version['major'] as num?)?.toInt()??1,
          minor:(version['minor'] as num?)?.toInt()??0,
          patch:(version['patch'] as num?)?.toInt()??0,
        ),
      );
    });
    return ReportDefinition(
      id:ReportId(raw['id'].toString()),
      schemaVersion:(raw['schema_version'] as num?)?.toInt()??1,
      titleKey:raw['label']?.toString()??raw['id'].toString(),
      descriptionKey:raw['description']?.toString(),
      supportedLocaleTags:(raw['supported_locale_tags'] as List<dynamic>? ?? const ['ar-YE','en']).map((e)=>e.toString()),
      filters:filters,
      columns:columns,
      metricSlots:metrics,
      templates:templates,
      pageProfileIds:(raw['page_profile_ids'] as List<dynamic>? ?? const ['a4-portrait']).map((e)=>e.toString()),
      executionPolicy:ReportExecutionPolicy.server,
      chartsAvailable:(raw['chart_slots'] is List<dynamic>)&&(raw['chart_slots'] as List<dynamic>).isNotEmpty,
    );
  }
  ReportDefinition? get currentDefinition{
    final raw=selectedDefinition;
    if(raw==null)return null;
    return _definitionRegistry.find(
      id:ReportId(raw['id'].toString()),
      schemaVersion:(raw['schema_version'] as num?)?.toInt()??1,
    );
  }
  void _resetStudio(ReportDefinition definition){
    _suppressSearchWorker=true;
    final template=definition.templates.isEmpty?null:definition.templates.first;
    final page=definition.pageProfileIds.isEmpty?null:definition.pageProfileIds.first;
    criteria.value=ReportCriteria();
    presentation.value=ReportPresentationOptions(
      visibleColumnIds:definition.columns.map((e)=>e.id),
      template:template==null?null:ReportTemplateSelection(id:template.id,version:template.version),
      languageTag:definition.supportedLocaleTags.contains('ar-YE')?'ar-YE':definition.supportedLocaleTags.first,
      pageProfileId:page,
      includeMetrics:definition.metricSlots.isNotEmpty,
      includeCharts:false,
    );
    selectedLocale.value=presentation.value.languageTag;
    selectedPageProfile.value=page;
    selectedTemplateId.value=template?.id.value;
    searchController.clear();statusController.clear();_resetSearchQuery();selectedStatus.value=null;fromDate.value=null;toDate.value=null;
    _suppressSearchWorker=false;
  }
  void setCriteria(ReportCriteria value){
    criteria.value=value;
    final from=value.filters['from_date'];
    final to=value.filters['to_date'];
    final status=value.filters['status'];
    final search=value.filters['search'];
    fromDate.value=from is ReportDateFilterValue?from.value:null;
    toDate.value=to is ReportDateFilterValue?to.value:null;
    selectedStatus.value=status is ReportChoiceFilterValue?status.value:null;
    statusController.text=status is ReportTextFilterValue?status.value:'';
    searchController.text=search is ReportTextFilterValue?search.value:'';
    searchQuery.value=searchController.text;
  }
  void setPresentation(ReportPresentationOptions value){
    presentation.value=value;
    selectedLocale.value=value.languageTag;
    selectedPageProfile.value=value.pageProfileId;
    selectedTemplateId.value=value.template?.id.value;
  }
  List<Map<String,dynamic>> _list(dynamic value)=>value is List<dynamic>?value.whereType<Map<String,dynamic>>().map((e)=>Map<String,dynamic>.from(e)).toList():const [];
  Map<String,dynamic> _map(BillingPayload p){final d=p.data['data']??p.data;return d is Map<String,dynamic>?d:p.data;}
  String _date(DateTime? value)=>value==null?'':value.toIso8601String().substring(0,10);
  Map<String,dynamic>? get selectedDefinition => catalog.firstWhereOrNull((e)=>e['id']==selectedType.value);
  List<String> get _filterIds => currentDefinition?.filters.map((e)=>e.id).toList() ?? const ['from_date','to_date','status','search'];
  bool get hasDateFilters => _filterIds.contains('from_date') || _filterIds.contains('to_date');
  bool get hasStatusFilter => _filterIds.contains('status');
  bool get hasSearchFilter => _filterIds.contains('search');
  List<Map<String,dynamic>> get statusChoices {
    final filter=currentDefinition?.filter('status');
    return filter?.choices.map((choice)=>{'value':choice.value,'label_key':choice.labelKey}).toList() ?? const [];
  }

  Map<String,dynamic> get _filters=>{
    'per_page':25,
    if(hasDateFilters&&fromDate.value!=null)'from_date':_date(fromDate.value),
    if(hasDateFilters&&toDate.value!=null)'to_date':_date(toDate.value),
    if(hasStatusFilter&&(selectedStatus.value?.isNotEmpty??false))'status':selectedStatus.value,
    if(hasStatusFilter&&statusChoices.isEmpty&&statusController.text.trim().isNotEmpty)'status':statusController.text.trim(),
    if(hasSearchFilter&&searchQuery.value.trim().isNotEmpty)'search':searchQuery.value.trim(),
  };

  void _bindSearchWorker() {
    _searchWorker?.dispose();
    _searchWorker = debounce(
      searchQuery,
      (_) {
        if (!_suppressSearchWorker) unawaited(loadReport());
      },
      time: const Duration(milliseconds: 400),
    );
  }

  void _resetSearchQuery() {
    _searchWorker?.dispose();
    searchQuery.value = '';
    _bindSearchWorker();
  }

  @override
  void onInit() {
    super.onInit();
    _bindSearchWorker();
    final signal = networkIdSignal;
    if (signal != null) {
      _networkWorker = ever<int?>(signal, (_) => unawaited(loadCatalog()));
    }
    unawaited(loadCatalog());
  }
  @override void onClose(){
    _searchWorker?.dispose();
    _networkWorker?.dispose();
    searchController.dispose();
    statusController.dispose();
    super.onClose();
  }

  Future<void> loadCatalog() async {
    final rev = ++_revision;
    final n = networkId();
    if (n == null) {
      _loadedNetworkId = null;
      catalog.clear();
      _definitionRegistry = ReportDefinitionRegistry();
      selectedType.value = null;
      rows.clear();
      charts.clear();
      summary.value = null;
      _nextCursor = null;
      _seenCursors.clear();
      isLoading.value = false;
      errorMessage.value = 'حدد الشبكة أولاً.';
      return;
    }

    if (_loadedNetworkId != n) {
      catalog.clear();
      _definitionRegistry = ReportDefinitionRegistry();
      selectedType.value = null;
      criteria.value = ReportCriteria();
      presentation.value = ReportPresentationOptions();
      searchController.clear();
      statusController.clear();
      _resetSearchQuery();
      selectedStatus.value = null;
      fromDate.value = null;
      toDate.value = null;
      rows.clear();
      charts.clear();
      summary.value = null;
      _nextCursor = null;
      _seenCursors.clear();
      _loadedNetworkId = n;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = _map(await useCases.reportsCatalog(n));
      if (rev != _revision || n != networkId()) return;

      final nextCatalog = _list(result['reports']);
      final nextRegistry = ReportDefinitionRegistry();
      for (final schema in nextCatalog) {
        nextRegistry.register(_parseDefinition(schema));
      }
      catalog.assignAll(nextCatalog);
      _definitionRegistry = nextRegistry;
      if (catalog.isEmpty) {
        selectedType.value = null;
        rows.clear();
        summary.value = null;
        charts.clear();
        return;
      }
      final chosen=catalog.firstWhereOrNull((e)=>e['id']==selectedType.value)??catalog.first;
      selectedType.value=chosen['id']?.toString();
      final definition=currentDefinition;if(definition!=null)_resetStudio(definition);
      await loadReport(revision:rev);
    }catch(e){if(rev==_revision)errorMessage.value=AppException.sanitizeMessage(e,fallback:'تعذر تحميل كتالوج تقارير الاشتراكات.');}
    finally{if(rev==_revision)isLoading.value=false;}
  }
  Future<void> selectReport(String? type)async{
    if(type==null||type==selectedType.value)return;selectedType.value=type;final definition=currentDefinition;if(definition!=null)_resetStudio(definition);await loadReport();
  }
  Future<void> applyFilters() {
    _searchWorker?.dispose();
    _bindSearchWorker();
    return loadReport();
  }

  Future<void> setStatus(String? value) async {
    selectedStatus.value = value;
    final next = Map<String, ReportFilterValue>.from(criteria.value.filters);
    if (value == null || value.isEmpty) {
      next.remove('status');
    } else {
      next['status'] = ReportChoiceFilterValue(value);
    }
    setCriteria(ReportCriteria(filters: next));
    await applyFilters();
  }

  Future<void> setFromDate(DateTime? value) async {
    fromDate.value = value;
    await applyFilters();
  }

  Future<void> setToDate(DateTime? value) async {
    toDate.value = value;
    await applyFilters();
  }
  Future<void> clearFilters()async{
    criteria.value=ReportCriteria();searchController.clear();statusController.clear();_resetSearchQuery();selectedStatus.value=null;fromDate.value=null;toDate.value=null;await loadReport();
  }

  Future<void> loadReport({int? revision}) async {
    final network = networkId();
    final type = selectedType.value;
    if (network == null || type == null) return;

    final currentRevision = revision ?? ++_revision;
    isLoading.value = true;
    isLoadingMore.value = false;
    errorMessage.value = null;
    loadMoreError.value = null;
    _nextCursor = null;
    _seenCursors.clear();
    rows.clear();
    charts.clear();
    summary.value = null;

    try {
      final query = _filters;
      final values = await Future.wait([
        useCases.billingReport(network, type, query),
        useCases.billingReportSummary(network, type, query),
      ]);
      if (currentRevision != _revision ||
          network != networkId() ||
          type != selectedType.value) {
        return;
      }

      final data = _map(values[0]);
      rows.assignAll(_list(data['data'] ?? data['items']));
      _nextCursor = _cursorFrom(
        data['next_page_url'] ??
            (data['links'] is Map<String, dynamic>
                ? data['links']['next']
                : null),
      );

      final summaryEnvelope = _map(values[1]);
      final rawSummary = summaryEnvelope['summary'];
      summary.value = rawSummary is Map<String, dynamic>
          ? rawSummary
          : summaryEnvelope;
      charts.assignAll(_list(summaryEnvelope['charts']));
    } catch (error) {
      if (currentRevision == _revision) {
        errorMessage.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر تحميل تقرير الاشتراكات.',
        );
      }
    } finally {
      if (currentRevision == _revision) isLoading.value = false;
    }
  }
  bool get hasMore => _nextCursor != null && _nextCursor!.isNotEmpty;

  String? _cursorFrom(dynamic url){
    if(url is! String||url.isEmpty)return null;
    try{return Uri.parse(url).queryParameters['cursor'];}catch(_){return null;}
  }

  Future<void> loadMore() async {
    final network = networkId();
    final type = selectedType.value;
    final cursor = _nextCursor;
    if (network == null ||
        type == null ||
        cursor == null ||
        cursor.isEmpty ||
        isLoading.value ||
        isLoadingMore.value) {
      return;
    }

    if (!_seenCursors.add(cursor)) {
      loadMoreError.value =
          'توقف تحميل التقرير لأن الخادم أعاد مؤشر صفحة سبق استخدامه.';
      return;
    }

    final revision = _revision;
    loadMoreError.value = null;
    isLoadingMore.value = true;
    try {
      final query = <String, dynamic>{..._filters, 'cursor': cursor};
      final page = _map(await useCases.billingReport(network, type, query));
      if (revision != _revision ||
          network != networkId() ||
          type != selectedType.value) {
        return;
      }

      final nextCursor = _cursorFrom(
        page['next_page_url'] ??
            (page['links'] is Map<String, dynamic>
                ? page['links']['next']
                : null),
      );
      if (nextCursor != null &&
          (nextCursor == cursor || _seenCursors.contains(nextCursor))) {
        throw StateError('The billing report API returned a repeated cursor.');
      }

      rows.addAll(_list(page['data'] ?? page['items']));
      _nextCursor = nextCursor;
      loadMoreError.value = null;
    } catch (error) {
      if (revision == _revision &&
          network == networkId() &&
          type == selectedType.value) {
        _seenCursors.remove(cursor);
        loadMoreError.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر تحميل بقية سجلات التقرير.',
        );
      }
    } finally {
      if (revision == _revision) isLoadingMore.value = false;
    }
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

  String _englishReportLabel(String type)=>const {
    'subscriptions':'Subscriptions','trials':'Trial usage','trial_conversion':'Trial conversion funnel',
    'renewals':'Renewals','plan_performance':'Plan performance','invoices':'Invoices',
    'collections':'Collections','receivables':'Accounts receivable','usage':'Usage',
    'dunning':'Dunning','refunds':'Refunds','revenue_recognition':'Revenue recognition',
  }[type]??type.replaceAll('_',' ');

  Future<void> exportPdfSummary() async {
    final type = selectedType.value;
    final metrics = summary.value;
    final definition = catalog.firstWhereOrNull((item) => item['id'] == type);
    final network = networkId();
    final revision = _revision;
    final criteriaStateSnapshot = criteria.value;
    final filtersSnapshot = Map<String, dynamic>.from(_filters);
    final presentationSnapshot = presentation.value;
    final fromDateSnapshot = fromDate.value;
    final toDateSnapshot = toDate.value;
    final searchSnapshot = searchQuery.value.trim();
    final statusSnapshot = statusController.text.trim();

    if (type == null ||
        metrics == null ||
        definition == null ||
        network == null ||
        isExportingPdf.value) {
      return;
    }

    final label = presentationSnapshot.languageTag == 'en'
        ? _englishReportLabel(type)
        : definition['label']?.toString() ?? type;

    isExportingPdf.value = true;
    try {
      final total =
          int.tryParse(metrics['record_count']?.toString() ?? '') ?? 0;
      if (total > 1500) {
        throw StateError(
          'يتجاوز عدد السجلات 1500؛ استخدم تصدير CSV للحصول على الملف الكامل دون اقتطاع.',
        );
      }

      final allRows = <Map<String, dynamic>>[];
      final seenCursors = <String>{};
      String? cursor;

      do {
        if (_revision != revision ||
            networkId() != network ||
            selectedType.value != type ||
            !identical(criteria.value, criteriaStateSnapshot) ||
            !identical(presentation.value, presentationSnapshot)) {
          throw StateError(
            'تغيرت معايير التقرير أثناء تجهيز PDF؛ أُوقف التصدير لمنع إنشاء مستند ببيانات مختلطة.',
          );
        }

        if (cursor != null && !seenCursors.add(cursor)) {
          throw StateError(
            'توقف إنشاء PDF لأن الخادم أعاد مؤشر صفحة سبق استخدامه.',
          );
        }

        final query = <String, dynamic>{
          ...filtersSnapshot,
          'per_page': 100,
          if (cursor != null) 'cursor': cursor,
        };
        final page = _map(
          await useCases.billingReport(network, type, query),
        );
        if (_revision != revision ||
            networkId() != network ||
            selectedType.value != type) {
          throw StateError(
            'تغير نطاق التقرير أثناء تجهيز PDF؛ أُوقف التصدير.',
          );
        }

        allRows.addAll(_list(page['data'] ?? page['items']));
        if (allRows.length > 1500) {
          throw StateError(
            'يتجاوز عدد السجلات الحد الآمن لملف PDF.',
          );
        }

        final nextCursor = _cursorFrom(
          page['next_page_url'] ??
              (page['links'] is Map<String, dynamic>
                  ? page['links']['next']
                  : null),
        );
        if (nextCursor != null &&
            (nextCursor == cursor || seenCursors.contains(nextCursor))) {
          throw StateError(
            'توقف إنشاء PDF لأن الخادم أعاد مؤشراً مكرراً.',
          );
        }
        cursor = nextCursor;
      } while (cursor != null);

      if (searchSnapshot.isEmpty &&
          total > 0 &&
          allRows.length < total) {
        throw StateError(
          'لم تكتمل قراءة جميع صفحات التقرير؛ أُوقف إنشاء PDF الجزئي.',
        );
      }

      final rawColumns = definition['columns'];
      final allColumns = rawColumns is List<dynamic>
          ? rawColumns.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[];
      final visibleIds = presentationSnapshot.visibleColumnIds.toSet();
      final columns = allColumns
          .where(
            (column) => visibleIds.contains(
              column['id']?.toString() ?? column['key']?.toString(),
            ),
          )
          .toList(growable: false);

      if (columns.isEmpty) {
        throw StateError(
          'تعريف أعمدة التقرير غير متاح لإنشاء PDF.',
        );
      }

      final result = await BillingReportDocumentService.instance.exportSummary(
        reportType: type,
        reportLabel: label,
        summary: metrics,
        includeMetrics: presentationSnapshot.includeMetrics,
        rows: allRows,
        columns: columns,
        localeTag: presentationSnapshot.languageTag ?? 'ar-YE',
        fromDate: fromDateSnapshot == null ? null : _date(fromDateSnapshot),
        toDate: toDateSnapshot == null ? null : _date(toDateSnapshot),
        status: statusSnapshot.isEmpty ? null : statusSnapshot,
        search: searchSnapshot.isEmpty ? null : searchSnapshot,
      );
      if (!result.isSuccess) {
        errorMessage.value =
            result.errorMessage ?? 'تعذر حفظ ملف PDF.';
      }
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر إنشاء ملخص PDF.',
      );
    } finally {
      isExportingPdf.value = false;
    }
  }

}