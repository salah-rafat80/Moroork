import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/profile/presentation/widgets/profile_header.dart';
import 'package:traffic/features/settings/presentation/screens/about_app_screen.dart';
import 'package:traffic/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:traffic/features/settings/presentation/screens/terms_of_use_screen.dart';
import 'package:traffic/features/settings/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:traffic/features/smart_assistant/presentation/screens/smart_assistant_chat_screen.dart';

import '../widgets/theme_selection_card.dart';
import '../widgets/logout_button.dart';
import '../widgets/settings_menu_item.dart';
import 'faq_screen.dart';
import 'support_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBg,

      body: Column(
        children: [
          const ProfileHeader(title: 'الاعدادات'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    'المساعدة والدعم',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(
                        color: AppColors.greyBorder,
                        width: 1.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 4.r,
                          offset: Offset(0, 1.h),
                        ),
                      ],
                    ),
                    child: Column(
                      textDirection: TextDirection.rtl,
                      children: [
                        SettingsMenuItem(
                          title: 'الاسئلة الشائعة',
                          icon: Icons.help_outline,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FaqScreen(),
                              ),
                            );
                          },
                        ),
                        SettingsMenuItem(
                          title: 'التواصل مع الدعم',
                          icon: Icons.call_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SupportScreen(),
                              ),
                            );
                          },
                        ),
                        SettingsMenuItem(
                          title: 'المساعد الذكي',
                          icon: Icons.smart_toy_outlined,
                          showDivider: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SmartAssistantChatScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  const ThemeSelectionCard(),
                  SizedBox(height: 24.h),
                  Text(
                    'عن التطبيق',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(
                        color: AppColors.greyBorder,
                        width: 1.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 4.r,
                          offset: Offset(0, 1.h),
                        ),
                      ],
                    ),
                    child: Column(
                      textDirection: TextDirection.rtl,
                      children: [
                        SettingsMenuItem(
                          title: 'عن التطبيق',
                          icon: Icons.info_outline,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutAppScreen(),
                              ),
                            );
                          },
                        ),
                        SettingsMenuItem(
                          title: 'شروط الاستخدام',
                          icon: Icons.article_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TermsOfUseScreen(),
                              ),
                            );
                          },
                        ),
                        SettingsMenuItem(
                          title: 'سياسة الخصوصية',
                          icon: Icons.lock_outline,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                        SettingsMenuItem(
                          title: 'اصدار التطبيق',
                          icon: Icons.qr_code_scanner_outlined,
                          trailingText: 'v1.2.4',
                          hideArrow: true,
                          showDivider: false,
                          onTap: () {
                            // TODO: Action for App Version
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  LogoutButton(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const LogoutConfirmationDialog(),
                      );
                    },
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
