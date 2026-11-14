import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_trial_policy_summary.dart';

class BillingEntitlementsSection extends StatelessWidget {
  const BillingEntitlementsSection({required this.controller, super.key});

  final BillingController controller;

  @override
  Widget build(BuildContext context) {
    final rawFeatures = controller.entitlements.value?['features'];
    final features = rawFeatures is List
        ? rawFeatures.whereType<Map<String, dynamic>>().toList(growable: false)
        : const <Map<String, dynamic>>[];
    final trial = controller.entitlements.value?['trial'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Text('الاستحقاقات والمزايا', style: AppTypography.titleMedium),
        ),
        if (features.isEmpty)
          const CustomEmptyState.compact(
            title: 'لا توجد استحقاقات متاحة للعرض',
          )
        else
          ...features.map(_featureTile),
        if (trial is Map<String, dynamic>) BillingTrialPolicySummary(trial: trial),
      ],
    );
  }

  Widget _featureTile(Map<String, dynamic> feature) {
    final available = feature['available'] == true;
    return CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
      child: CustomInfoListTile(
        title: Text(
          feature['name']?.toString() ??
              feature['feature_key']?.toString() ??
              'ميزة',
        ),
        subtitle: Text(
          'القيمة: ${feature['configured_value']?.toString() ?? '—'}',
        ),
        trailing: CustomStatusBadge(
          label: available ? 'متاح' : 'غير متاح',
          tone:
              available ? SemanticTone.success : SemanticTone.neutral,
          icon: available
              ? Icons.check_circle_rounded
              : Icons.block_rounded,
        ),
      ),
    );
  }

}
