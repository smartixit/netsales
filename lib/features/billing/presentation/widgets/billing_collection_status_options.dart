import 'package:flutter/material.dart';
import 'package:netsales/core/enums/billing_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class BillingCollectionStatusOptions {
  BillingCollectionStatusOptions._();

  static List<DropdownItem<String>> build(Iterable<String> values) {
    return [
      DropdownItem<String>(
        value: '',
        child: Text('كل الحالات'),
      ),
      ...values.map((value) {
        final presentation = EnumPresentationRegistry.resolveBillingStatus(
          BillingStatus.fromWire(value),
        );
        return DropdownItem<String>(
          value: value,
          child: Text(presentation.label),
        );
      }),
    ];
  }
}
