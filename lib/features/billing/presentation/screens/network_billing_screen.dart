import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/domain/entities/billing_entities.dart';
import 'package:netsales/features/billing/presentation/controllers/network_billing_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

class NetworkBillingScreen extends GetView<NetworkBillingController> {
  const NetworkBillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('اشتراك الشبكة والفوترة')),
      body: Obx(() {
        if (controller.isLoading.value && controller.accounts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null &&
            controller.accounts.isEmpty &&
            controller.currencies.isEmpty) {
          return _EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'تعذر تحميل بيانات الفوترة',
            message: controller.errorMessage.value!,
            action: CustomButton.primary(
              text: 'إعادة المحاولة',
              prefix: const Icon(Icons.refresh_rounded),
              onPressed: controller.load,
            ),
          );
        }
        if (controller.accounts.isEmpty) {
          return _CreateBillingAccountState(controller: controller);
        }

        final account = controller.selectedAccount;
        final recentPurchaseInvoice = controller.lastPurchase.value?.invoice;
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              _AccountHeader(
                account: account,
                accounts: controller.accounts,
                selectedAccountId: controller.selectedAccountId,
                onAccountChanged: controller.selectAccount,
              ),
              SizedBox(height: 16.h),
              if (recentPurchaseInvoice != null)
                _PurchaseNotice(invoice: recentPurchaseInvoice),
              _SectionNavigation(controller: controller),
              SizedBox(height: 16.h),
              switch (controller.selectedSection.value) {
                BillingSection.overview => _OverviewSection(controller: controller),
                BillingSection.subscriptions => _SubscriptionsSection(controller: controller),
                BillingSection.plans => _PlansSection(controller: controller),
                BillingSection.invoices => _InvoicesSection(controller: controller),
                BillingSection.payments => _PaymentsSection(controller: controller),
                BillingSection.credits => _CreditNotesSection(controller: controller),
                BillingSection.refunds => _RefundsSection(controller: controller),
              },
              if (controller.errorMessage.value != null)
                Padding(
                  padding: EdgeInsets.only(top: 14.h),
                  child: Text(
                    controller.errorMessage.value!,
                    style: TextStyle(color: colors.error),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _CreateBillingAccountState extends StatelessWidget {
  const _CreateBillingAccountState({required this.controller});
  final NetworkBillingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Obx(() {
              final currencies = controller.currencies;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 48.r,
                    color: colors.primary,
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'افتح حساب فوترة لشبكتك',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSmall,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'يُنشأ حساب مستقل لكل عملة تختارها. تبقى الفواتير والمدفوعات والسجلات مرتبطة بعملة حسابها ولا تُدمج مع عملات أخرى.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  if (currencies.isNotEmpty)
                    CustomDropdown<int>(
                      label: 'عملة حساب الفوترة',
                      hint: 'اختر العملة',
                      rxValue: controller.selectedCurrencyId,
                      items: currencies
                          .map((currency) => DropdownItem<int>(
                                value: currency.currencyId,
                                child: Text(
                                  '${currency.code} — ${currency.name}',
                                ),
                              ))
                          .toList(),
                      itemSearchText: (id) {
                        final item = currencies.firstWhere(
                          (currency) => currency.currencyId == id,
                        );
                        return '${item.code} ${item.name}';
                      },
                      onChanged: (value) =>
                          controller.selectedCurrencyId.value = value,
                    )
                  else
                    const Text('لا توجد عملات نشطة متاحة لفتح حساب فوترة.'),
                  SizedBox(height: 18.h),
                  CustomButton.primary(
                    text: 'إنشاء حساب الفوترة',
                    loading: controller.isCreatingAccount.value,
                    enabled: controller.selectedCurrencyId.value != null &&
                        !controller.isCreatingAccount.value,
                    prefix: const Icon(Icons.add_card_rounded),
                    onPressed: () {
                      final currencyId = controller.selectedCurrencyId.value;
                      if (currencyId != null) {
                        controller.createBillingAccount(currencyId);
                      }
                    },
                  ),
                  if (controller.errorMessage.value != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      controller.errorMessage.value!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.error),
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.account,
    required this.accounts,
    required this.selectedAccountId,
    required this.onAccountChanged,
  });

  final BillingAccountEntity? account;
  final List<BillingAccountEntity> accounts;
  final RxnInt selectedAccountId;
  final ValueChanged<int?> onAccountChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [colors.primary.withValues(alpha: .12), colors.surface],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: colors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('حساب فوترة الشبكة', style: AppTypography.titleMedium),
                    Text(
                      account?.legalName ?? 'حساب الشبكة',
                      style: AppTypography.headlineSmall,
                    ),
                  ],
                ),
              ),
              _StatusPill(status: account?.status ?? 'UNKNOWN'),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 18.w,
            runSpacing: 8.h,
            children: [
              _Metadata(label: 'رقم الحساب', value: account?.accountNumber ?? '—'),
              _Metadata(
                label: 'العملة الافتراضية',
                value: account?.currency?.code ?? '—',
              ),
              _Metadata(
                label: 'البريد المالي',
                value: account?.billingEmail ?? 'غير محدد',
              ),
            ],
          ),
          if (accounts.length > 1) ...[
            SizedBox(height: 16.h),
            CustomDropdown<int>(
              label: 'التبديل بين حسابات العملات',
              rxValue: selectedAccountId,
              items: accounts
                  .map((item) => DropdownItem<int>(
                        value: item.billingAccountId,
                        child: Text(
                          '${item.accountNumber} · ${item.currency?.code ?? ''}',
                        ),
                      ))
                  .toList(),
              itemSearchText: (id) {
                final item = accounts.firstWhere(
                  (entry) => entry.billingAccountId == id,
                );
                return '${item.accountNumber} ${item.currency?.code ?? ''}';
              },
              onChanged: onAccountChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionNavigation extends StatelessWidget {
  const _SectionNavigation({required this.controller});
  final NetworkBillingController controller;

  static const labels = <BillingSection, String>{
    BillingSection.overview: 'الملخص',
    BillingSection.subscriptions: 'اشتراكاتي',
    BillingSection.plans: 'الخطط والأسعار',
    BillingSection.invoices: 'الفواتير',
    BillingSection.payments: 'المدفوعات',
    BillingSection.credits: 'الإشعارات الدائنة',
    BillingSection.refunds: 'الاستردادات',
  };

  @override
  Widget build(BuildContext context) => Obx(
        () => Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: BillingSection.values.map((section) {
            final selected = controller.selectedSection.value == section;
            return CustomButton(
              text: labels[section],
              size: AppButtonSize.small,
              variant: selected
                  ? AppButtonVariant.primary
                  : AppButtonVariant.outline,
              onPressed: () => controller.selectSection(section),
            );
          }).toList(),
        ),
      );
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.controller});
  final NetworkBillingController controller;

  @override
  Widget build(BuildContext context) {
    final statement = controller.statement.value;
    final active = controller.subscriptions.where(
      (item) => item.status == 'ACTIVE' || item.status == 'TRIALING',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'الوضع الحالي للاشتراك',
          subtitle: 'الحالة والفترة المستمدة من سجل الاشتراك في الخادم',
        ),
        if (active.isEmpty)
          const _InfoPanel(
            icon: Icons.info_outline_rounded,
            message: 'لا يوجد اشتراك نشط أو فترة تجريبية ظاهرة لهذا الحساب حالياً.',
          )
        else
          ...active.map((item) => _SubscriptionCard(item: item)),
        SizedBox(height: 16.h),
        _SectionTitle(
          title: 'كشف حساب الاشتراك',
          subtitle: statement == null
              ? 'لا تتوفر بيانات كشف الحساب حالياً.'
              : '${statement.from} — ${statement.to} · ${statement.timezone}',
        ),
        if (statement == null || statement.balances.isEmpty)
          const _InfoPanel(
            icon: Icons.account_balance_rounded,
            message: 'لا توجد حركة مالية مسجلة في نطاق العملات والفترة الحالية.',
          )
        else
          ...statement.balances.map((balance) => _StatementCard(balance: balance)),
        SizedBox(height: 16.h),
        _SectionTitle(title: 'آخر الفواتير', subtitle: 'أحدث الفواتير المرتبطة بهذا الحساب'),
        if (controller.invoices.isEmpty)
          const _InfoPanel(
            icon: Icons.receipt_long_outlined,
            message: 'لا توجد فواتير اشتراك حتى الآن.',
          )
        else
          ...controller.invoices.take(3).map((invoice) => _InvoiceCard(
            invoice: invoice,
            onPay: invoice.remainingMinor > 0 ? () => _showPaymentSheet(invoice) : null,
          )),
        SizedBox(height: 10.h),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: CustomButton.outline(
            text: 'عرض كل الفواتير',
            size: AppButtonSize.small,
            onPressed: () => controller.selectSection(BillingSection.invoices),
          ),
        ),
      ],
    );
  }
}

