// path: lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/home/presentation/widgets/home_header.dart';
import 'package:traffic/features/home/presentation/widgets/popular_services_section.dart';
import 'package:traffic/features/home/presentation/widgets/services_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HomeHeader(),
            SizedBox(height: 32.h),
            const PopularServicesSection(),
            SizedBox(height: 25.h),
            const ServicesSection(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
