import 'package:netsales/features/onboarding/domain/entities/onboarding_item_entity.dart';

/// نموذج شريحة التعريف في جولة البداية يرث من الكيان الدوميني
class OnboardingItemModel extends OnboardingItemEntity {
  const OnboardingItemModel({
    required super.title,
    required super.description,
    required super.badge,
    required super.icon,
    super.animationAsset,
    super.imageAsset,
  });
}