class _SubscriptionsSection extends StatelessWidget {
  const _SubscriptionsSection({required this.controller});
  final NetworkBillingController controller;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'سجل الاشتراكات',
            subtitle: 'الخطط والفترات والحالة الحالية وسجل الاشتراكات السابقة',
          ),
          if (controller.subscriptions.isEmpty)
            const _InfoPanel(
              icon: Icons.workspace_premium_outlined,
              message: 'لا توجد اشتراكات مسجلة لهذا الحساب.',
            )
          else
            ...controller.subscriptions.map((item) => _SubscriptionCard(item: item)),
          if (controller.canLoadMoreSubscriptions)
            _LoadMoreButton(
              loading: controller.isLoadingMoreSubscriptions.value,
              onPressed: controller.loadMoreSubscriptions,
            ),
        ],
      );
}

class _PlansSection extends StatelessWidget {
  const _PlansSection({required this.controller});
  final NetworkBillingController controller;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'الخطط والأسعار المتاحة',
            subtitle: 'الأسعار المنشورة والمتاحة لعملة حساب الفوترة الحالي',
          ),
          if (controller.plans.isEmpty)
            const _InfoPanel(
              icon: Icons.inventory_2_outlined,
              message: 'لا توجد خطط منشورة ومتاحة لهذه العملة حالياً.',
            )
          else
            ...controller.plans.map((plan) => _PlanCard(
                  plan: plan,
                  isPurchasing: controller.isPurchasing.value,
                  onPurchase: _confirmPurchase,
                )),
        ],
      );

  void _confirmPurchase(BillingPriceEntity price, BillingPlanEntity plan) {
    Get.dialog<void>(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(22.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('تأكيد طلب الاشتراك', style: AppTypography.titleLarge),
              SizedBox(height: 12.h),
              Text('الخطة: ${plan.name}'),
              Text(
                'السعر: ${price.unitAmount} ${price.currency?.code ?? ''} / ${price.billingIntervalLabel}',
              ),
              if (price.setupFeeMinor > 0)
                Text(
                  'رسوم الإعداد: ${price.setupFee} ${price.currency?.code ?? ''}',
                ),
              SizedBox(height: 12.h),
              const Text(
                'سيصدر النظام فاتورة اشتراك. لا يتم تفعيل الاشتراك بمجرد إنشاء الطلب؛ يخضع التفعيل لاعتماد السداد وفق سياسة المنصة.',
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton.outline(
                      text: 'رجوع',
                      onPressed: Get.back,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CustomButton.primary(
                      text: 'تأكيد الطلب',
                      loading: controller.isPurchasing.value,
                      onPressed: () async {
                        Get.back<void>();
                        await controller.buyPlan(price.priceId);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoicesSection extends StatelessWidget {
  const _InvoicesSection({required this.controller});
  final NetworkBillingController controller;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'فواتير الاشتراك',
            subtitle: 'المبالغ المستحقة والمدفوعة والرصيد المتبقي كما أصدرها الخادم',
          ),
          if (controller.invoices.isEmpty)
            const _InfoPanel(
              icon: Icons.receipt_long_outlined,
              message: 'لا توجد فواتير.',
            )
          else
            ...controller.invoices.map((invoice) => _InvoiceCard(
              invoice: invoice,
              onPay: invoice.remainingMinor > 0 ? () => _showPaymentSheet(invoice) : null,
            )),
          if (controller.canLoadMoreInvoices)
            _LoadMoreButton(
              loading: controller.isLoadingMoreInvoices.value,
              onPressed: controller.loadMoreInvoices,
            ),
        ],
      );
}

class _PaymentsSection extends StatelessWidget {
  const _PaymentsSection({required this.controller});
  final NetworkBillingController controller;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'المدفوعات',
            subtitle: 'طلبات السداد وإيصالات العمليات التي سجلتها المنصة',
          ),
          if (controller.payments.isEmpty)
            const _InfoPanel(
              icon: Icons.payments_outlined,
              message: 'لا توجد مدفوعات مسجلة.',
            )
          else
            ...controller.payments.map((item) => _PaymentCard(item: item)),
          if (controller.canLoadMorePayments)
            _LoadMoreButton(
              loading: controller.isLoadingMorePayments.value,
              onPressed: controller.loadMorePayments,
            ),
        ],
      );
}

class _CreditNotesSection extends StatelessWidget {
  const _CreditNotesSection({required this.controller});
  final NetworkBillingController controller;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'الإشعارات الدائنة',
            subtitle: 'القيمة المطبقة على الذمم والمبلغ القابل للاسترداد',
          ),
          if (controller.creditNotes.isEmpty)
            const _InfoPanel(
              icon: Icons.note_alt_outlined,
              message: 'لا توجد إشعارات دائنة.',
            )
          else
            ...controller.creditNotes.map((item) => _CreditNoteCard(item: item)),
          if (controller.canLoadMoreCreditNotes)
            _LoadMoreButton(
              loading: controller.isLoadingMoreCreditNotes.value,
              onPressed: controller.loadMoreCreditNotes,
            ),
        ],
      );
}

