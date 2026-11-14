import 'package:flutter/material.dart';

/// Available luxury visual themes for [PremiumBankCard].
enum PremiumBankCardTheme {
  /// Deep obsidian & dark titanium gradient with silver hairline accents.
  obsidian,

  /// Royal emerald & deep forest green gradient with gold micro-accents.
  emerald,

  /// Crisp ceramic pearl opal for pristine light-mode executive elegance.
  platinum,

  /// Royal sapphire & midnight navy gradient with electric blue accents.
  sapphire,

  /// Custom gradient and coloration supplied via properties.
  custom,
}

/// A luxury, executive banking-style card widget designed for carousels
/// and financial wallets across Network and POS workspaces.
class PremiumBankCard extends StatefulWidget {
  const PremiumBankCard({
    super.key,
    required this.title,
    this.subtitle,
    this.logo,
    this.cardNumber,
    this.primaryLabel = 'الرصيد المتاح',
    required this.primaryValue,
    this.secondaryLabel,
    this.secondaryValue,
    this.cardholderName,
    this.statusText,
    this.statusColor,
    this.theme = PremiumBankCardTheme.emerald,
    this.customGradient,
    this.customTextColor,
    this.isSelected = false,
    this.onTap,
    this.height = 205,
    this.width,
    this.showChip = true,
    this.showContactless = true,
    this.cardUuidLabel = 'UUID',
  });

  /// Name of the issuing entity (e.g., Network Name, Bank, or Treasury Vault).
  final String title;

  /// Subtitle or relationship label (e.g., 'المزود المعتمد', 'الحساب الرئيسي').
  final String? subtitle;

  /// Leading logo or avatar widget (e.g., Network brand logo or bank icon).
  final Widget? logo;

  /// Monospace masked account or card number (e.g., '•••• •••• •••• 4092').
  final String? cardNumber;

  /// Label for the prominent financial metric.
  final String primaryLabel;

  /// Main balance or credit capacity to display in large typography.
  final String primaryValue;

  /// Optional secondary metric label (e.g., 'سقف الائتمان', 'المديونية').
  final String? secondaryLabel;

  /// Value for the secondary metric.
  final String? secondaryValue;

  /// Name of the cardholder (e.g., POS Agent name or Network Director).
  final String? cardholderName;

  /// Status badge label (e.g., 'حساب معتمد', 'نشط', 'VIP').
  final String? statusText;

  /// Custom accent color for the status badge.
  final Color? statusColor;

  /// The preset luxury theme.
  final PremiumBankCardTheme theme;

  /// Custom gradient when using [PremiumBankCardTheme.custom].
  final Gradient? customGradient;

  /// Custom primary text color when using [PremiumBankCardTheme.custom].
  final Color? customTextColor;

  /// Whether this card is currently selected/active in the carousel.
  final bool isSelected;

  /// Tap callback with micro-bounce animation.
  final VoidCallback? onTap;

  /// Height of the card (defaults to standard 205).
  final double height;

  /// Optional width override (defaults to double.infinity).
  final double? width;

  /// Whether to render the stylized metallic EMV Smart Chip.
  final bool showChip;

  /// Whether to render the contactless NFC icon waves.
  final bool showContactless;

  /// Prefix label for the UUID / account code badge (e.g. 'Network UUID', 'Wallet UUID').
  final String cardUuidLabel;

  @override
  State<PremiumBankCard> createState() => _PremiumBankCardState();
}

