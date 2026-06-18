import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/injection_container.dart';
import 'package:traffic/features/home/bloc/home_search_bloc.dart';
import 'package:traffic/features/home/bloc/home_search_event_state.dart';
import 'package:traffic/features/home/presentation/widgets/home_search_field.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _GreenBackground(),
        Positioned(
          bottom: 20.h,
          left: 20.w,
          right: 20.w,
          child: BlocProvider<HomeSearchBloc>(
            create: (_) =>
                getIt<HomeSearchBloc>()..add(const SearchQueryChanged('')),
            child: const HomeSearchField(),
          ),
        ),
      ],
    );
  }
}

class _GreenBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.h,
      width: double.infinity,
      color: AppColors.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                  stops: [0.8, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.primary, AppColors.background],
                            stops: [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 260.h,
                    width: 200.w,
                    child: Image.asset(
                      'assets/image_6__1_-removebg-preview.png',
                      width: double.infinity,
                      height: 200.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 52.h,
            right: 20.w,
            left: 20.w,
            child: Text(
              'كل خدمات المرور\nفي مكان واحد',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