class _RefundsSection extends StatelessWidget {
  const _RefundsSection({required this.controller});
  final NetworkBillingController controller;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'عمليات الاسترداد',
            subtitle: 'الاستردادات المنفذة والمرتبطة بمدفوعات وإشعارات دائنة',
          ),
          if (controller.refunds.isEmpty)
            const _InfoPanel(
              icon: Icons.currency_exchange_rounded,
              message: 'لا توجد عمليات استرداد.',
            )
          else
            ...controller.refunds.map((item) => _RefundCard(item: item)),
          if (controller.canLoadMoreRefunds)
            _LoadMoreButton(
              loading: controller.isLoadingMoreRefunds.value,
              onPressed: controller.loadMoreRefunds,
            ),
        ],
      );
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.item});
  final BillingSubscriptionEntity item;
  @override
  Widget build(BuildContext context) => _SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.planName, style: AppTypography.titleMedium),
                ),
                _StatusPill(status: item.status, label: item.statusLabel),
              ],
            ),
            SizedBox(height: 9.h),
            _Metadata(
              label: 'الفترة الحالية',
              value: '${item.currentPeriodStart ?? item.trialStart ?? '—'} إلى ${item.currentPeriodEnd ?? item.trialEnd ?? '—'}',
            ),
            if (item.trialEnd != null)
              _Metadata(label: 'انتهاء التجربة', value: item.trialEnd!),
            if (item.gracePeriodEndsAt != null)
              _Metadata(label: 'نهاية فترة السماح', value: item.gracePeriodEndsAt!),
            if (item.cancelAtPeriodEnd)
              const _InlineNotice(text: 'تم تسجيل طلب الإلغاء عند نهاية الفترة الحالية.'),
          ],
        ),
      );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isPurchasing,
    required this.onPurchase,
  });
  final BillingPlanEntity plan;
  final bool isPurchasing;
  final void Function(BillingPriceEntity price, BillingPlanEntity plan) onPurchase;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: AppTypography.titleLarge),
            if (plan.description.isNotEmpty) ...[
              SizedBox(height: 5.h),
              Text(plan.description, style: AppTypography.bodyMedium),
            ],
            if (plan.trialDurationValue != null && plan.trialDurationValue! > 0)
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Text(
                  'مدة التجربة حسب السياسة المنشورة: ${plan.trialDurationValue} ${plan.trialDurationUnit ?? ''}',
                  style: AppTypography.bodySmall,
                ),
              ),
            SizedBox(height: 12.h),
            if (plan.prices.isEmpty)
              const _InlineNotice(text: 'لا يوجد سعر نشط متاح ضمن إصدار الخطة الحالي.')
            else
              ...plan.prices.where((price) => price.isActive).map((price) {
                final currency = price.currency?.code ?? '';
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${price.unitAmount} $currency / ${price.billingIntervalLabel}',
                                style: AppTypography.titleMedium,
                              ),
                              if (price.setupFeeMinor > 0)
                                Text('رسوم الإعداد: ${price.setupFee} $currency'),
                              Text(
                                'الكمية الدورية: ${price.intervalCount}',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        CustomButton.primary(
                          text: 'اشترك',
                          size: AppButtonSize.small,
                          loading: isPurchasing,
                          enabled: !isPurchasing,
                          onPressed: () => onPurchase(price, plan),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      );
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, this.onPay});
  final BillingInvoiceEntity invoice;
  final VoidCallback? onPay;
  @override
  Widget build(BuildContext context) => _SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(invoice.invoiceNumber, style: AppTypography.titleMedium)),
                _StatusPill(status: invoice.status, label: invoice.statusLabel),
              ],
            ),
            SizedBox(height: 8.h),
            _Metadata(label: 'تاريخ الإصدار', value: invoice.issuedOn ?? '—'),
            _Metadata(label: 'تاريخ الاستحقاق', value: invoice.dueOn ?? '—'),
            SizedBox(height: 8.h),
            _MoneyLine(label: 'إجمالي الفاتورة', value: invoice.total, currency: invoice.currency?.code),
            _MoneyLine(label: 'المدفوع', value: invoice.paid, currency: invoice.currency?.code),
            _MoneyLine(label: 'المتبقي', value: invoice.remaining, currency: invoice.currency?.code, emphasis: true),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton.outline(
                  text: 'تفاصيل البنود',
                  size: AppButtonSize.small,
                  onPressed: () => _showInvoiceDetails(invoice),
                ),
                if (onPay != null) ...[
                  SizedBox(width: 8.w),
                  CustomButton.primary(
                    text: 'تسجيل السداد',
                    size: AppButtonSize.small,
                    onPressed: onPay,
                  ),
                ],
              ],
            ),
          ],
        ),
      );
}

