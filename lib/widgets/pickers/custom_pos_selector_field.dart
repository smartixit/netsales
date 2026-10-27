import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/partners/domain/entities/pos_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// حقل اختيار نقطة البيع المؤسسي الموحد (CustomPosSelectorField)
/// ============================================================================
/// يمنع تماماً كتابة أو إدخال أرقام المعرفات (POS ID) يدوياً من قِبل المستخدم.
/// يتيح البحث الذكي بالاسم ورقم الهاتف والمديرية مع بطاقة عرض تفاعلية غنية.
class CustomPosSelectorField extends StatelessWidget {
  final String label;
  final PosEntity? selectedPos;
  final List<PosEntity> posList;
  final ValueChanged<PosEntity?> onPosChanged;
  final bool isLoading;
  final bool readOnly;
  final String? Function(PosEntity?)? validator;
  final String? errorText;

  const CustomPosSelectorField({
    super.key,
    this.label = 'نقطة البيع / الوكيل',
    required this.selectedPos,
    required this.posList,
    required this.onPosChanged,
    this.isLoading = false,
    this.readOnly = false,
    this.validator,
    this.errorText,
  });

  Future<void> _openPicker(BuildContext context) async {
    if (readOnly) return;

    final picked = await CustomPosPickerModal.show(
      context,
      posList: posList,
      selectedPosId: selectedPos?.posId,
    );

    if (picked != null) {
      onPosChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: hasError ? colors.error : colors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 14.r,
                height: 14.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              ),
          ],
        ),
        AppSpacing.vXs,
        CustomInteractiveBounce(
          onTap: readOnly ? () {} : () => _openPicker(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: hasError
                    ? colors.error
                    : selectedPos != null
                    ? colors.primary.withValues(alpha: 0.5)
                    : colors.outlineVariant,
                width: selectedPos != null || hasError ? 1.5.w : 1.w,
              ),
            ),
            child: selectedPos != null
                ? _SelectedPosCard(
                    pos: selectedPos!,
                    readOnly: readOnly,
                    onChangeTap: () => _openPicker(context),
                  )
                : _PlaceholderPickerPrompt(readOnly: readOnly),
          ),
        ),
        if (hasError) ...[
          AppSpacing.vXxs,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              errorText!,
              style: AppTypography.labelSmall.copyWith(color: colors.error),
            ),
          ),
        ],
      ],
    );
  }
}

/// ودجت عرض بطاقة نقطة البيع المحددة
class _SelectedPosCard extends StatelessWidget {
  final PosEntity pos;
  final bool readOnly;
  final VoidCallback onChangeTap;

  const _SelectedPosCard({
    required this.pos,
    required this.readOnly,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final location = [
      if (pos.governorateName != null && pos.governorateName!.isNotEmpty)
        pos.governorateName,
      if (pos.directorateName != null && pos.directorateName!.isNotEmpty)
        pos.directorateName,
    ].join(' - ');

    final phoneInfo = [
      if (pos.agentName != null && pos.agentName!.isNotEmpty) pos.agentName,
      if (pos.posPhoneNumber != null && pos.posPhoneNumber!.isNotEmpty)
        pos.posPhoneNumber,
    ].join(' • ');

    return Row(
      children: [
        Container(
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.storefront_rounded,
            color: colors.primary,
            size: 22.r,
          ),
        ),
        AppSpacing.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pos.posName,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (phoneInfo.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  phoneInfo,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (location.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 11.r,
                      color: colors.outline,
                    ),
                    AppSpacing.hXxs,
                    Expanded(
                      child: Text(
                        location,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.outline,
                          fontSize: 10.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (!readOnly)
          CustomButton.text(
            text: 'تغيير',
            icon: Icons.sync_alt_rounded,
            onPressed: onChangeTap,
          ),
      ],
    );
  }
}

/// ودجت التوجيه لاختيار نقطة بيع
class _PlaceholderPickerPrompt extends StatelessWidget {
  final bool readOnly;

  const _PlaceholderPickerPrompt({required this.readOnly});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.storefront_outlined,
            color: colors.outline,
            size: 20.r,
          ),
        ),
        AppSpacing.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                readOnly
                    ? 'لم يتم تحديد وكيل'
                    : 'اضغط للبحث واختيار نقطة البيع أو الوكيل...',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'البحث بالاسم التجاري، رقم الهاتف، أو المحافظة',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.outline.withValues(alpha: 0.7),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14.r,
          color: colors.outline,
        ),
      ],
    );
  }
}

