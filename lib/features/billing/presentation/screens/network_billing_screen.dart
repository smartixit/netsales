import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/controllers/network_billing_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class NetworkBillingScreen extends GetView<NetworkBillingController> {
  const NetworkBillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('اشتراكات الشبكة والفوترة')),
      body: Obx(() {
        if (controller.isLoading.value && controller.accounts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null &&
            controller.accounts.isEmpty) {
          return _MessageState(
            message: controller.errorMessage.value!,
            action: CustomButton.primary(
              text: 'إعادة المحاولة',
              onPressed: controller.load,
              prefix: const Icon(Icons.refresh_rounded),
            ),
          );
        }
        if (controller.accounts.isEmpty) {
          return _MessageState(
            message: 'لا يوجد حساب فوترة لهذه الشبكة حتى الآن.',
            action: CustomButton.primary(
              text: 'تحديث البيانات',
              onPressed: controller.load,
              prefix: const Icon(Icons.refresh_rounded),
            ),
          );
        }
        final account = controller.selectedAccount;
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('حساب الفوترة', style: AppTypography.titleMedium),
                    SizedBox(height: 8.h),
                    Text(account?.legalName ?? 'حساب الشبكة',
                        style: AppTypography.headlineSmall),
                    Text('رقم الحساب: ${account?.accountNumber ?? '—'}'),
                    Text('الحالة: ${account?.status ?? '—'}'),
                    if (controller.accounts.length > 1)
                      CustomDropdown<int>(
                        label: 'حساب الفوترة',
                        rxValue: controller.selectedAccountId,
                        items: controller.accounts
                            .map((a) => DropdownItem<int>(
                                  value: a.billingAccountId,
                                  child: Text(a.accountNumber),
                                ))
                            .toList(),
                        itemSearchText: (id) => controller.accounts
                            .firstWhere((a) => a.billingAccountId == id)
                            .accountNumber,
                        onChanged: controller.selectAccount,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              _SectionHeader(title: 'اشتراكاتي'),
              _CountRow(label: 'الاشتراكات', count: controller.subscriptions.length),
              _CountRow(label: 'الفواتير', count: controller.invoices.length),
              _CountRow(label: 'المدفوعات', count: controller.payments.length),
              _CountRow(label: 'الإشعارات الدائنة', count: controller.creditNotes.length),
              _CountRow(label: 'عمليات الاسترداد', count: controller.refunds.length),
              SizedBox(height: 16.h),
              _SectionHeader(title: 'آخر الفواتير'),
              ...controller.invoices.take(8).map((invoice) => Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_rounded),
                  title: Text(invoice.invoiceNumber),
                  subtitle: Text('${invoice.statusLabel} • ${invoice.issuedOn ?? ''}'),
                  trailing: Text('${invoice.total} ${invoice.currency?.code ?? ''}'),
                ),
              )),
              _SectionHeader(title: 'آخر المدفوعات'),
              ...controller.payments.take(8).map((payment) => Card(
                child: ListTile(
                  leading: const Icon(Icons.payments_rounded),
                  title: Text(payment.reference),
                  subtitle: Text(payment.status),
                  trailing: Text('${payment.amount} ${payment.currency?.code ?? ''}'),
                ),
              )),
              if (controller.errorMessage.value != null)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Text(controller.errorMessage.value!,
                      style: TextStyle(color: colors.error)),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.action});
  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 48),
          SizedBox(height: 12.h),
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          action,
        ],
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(top: 16.h, bottom: 8.h),
    child: Text(title, style: AppTypography.titleMedium),
  );
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.label, required this.count});
  final String label;
  final int count;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 5.h),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text('$count', style: AppTypography.titleSmall),
      ],
    ),
  );
}
