import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';

class OrderLoadingOverlay extends StatelessWidget {
  const OrderLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(child: CustomLoadingIndicator()),
    );
  }
}
