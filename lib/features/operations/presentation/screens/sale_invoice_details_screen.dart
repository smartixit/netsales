import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/invoice_details_action_dock.dart';
import 'package:netsales/features/operations/presentation/widgets/invoice_financial_summary_card.dart';
import 'package:netsales/features/operations/presentation/widgets/invoice_hero_bond_card.dart';
import 'package:netsales/features/operations/presentation/widgets/invoice_items_card.dart';
import 'package:netsales/features/operations/presentation/widgets/invoice_parties_card.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_details_skeleton_view.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/sheets/invoice_print_format_sheet.dart';

/// ============================================================================
/// شاشة تفاصيل فاتورة المبيعات والسند الرقمي السيادي (SaleInvoiceDetailsScreen)
/// ============================================================================
/// تعرض فاتورة مبيعات كروت الشبكة بنمط السند المالي الرقمي عالي الدقة:
/// مجمّع تركيبي رشيق خالٍ تماماً من دوال البناء الفرعية، مزود برصيف إجراءات عائم دائم.
class SaleInvoiceDetailsScreen extends StatefulWidget {
  final int? invoiceId;

  const SaleInvoiceDetailsScreen({super.key, this.invoiceId});

  @override
  State<SaleInvoiceDetailsScreen> createState() =>
      _SaleInvoiceDetailsScreenState();
}

class _SaleInvoiceDetailsScreenState extends State<SaleInvoiceDetailsScreen> {
  late final OperationsController _controller;
  int? _id;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OperationsController>();
    _id =
        widget.invoiceId ??
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
      showBackButton: true,
      appBarTitle: 'تفاصيل فاتورة المبيعات',
      centerTitle: true,
      useSurfaceMesh: true,
      extendBodyBehindAppBar: true,
      actions: [
        CustomButton.icon(
          icon: Icons.share_outlined,
          tooltip: 'خيارات الطباعة والمشاركة',
          onPressed: () {
            final invoice = _controller.selectedInvoice.value;
            if (invoice != null) {
              InvoicePrintFormatSheet.show(context, invoice: invoice);
            }
          },
          dimension: 40.r,
          iconSize: 18.r,
          backgroundColor: Colors.transparent,
        ),
        AppSpacing.hXs,
      ],
      bottomNavigationBar: Obx(() {
        final invoice = _controller.selectedInvoice.value;
        if (invoice == null || _controller.isLoadingInvoiceDetails.value) {
          return const SizedBox.shrink();
        }
        return InvoiceDetailsActionDock(invoice: invoice);
      }),
      body: Obx(() {
        if (_controller.isLoadingInvoiceDetails.value) {
          return const OperationsDetailsSkeletonView();
        }

        if (_controller.invoiceDetailsError.value.isNotEmpty) {
          return CustomErrorState(
            title: 'تعذر تحميل بيانات الفاتورة',
            subtitle: _controller.invoiceDetailsError.value,
            onRetry: _id == null
                ? null
                : () => _controller.loadInvoiceDetails(_id!),
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
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.appBarHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. بطاقة السند المالي الرقمي الهيرو
                    InvoiceHeroBondCard(invoice: invoice),

                    AppSpacing.vMd,

                    // 2. بطاقة أطراف المعاملة المالية السيادية
                    InvoicePartiesCard(invoice: invoice),

                    AppSpacing.vMd,

                    // 3. بطاقة بنود كروت الإنترنت المُباعة مع المحاذاة الدقيقة
                    InvoiceItemsCard(invoice: invoice),

                    AppSpacing.vMd,

                    // 4. بطاقة الملخص المالي ومطابقة الحساب
                    InvoiceFinancialSummaryCard(invoice: invoice),

                    AppSpacing.vLg,
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
