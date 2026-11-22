import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/usecases/approve_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/delete_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/reject_request_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_action_dialogs.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم تفاصيل طلب التوريد وعرض البنود والتسلسل الزمني وإجراءات القرار
class ProcurementRequestDetailsController extends GetxController {
  final GetRequestDetailsUseCase getRequestDetailsUseCase;
  final CancelRequestUseCase? cancelRequestUseCase;
  final ApproveRequestUseCase? approveRequestUseCase;
  final RejectRequestUseCase? rejectRequestUseCase;
  final DeleteRequestUseCase? deleteRequestUseCase;

  ProcurementRequestDetailsController({
    required this.getRequestDetailsUseCase,
    this.cancelRequestUseCase,
    this.approveRequestUseCase,
    this.rejectRequestUseCase,
    this.deleteRequestUseCase,
  });

  final request = Rxn<RequestEntity>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  /// فهرس البند المفتوح حالياً بنظام الأكورديون الحصري (فتح بند يغلق البنود الأخرى تلقائياً)
  final expandedItemIndex = Rxn<int>();

  void toggleItemExpansion(int index) {
    if (expandedItemIndex.value == index) {
      expandedItemIndex.value = null;
    } else {
      expandedItemIndex.value = index;
    }
  }

  bool isItemExpanded(int index) => expandedItemIndex.value == index;

  bool get isNetworkWorkspace =>
      Get.isRegistered<WorkspaceService>() &&
      WorkspaceService.to.activeWorkspace == AppWorkspace.network;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RequestEntity) {
      request.value = args;
      loadRequestDetails(args.requestId);
    } else if (args is int) {
      loadRequestDetails(args);
    }
  }

  Future<void> loadRequestDetails(int requestId) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final details = await getRequestDetailsUseCase(requestId);
      request.value = details;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      CustomSnackbar.show(
        title: 'خطأ في جلب التفاصيل',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      errorMessage.value = 'تعذر تحميل بيانات الطلب: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// فتح الفاتورة المنشأة من الطلب في منظور مساحة العمل الحالية.
  Future<void> openLinkedInvoice() async {
    final invoiceId = request.value?.invoiceId;
    if (invoiceId == null || invoiceId <= 0) return;

    final route = isNetworkWorkspace
        ? AppRoutes.saleInvoiceDetails
        : AppRoutes.purchaseInvoiceDetails;

    await Get.toNamed<void>(route, arguments: invoiceId);
  }

  /// فتح معالج التعديل للطلب قيد الانتظار
  Future<void> openEditOrder() async {
    final current = request.value;
    if (current == null) return;
    if (Get.isRegistered<PosNewProcurementOrderController>()) {
      await Get.delete<PosNewProcurementOrderController>();
    }
    await Get.toNamed<void>(AppRoutes.newProcurementOrder, arguments: current);
    await loadRequestDetails(current.requestId);
  }

  /// إلغاء الطلب من قبل نقطة البيع
  Future<void> cancelRequest() async {
    final current = request.value;
    if (current == null) return;

    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري إلغاء طلب التوريد...',
      );
      final cancelUseCase =
          cancelRequestUseCase ??
          (Get.isRegistered<CancelRequestUseCase>()
              ? Get.find<CancelRequestUseCase>()
              : null);
      if (cancelUseCase == null) return;

      final cancelled = await cancelUseCase(current.requestId);
      request.value = cancelled;

      Get.back<void>();
      await CustomAnimationOverlay.showSuccess(
        message: 'تم إلغاء طلب الكروت بنجاح',
      );
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر إلغاء الطلب',
        message: error.message,
        type: SnackType.error,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إلغاء الطلب: $error',
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// اعتماد الطلب وتوليد الفاتورة من قبل إدارة الشبكة
  Future<void> approveRequest({String? note}) async {
    final current = request.value;
    if (current == null) return;

    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري اعتماد الطلب وإصدار الفاتورة...',
      );
      final approveUseCase =
          approveRequestUseCase ??
          (Get.isRegistered<ApproveRequestUseCase>()
              ? Get.find<ApproveRequestUseCase>()
              : null);
      if (approveUseCase == null) return;

      final result = await approveUseCase(
        current.requestId,
        requestNote: note,
        paidAmount: paidAmount,
      );
      request.value = result.request;

      Get.back<void>();
      await CustomAnimationOverlay.showSuccess(
        message: 'تم اعتماد الطلب وتوليد الفاتورة بنجاح',
      );
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر اعتماد الطلب',
        message: error.message,
        type: SnackType.error,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر اعتماد الطلب: $error',
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// رفض الطلب مع توثيق السبب
  Future<void> rejectRequest(String reason) async {
    final current = request.value;
    if (current == null) return;

    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري رفض طلب التوريد وتوثيق السبب...',
      );
      final rejectUseCase =
          rejectRequestUseCase ??
          (Get.isRegistered<RejectRequestUseCase>()
              ? Get.find<RejectRequestUseCase>()
              : null);
      if (rejectUseCase == null) return;

      final rejected = await rejectUseCase(current.requestId, reason);
      request.value = rejected;

      Get.back<void>();
      await CustomAnimationOverlay.showSuccess(
        message: 'تم رفض طلب التوريد وتوثيق السبب',
      );
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر رفض الطلب',
        message: error.message,
        type: SnackType.error,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إتمام عملية الرفض: $error',
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  Future<void> promptCancelRequest() async {
    final current = request.value;
    if (current == null) return;
    await ProcurementActionDialogs.showCancelDialog(
      requestUuid: current.requestUuid ?? '-',
      onConfirm: () => cancelRequest(),
    );
  }

  Future<void> promptApproveRequest() async {
    final current = request.value;
    if (current == null) return;
    const isCredit = false;
    await ProcurementActionDialogs.showApprovalDialog(
      requestUuid: current.requestUuid ?? '-',
      isCredit: isCredit,
      maxAmount: current.requestTotalAmount,
      onConfirm: (note, _) => approveRequest(note: note),
    );
  }

  Future<void> promptRejectRequest() async {
    final current = request.value;
    if (current == null) return;
    await ProcurementActionDialogs.showRejectionDialog(
      requestUuid: current.requestUuid ?? '-',
      onConfirm: (reason) => rejectRequest(reason),
    );
  }
}
