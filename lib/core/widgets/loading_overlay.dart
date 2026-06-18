import 'package:traffic/core/constants/colors.dart';
import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.blackOverlay,
            child: const Center(
              child: CustomLoadingIndicator(),
            ),
          ),
      ],
    );
  }
}