void _showPaymentSheet(BillingInvoiceEntity invoice) {
  final controller = Get.find<NetworkBillingController>();
  controller.preparePayment(invoice);
  Get.bottomSheet<void>(
    _PaymentSubmissionSheet(invoice: invoice, controller: controller),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _PaymentSubmissionSheet extends StatelessWidget {
  const _PaymentSubmissionSheet({
    required this.invoice,
    required this.controller,
  });
  final BillingInvoiceEntity invoice;
  final NetworkBillingController controller;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Obx(() {
          final selectedMethod = controller.paymentMethods.firstWhereOrNull(
            (item) => item.paymentMethodId == controller.selectedPaymentMethodId.value,
          );
          return Container(
            constraints: BoxConstraints(maxHeight: Get.height * .9),
            padding: EdgeInsets.fromLTRB(20.r, 18.r, 20.r, 24.r),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('تسجيل طلب سداد', style: AppTypography.titleLarge),
                  SizedBox(height: 6.h),
                  Text('الفاتورة ${invoice.invoiceNumber}'),
                  _MoneyLine(
                    label: 'المتبقي وفق الخادم',
                    value: invoice.remaining,
                    currency: invoice.currency?.code,
                    emphasis: true,
                  ),
                  SizedBox(height: 14.h),
                  if (controller.paymentMethods.isEmpty)
                    const _InlineNotice(
                      text: 'لا توجد وسيلة دفع نشطة متاحة بعملة هذه الفاتورة. تواصل مع إدارة المنصة.',
                    )
                  else
                    CustomDropdown<int>(
                      label: 'وسيلة الدفع',
                      rxValue: controller.selectedPaymentMethodId,
                      items: controller.paymentMethods
                          .where((method) => method.isActive)
                          .map((method) => DropdownItem<int>(
                                value: method.paymentMethodId,
                                child: Text(method.name),
                              ))
                          .toList(),
                      itemSearchText: (id) => controller.paymentMethods
                          .firstWhere((item) => item.paymentMethodId == id)
                          .name,
                      onChanged: (value) =>
                          controller.selectedPaymentMethodId.value = value,
                    ),
                  if (selectedMethod?.instructions != null &&
                      selectedMethod!.instructions!.trim().isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    _InfoPanel(
                      icon: Icons.info_outline_rounded,
                      message: selectedMethod.instructions!,
                    ),
                  ],
                  SizedBox(height: 12.h),
                  CustomTextField(
                    controller: controller.paymentAmountController,
                    label: 'المبلغ',
                    hint: 'المبلغ بعملة ${invoice.currency?.code ?? ''}',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                  SizedBox(height: 10.h),
                  CustomTextField(
                    controller: controller.paymentReferenceController,
                    label: 'المرجع الخارجي (اختياري)',
                    hint: 'رقم الحوالة أو العملية',
                    isRequired: false,
                    prefixIcon: const Icon(Icons.tag_rounded),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.selectedProofPath.value == null
                              ? 'لم يتم إرفاق إثبات دفع'
                              : controller.selectedProofPath.value!.split(RegExp(r'[/\\\\]')).last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall,
                        ),
                      ),
                      CustomButton.outline(
                        text: controller.selectedProofPath.value == null
                            ? 'إرفاق الإثبات'
                            : 'تغيير الملف',
                        size: AppButtonSize.small,
                        prefix: const Icon(Icons.attach_file_rounded),
                        onPressed: controller.choosePaymentProof,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  const _InlineNotice(
                    text: 'سيُسجّل الطلب بانتظار المراجعة. إرسال الإثبات لا يعني اعتماد الدفع أو تفعيل الاشتراك تلقائياً.',
                  ),
                  if (controller.errorMessage.value != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      controller.errorMessage.value!,
                      style: TextStyle(color: context.colors.error),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton.outline(
                          text: 'إلغاء',
                          onPressed: () => Get.back<void>(),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: CustomButton.primary(
                          text: 'إرسال طلب السداد',
                          loading: controller.isSubmittingPayment.value,
                          enabled: controller.paymentMethods.any((method) => method.isActive) &&
                              !controller.isSubmittingPayment.value,
                          onPressed: () async {
                            final payment = await controller.submitPayment(invoice);
                            if (payment != null) Get.back<void>();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      );
}

void _showInvoiceDetails(BillingInvoiceEntity invoice) {
  Get.bottomSheet<void>(
    SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.height * .82),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('تفاصيل الفاتورة ${invoice.invoiceNumber}', style: AppTypography.titleLarge),
              SizedBox(height: 12.h),
              _MoneyLine(label: 'الإجمالي', value: invoice.total, currency: invoice.currency?.code),
              _MoneyLine(label: 'المدفوع', value: invoice.paid, currency: invoice.currency?.code),
              _MoneyLine(label: 'المتبقي', value: invoice.remaining, currency: invoice.currency?.code),
              if (invoice.memo != null && invoice.memo!.isNotEmpty)
                Text(invoice.memo!, style: AppTypography.bodyMedium),
              SizedBox(height: 14.h),
              Text('بنود الفاتورة', style: AppTypography.titleMedium),
              if (invoice.lines.isEmpty)
                const _InlineNotice(text: 'لم تُرجع الواجهة بنوداً لهذه الفاتورة.')
              else
                ...invoice.lines.map((line) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(line.description, style: AppTypography.bodyMedium),
                          _MoneyLine(
                            label: 'الكمية × سعر الوحدة',
                            value: '${line.quantity} × ${_minorToDisplay(line.unitAmountMinor, line.currency?.decimalPlaces ?? invoice.currency?.decimalPlaces ?? 2)}',
                            currency: line.currency?.code ?? invoice.currency?.code,
                          ),
                          _MoneyLine(
                            label: 'الإجمالي',
                            value: _minorToDisplay(line.totalMinor, line.currency?.decimalPlaces ?? invoice.currency?.decimalPlaces ?? 2),
                            currency: line.currency?.code ?? invoice.currency?.code,
                          ),
                        ],
                      ),
                    )),
              SizedBox(height: 12.h),
              CustomButton.outline(text: 'إغلاق', onPressed: Get.back<void>),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

String _minorToDisplay(int minor, int decimalPlaces) {
  final negative = minor < 0;
  final absolute = minor.abs().toString().padLeft(decimalPlaces + 1, '0');
  if (decimalPlaces == 0) return '${negative ? '-' : ''}$absolute';
  final split = absolute.length - decimalPlaces;
  return '${negative ? '-' : ''}${absolute.substring(0, split)}.${absolute.substring(split)}';
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.item});
  final BillingPaymentEntity item;
  @override
  Widget build(BuildContext context) => _SurfaceCard(
        child: Row(
          children: [
            Icon(Icons.payments_rounded, color: context.colors.primary),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.reference, style: AppTypography.titleMedium),
                  Text(item.methodName ?? item.status, style: AppTypography.bodySmall),
                  if (item.invoiceNumber != null)
                    Text('الفاتورة: ${item.invoiceNumber}', style: AppTypography.bodySmall),
                  if (item.verifiedAt != null)
                    Text('تاريخ الاعتماد: ${item.verifiedAt}', style: AppTypography.bodySmall),
                ],
              ),
            ),
            Text(
              '${item.amount} ${item.currency?.code ?? ''}',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.end,
            ),
          ],
        ),
      );
}

class _CreditNoteCard extends StatelessWidget {
  const _CreditNoteCard({required this.item});
  final BillingCreditNoteEntity item;
  @override
  Widget build(BuildContext context) => _SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(item.number, style: AppTypography.titleMedium)),
                _StatusPill(status: item.status),
              ],
            ),
            if (item.invoiceNumber != null)
              _Metadata(label: 'الفاتورة الأصلية', value: item.invoiceNumber!),
            _MoneyLine(label: 'إجمالي الإشعار', value: item.total, currency: item.currency?.code),
            _MoneyLine(
              label: 'المطبق على الذمم',
              value: _minorToDisplay(item.appliedToReceivableMinor, item.currency?.decimalPlaces ?? 2),
              currency: item.currency?.code,
            ),
            _MoneyLine(
              label: 'القابل للاسترداد',
              value: _minorToDisplay(item.refundableMinor, item.currency?.decimalPlaces ?? 2),
              currency: item.currency?.code,
            ),
            _MoneyLine(
              label: 'المسترد فعلياً',
              value: _minorToDisplay(item.refundedMinor, item.currency?.decimalPlaces ?? 2),
              currency: item.currency?.code,
            ),
            if (item.reason != null) Text(item.reason!, style: AppTypography.bodySmall),
          ],
        ),
      );
}

