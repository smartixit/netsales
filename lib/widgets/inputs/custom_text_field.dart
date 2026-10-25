import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netsales/core/themes/app_typography.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.enablePasswordToggle = false,
    this.inputFormatters,
    this.allowSpaces,
    this.focusNode,
    this.autofillHints,
    this.isRequired = true,
  });

  final TextEditingController controller;

  final String label;

  final String? hint;

  final String? Function(String?)? validator;

  final Widget? prefixIcon;

  final Widget? suffixIcon;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final bool obscureText;

  final bool enablePasswordToggle;

  final bool enabled;

  final bool readOnly;

  final int maxLines;

  final int? minLines;

  final int? maxLength;

  final bool autofocus;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onFieldSubmitted;

  final List<TextInputFormatter>? inputFormatters;

  final bool? allowSpaces;

  final FocusNode? focusNode;

  final Iterable<String>? autofillHints;

  final bool isRequired;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late bool _obscureText;
  late final FocusNode _effectiveFocusNode;
  bool _isInternalFocusNode = false;
  late final AnimationController _shakeController;
  late final Animation<Offset> _shakeAnimation;
  late final String? Function(String?) _wrappedValidator;
  bool _hadError = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    _shakeController = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );
    _shakeAnimation = _shakeController.drive(
      TweenSequence<Offset>([
        TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(-10, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(-10, 0), end: const Offset(10, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(10, 0), end: const Offset(-7, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(-7, 0), end: const Offset(7, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(7, 0), end: const Offset(-4, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(-4, 0), end: const Offset(4, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(4, 0), end: Offset.zero),
          weight: 1,
        ),
      ]),
    );

    if (widget.focusNode == null) {
      _effectiveFocusNode = FocusNode();
      _isInternalFocusNode = true;
    } else {
      _effectiveFocusNode = widget.focusNode!;
    }

    _wrappedValidator = (value) {
      final error = widget.validator?.call(value);
      if (error != null && !_hadError) {
        _shake();
      }
      _hadError = error != null;
      return error;
    };

    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (_isInternalFocusNode) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_effectiveFocusNode.hasFocus) {
      final text = widget.controller.text;
      final trimmed = text.trim();
      if (text != trimmed) {
        widget.controller.text = trimmed;
      }
    }
  }

  void _shake() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _shakeController.forward(from: 0);
      }
    });
  }

  String? Function(String?)? get _effectiveValidator {
    if (widget.validator == null) return null;
    return _wrappedValidator;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final shouldDenyAllSpaces =
        widget.allowSpaces == false ||
        (widget.allowSpaces == null &&
            (widget.keyboardType == TextInputType.phone ||
                widget.keyboardType == TextInputType.number ||
                widget.keyboardType == TextInputType.emailAddress ||
                widget.obscureText));

    final effectiveInputFormatters = <TextInputFormatter>[
      if (shouldDenyAllSpaces)
        FilteringTextInputFormatter.deny(RegExp(r'\s'))
      else
        _PreventLeadingSpaceFormatter(),
      if (widget.inputFormatters != null) ...widget.inputFormatters!,
    ];

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) =>
          Transform.translate(offset: _shakeAnimation.value, child: child),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,

        controller: widget.controller,

        focusNode: _effectiveFocusNode,

        obscureText: _obscureText,

        enabled: widget.enabled,

        readOnly: widget.readOnly,

        autofocus: widget.autofocus,

        keyboardType: widget.keyboardType,

        textInputAction: widget.textInputAction,

        maxLines: widget.obscureText ? 1 : widget.maxLines,

        minLines: widget.minLines,

        maxLength: widget.maxLength,

        onChanged: widget.onChanged,

        onFieldSubmitted: (value) {
          final trimmed = widget.controller.text.trim();
          if (widget.controller.text != trimmed) {
            widget.controller.text = trimmed;
          }
          widget.onFieldSubmitted?.call(trimmed);
        },

        validator: _effectiveValidator,

        inputFormatters: effectiveInputFormatters,

        autofillHints: widget.autofillHints,

        style: theme.textTheme.bodyLarge,

        decoration: InputDecoration(
          label: widget.label.isNotEmpty
              ? Text.rich(
                  TextSpan(
                    text: widget.label,
                    style: AppTypography.inputLabel.copyWith(
                      color: context.colors.onSurface,
                    ),
                    children: [
                      if (widget.isRequired) ...[
                        const WidgetSpan(child: SizedBox(width: 4)),
                        TextSpan(
                          text: '*',
                          style: AppTypography.inputLabel.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : null,

          hintText: widget.hint,

          prefixIcon: widget.prefixIcon,

          suffixIcon: widget.enablePasswordToggle
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: context.colors.onSuccessVariant.withValues(
                      alpha: 0.5,
                    ),
                    size: 20.r,
                  ),

                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : widget.suffixIcon,

          // filled: true,

          // fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),

          // labelStyle: theme.textTheme.bodyMedium?.copyWith(
          //   color: colorScheme.onSurfaceVariant,
          // ),

          // hintStyle: theme.textTheme.bodyMedium?.copyWith(
          //   color: colorScheme.onSurfaceVariant.withValues(alpha: .7),
          // ),

          // contentPadding: EdgeInsets.symmetric(
          //   horizontal: AppSpacing.inputPadding,
          //   vertical: AppSpacing.inputPadding,
          // ),

          // border: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppRadius.input),

          //   borderSide: BorderSide.none,
          // ),

          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppRadius.input),

          //   borderSide: BorderSide(
          //     color: colorScheme.outline.withValues(alpha: .25),
          //   ),
          // ),

          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(16),

          //   borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
          // ),

          // errorBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppRadius.input),

          //   borderSide: BorderSide(color: colorScheme.error),
          // ),

          // focusedErrorBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(16),

          //   borderSide: BorderSide(color: colorScheme.error, width: 1.8),
          // ),
        ),
      ),
    );
  }
}

/// Custom formatter that prevents typing leading spaces at the start of a field.
class _PreventLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith(' ')) {
      final trimmedLeading = newValue.text.trimLeft();
      final diff = newValue.text.length - trimmedLeading.length;
      final newOffset = (newValue.selection.end - diff).clamp(
        0,
        trimmedLeading.length,
      );
      return TextEditingValue(
        text: trimmedLeading,
        selection: TextSelection.collapsed(offset: newOffset),
      );
    }
    return newValue;
  }
}