/// ============================================================================
/// نافذة البحث واختيار نقطة البيع السفلية (CustomPosPickerModal)
/// ============================================================================
class CustomPosPickerModal extends StatefulWidget {
  final List<PosEntity> posList;
  final int? selectedPosId;

  const CustomPosPickerModal({
    super.key,
    required this.posList,
    this.selectedPosId,
  });

  static Future<PosEntity?> show(
    BuildContext context, {
    required List<PosEntity> posList,
    int? selectedPosId,
  }) {
    final colors = context.colors;

    return CustomBottomSheet.show<PosEntity>(
      title: 'اختيار نقطة البيع / الوكيل',
      subtitle: 'ابحث بالاسم أو رقم الهاتف أو الموقع الجغرافي للاختيار الفوري',
      leadingIcon: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.storefront_rounded,
          color: colors.primary,
          size: 20.r,
        ),
      ),
      scrollable: true,
      child: CustomPosPickerModal(
        posList: posList,
        selectedPosId: selectedPosId,
      ),
    );
  }

  @override
  State<CustomPosPickerModal> createState() => _CustomPosPickerModalState();
}

class _CustomPosPickerModalState extends State<CustomPosPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PosEntity> get _filteredList {
    if (_searchQuery.isEmpty) return widget.posList;
    return widget.posList.where((pos) {
      final name = pos.posName.toLowerCase();
      final agent = (pos.agentName ?? '').toLowerCase();
      final phone = (pos.posPhoneNumber ?? '').toLowerCase();
      final gov = (pos.governorateName ?? '').toLowerCase();
      final dir = (pos.directorateName ?? '').toLowerCase();

      return name.contains(_searchQuery) ||
          agent.contains(_searchQuery) ||
          phone.contains(_searchQuery) ||
          gov.contains(_searchQuery) ||
          dir.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filtered = _filteredList;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _searchController,
          label: 'بحث فوري في قائمة الوكلاء',
          hint: 'ابحث باسم المحل، الوكيل، الهاتف، أو المدينة...',
          prefixIcon: const Icon(Icons.search_rounded),
        ),
        AppSpacing.vMd,
        if (filtered.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Column(
                children: [
                  Icon(
                    Icons.store_mall_directory_outlined,
                    size: 48.r,
                    color: colors.outline,
                  ),
                  AppSpacing.vSm,
                  Text(
                    'لا توجد نقاط بيع مطابقة للبحث',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Text(
                    'تأكد من صحة الاسم أو رقم الهاتف',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.outline,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 360.h),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => AppSpacing.vXs,
              itemBuilder: (context, index) {
                final pos = filtered[index];
                final isSelected = pos.posId == widget.selectedPosId;

                return _PosModalItemTile(
                  pos: pos,
                  isSelected: isSelected,
                  onTap: () => Navigator.of(context).pop(pos),
                );
              },
            ),
          ),
        AppSpacing.vMd,
      ],
    );
  }
}

/// ودجت السطر الفردي لنقطة البيع داخل النافذة السفلية
class _PosModalItemTile extends StatelessWidget {
  final PosEntity pos;
  final bool isSelected;
  final VoidCallback onTap;

  const _PosModalItemTile({
    required this.pos,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final phone = pos.posPhoneNumber ?? '';
    final agent = pos.agentName ?? '';
    final location = [
      pos.governorateName,
      pos.directorateName,
    ].where((s) => s != null && s.isNotEmpty).join(' - ');

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryContainer.withValues(alpha: 0.25)
              : colors.surfaceContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outlineVariant,
            width: isSelected ? 1.5.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary
                    : colors.primaryContainer.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: isSelected ? colors.onPrimary : colors.primary,
                size: 18.r,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pos.posName,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  if (agent.isNotEmpty || phone.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      [agent, phone].where((s) => s.isNotEmpty).join(' • '),
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (location.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      location,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.outline,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colors.primary,
                size: 20.r,
              )
            else
              Icon(
                Icons.chevron_left_rounded,
                color: colors.outline,
                size: 18.r,
              ),
          ],
        ),
      ),
    );
  }
}
