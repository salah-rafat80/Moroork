import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable card representing a selectable payment method option with animations.
class PaymentOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String logoAssetPath;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  const PaymentOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.logoAssetPath,
    this.isSelected = false,
    this.isAvailable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.6,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: 72.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.03)
                : AppColors.cardBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.greyBorder.withValues(alpha: 0.8),
              width: isSelected ? 2.w : 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.shadowColor.withValues(alpha: 0.02),
                blurRadius: isSelected ? 8.r : 4.r,
                offset: Offset(0, isSelected ? 3.h : 1.h),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Logo / Icon (Rightmost in RTL)
              Container(
                height: 48.w,
                padding: (logoAssetPath.contains('visa') || logoAssetPath.contains('wallet'))
                    ? EdgeInsets.symmetric(horizontal: 8.w)
                    : null,
                width: (logoAssetPath.contains('visa') || logoAssetPath.contains('wallet')) ? null : 48.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.lightGreyBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: logoAssetPath.contains('visa')
                      ? _buildCardLogos()
                      : logoAssetPath.contains('wallet')
                          ? _buildWalletLogos()
                          : Image.asset(
                              logoAssetPath,
                              width: 32.w,
                              height: 22.h,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  logoAssetPath.contains('wallet')
                                      ? Icons.account_balance_wallet_rounded
                                      : Icons.credit_card_rounded,
                                  size: 22.w,
                                  color: isSelected ? AppColors.primary : AppColors.mediumGrey,
                                );
                              },
                            ),
                ),
              ),
              SizedBox(width: 16.w),

              // Title & Subtitle (Middle in RTL, aligned right)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  textDirection: TextDirection.rtl,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.sp,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!isAvailable) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.mediumGrey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'قريباً',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontFamily: 'Cairo',
                                color: AppColors.mediumGrey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 11.sp,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),

              // Selection Indicator (Radio / Check circle - Leftmost in RTL)
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.mediumGrey,
                    width: isSelected ? 6.w : 2.w,
                  ),
                  color: isSelected ? Colors.white : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardLogos() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Visa Logo
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F71),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'VISA',
            style: TextStyle(
              fontSize: 7.sp,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFFF7B600),
              letterSpacing: 0.2,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        // Mastercard circles
        SizedBox(
          width: 18.w,
          height: 12.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                right: 6.w,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEB001B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: 6.w,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5F00).withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 4.w),
        // Meeza Logo
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: const Color(0xFF005A3C),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'ميزة',
            style: TextStyle(
              fontSize: 7.sp,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletLogos() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Vodafone Cash stylized circle
        Container(
          width: 16.w,
          height: 16.w,
          decoration: const BoxDecoration(
            color: Color(0xFFE60000), // Vodafone red
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'V',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        // Fawry stylized circle
        Container(
          width: 16.w,
          height: 16.w,
          decoration: const BoxDecoration(
            color: Color(0xFFFFC72C), // Fawry yellow
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'F',
              style: TextStyle(
                color: const Color(0xFF002D72),
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        // InstaPay stylized circle
        Container(
          width: 16.w,
          height: 16.w,
          decoration: const BoxDecoration(
            color: Color(0xFF8C3494), // InstaPay purple
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'I',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
