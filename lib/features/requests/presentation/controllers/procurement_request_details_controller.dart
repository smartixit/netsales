import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
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
}
