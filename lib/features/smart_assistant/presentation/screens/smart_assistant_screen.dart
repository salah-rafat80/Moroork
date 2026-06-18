import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/smart_assistant/presentation/screens/smart_assistant_chat_screen.dart';
import 'package:traffic/features/vehicle_inspection/presentation/screens/vehicle_inspection_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/premium_service_card.dart';
import '../widgets/pulsing_ai_hero.dart';
import '../widgets/smart_assistant_background_blobs.dart';

class SmartAssistantScreen extends StatefulWidget {
  const SmartAssistantScreen({super.key});

  @override
  State<SmartAssistantScreen> createState() => _SmartAssistantScreenState();
}

class _SmartAssistantScreenState extends State<SmartAssistantScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  late AnimationController _entranceController;
  late Animation<Offset> _slideAnimation1;
  late Animation<Offset> _slideAnimation2;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Glow Animation for the Hero Robot
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 4.0, end: 20.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Entrance Animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _slideAnimation1 = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _slideAnimation2 = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          const SmartAssistantBackgroundBlobs(),
          SafeArea(
            child: Column(
              children: [
                ServiceScreenAppBar(
                  title: 'المساعد الذكي',
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 30.h),
                        PulsingAiHero(glowAnimation: _glowAnimation),
                        SizedBox(height: 32.h),

                        // Title & Subtitle
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                'كيف يمكنني مساعدتك اليوم؟',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'خدمة ذكية مخصصة للإجابة على استفساراتك المرورية وفحص مركبتك باستخدام أحدث تقنيات الذكاء الاصطناعي.',
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h),

                        // Action Cards
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation1,
                            child: PremiumServiceCard(
                              title: 'محادثة المساعد الذكي',
                              subtitle: 'إجابات فورية لكل أسئلتك واحتياجاتك',
                              iconWidget: SvgPicture.asset(
                                'assets/ai_robot.svg',
                                width: 30.w,
                                height: 30.w,
                              ),
                              gradientColors: [
                                AppColors.chatCardGradientStart,
                                AppColors.chatCardGradientEnd,
                              ],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SmartAssistantChatScreen(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation2,
                            child: PremiumServiceCard(
                              title: 'فحص المركبة الذكي',
                              subtitle: 'تحليل دقيق للأعطال بالكاميرا',
                              iconWidget: SvgPicture.asset(
                                'assets/search.svg',
                                width: 30.w,
                                height: 30.w,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              gradientColors: [
                                AppColors.primary,
                                AppColors.inspectionCardGradientEnd,
                              ],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const VehicleInspectionScreen(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
