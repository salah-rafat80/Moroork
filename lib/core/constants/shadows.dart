import 'package:flutter/widgets.dart';
import 'package:traffic/core/constants/colors.dart';

class AppShadows {
  static List<BoxShadow> low = [
    BoxShadow(
      color: AppColors.shadowUltraLight,
      offset: const Offset(0, 4),
      blurRadius: 16,
    ),
  ];
}