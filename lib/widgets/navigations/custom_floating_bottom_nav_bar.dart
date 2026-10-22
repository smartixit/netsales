import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


/// شريط التنقل السفلي العائم بتصميم زجاجي عصري
/// واجهة رفيعة تُحقن تبعياتها عبر الـ constructor (لا `Get.find` داخل الواجهة).
class CustomFloatingBottomNavBar extends StatelessWidget {
  final HomeLayoutController controller;
  final VoidCallback onCenterActionTap;

  const CustomFloatingBottomNavBar({
    super.key,
    required this.controller,
    required this.onCenterActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      height: 72.h,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final current = controller.selectedIndex.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              key: const ValueKey('nav_0'),
              icon: Icons.grid_view_outlined,
              activeIcon: Icons.grid_view_rounded,
              label: 'الرئيسية',
              index: 0,
              current: current,
              colorScheme: colorScheme,
              onTap: () => controller.changeTab(0),
            ),
            _NavItem(
              key: const ValueKey('nav_1'),
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long_rounded,
              label: 'المبيعات',
              index: 1,
              current: current,
              colorScheme: colorScheme,
              onTap: () => controller.changeTab(1),
            ),
            _buildCenterActionButton(context, colorScheme),
            _NavItem(
              key: const ValueKey('nav_2'),
              icon: Icons.people_alt_outlined,
              activeIcon: Icons.people_alt_rounded,
              label: 'العملاء',
              index: 2,
              current: current,
              colorScheme: colorScheme,
              onTap: () => controller.changeTab(2),
            ),
            _NavItem(
              key: const ValueKey('nav_3'),
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: 'الإعدادات',
              index: 3,
              current: current,
              colorScheme: colorScheme,
              onTap: () => controller.changeTab(3),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCenterActionButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return InteractiveBounce(
      onTap: onCenterActionTap,
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [colorScheme.primary, colorScheme.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.add_rounded,
            color: colorScheme.onPrimary,
            size: 28.sp,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInOut,
      ),
    );
    _scaleController.value = 1.0;
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // عند اختيار العنصر حديثاً — نبضة ارتداد واضحة
    if (oldWidget.current != widget.current && widget.current == widget.index) {
      _scaleController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.current == widget.index;

    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) {
        _scaleController.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.forward(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          width: 70.w,
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: isSelected
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.colorScheme.primary.withValues(alpha: 0.14),
                      widget.colorScheme.secondary.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: widget.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Icon(
                  isSelected ? widget.activeIcon : widget.icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? widget.colorScheme.primary
                      : widget.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                  size: 22.sp,
                ),
              ),
              SizedBox(height: 3.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected
                      ? widget.colorScheme.primary
                      : widget.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                  fontSize: isSelected ? 10.sp : 9.5.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
