import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:traffic/core/constants/app_sizes.dart';
import 'package:traffic/features/auth/presentation/screens/login_screen/login_screen.dart';
import 'package:traffic/features/auth/presentation/screens/signup_screen/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/Hello-rafiki (2) 1.svg",
      "title": "مرحباً بك في منصة مرورنا الذكية",
    },
    {
      "image": "assets/Payment Information-rafiki (4) 1.svg",
      "title": "استعلام ودفع المخالفات بسهولة",
    },
    {
      "image": "assets/Schedule-rafiki 2.svg",
      "title": "احجز (كشف طبي - اختبار قيادة)",
    },
    {
      "image": "assets/Chat bot-rafiki (1) 1.svg",
      "title": "مساعدك الشخصي لخدمات المرور",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final horizontalPadding = context.isLargeScreen
        ? 48.w
        : (context.isTablet ? 32.w : 16.w);
    final logoHeight = context.isTablet ? 50.r : 40.r;
    final maxContentWidth = context.isLargeScreen
        ? AppSizes.maxContentWidth
        : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              SizedBox(
                width: logoHeight * 2,
                height: logoHeight,
                child: Image.asset('assets/logo.png', fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    // Spacer at top
                    SizedBox(height: context.isSmallHeight ? 16.h : 32.h),

                    // Image PageView
                    Expanded(
                      flex: context.isSmallHeight ? 4 : 5,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _onboardingData.length,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemBuilder: (context, index) {
                          return OnboardingPage(
                            imageData: _onboardingData[index],
                          );
                        },
                      ),
                    ),

                    SizedBox(height: context.isSmallHeight ? 16.h : 24.h),

                    // Title
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.isTablet ? 24.w : 16.w,
                      ),
                      child: Text(
                        _onboardingData[_currentPage]['title']!,
                        style: TextStyle(
                          fontSize: context.isLargeScreen
                              ? 25.sp
                              : (context.isTablet ? 22.sp : 20.sp),
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: context.isSmallHeight ? 16.h : 24.h),

                    // Page Indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _onboardingData.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Theme.of(context).colorScheme.primary,
                        dotColor: AppColors.lightGreyBorder,
                        dotHeight: context.isTablet ? 8.r : 6.r,
                        dotWidth: context.isTablet ? 8.r : 6.r,
                        spacing: context.isTablet ? 6.w : 5.w,
                        expansionFactor: context.isTablet ? 3 : 2.5,
                      ),
                    ),

                    SizedBox(height: context.isSmallHeight ? 24.h : 40.h),

                    // Create Account Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: context.isTablet ? 20.h : 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'إنشاء حساب',
                          style: TextStyle(
                            fontSize: context.isTablet ? 20.sp : 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: context.isSmallHeight ? 16.h : 24.h),

                    // Login Row
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4.w,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            minimumSize: Size(0, 30.h),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'تسجيل دخول',
                            style: TextStyle(
                              fontSize: context.isTablet ? 17.sp : 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Text(
                          'لديك حساب بالفعل ؟',
                          style: TextStyle(
                            fontSize: context.isTablet ? 17.sp : 15.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    // Help Button
                    SizedBox(height: context.isSmallHeight ? 16.h : 24.h),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final Map<String, String>? imageData;

  const OnboardingPage({super.key, this.imageData});

  @override
  Widget build(BuildContext context) {
    final imagePadding = context.isTablet ? 40.w : 32.w;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: imagePadding),
        child: SvgPicture.asset(
          imageData!['image']!,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