class _RefundCard extends StatelessWidget {
  const _RefundCard({required this.item});
  final BillingRefundEntity item;
  @override
  Widget build(BuildContext context) => _SurfaceCard(
        child: Row(
          children: [
            Icon(Icons.currency_exchange_rounded, color: context.colors.primary),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.reference, style: AppTypography.titleMedium),
                  Text(item.status, style: AppTypography.bodySmall),
                  if (item.invoiceNumber != null)
                    Text('الفاتورة: ${item.invoiceNumber}', style: AppTypography.bodySmall),
                  if (item.processedAt != null)
                    Text('تاريخ التنفيذ: ${item.processedAt}', style: AppTypography.bodySmall),
                ],
              ),
            ),
            Text(
              '${item.amount} ${item.currency?.code ?? ''}',
              style: AppTypography.titleMedium,
            ),
          ],
        ),
      );
}

class _StatementCard extends StatelessWidget {
  const _StatementCard({required this.balance});
  final BillingStatementBalanceEntity balance;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${balance.currency.name} · ${balance.currency.code}',
              style: AppTypography.titleMedium,
            ),
            SizedBox(height: 12.h),
            _MoneyLine(
              label: 'الرصيد الافتتاحي',
              value: balance.openingReceivable,
              currency: balance.currency.code,
            ),
            _MoneyLine(
              label: 'الفواتير الصادرة',
              value: balance.invoiced,
              currency: balance.currency.code,
            ),
            _MoneyLine(
              label: 'المدفوعات المعتمدة',
              value: balance.verifiedPayments,
              currency: balance.currency.code,
            ),
            _MoneyLine(
              label: 'الإشعارات المطبقة على الذمم',
              value: balance.creditsApplied,
              currency: balance.currency.code,
            ),
            Divider(color: context.colors.outlineVariant),
            _MoneyLine(
              label: 'الرصيد الختامي',
              value: balance.closingReceivable,
              currency: balance.currency.code,
              emphasis: true,
            ),
          ],
        ),
      );
}

