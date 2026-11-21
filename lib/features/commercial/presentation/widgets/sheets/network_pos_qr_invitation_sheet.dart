import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/services/qr_code_service.dart';
import 'package:netsales/core/services/share_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_status_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/qr/custom_qr_code.dart';
import 'package:netsales/widgets/qr/custom_qr_share_card.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';
import 'package:share_plus/share_plus.dart' show ShareResultStatus;

/// نافذة دعوة مرتبطة بشبكة محددة، مع متابعة الحالة وتصدير بطاقة آمنة.
class NetworkPosQrInvitationSheet extends StatefulWidget {
  const NetworkPosQrInvitationSheet({
    super.key,
    required this.challenge,
    required this.networkName,
    required this.getStatus,
    required this.onRevoke,
  });

  final NetworkPosLinkChallengeEntity challenge;
  final String networkName;
  final Future<NetworkPosLinkChallengeStatusEntity> Function() getStatus;
  final VoidCallback onRevoke;

  @override
  State<NetworkPosQrInvitationSheet> createState() =>
      _NetworkPosQrInvitationSheetState();
}

class _NetworkPosQrInvitationSheetState
    extends State<NetworkPosQrInvitationSheet> {
  final GlobalKey _shareCardKey = GlobalKey();
  Timer? _statusTimer;
  Timer? _clockTimer;
  late LinkingChallengeStatus _status;
  DateTime? _expiresAt;
  bool _isRefreshingStatus = false;
  bool _isExporting = false;

  bool get _isActive =>
      _status == LinkingChallengeStatus.pending &&
      _expiresAt != null &&
      _expiresAt!.isAfter(DateTime.now());

  @override
  void initState() {
    super.initState();
    _status = widget.challenge.typedStatus;
    _expiresAt = DateTime.tryParse(widget.challenge.expiresAt ?? '');
    _refreshStatus();
    if (_status == LinkingChallengeStatus.pending) {
      _statusTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _refreshStatus(),
      );
    }
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) setState(() {});
        if (!_isActive) {
          _statusTimer?.cancel();
          _clockTimer?.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    if (_isRefreshingStatus || !mounted || !_status.isPending) return;
    _isRefreshingStatus = true;
    try {
      final latest = await widget.getStatus();
      if (!mounted) return;
      setState(() {
        _status = latest.status;
        _expiresAt = latest.expiresAt ?? _expiresAt;
        if (!_isActive) _statusTimer?.cancel();
      });
    } catch (_) {
      // Keep the last server-confirmed state; a transient network failure
      // must not be interpreted as expiration or revocation.
    } finally {
      _isRefreshingStatus = false;
    }
  }

  String get _remainingLabel {
    final expiry = _expiresAt;
    if (expiry == null) return 'تعذر تحديد وقت الانتهاء';
    final remaining = expiry.difference(DateTime.now());
    if (remaining.isNegative || remaining == Duration.zero) {
      return 'انتهت مدة الدعوة';
    }
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return 'متبقي $minutes دقيقة و$seconds ثانية';
  }

  Future<Uint8List?> _captureShareCard() async {
    await precacheImage(
      const AssetImage('assets/images/brand_icon.png'),
      context,
    );
    await WidgetsBinding.instance.endOfFrame;
    final renderObject =
        _shareCardKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return null;

    final image = await renderObject.toImage(pixelRatio: 1);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return null;
      return data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
    } finally {
      image.dispose();
    }
  }

  Future<void> _shareInvitation() async {
    if (!_isActive || _isExporting) return;
    setState(() => _isExporting = true);
    try {
      final bytes = await _captureShareCard();
      if (bytes == null || bytes.isEmpty) {
        throw StateError('تعذر تجهيز صورة الدعوة.');
      }
      final result = await ShareService.instance.shareBytes(
        bytes: bytes,
        fileName: 'NetSales_Invitation.png',
        mimeType: 'image/png',
        subject: 'دعوة ربط عبر NetSales',
        text: 'امسح رمز الدعوة من داخل تطبيق NetSales.',
      );
      if (!mounted) return;
      if (result.status == ShareResultStatus.success) {
        CustomSnackbar.show(
          title: 'تمت المشاركة',
          message: 'تم إرسال بطاقة الدعوة إلى تطبيق المشاركة المختار.',
          type: SnackType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        CustomSnackbar.show(
          title: 'تعذرت المشاركة',
          message: 'لم نتمكن من تجهيز بطاقة الدعوة أو مشاركتها.',
          type: SnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _saveInvitation() async {
    if (!_isActive || _isExporting) return;
    setState(() => _isExporting = true);
    try {
      final bytes = await _captureShareCard();
      if (bytes == null || bytes.isEmpty) {
        throw StateError('تعذر تجهيز صورة الدعوة.');
      }
      final result = await FileExportService.instance.saveFile(
        bytes: bytes,
        fileName: 'NetSales_Invitation',
        extension: 'png',
        folderName: 'NetSales',
        autoOpen: false,
        showFeedback: false,
      );
      if (!mounted) return;
      CustomSnackbar.show(
        title: result.isSuccess ? 'تم حفظ الدعوة' : 'تعذر حفظ الدعوة',
        message: result.isSuccess
            ? 'تم حفظ بطاقة الدعوة في مجلد تنزيلات NetSales.'
            : 'لم نتمكن من حفظ صورة الدعوة.',
        type: result.isSuccess ? SnackType.success : SnackType.error,
      );
    } catch (_) {
      if (mounted) {
        CustomSnackbar.show(
          title: 'تعذر حفظ الدعوة',
          message: 'حدث خطأ أثناء تجهيز صورة الدعوة.',
          type: SnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusPresentation =
        EnumPresentationRegistry.resolveLinkingChallengeStatus(_status);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.hub_rounded, color: colors.primary, size: 26.r),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الجهة المرتبطة بالدعوة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        widget.networkName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded, color: colors.primary),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: colors.primary.withValues(alpha: .2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: CustomQrCode(
                data: widget.challenge.payload,
                size: 224.r,
                decoration: QrCodeService.brandDecoration,
                semanticsLabel: 'رمز دعوة ربط تجارية',
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomStatusBadge(
                label: statusPresentation.label,
                tone: statusPresentation.tone,
                icon: statusPresentation.icon,
              ),
              SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  _remainingLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'اطلب من نقطة البيع فتح ماسح QR داخل تطبيق NetSales ومسح الرمز لإتمام الربط.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: CustomButton.primary(
                  text: 'مشاركة البطاقة',
                  icon: Icons.share_rounded,
                  size: AppButtonSize.medium,
                  loading: _isExporting,
                  onPressed: _isActive && !_isExporting
                      ? _shareInvitation
                      : null,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CustomButton.outline(
                  text: 'حفظ الصورة',
                  icon: Icons.download_rounded,
                  size: AppButtonSize.medium,
                  loading: _isExporting,
                  onPressed: _isActive && !_isExporting
                      ? _saveInvitation
                      : null,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          if (_isActive)
            CustomButton.outline(
              text: 'إلغاء الدعوة',
              icon: Icons.block_rounded,
              size: AppButtonSize.medium,
              onPressed: () {
                _statusTimer?.cancel();
                widget.onRevoke();
                Get.back<void>();
              },
            )
          else
            Text(
              _status == LinkingChallengeStatus.consumed
                  ? 'تم استخدام الدعوة وإتمام الارتباط.'
                  : 'هذه الدعوة لم تعد صالحة للمشاركة أو الحفظ.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          SizedBox(height: AppSpacing.md),
          Offstage(
            offstage: true,
            child: UnconstrainedBox(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: _shareCardKey,
                child: CustomQrShareCard(payload: widget.challenge.payload),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
