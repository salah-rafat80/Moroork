import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';

enum OfficerRole {
  examinator, // Practical Test
  doctor,     // Medical Check
  inspector   // Technical Inspection
}

class DashboardConfig {
  final String dashboardTitle;
  final String listTitle;
  final String cardButtonText;
  final String detailsTitle;
  final String typeTagText;
  final Color typeTagColor;
  final String passButtonText;
  final String failButtonText;
  final String searchHint;
  final String applicantDetailsLabel;
  final String resultConfirmationTitle;
  final String testTypeLabel;
  final String requestNumberLabel;

  DashboardConfig({
    required this.dashboardTitle,
    required this.listTitle,
    required this.cardButtonText,
    required this.detailsTitle,
    required this.typeTagText,
    required this.typeTagColor,
    required this.passButtonText,
    required this.failButtonText,
    required this.searchHint,
    required this.applicantDetailsLabel,
    required this.resultConfirmationTitle,
    required this.testTypeLabel,
    required this.requestNumberLabel,
  });

  factory DashboardConfig.fromRole(String role) {
    switch (role) {
      case 'DOCTOR':
        return DashboardConfig(
          dashboardTitle: 'الكشف الطبي',
          listTitle: 'الكشوفات الطبية اليوم',
          cardButtonText: 'تسجيل النتيجة',
          detailsTitle: 'تسجيل الكشف الطبي',
          typeTagText: 'كشف طبي',
          typeTagColor: AppColors.alertAmber, // Orange
          passButtonText: 'لائق طبياً',
          failButtonText: 'غير لائق طبياً',
          searchHint: 'بحث برقم الكشف أو الرقم القومي',
          applicantDetailsLabel: 'تفاصيل الحالة الطبية',
          resultConfirmationTitle: 'هل أنت متأكد من تسجيل نتيجة الكشف؟',
          testTypeLabel: 'نوع الكشف',
          requestNumberLabel: 'رقم الكشف',
        );
      case 'INSPECTOR':
        return DashboardConfig(
          dashboardTitle: 'الفحص الفني',
          listTitle: 'الفحوصات الفنية اليوم',
          cardButtonText: 'عرض التفاصيل',
          detailsTitle: 'تفاصيل المتقدم للفحص',
          typeTagText: 'فحص فني',
          typeTagColor: AppColors.themeBlue, // Blue
          passButtonText: 'سليم',
          failButtonText: 'غير سليم',
          searchHint: 'بحث برقم الطلب أو اللوحة',
          applicantDetailsLabel: 'تفاصيل المركبة والمتقدم',
          resultConfirmationTitle: 'هل أنت متأكد من تسجيل نتيجة الفحص؟',
          testTypeLabel: 'نوع الفحص',
          requestNumberLabel: 'رقم الفحص',
        );
      case 'EXAMINATOR':
      default:
        return DashboardConfig(
          dashboardTitle: 'اختبار القيادة العملي',
          listTitle: 'الاختبارات العملية اليوم',
          cardButtonText: 'تسجيل النتيجة',
          detailsTitle: 'تسجيل نتيجة الاختبار',
          typeTagText: 'اختبار قيادة عملي',
          typeTagColor: AppColors.purpleAccent, // Purple
          passButtonText: 'ناجح',
          failButtonText: 'راسب',
          searchHint: 'بحث برقم الطلب أو الرقم القومي',
          applicantDetailsLabel: 'تفاصيل المتقدم للاختبار',
          resultConfirmationTitle: 'هل أنت متأكد من تسجيل نتيجة الاختبار؟',
          testTypeLabel: 'نوع الاختبار',
          requestNumberLabel: 'رقم الطلب',
        );
    }
  }
}
