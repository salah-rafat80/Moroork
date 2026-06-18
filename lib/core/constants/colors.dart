import 'package:flutter/material.dart';

class AppColors {
  static bool isDarkMode = false;

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Brand Colors
  static Color get primary =>
      isDarkMode ? const Color(0xFF27AE60) : const Color(0xFF27AE60);
  static Color get secondary =>
      isDarkMode ? const Color(0xFF27AE60) : const Color(0xFF27AE60);
  static Color get background =>
      isDarkMode ? const Color(0xFF121824) : const Color(0xFFFFFFFF);
  static Color get surface =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF7F7F7);
  static Color get textPrimary =>
      isDarkMode ? const Color(0xFFF3F4F6) : const Color(0xFF222222);
  static Color get textSecondary =>
      isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  static Color get border =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
  static Color get error =>
      isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFD32F2F);
  static Color get onPrimary =>
      isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

  // Mapped UI Colors (Refactored from hardcoded values)
  static Color get greyBorder =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFDADADA);
  static Color get cardBg =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
  static Color get alertRed =>
      isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFE53935);
  static Color get lightGreyBg =>
      isDarkMode ? const Color(0xFF121824) : const Color(0xFFF5F5F5);
  static Color get mediumGrey =>
      isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF707070);
  static Color get darkGrey =>
      isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF333333);
  static Color get shadowColor =>
      isDarkMode ? const Color(0x7F000000) : const Color(0x3F000000);
  static Color get greyIcon =>
      isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFFAEAEAE);
  static Color get lightPurpleGrey =>
      isDarkMode ? const Color(0xFFA5B4FC) : const Color(0xFF9490A1);
  static Color get lightGreenBg =>
      isDarkMode ? const Color(0xFF166534) : const Color(0xFFD4ECDE);
  static Color get dividerGrey =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFE0E0E0);
  static Color get charcoal =>
      isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF1A1A1A);
  static Color get deepGrey =>
      isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF444444);
  static Color get successLight =>
      isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9);
  static Color get bodyGrey =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF555555);
  static Color get inputHint =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFF999999);
  static Color get mutedGrey =>
      isDarkMode ? const Color(0xFF475569) : const Color(0xFFBDBDBD);
  static Color get warningOrange =>
      isDarkMode ? const Color(0xFFF59E0B) : const Color(0xFFEA9555);
  static Color get slateGrey =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFF9CA3AF);
  static Color get redError =>
      isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFE74C3C);
  static Color get softGrey =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF666666);
  static Color get extraLightGrey =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFEFEFEF);
  static Color get skyBlueLight =>
      isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFA5D4FF);
  static Color get primaryBlue =>
      isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
  static Color get shadowLight =>
      isDarkMode ? const Color(0xFF222222) : const Color(0x1F000000);
  static Color get borderLight =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE8E8E8);
  static Color get alertRedLight =>
      isDarkMode ? const Color(0xFF7F1D1D) : const Color(0xFFFFE9E9);
  static Color get darkRed =>
      isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFE02424);
  static Color get borderMedium =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFEBEBEB);
  static Color get whiteBg =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
  static Color get dividerLight =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF0F0F0);
  static Color get alertRedBg =>
      isDarkMode ? const Color(0xFFEF4444) : const Color(0xFF9B1C1C);
  static Color get errorLightBg =>
      isDarkMode ? const Color(0xFF7F1D1D) : const Color(0xFFFDE8E8);
  static Color get shadowUltraLight =>
      isDarkMode ? const Color(0x28000000) : const Color(0x14000000);
  static Color get successGreen =>
      isDarkMode ? const Color(0xFF27AE60) : const Color(0xFF27AE60);
  static Color get lightGreenBorder =>
      isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFDAEEE3);
  static Color get lightGreyBorder =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFD1D5DB);
  static Color get shadowOverlay =>
      isDarkMode ? const Color(0x4C000000) : const Color(0x19000000);
  static Color get inputFieldBg =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);
  static Color get alertRedBorder =>
      isDarkMode ? const Color(0xFF7F1D1D) : const Color(0xFFF8B4B4);
  static Color get alertOrangeLightBg =>
      isDarkMode ? const Color(0xFF78350F) : const Color(0xFFFFE3CF);
  static Color get alertOrangeText =>
      isDarkMode ? const Color(0xFFF59E0B) : const Color(0xFFDD8C50);
  static Color get warningOrangeLightBg =>
      isDarkMode ? const Color(0xFF78350F) : const Color(0xFFFFDAB9);
  static Color get warningOrangeText =>
      isDarkMode ? const Color(0xFFF59E0B) : const Color(0xFFE67E22);
  static Color get errorRedLightBg =>
      isDarkMode ? const Color(0xFF7F1D1D) : const Color(0xFFFFCDD2);
  static Color get errorRedText =>
      isDarkMode ? const Color(0xFFF87171) : const Color(0xFFF44336);
  static Color get alertRedLightSoft =>
      isDarkMode ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2);
  static Color get activeGreenLightBg =>
      isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE3FAED);
  static Color get chatBgLight =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF2F2F2);
  static Color get chatBgDark =>
      isDarkMode ? const Color(0xFF475569) : const Color(0xFF9E9E9E);
  static Color get inspectIconBg =>
      isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFF0F7F0);
  static Color get amberWarning =>
      isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFF1C40F);
  static Color get dividerSolid =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFEEEEEE);
  static Color get warningRedSoft =>
      isDarkMode ? const Color(0xFF450A0A) : const Color(0xFFFFE9E8);
  static Color get greenOpacityBg =>
      isDarkMode ? const Color(0x8027AE60) : const Color(0x8027AE60);
  static Color get blackOpacityBg =>
      isDarkMode ? const Color(0x80000000) : const Color(0x80000000);
  static Color get blackOverlay =>
      isDarkMode ? const Color(0x80000000) : const Color(0x66000000);
  static Color get alertAmber =>
      isDarkMode ? const Color(0xFFF59E0B) : const Color(0xFFF39C12);
  static Color get themeBlue =>
      isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF3498DB);
  static Color get purpleAccent =>
      isDarkMode ? const Color(0xFFC084FC) : const Color(0xFF9B59B6);
  static Color get textMuted =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFF757575);
  static Color get lightGreenBrand =>
      isDarkMode ? const Color(0xFF27AE60) : const Color(0xFF27AE60);
  static Color get lightGreenOpacity =>
      isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFD3FFE9);
  static Color get infoBlueBg =>
      isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE3F2FD);
  static Color get infoBlueText =>
      isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF1565C0);
  static Color get infoBlueDark =>
      isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF1F2937);
  static Color get alertRedLightBg =>
      isDarkMode ? const Color(0xFF450A0A) : const Color(0xFFFDF2F2);
  static Color get lightOrangeBg =>
      isDarkMode ? const Color(0xFF78350F) : const Color(0xFFFFF3E0);
  static Color get orangeText =>
      isDarkMode ? const Color(0xFFF59E0B) : const Color(0xFFE65100);
  static Color get filterBorderGrey =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFD9D9D9);
  static Color get successGreenAlt =>
      isDarkMode ? const Color(0xFF27AE60) : const Color(0xFF27AE60);
  static Color get googleBlue =>
      isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF4285F4);
  static Color get darkGreen =>
      isDarkMode ? const Color(0xFF27AE60) : const Color(0xFF27AE60);

  // Smart Assistant & Chat specific colors
  static Color get chatUserBubbleStart =>
      isDarkMode ? const Color(0xFF1E8449) : const Color(0xFF27AE60);
  static Color get chatUserBubbleEnd =>
      isDarkMode ? const Color(0xFF145C32) : const Color(0xFF1E8449);

  static Color get chatInputButtonDisabledStart =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  static Color get chatInputButtonDisabledEnd =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

  static Color get chatCardGradientStart =>
      isDarkMode ? const Color(0xFF38384A) : const Color(0xFFF4F6F9);
  static Color get chatCardGradientEnd =>
      isDarkMode ? const Color(0xFF222230) : const Color(0xFFE2E6F0);

  static Color get inspectionCardGradientEnd =>
      isDarkMode ? const Color(0xFF00E676) : const Color(0xFF00E676);
}
