import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم تفاصيل طلب التوريد وعرض البنود والتسلسل الزمني
class ProcurementRequestDetailsController extends GetxController {
  final GetRequestDetailsUseCase getRequestDetailsUseCase;

  ProcurementRequestDetailsController({required this.getRequestDetailsUseCase});

  final request = Rxn<RequestEntity>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

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

    final route = WorkspaceService.to.activeWorkspace == AppWorkspace.pos
        ? AppRoutes.purchaseInvoiceDetails
        : AppRoutes.saleInvoiceDetails;

    await Get.toNamed<void>(route, arguments: invoiceId);
  }
}
