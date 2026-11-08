import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_operating_expenses_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_file_picker.dart';

class NetworkOperatingExpensesScreen extends GetView<NetworkOperatingExpensesController> {
  const NetworkOperatingExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomAppScaffold(
    appBarTitle: 'المصروفات التشغيلية',
    appBarSubtitle: 'سجل النفقات وبنود الصرف',
    actions: [
      if (controller.canCreate)
        Padding(
          padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
          child: CustomButton.primary(
            text: 'مصروف جديد',
            prefix: Icons.add_rounded,
            onPressed: () => Get.to<void>(() => const NetworkExpenseFormScreen()),
          ),
        ),
    ],
    body: Padding(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        children: [
          _NetworkScope(controller: controller),
          AppSpacing.vMd,
          CustomTextField(
            controller: controller.searchTextController,
            label: 'بحث في المصروفات',
            hint: 'ابحث بوصف البند أو رقم المصروف',
            prefixIcon: const Icon(Icons.search_rounded),
            isRequired: false,
            onChanged: controller.onSearchChanged,
            onFieldSubmitted: (v) => controller.applyFilters(search: v),
          ),
          AppSpacing.vMd,
          Expanded(child: Obx(() {
            if (controller.isLoadingNetworks.value) return const CustomSkeletonFeed(itemCount: 3);
            if (controller.networkError.value != null && controller.networks.isEmpty) {
              return CustomErrorState.compact(
                title: 'تعذر تحميل الشبكات',
                subtitle: controller.networkError.value,
                onRetry: controller.initializeNetworks,
              );
            }
            if (controller.networks.isEmpty) {
              return const CustomEmptyState.compact(
                title: 'لا توجد شبكة متاحة',
                subtitle: 'لا توجد شبكة مصرح بها لهذا الحساب.',
              );
            }
            if (!controller.hasSelectedNetwork) {
              return const CustomEmptyState.compact(
                title: 'اختر الشبكة',
                subtitle: 'حدد شبكة لعرض مصروفاتها. لا يتم اختيار شبكة تلقائياً عند تعدد الشبكات.',
                icon: Icons.account_tree_outlined,
              );
            }
            if (controller.isLoading.value && controller.expenses.isEmpty) {
              return const CustomSkeletonFeed(itemCount: 5);
            }
            if (controller.error.value != null && controller.expenses.isEmpty) {
              return CustomErrorState.compact(
                title: 'تعذر تحميل المصروفات',
                subtitle: controller.error.value,
                onRetry: () => controller.loadExpenses(refresh: true),
              );
            }
            if (controller.expenses.isEmpty) {
              return CustomEmptyState(
                title: 'لا توجد مصروفات مسجلة',
                subtitle: 'ستظهر هنا سندات الصرف الخاصة بالشبكة المحددة.',
                icon: Icons.receipt_long_outlined,
                actionLabel: controller.canCreate ? 'تسجيل أول مصروف' : null,
                onAction: controller.canCreate
                    ? () => Get.to<void>(() => const NetworkExpenseFormScreen())
                    : null,
              );
            }
            return RefreshIndicator(
              onRefresh: () => controller.loadExpenses(refresh: true),
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.pixels >= n.metrics.maxScrollExtent - 180 &&
                      controller.hasMore &&
                      !controller.isLoadingMore.value &&
                      controller.loadMoreError.value == null) {
                    controller.loadExpenses();
                  }
                  return false;
                },
                child: ListView.separated(
                  itemCount: controller.expenses.length +
                      ((controller.hasMore || controller.loadMoreError.value != null) ? 1 : 0),
                  separatorBuilder: (_, _) => AppSpacing.vSm,
                  itemBuilder: (context, index) {
                    if (index == controller.expenses.length) {
                      if (controller.loadMoreError.value != null) {
                        return CustomErrorState.compact(
                          title: 'تعذر تحميل بقية السجلات',
                          subtitle: controller.loadMoreError.value,
                          onRetry: () {
                            controller.loadMoreError.value = null;
                            controller.loadExpenses();
                          },
                        );
                      }
                      return const CustomSkeletonFeed(itemCount: 1);
                    }
                    final expense = controller.expenses[index];
                    return _ExpenseCard(
                      expense: expense,
                      onTap: () => Get.to<void>(
                        () => NetworkExpenseDetailsScreen(expenseId: expense.expenseId),
                      ),
                    );
                  },
                ),
              ),
            );
          })),
        ],
      ),
    ),
  );
}

