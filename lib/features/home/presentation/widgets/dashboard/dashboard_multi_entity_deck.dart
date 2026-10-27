import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';

/// ============================================================================
/// منصة بطاقات الكيانات الشبكية المستقلة (DashboardMultiEntityDeck)
/// ============================================================================
/// تطبق المعيار العالمي لإدارة الكيانات المتعددة المستقلة (Multi-Entity Horizon Deck)،
/// حيث تحتفظ كل شبكة بذمتها المالية وبياناتها التشغيلية الخاصة دون خلط أو دمج مضلل،
/// مع دعم الانتقال الحركي السلس ومزامنة البيانات اللحظية والخصوصية.
class DashboardMultiEntityDeck extends StatefulWidget {
  final DashboardController controller;
  final VoidCallback? onActionTap;

  const DashboardMultiEntityDeck({
    super.key,
    required this.controller,
    this.onActionTap,
  });

  @override
  State<DashboardMultiEntityDeck> createState() => _DashboardMultiEntityDeckState();
}

class _DashboardMultiEntityDeckState extends State<DashboardMultiEntityDeck> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.controller.selectedNetworkIndex.value;
    _pageController = PageController(
      initialPage: initialIndex,
      viewportFraction: widget.controller.hasMultipleNetworks ? 0.92 : 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final networks = widget.controller.networks;
      final liquidity = widget.controller.liquidity;
      final isMasked = widget.controller.isPrivacyMasked.value;
      final hasMultiple = widget.controller.hasMultipleNetworks;

      // في حال عدم وجود شبكات في المحفظة، الاعتماد على بطاقة السيولة الافتراضية
      if (networks.isEmpty) {
        if (liquidity == null) return const SizedBox.shrink();
        return SizedBox(
          height: 224.h,
          child: _SingleEntityCard(
            title: widget.controller.contextData?.displayName ?? 'الشبكة التشغيلية',
            code: widget.controller.contextData?.displayCode ?? '',
            logoUrl: null,
            balance: liquidity.balance,
            currency: liquidity.currency,
            activePosCount: 0,
            pendingRequestsCount: 0,
            isNegative: liquidity.balance < 0 || liquidity.isOverdrawn,
            isMasked: isMasked,
            onActionTap: widget.onActionTap,
          ),
        );
      }

      // في حال وجود شبكة واحدة فقط، عرض بطاقة مهيمنة وأنيقة بدون ترقيم
      if (!hasMultiple) {
        final net = networks.first;
        final isNegative = net.walletBalance < 0;
        return SizedBox(
          height: 224.h,
          child: _SingleEntityCard(
            title: net.networkName,
            code: net.networkCode,
            logoUrl: net.networkProfileLogo,
            balance: net.walletBalance,
            currency: net.currency,
            activePosCount: net.activePosCount,
            pendingRequestsCount: net.pendingRequestsCount,
            isNegative: isNegative,
            isMasked: isMasked,
            onActionTap: widget.onActionTap,
          ),
        );
      }

      // في حال تعدد الشبكات: عرض Deck تفاعلي أفقي مستقل لكل كيان
      final currentIndex = widget.controller.selectedNetworkIndex.value;

      return Column(
        children: [
          SizedBox(
            height: 228.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: networks.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: widget.controller.onNetworkCardChanged,
              itemBuilder: (context, index) {
                final net = networks[index];
                final isNegative = net.walletBalance < 0;
                final isSelected = currentIndex == index;

                return AnimatedContainer(
                  duration: AppMotion.normal,
                  curve: AppMotion.standard,
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: isSelected ? 0 : 6.h,
                  ),
                  child: _SingleEntityCard(
                    title: net.networkName,
                    code: net.networkCode,
                    logoUrl: net.networkProfileLogo,
                    balance: net.walletBalance,
                    currency: net.currency,
                    activePosCount: net.activePosCount,
                    pendingRequestsCount: net.pendingRequestsCount,
                    isNegative: isNegative,
                    isMasked: isMasked,
                    onActionTap: widget.onActionTap,
                  ),
                );
              },
            ),
          ),

          AppSpacing.vSm,

          // مؤشر الشرائح التفاعلي الناعم (Smooth Page Indicator)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(networks.length, (index) {
              final isSelected = currentIndex == index;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: AppMotion.normal,
                    curve: AppMotion.standard,
                  );
                },
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  curve: AppMotion.standard,
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                  height: 6.h,
                  width: isSelected ? 24.w : 6.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    });
  }
}

