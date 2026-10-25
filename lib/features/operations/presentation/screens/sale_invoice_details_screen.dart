import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/invoice_financial_summary_card.dart';
import 'package:netsales/features/operations/presentation/widgets/invoice_hero_bond_card.dart';
import 'package:netsales/features/operations/presentation/widgets/invoice_items_card.dart';
import 'package:netsales/features/operations/presentation/widgets/invoice_parties_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_loading_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// شاشة تفاصيل فاتورة المبيعات والسند الرقمي (SaleInvoiceDetailsScreen)
/// ============================================================================
/// تعرض فاتورة مبيعات كروت الشبكة بنمط السند المالي الرقمي عالي الدقة:
/// مجمّع تركيبي رشيق خالٍ تماماً من دوال البناء الفرعية، ويدعم التجاوب والتحديث اللحظي.
class SaleInvoiceDetailsScreen extends StatefulWidget {
  final int? invoiceId;

  const SaleInvoiceDetailsScreen({super.key, this.invoiceId});

  @override
  State<SaleInvoiceDetailsScreen> createState() => _SaleInvoiceDetailsScreenState();
}

class _SaleInvoiceDetailsScreenState extends State<SaleInvoiceDetailsScreen> {
  late final OperationsController _controller;
  int? _id;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OperationsController>();
    _id = widget.invoiceId ??
        (Get.arguments is int
            ? Get.arguments as int
            : int.tryParse(Get.parameters['id'] ?? ''));

    if (_id != null) {
      _controller.loadInvoiceDetails(_id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل فاتورة المبيعات',
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
        actions: [
          CustomButton.icon(
            icon: Icons.share_outlined,
            onPressed: () {
              CustomSnackbar.show(
                title: 'مشاركة الفاتورة',
                message: 'سيتم تصدير سند الفاتورة الرقمي قريباً',
                type: SnackType.info,
              );
            },
            dimension: 40.r,
            iconSize: 18.r,
            backgroundColor: Colors.transparent,
          ),
          AppSpacing.hXs,
        ],
      ),
      body: Obx(() {
        if (_controller.isLoadingInvoiceDetails.value) {
          return const CustomLoadingState(
            message: 'جاري تحميل تفاصيل الفاتورة والسند المالي...',
          );
        }

        if (_controller.invoiceDetailsError.value.isNotEmpty) {
          return CustomErrorState(
            title: 'تعذر تحميل بيانات الفاتورة',
            subtitle: _controller.invoiceDetailsError.value,
            onRetry: _id == null ? null : () => _controller.loadInvoiceDetails(_id!),
          );
        }

        final invoice = _controller.selectedInvoice.value;
        if (invoice == null) {
          return const CustomEmptyState(
            title: 'الفاتورة غير متوفرة',
            subtitle: 'لم يتم العثور على أي بيانات مطابقة لهذه الفاتورة',
          );
        }

        return RefreshIndicator(
          color: colors.primary,
          onRefresh: () async {
            if (_id != null) {
              await _controller.loadInvoiceDetails(_id!);
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
                    // 1. بطاقة السند المالي الرقمي الهيرو
                    InvoiceHeroBondCard(invoice: invoice),

                    AppSpacing.vMd,

                    // 2. بطاقة أطراف المعاملة المالية (الشبكة والوكيل)
                    InvoicePartiesCard(invoice: invoice),

                    AppSpacing.vMd,

                    // 3. بطاقة بنود كروت الإنترنت المباعة
                    InvoiceItemsCard(invoice: invoice),

                    AppSpacing.vMd,

                    // 4. بطاقة الملخص المالي ومطابقة الحساب
                    InvoiceFinancialSummaryCard(invoice: invoice),

                    AppSpacing.vLg,

                    // 5. شريط الإجراءات والطباعة
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton.outline(
                            text: 'طباعة الإيصال',
                            icon: Icons.print_outlined,
                            onPressed: () {
                              CustomSnackbar.show(
                                title: 'طباعة الإيصال',
                                message: 'جاري تجهيز أمر الطباعة اللاسلكية...',
                                type: SnackType.info,
                              );
                            },
                          ),
                        ),
                        AppSpacing.hSm,
                        Expanded(
                          child: CustomButton.primary(
                            text: 'مشاركة السند',
                            icon: Icons.share_rounded,
                            onPressed: () {
                              CustomSnackbar.show(
                                title: 'مشاركة السند',
                                message: 'تم إعداد السند للمشاركة بصيغة PDF',
                                type: SnackType.success,
                              );
                            },
                          ),
                        ),
                      ],
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
