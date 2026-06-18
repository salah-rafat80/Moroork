// path: lib/features/home/presentation/screens/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traffic/features/home/presentation/screens/home_screen.dart';
import 'package:traffic/features/profile/presentation/profile_screen.dart';
import 'package:traffic/features/orders/presentation/my_orders_screen.dart';
import 'package:traffic/features/orders/presentation/cubits/my_orders_cubit.dart';
import 'package:traffic/features/settings/presentation/screens/settings_screen.dart';
import 'package:traffic/injection_container.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 3});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late MyOrdersCubit _myOrdersCubit;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _myOrdersCubit = getIt<MyOrdersCubit>();
    
    _screens = [
      const ProfileScreen(),
      const SettingsScreen(),
      BlocProvider.value(
        value: _myOrdersCubit,
        child: const MyOrdersScreen(),
      ),
      const HomeScreen(),
    ];

    if (_currentIndex == 2) {
      _myOrdersCubit.fetchMyOrders();
    }
  }

  @override
  void dispose() {
    _myOrdersCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBg,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 2) {
            _myOrdersCubit.fetchMyOrders();
          }
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.slateGrey,
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/profile.svg"),
              activeIcon: SvgPicture.asset("assets/profile_G.svg"),
              label: 'حسابي',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/settings.svg"),
              activeIcon: SvgPicture.asset("assets/settings_G.svg"),
              label: 'الاعدادات',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/order.svg"),
              activeIcon: SvgPicture.asset("assets/order_G.svg"),
              label: 'طلباتي',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/home.svg"),
              activeIcon: SvgPicture.asset("assets/home_G.svg"),
              label: 'الصفحة الرئيسية',
            ),
          ],
        ),
      ),
    );
  }
}
