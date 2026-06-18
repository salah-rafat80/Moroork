// path: lib/features/home/data/home_mock_data.dart
import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';

class HomeMockData {
  static final List<Map<String, dynamic>> popularServices = [
    {
      'title': 'استعلام عن\nمخالفات',
      'icon': Icons.search,
      'color': AppColors.successLight, // Light Green
    },
    {
      'title': 'تجديد رخصة\nقيادة',
      'icon': Icons.assignment_ind_outlined,
      'color': AppColors.successLight,
    },
    {
      'title':
          'تجديد رخصة\nمركبة', // Added for variety based on scroll potential
      'icon': Icons.directions_car_outlined,
      'color': AppColors.successLight,
    },
  ];

  static final List<Map<String, dynamic>> mainServices = [
    {
      'title': 'رخصة القيادة',
      'icon': Icons.assignment_ind_outlined,
      'route': '/driving-license',
    },
    {
      'title': 'رخصة المركبة',
      'icon': Icons.directions_car_outlined,
      'route': '/vehicle-license',
    },
  ];

  static final Map<String, dynamic> smartAssistant = {
    'title': 'المساعد الذكي',
    'icon': Icons.auto_awesome, // Sparkles icon closest to "Smart"
  };
}