class _NetworkScope extends StatelessWidget {
  const _NetworkScope({required this.controller});
  final NetworkOperatingExpensesController controller;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      final selected = controller.networks.where((n) => n.networkId == controller.selectedNetworkId.value);
      final current = selected.isEmpty ? null : selected.first;
      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: .55)),
        ),
        child: Row(children: [
          Icon(Icons.account_tree_outlined, color: colors.primary),
          AppSpacing.hSm,
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('نطاق المصروفات', style: AppTypography.labelMedium.copyWith(color: colors.onSurfaceVariant)),
            Text(current?.networkName ?? 'حدد الشبكة', style: AppTypography.titleSmall.copyWith(color: colors.onSurface)),
          ])),
          if (controller.networks.length > 1)
            PopupMenuButton<int>(
              tooltip: 'تغيير الشبكة',
              onSelected: controller.selectNetwork,
              itemBuilder: (_) => controller.networks.map((n) => PopupMenuItem<int>(
                value: n.networkId,
                child: Text(n.networkName),
              )).toList(),
              child: Icon(Icons.unfold_more_rounded, color: colors.onSurfaceVariant),
            ),
        ]),
      );
    });
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expense, required this.onTap});
  final ExpenseEntity expense;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomButton.outline(
      width: double.infinity,
      onPressed: onTap,
      padding: EdgeInsets.all(AppSpacing.md),
      borderColor: colors.outlineVariant.withValues(alpha: .55),
      foregroundColor: colors.onSurface,
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Icon(Icons.receipt_long_rounded, color: colors.onPrimaryContainer),
        ),
        AppSpacing.hMd,
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('مصروف #${expense.expenseId}', style: AppTypography.titleSmall.copyWith(color: colors.onSurface)),
          AppSpacing.vXxs,
          Text(expense.expenseDate ?? 'بدون تاريخ', style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant)),
          Text('${expense.items.length} بند • ${expense.attachments.length} مرفق', style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(expense.totalAmount.toStringAsFixed(2), style: AppTypography.titleMedium.copyWith(color: colors.primary, fontWeight: FontWeight.bold)),
          Text('إجمالي الخادم', style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
        ]),
        AppSpacing.hXs,
        Icon(Icons.chevron_left_rounded, color: colors.onSurfaceVariant),
      ]),
    );
  }
}

class NetworkExpenseFormScreen extends GetView<NetworkOperatingExpensesController> {
  const NetworkExpenseFormScreen({super.key, this.expense});
  final ExpenseEntity? expense;

  @override
  Widget build(BuildContext context) => _ExpenseFormBody(expense: expense);
}

class _ExpenseFormBody extends StatefulWidget {
  const _ExpenseFormBody({this.expense});
  final ExpenseEntity? expense;
  @override
  State<_ExpenseFormBody> createState() => _ExpenseFormBodyState();
}

