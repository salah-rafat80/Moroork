import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/primary_button.dart';

class FinalizeOrderButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const FinalizeOrderButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      child: PrimaryButton(
        label: label,
        onPressed: onPressed,
        height: 48.h,
      ),
    );
  }
}
