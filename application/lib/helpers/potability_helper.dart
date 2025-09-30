import 'package:application/enum/potability_enum.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PotabilityInfo {
  final IconData icon;
  final Color color;
  final String label;

  PotabilityInfo({
    required this.icon,
    required this.color,
    required this.label,
  });
}

class PotabilityHelper {
  static PotabilityInfo getInfo(Potability p) {
    switch (p) {
      case Potability.potable:
        return PotabilityInfo(
          icon: Icons.invert_colors,
          color: Colors.lightBlue,
          label: 'drinking_fountain.potable'.tr(),
        );
      case Potability.notPotable:
        return PotabilityInfo(
          icon: Icons.invert_colors_off,
          color: Colors.orange,
          label: 'drinking_fountain.not_potable'.tr(),
        );
      case Potability.unknown:
        return PotabilityInfo(
          icon: Icons.invert_colors,
          color: Colors.grey,
          label: 'drinking_fountain.unknown'.tr(),
        );
    }
  }
}
