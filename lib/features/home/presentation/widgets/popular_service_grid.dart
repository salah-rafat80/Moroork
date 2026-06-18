// path: lib/features/home/presentation/widgets/popular_service_grid.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/driving_license/presentation/screens/driving_license_screen.dart';
import 'package:traffic/features/home/presentation/widgets/popular_service_item.dart';
import 'package:traffic/features/vehicle_license/presentation/screens/vehicle_license_screen.dart';
import 'package:traffic/features/violations_inquiry/presentation/screens/select_license_screen.dart';

class PopularServiceGrid extends StatefulWidget {
  const PopularServiceGrid({super.key});

  @override
  State<PopularServiceGrid> createState() => _PopularServiceGridState();
}

class _PopularServiceGridState extends State<PopularServiceGrid> {
  late final ScrollController _scrollController;
  Timer? _scrollTimer;
  Timer? _resumeTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final itemWidth = 135.w;
        final separatorWidth = 10.w;
        final oneSetWidth = 4 * (itemWidth + separatorWidth);
        _scrollController.jumpTo(oneSetWidth);
      }
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_scrollController.hasClients) return;
      if (_isUserInteracting) return;

      final currentOffset = _scrollController.offset;
      final itemWidth = 135.w;
      final separatorWidth = 10.w;
      final oneSetWidth = 4 * (itemWidth + separatorWidth);

      // Decrement scroll offset by 0.6 pixels for a reverse marquee effect (scrolling opposite direction)
      double nextOffset = currentOffset - 0.6;

      // Wrap-around logic: when dropping below oneSetWidth, wrap forward by oneSetWidth
      if (nextOffset <= oneSetWidth) {
        nextOffset += oneSetWidth;
        _scrollController.jumpTo(nextOffset);
      } else {
        _scrollController.jumpTo(nextOffset);
      }
    });
  }

  void _onUserInteractionStart() {
    _isUserInteracting = true;
    _resumeTimer?.cancel();
  }

  void _onUserInteractionEnd() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isUserInteracting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = [
      _ServiceData(
        title: 'استعلام عن\nمخالفات',
        icon: "assets/file.svg",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SelectLicenseScreen()),
        ),
      ),
      _ServiceData(
        title: 'تجديد رخصة\nقيادة',
        icon: "assets/license.svg",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DrivingLicenseScreen(startWithRenewal: true),
          ),
        ),
      ),
      _ServiceData(
        title: 'تجديد رخصة\nمركبة',
        icon: "assets/car.svg",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const VehicleLicenseScreen(startWithRenewal: true),
          ),
        ),
      ),
      _ServiceData(
        title: 'سداد مخالفة\n رخصة القيادة',
        icon: "assets/payment.svg",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SelectLicenseScreen()),
        ),
      ),
    ];

    // Repeat original 4 items 3 times for a seamless infinite loop
    final repeatedServices = [...services, ...services, ...services];

    return Listener(
      onPointerDown: (_) => _onUserInteractionStart(),
      onPointerUp: (_) => _onUserInteractionEnd(),
      onPointerCancel: (_) => _onUserInteractionEnd(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            final offset = _scrollController.offset;
            final itemWidth = 135.w;
            final separatorWidth = 10.w;
            final oneSetWidth = 4 * (itemWidth + separatorWidth);

            // Manual wrap-around limits with a 50px buffer to prevent feedback loop:
            if (offset >= 2 * oneSetWidth + 50) {
              _scrollController.jumpTo(offset - oneSetWidth);
            } else if (offset <= oneSetWidth - 50) {
              _scrollController.jumpTo(offset + oneSetWidth);
            }
          }
          return false;
        },
        child: SizedBox(
          height: 90.h,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: repeatedServices.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final item = repeatedServices[index];
              return SizedBox(
                width: 135.w,
                // height: 100.h,
                child: PopularServiceItem(
                  title: item.title,
                  icon: item.icon,
                  onTap: item.onTap,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ServiceData {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const _ServiceData({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
