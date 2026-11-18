import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/usecases/approve_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/delete_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/reject_request_use_case.dart';
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
    await Get.toNamed<void>(AppRoutes.newProcurementOrder, arguments: current);
    await loadRequestDetails(current.requestId);
  }

  /// إلغاء الطلب من قبل نقطة البيع
  Future<bool> cancelRequest() async {
    final current = request.value;
    if (current == null) return false;

    final cancelUseCase =
        cancelRequestUseCase ??
        (Get.isRegistered<CancelRequestUseCase>()
            ? Get.find<CancelRequestUseCase>()
            : null);
    if (cancelUseCase == null) return false;

    await CustomAnimationOverlay.showLoading(
      message: 'جاري إلغاء طلب التوريد...',
    );

    try {
      final cancelled = await cancelUseCase(current.requestId);
      request.value = cancelled;

      await CustomAnimationOverlay.showSuccess(
        message: 'تم إلغاء طلب الكروت بنجاح',
      );
      CustomSnackbar.show(
        title: 'تم الإلغاء',
        message: 'تم إلغاء الطلب بنجاح.',
        type: SnackType.success,
      );
      return true;
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر إلغاء الطلب',
        message: error.message,
        type: SnackType.error,
      );
      return false;
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إلغاء الطلب: $error',
        type: SnackType.error,
      );
      return false;
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// اعتماد الطلب وتوليد الفاتورة من قبل إدارة الشبكة
  Future<bool> approveRequest({String? note}) async {
    final current = request.value;
    if (current == null) return false;

    final approveUseCase =
        approveRequestUseCase ??
        (Get.isRegistered<ApproveRequestUseCase>()
            ? Get.find<ApproveRequestUseCase>()
            : null);
    if (approveUseCase == null) return false;

    await CustomAnimationOverlay.showLoading(
      message: 'جاري اعتماد الطلب وإصدار الفاتورة...',
    );

    try {
      final result = await approveUseCase(current.requestId, requestNote: note);
      request.value = result.request;

      await CustomAnimationOverlay.showSuccess(
        message: 'تم اعتماد الطلب وتوليد الفاتورة بنجاح',
      );
      CustomSnackbar.show(
        title: 'تم الاعتماد',
        message: 'تم اعتماد الطلب وتوليد الفاتورة بنجاح.',
        type: SnackType.success,
      );
      return true;
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر اعتماد الطلب',
        message: error.message,
        type: SnackType.error,
      );
      return false;
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر اعتماد الطلب: $error',
        type: SnackType.error,
      );
      return false;
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// رفض الطلب مع توثيق السبب
  Future<bool> rejectRequest(String reason) async {
    final current = request.value;
    if (current == null) return false;

    final rejectUseCase =
        rejectRequestUseCase ??
        (Get.isRegistered<RejectRequestUseCase>()
            ? Get.find<RejectRequestUseCase>()
            : null);
    if (rejectUseCase == null) return false;

    await CustomAnimationOverlay.showLoading(
      message: 'جاري رفض طلب التوريد وتوثيق السبب...',
    );

    try {
      final rejected = await rejectUseCase(current.requestId, reason);
      request.value = rejected;

      await CustomAnimationOverlay.showSuccess(
        message: 'تم رفض طلب التوريد وتوثيق السبب',
      );
      CustomSnackbar.show(
        title: 'تم الرفض',
        message: 'تم توثيق رفض الطلب بنجاح.',
        type: SnackType.success,
      );
      return true;
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر رفض الطلب',
        message: error.message,
        type: SnackType.error,
      );
      return false;
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إتمام عملية الرفض: $error',
        type: SnackType.error,
      );
      return false;
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
      requestId: current.requestId,
      onConfirm: () => cancelRequest(),
    );
  }

  Future<void> promptApproveRequest() async {
    final current = request.value;
    if (current == null) return;
    await ProcurementActionDialogs.showApprovalDialog(
      requestId: current.requestId,
      onConfirm: (note) => approveRequest(note: note),
    );
  }

  Future<void> promptRejectRequest() async {
    final current = request.value;
    if (current == null) return;
    await ProcurementActionDialogs.showRejectionDialog(
      requestId: current.requestId,
      onConfirm: (reason) => rejectRequest(reason),
    );
  }
}
