import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_qr_share_card.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// نافذة سفلية لعرض ومشاركة دعوة ربط نقطة البيع بالشبكة عبر QR
class NetworkPosQrChallengeSheet {
  NetworkPosQrChallengeSheet._();

  static Future<void> show({
    required int networkId,
    required String networkName,
    String? networkPhone,
    int? posId,
    String? posName,
    int durationMinutes = 30,
  }) async {
    final controller = Get.find<CommercialDirectoryController>();

    // إنشاء التحدي المشفر فورياً عند فتح النافذة
    final futureChallenge = controller.createQrChallenge(
      networkId: networkId,
      posId: posId,
      durationMinutes: durationMinutes,
    );

    return CustomBottomSheet.show<void>(
      title: 'دعوة ربط عبر رمز QR',
      subtitle:
          'شارك رمز الاستجابة السريعة مع نقطة البيع لإتمام الارتباط فورياً',
      leadingIcon: Icons.qr_code_2_rounded,
      child: FutureBuilder<NetworkPosLinkChallengeEntity?>(
        future: futureChallenge,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: CustomSkeletonFeed(itemCount: 1, cardHeight: 280),
            );
          }

          final challenge = snapshot.data;
          if (challenge == null) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'تعذر إنشاء دعوة الربط المشفرة. يرجى المحاولة لاحقاً.',
                ),
              ),
            );
          }

          return NetworkPosQrShareCard(
            challenge: challenge,
            networkName: networkName,
            networkPhone: networkPhone,
            posName: posName,
            onRevoke: () async {
              await controller.revokeActiveChallenge();
              Get.back<void>();
            },
          );
        },
      ),
    );
  }
}
