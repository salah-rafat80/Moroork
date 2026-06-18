import 'package:flutter/material.dart';
import 'package:traffic/features/auth/presentation/screens/otp_screen/otp_styles.dart';

/// Success bottom sheet widget.
class OtpSuccessSheet extends StatelessWidget {
  const OtpSuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: OtpStyles.sheetVerticalPadding),
      decoration: BoxDecoration(
        color: OtpStyles.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(OtpStyles.sheetRadius),
          topRight: Radius.circular(OtpStyles.sheetRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Green checkmark circle
          Container(
            width: OtpStyles.successCircleSize,
            height: OtpStyles.successCircleSize,
            decoration: BoxDecoration(
              color: OtpStyles.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: OtpStyles.successIconSize,
            ),
          ),
          SizedBox(height: OtpStyles.successCircleToTextSpacing),
          // Success text
          Text(
            'تم التحقق بنجاح!',
            style: OtpStyles.successTitleStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