/// بطاقة الكيان المستقل المصرفية الفخمة
class _SingleEntityCard extends StatelessWidget {
  final String title;
  final String code;
  final String? logoUrl;
  final double balance;
  final String currency;
  final int activePosCount;
  final int pendingRequestsCount;
  final bool isNegative;
  final bool isMasked;
  final VoidCallback? onActionTap;

  const _SingleEntityCard({
    required this.title,
    required this.code,
    required this.logoUrl,
    required this.balance,
    required this.currency,
    required this.activePosCount,
    required this.pendingRequestsCount,
    required this.isNegative,
    required this.isMasked,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final formattedBalance = isMasked
        ? '••••••••'
        : AmountFormatter.formatValue(balance.abs());

    return Container(
      width: double.infinity,
      height: 224.h,
      decoration: BoxDecoration(
        gradient: isNegative
            ? LinearGradient(
                colors: [colors.error, colors.error.withValues(alpha: 0.82)],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              )
            : AppGradients.financialHero(context),
        borderRadius: AppRadius.xlRadius,
        boxShadow: isNegative
            ? AppElevation.tinted(context, colors.error)
            : AppElevation.tinted(context, colors.primary),
      ),
      child: Stack(
        children: [
          // خلفية زخرفية هندسية شفافة
          PositionedDirectional(
            end: -24.r,
            bottom: -24.r,
            child: Icon(
              Icons.hub_rounded,
              size: 150.r,
              color: colors.onPrimary.withValues(alpha: 0.07),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. ترويسة الكيان: الشعار والاسم والرمز والحالة
                Row(
                  children: [
                    Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: colors.onPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.onPrimary.withValues(alpha: 0.25),
                          width: 1.w,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CustomCachedImage.avatar(
                        url: logoUrl,
                        radius: 19.r,
                        fallbackText: title.isNotEmpty ? title[0] : 'ش',
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (code.isNotEmpty)
                            Text(
                              code,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onPrimary.withValues(alpha: 0.75),
                                fontSize: 10.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                    AppSpacing.hXs,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.onPrimary.withValues(alpha: 0.18),
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Text(
                        isNegative ? 'حساب مدين' : 'محفظة نشطة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),

                AppSpacing.vSm,

                // 2. الرصيد المالي المستقل للشبكة
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNegative
                          ? 'الرصيد المستحق السداد للشبكة'
                          : 'رصيد محفظة الشبكة المتاح',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSpacing.vXxs,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isNegative && !isMasked)
                          Text(
                            '- ',
                            style: AppTypography.displayMedium.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            formattedBalance,
                            style: AppTypography.displayMedium.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: isMasked ? 3.0 : 0.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppSpacing.hSm,
                        Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Text(
                            currency,
                            style: AppTypography.titleMedium.copyWith(
                              color: colors.onPrimary.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                AppSpacing.vSm,

                // 3. النبض الميداني المباشر والإجراء السريع
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // إحصائيات سريعة للكيان
                    Row(
                      children: [
                        _MicroMetricBadge(
                          icon: Icons.storefront_outlined,
                          label: '$activePosCount نقطة',
                        ),
                        if (pendingRequestsCount > 0) ...[
                          AppSpacing.hXs,
                          _MicroMetricBadge(
                            icon: Icons.pending_actions_rounded,
                            label: '$pendingRequestsCount طلب معلق',
                            isWarning: true,
                          ),
                        ],
                      ],
                    ),

                    // زر الإجراء السريع
                    CustomButton.secondary(
                      text: isNegative ? 'تسوية الحساب' : 'سجل المحفظة',
                      icon: isNegative ? Icons.payment_rounded : Icons.history_rounded,
                      size: AppButtonSize.small,
                      onPressed: onActionTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// شارة مؤشر مصغر داخل البطاقة
class _MicroMetricBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isWarning;

  const _MicroMetricBadge({
    required this.icon,
    required this.label,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: isWarning
            ? colors.warning.withValues(alpha: 0.28)
            : colors.onPrimary.withValues(alpha: 0.16),
        borderRadius: AppRadius.smRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.r,
            color: isWarning ? colors.warningContainer : colors.onPrimary,
          ),
          AppSpacing.hXxs,
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isWarning ? colors.warningContainer : colors.onPrimary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
