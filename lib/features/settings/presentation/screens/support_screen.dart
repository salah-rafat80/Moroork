import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/support_option_card.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا يمكن إتمام الإجراء على جهازك.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ غير متوقع.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBg,
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          ServiceScreenAppBar(
            title: "التواصل مع الدعم",
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    'نحن هنا لمساعدتك ,اختر طريقة التواصل المناسبة لك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 13.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SupportOptionCard(
                    title: 'الاتصال الهاتفي',
                    subtitle: '123456789098',
                    buttonText: 'اتصل الان',
                    onActionPressed: () => _launchURL('tel:123456789098'),
                  ),
                  SizedBox(height: 16.h),
                  SupportOptionCard(
                    title: 'البريد الالكتروني',
                    subtitle: 'moroork123@gmail.com',
                    buttonText: 'ارسال رسالة',
                    onActionPressed: () => _launchURL('mailto:moroork123@gmail.com'),
                  ),
                  SizedBox(height: 16.h),
                  SupportOptionCard(
                    title: 'الدردشة المباشرة',
                    buttonText: 'بدء المحادثة',
                    onActionPressed: () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('خاصية الدردشة المباشرة غير مفعلة حالياً.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