class _PurchaseNotice extends StatelessWidget {
  const _PurchaseNotice({required this.invoice});
  final BillingInvoiceEntity invoice;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: _SurfaceCard(
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: context.colors.primary),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'تم إنشاء طلب اشتراك وفاتورة ${invoice.invoiceNumber}. حالة الفاتورة: ${invoice.statusLabel}. يبقى الاشتراك غير مكتمل حتى اعتماد السداد.',
                  style: AppTypography.bodyMedium,
                ),
              ),
              CustomButton.outline(
                text: 'عرض',
                size: AppButtonSize.small,
                onPressed: () => Get.find<NetworkBillingController>()
                    .selectSection(BillingSection.invoices),
              ),
            ],
          ),
        ),
      );
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.loading, required this.onPressed});
  final bool loading;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: CustomButton.outline(
            text: 'تحميل المزيد',
            size: AppButtonSize.small,
            loading: loading,
            onPressed: onPressed,
          ),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsetsDirectional.only(bottom: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.titleLarge),
            if (subtitle != null) ...[
              SizedBox(height: 3.h),
              Text(
                subtitle!,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, this.label});
  final String status;
  final String? label;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final normalized = status.toUpperCase();
    final positive = ['ACTIVE', 'TRIALING', 'PAID', 'VERIFIED', 'COMPLETED'].contains(normalized);
    final negative = ['SUSPENDED', 'CANCELED', 'CANCELLED', 'REJECTED', 'FAILED', 'VOID', 'EXPIRED'].contains(normalized);
    final tone = positive
        ? colors.success
        : negative
            ? colors.error
            : colors.warning;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Text(
        label ?? status,
        style: AppTypography.labelSmall.copyWith(
          color: tone,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: child,
      );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.icon, required this.message});
  final IconData icon;
  final String message;
  @override
  Widget build(BuildContext context) => _SurfaceCard(
        child: Row(
          children: [
            Icon(icon, color: context.colors.onSurfaceVariant),
            SizedBox(width: 10.w),
            Expanded(child: Text(message, style: AppTypography.bodyMedium)),
          ],
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget action;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 54.r, color: context.colors.onSurfaceVariant),
              SizedBox(height: 12.h),
              Text(title, style: AppTypography.titleLarge),
              SizedBox(height: 6.h),
              Text(message, textAlign: TextAlign.center),
              SizedBox(height: 16.h),
              action,
            ],
          ),
        ),
      );
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsetsDirectional.only(bottom: 5.h),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              TextSpan(text: value, style: AppTypography.bodySmall),
            ],
          ),
        ),
      );
}

class _MoneyLine extends StatelessWidget {
  const _MoneyLine({
    required this.label,
    required this.value,
    this.currency,
    this.emphasis = false,
  });
  final String label;
  final String value;
  final String? currency;
  final bool emphasis;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              '$value ${currency ?? ''}',
              style: emphasis
                  ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800)
                  : AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      );
}