class _ExpenseFormBodyState extends State<_ExpenseFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _date;
  late final List<_ExpenseItemFields> _items;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Get.find<NetworkOperatingExpensesController>().formAttachments.clear();
    _selectedDate = DateTime.tryParse(widget.expense?.expenseDate ?? '') ?? DateTime.now();
    _date = TextEditingController(text: _selectedDate.toIso8601String().substring(0, 10));
    _items = widget.expense == null
      ? [_ExpenseItemFields()]
      : widget.expense!.items.map((i) => _ExpenseItemFields(statement: i.statement, amount: i.amount.toString())).toList();
  }

  @override
  void dispose() {
    _date.dispose();
    for (final item in _items) { item.statement.dispose(); item.amount.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NetworkOperatingExpensesController>();
    final colors = context.colors;
    return CustomAppScaffold(
      showBackButton: true,
      appBarTitle: widget.expense == null ? 'تسجيل مصروف' : 'تعديل المصروف',
      appBarSubtitle: 'أدخل بنود الصرف والمستندات المؤيدة',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, color: colors.onPrimaryContainer),
                AppSpacing.hSm,
                Expanded(child: Text('سيتم احتساب الإجمالي وخصم المحفظة من الخادم بعد اعتماد الطلب.', style: AppTypography.bodySmall.copyWith(color: colors.onPrimaryContainer))),
              ]),
            ),
            AppSpacing.vLg,
            CustomTextField(
              controller: _date,
              label: 'تاريخ المصروف',
              readOnly: true,
              prefixIcon: const Icon(Icons.calendar_month_outlined),
              onChanged: (_) {},
              suffixIcon: CustomButton.icon(
                icon: Icons.edit_calendar_outlined,
                onPressed: () async {
                  final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (date != null) setState(() { _selectedDate = date; _date.text = date.toIso8601String().substring(0,10); });
                },
              ),
            ),
            AppSpacing.vLg,
            Row(children: [
              Expanded(child: Text('بنود المصروف', style: AppTypography.titleMedium.copyWith(color: colors.onSurface))),
              CustomButton.outline(text: 'إضافة بند', icon: Icons.add_rounded, onPressed: () => setState(() => _items.add(_ExpenseItemFields()))),
            ]),
            AppSpacing.vSm,
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return Container(
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: colors.outlineVariant.withValues(alpha: .5))),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: Text('البند ${index + 1}', style: AppTypography.titleSmall.copyWith(color: colors.onSurface))),
                    if (_items.length > 1) CustomButton.icon(icon: Icons.delete_outline_rounded, foregroundColor: colors.error, onPressed: () => setState(() { _items.removeAt(index); item.dispose(); })),
                  ]),
                  AppSpacing.vSm,
                  CustomTextField(controller: item.statement, label: 'وصف المصروف', hint: 'مثال: إيجار مقر الشبكة', validator: (v) => v == null || v.trim().isEmpty ? 'أدخل وصف البند' : null),
                  AppSpacing.vSm,
                  CustomTextField(controller: item.amount, label: 'المبلغ', keyboardType: const TextInputType.numberWithOptions(decimal: true), prefixIcon: const Icon(Icons.payments_outlined), validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'أدخل مبلغاً أكبر من صفر' : null),
                ]),
              );
            }),
            AppSpacing.vMd,
            CustomFilePicker(
              label: 'المرفقات والفواتير',
              hint: 'PDF أو صور أو مستندات داعمة — حتى 5 ملفات',
              maxFiles: 5,
              maxFileSizeBytes: 10 * 1024 * 1024,
              allowedExtensions: const ['pdf','jpg','jpeg','png','webp'],
              onFilesChanged: (files) => c.formAttachments.assignAll(files),
            ),
            AppSpacing.vXl,
            Obx(() => CustomButton.primary(
              text: widget.expense == null ? 'حفظ المصروف' : 'حفظ التعديلات',
              width: double.infinity,
              size: AppButtonSize.large,
              loading: c.isSaving.value,
              onPressed: c.isSaving.value ? null : () async {
                if (!_formKey.currentState!.validate()) return;
                final payload = _items.map((i) => {
                  'item_statement': i.statement.text.trim(),
                  'item_amount': i.amount.text.trim(),
                }).toList();
                final success = await c.saveExpense(expenseId: widget.expense?.expenseId, date: _selectedDate, items: payload);
                if (success && context.mounted) Get.back<void>();
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _ExpenseItemFields {
  _ExpenseItemFields({String? statement, String? amount})
    : statement = TextEditingController(text: statement),
      amount = TextEditingController(text: amount);
  final TextEditingController statement;
  final TextEditingController amount;
  void dispose() { statement.dispose(); amount.dispose(); }
}

class NetworkExpenseDetailsScreen extends StatefulWidget {
  const NetworkExpenseDetailsScreen({super.key, required this.expenseId});
  final int expenseId;

  @override
  State<NetworkExpenseDetailsScreen> createState() => _NetworkExpenseDetailsScreenState();
}

class _NetworkExpenseDetailsScreenState extends State<NetworkExpenseDetailsScreen> {
  late final NetworkOperatingExpensesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NetworkOperatingExpensesController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.loadDetails(widget.expenseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseId = widget.expenseId;
    return CustomAppScaffold(
      showBackButton: true,
      appBarTitle: 'تفاصيل المصروف #$expenseId',
      body: Obx(() {
        if (controller.isLoadingDetails.value) return const CustomSkeletonFeed(itemCount: 4);
        final expense = controller.selectedExpense.value;
        if (expense == null) {
          return CustomErrorState.compact(
            title: 'تعذر عرض المصروف',
            subtitle: 'لم يتم تحميل تفاصيل هذا السجل.',
            onRetry: () => controller.loadDetails(expenseId),
          );
        }
        final colors = context.colors;
        return ListView(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [colors.primary, colors.primary.withValues(alpha: .78)]),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('إجمالي المصروف', style: AppTypography.labelLarge.copyWith(color: colors.onPrimary.withValues(alpha: .85))),
                AppSpacing.vXs,
                Text(expense.totalAmount.toStringAsFixed(2), style: AppTypography.headlineMedium.copyWith(color: colors.onPrimary, fontWeight: FontWeight.bold)),
                AppSpacing.vXs,
                Text(expense.expenseDate ?? '—', style: AppTypography.bodySmall.copyWith(color: colors.onPrimary)),
              ]),
            ),
            AppSpacing.vLg,
            Text('تفاصيل البنود', style: AppTypography.titleMedium.copyWith(color: colors.onSurface)),
            AppSpacing.vSm,
            ...expense.items.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.receipt_outlined, color: colors.primary),
              title: Text(item.statement),
              trailing: Text(item.amount.toStringAsFixed(2), style: AppTypography.titleSmall.copyWith(color: colors.onSurface)),
            )),
            AppSpacing.vLg,
            Text('المرفقات', style: AppTypography.titleMedium.copyWith(color: colors.onSurface)),
            AppSpacing.vSm,
            if (expense.attachments.isEmpty)
              const CustomEmptyState.compact(title: 'لا توجد مرفقات', icon: Icons.attach_file_rounded)
            else
              ...expense.attachments.map((attachment) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(attachment.mimeType?.startsWith('image/') == true ? Icons.image_outlined : Icons.picture_as_pdf_outlined, color: colors.primary),
                title: Text(attachment.name),
                subtitle: Text(attachment.sizeBytes > 0 ? '${(attachment.sizeBytes / 1024).toStringAsFixed(0)} KB' : 'مستند مرفق'),
                trailing: attachment.fileUrl == null ? null : CustomButton.icon(icon: Icons.open_in_new_rounded, onPressed: () => UrlLauncherService.openInExternalBrowser(attachment.fileUrl!)),
              )),
            if (controller.canEdit)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.lg),
                child: CustomButton.primary(
                  width: double.infinity,
                  text: 'تعديل المصروف',
                  prefix: Icons.edit_outlined,
                  onPressed: () => Get.to<void>(() => NetworkExpenseFormScreen(expense: expense)),
                ),
              ),
          ],
        );
      }),
    );
  }
}
