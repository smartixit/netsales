import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/request_approval_actions_bar.dart';
import 'package:netsales/features/operations/presentation/widgets/request_hero_bond_card.dart';
import 'package:netsales/features/operations/presentation/widgets/request_items_card.dart';
import 'package:netsales/features/operations/presentation/widgets/request_notes_card.dart';
import 'package:netsales/features/operations/presentation/widgets/request_parties_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_loading_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// ============================================================================
/// شاشة تفاصيل طلب توريد الكروت (VoucherRequestDetailsScreen)
/// ============================================================================
/// مجمّع تركيبي رشيق يعرض تفاصيل طلب التوريد بنمط السند الرقمي المعتمد:
/// يدعم المراجعة الفورية، اعتماد وتوليد الفاتورة، أو الرفض والإلغاء وفق ميثاق النظافة البرمجية.
class VoucherRequestDetailsScreen extends StatefulWidget {
  final int? requestId;

  const VoucherRequestDetailsScreen({super.key, this.requestId});

  @override
  State<VoucherRequestDetailsScreen> createState() => _VoucherRequestDetailsScreenState();
}

class _VoucherRequestDetailsScreenState extends State<VoucherRequestDetailsScreen> {
  late final OperationsController _controller;
  int? _id;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OperationsController>();
    _id = widget.requestId ??
        (Get.arguments is int
            ? Get.arguments as int
            : int.tryParse(Get.parameters['id'] ?? ''));

    if (_id != null) {
      _controller.loadRequestDetails(_id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل طلب التوريد',
          style: AppTypography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: CustomButton.icon(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Get.back(),
          dimension: 40.r,
          iconSize: 18.r,
          backgroundColor: Colors.transparent,
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingRequestDetails.value) {
          return const CustomLoadingState(
            message: 'جاري تحميل تفاصيل طلب التوريد والسند...',
          );
        }

        if (_controller.requestDetailsError.value.isNotEmpty) {
          return CustomErrorState(
            title: 'تعذر تحميل بيانات الطلب',
            subtitle: _controller.requestDetailsError.value,
            onRetry: _id == null ? null : () => _controller.loadRequestDetails(_id!),
          );
        }

        final request = _controller.selectedRequest.value;
        if (request == null) {
          return const CustomEmptyState(
            title: 'الطلب غير متوفر',
            subtitle: 'لم يتم العثور على أي بيانات مطابقة لهذا الطلب',
          );
        }

        return RefreshIndicator(
          color: colors.primary,
          onRefresh: () async {
            if (_id != null) {
              await _controller.loadRequestDetails(_id!);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: ResponsiveContentWrapper(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. بطاقة السند الرقمي الهيرو
                    RequestHeroBondCard(request: request),

                    AppSpacing.vMd,

                    // 2. بطاقة أطراف طلب التوريد (الوكيل الطالب والشبكة المزودة)
                    RequestPartiesCard(request: request),

                    AppSpacing.vMd,

                    // 3. بطاقة بنود الباقات والكميات المطلوبة
                    RequestItemsCard(request: request),

                    if (request.requestNote != null &&
                        request.requestNote!.trim().isNotEmpty) ...[
                      AppSpacing.vMd,
                      RequestNotesCard(note: request.requestNote!.trim()),
                    ],

                    AppSpacing.vLg,

                    // 4. شريط إجراءات الاعتماد وإدارة الطلب
                    RequestApprovalActionsBar(
                      request: request,
                      controller: _controller,
                    ),

                    AppSpacing.vXl,
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
