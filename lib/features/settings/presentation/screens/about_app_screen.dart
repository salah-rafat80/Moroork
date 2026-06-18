import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/settings/presentation/widgets/about_info_card.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBg,
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          ServiceScreenAppBar(
            title: 'عن التطبيق',
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  'تطبيق المرور هو التطبيق الرسمي للإدارة العامة للمرور في جمهورية مصر العربية .\nيوفر التطبيق مجموعة شاملة من الخدمات الإلكترونية التي تسهل على المواطنين والمقيمين إتمام معاملاتهم المرورية بكل سهولة ويسر.',
                  textAlign: TextAlign.start,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 13.sp,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 24.h),
                const AboutInfoCard(
                  title: 'رؤيتنا',
                  content:
                      'تقديم خدمات مرورية متميزة ومتطورة تواكب رؤية المملكة 2030، من خلال التحول الرقمي وتسهيل الإجراءات للمستفيدين.',
                ),
                SizedBox(height: 16.h),
                const AboutInfoCard(
                  title: 'قيمنا',
                  content:
                      '• الشفافية والمصداقية\n• الجودة والتميز\n• الأمان والخصوصية\n• التطوير المستمر',
                ),
                SizedBox(height: 16.h),
                const AboutInfoCard(
                  title: 'تواصل معنا',
                  content:
                      'الهاتف: 920003344\nالبريد الإلكتروني: moroork123@gmail.com',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