class _PremiumBankCardState extends State<PremiumBankCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.975).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _pressController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveCardColors(context);

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _handleTapDown : null,
        onTapUp: widget.onTap != null ? _handleTapUp : null,
        onTapCancel: widget.onTap != null ? _handleTapCancel : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final hoverLift = _isHovered ? -2.0 : 0.0;
            return Transform.translate(
              offset: Offset(0, hoverLift),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: style.gradient,
              border: Border.all(
                color: widget.isSelected
                    ? style.selectedBorderColor
                    : style.borderColor,
                width: widget.isSelected ? 1.75 : 1.0,
              ),
              boxShadow: [
                if (widget.isSelected)
                  BoxShadow(
                    color: style.glowColor,
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Metallic linear gloss overlay
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            style.glossColor.withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Geometric luxury micro-pattern (curved subtle wave)
                  Positioned(
                    bottom: -60,
                    left: -40,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: style.glossColor.withValues(alpha: 0.06),
                          width: 32,
                        ),
                      ),
                    ),
                  ),

                  // Main card content padding
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header Row: Logo, Title, Chip, NFC & Badge
                        _buildHeader(style),

                        // Middle Row: Primary Financial Value & Account Mask
                        _buildFinancialCenter(style),

                        // Footer Row: Cardholder & Secondary Metric
                        _buildFooter(style),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_CardColorBundle style) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Entity Logo Avatar
        if (widget.logo != null) ...[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: style.chipSurfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: style.borderColor.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Center(child: widget.logo),
          ),
          const SizedBox(width: 8),
        ],

        // Entity Name & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  if (widget.subtitle != null)
                    Flexible(
                      child: Text(
                        widget.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: style.subtextColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (widget.statusText != null) ...[
                    if (widget.subtitle != null) const SizedBox(width: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.statusColor ?? style.accentBadgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      widget.statusText!,
                      style: TextStyle(
                        color: widget.statusColor ?? style.accentBadgeColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 6),

        // Contactless Icon Waves
        if (widget.showContactless) ...[
          Icon(
            Icons.contactless_rounded,
            color: style.subtextColor.withValues(alpha: 0.85),
            size: 17,
          ),
          const SizedBox(width: 6),
        ],

        // Metallic EMV Smart Chip
        if (widget.showChip) ...[
          _buildEmvChip(style),
        ],

        if (widget.isSelected && !widget.showChip)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: style.selectedBorderColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: style.gradient.colors.first,
              size: 13,
            ),
          ),
      ],
    );
  }

  Widget _buildEmvChip(_CardColorBundle style) {
    return Container(
      width: 24,
      height: 17,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37), // Metallic satin brass gold
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFAA820A), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 12,
              height: 8,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8C6D05), width: 0.4),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
          Positioned(
            top: 3.5,
            left: 0,
            right: 0,
            child: Container(height: 0.4, color: const Color(0xFF8C6D05)),
          ),
          Positioned(
            bottom: 3.5,
            left: 0,
            right: 0,
            child: Container(height: 0.4, color: const Color(0xFF8C6D05)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCenter(_CardColorBundle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.primaryLabel,
                    style: TextStyle(
                      color: style.subtextColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.primaryValue,
                      style: TextStyle(
                        color: style.textColor,
                        fontSize: 17.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.cardNumber != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.cardUuidLabel}: ',
                  style: TextStyle(
                    color: style.subtextColor.withValues(alpha: 0.75),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Flexible(
                  child: Text(
                    widget.cardNumber!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: style.textColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(_CardColorBundle style) {
    final hasCardholder =
        widget.cardholderName != null &&
        widget.cardholderName!.trim().isNotEmpty;
    final hasSecondary =
        widget.secondaryValue != null &&
        widget.secondaryValue!.trim().isNotEmpty;

    if (!hasCardholder && !hasSecondary) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: style.subtextColor.withValues(alpha: 0.15),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cardholder Details
          if (hasCardholder)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الكيان التجاري',
                    style: TextStyle(
                      color: style.subtextColor.withValues(alpha: 0.8),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.cardholderName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: style.textColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          // Secondary Financial Value (e.g. سقف الائتمان)
          if (hasSecondary)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.secondaryLabel ?? 'سقف الائتمان',
                  style: TextStyle(
                    color: style.subtextColor.withValues(alpha: 0.8),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  widget.secondaryValue!,
                  style: TextStyle(
                    color: style.accentBadgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  _CardColorBundle _resolveCardColors(BuildContext context) {
    switch (widget.theme) {
      case PremiumBankCardTheme.obsidian:
        return const _CardColorBundle(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF0B0F17)],
          ),
          textColor: Color(0xFFF8FAFC),
          subtextColor: Color(0xFF94A3B8),
          borderColor: Color(0xFF334155),
          selectedBorderColor: Color(0xFF10B981),
          glowColor: Color(0x3310B981),
          glossColor: Colors.white,
          chipSurfaceColor: Color(0xFF1E293B),
          accentBadgeColor: Color(0xFF34D399),
        );

      case PremiumBankCardTheme.emerald:
        return const _CardColorBundle(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF047857), Color(0xFF064E3B), Color(0xFF022C22)],
          ),
          textColor: Colors.white,
          subtextColor: Color(0xFFA7F3D0),
          borderColor: Color(0xFF065F46),
          selectedBorderColor: Color(0xFF6EE7B7),
          glowColor: Color(0x3D059669),
          glossColor: Color(0xFF34D399),
          chipSurfaceColor: Color(0xFF065F46),
          accentBadgeColor: Color(0xFFFDE047),
        );

      case PremiumBankCardTheme.platinum:
        return const _CardColorBundle(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
          textColor: Color(0xFF0F172A),
          subtextColor: Color(0xFF64748B),
          borderColor: Color(0xFFE2E8F0),
          selectedBorderColor: Color(0xFF059669),
          glowColor: Color(0x1F0F172A),
          glossColor: Color(0xFFCBD5E1),
          chipSurfaceColor: Color(0xFFE2E8F0),
          accentBadgeColor: Color(0xFF059669),
        );

      case PremiumBankCardTheme.sapphire:
        return const _CardColorBundle(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A), Color(0xFF0F172A)],
          ),
          textColor: Colors.white,
          subtextColor: Color(0xFFBFDBFE),
          borderColor: Color(0xFF1E40AF),
          selectedBorderColor: Color(0xFF60A5FA),
          glowColor: Color(0x3D2563EB),
          glossColor: Color(0xFF93C5FD),
          chipSurfaceColor: Color(0xFF1E3A8A),
          accentBadgeColor: Color(0xFF93C5FD),
        );

      case PremiumBankCardTheme.custom:
        return _CardColorBundle(
          gradient:
              widget.customGradient ??
              const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF020617)],
              ),
          textColor: widget.customTextColor ?? Colors.white,
          subtextColor: (widget.customTextColor ?? Colors.white).withValues(
            alpha: 0.7,
          ),
          borderColor: Colors.white.withValues(alpha: 0.12),
          selectedBorderColor: Colors.white.withValues(alpha: 0.5),
          glowColor: Colors.black.withValues(alpha: 0.2),
          glossColor: Colors.white,
          chipSurfaceColor: Colors.white.withValues(alpha: 0.1),
          accentBadgeColor: Colors.amber,
        );
    }
  }
}

class _CardColorBundle {
  const _CardColorBundle({
    required this.gradient,
    required this.textColor,
    required this.subtextColor,
    required this.borderColor,
    required this.selectedBorderColor,
    required this.glowColor,
    required this.glossColor,
    required this.chipSurfaceColor,
    required this.accentBadgeColor,
  });

  final Gradient gradient;
  final Color textColor;
  final Color subtextColor;
  final Color borderColor;
  final Color selectedBorderColor;
  final Color glowColor;
  final Color glossColor;
  final Color chipSurfaceColor;
  final Color accentBadgeColor;
}
