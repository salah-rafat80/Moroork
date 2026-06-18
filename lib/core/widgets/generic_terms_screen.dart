import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/features/auth/presentation/screens/signup_screen/widgets/signup_step1_form/widgets/next_button_widget.dart';
import 'package:traffic/features/driving_license/presentation/screens/terms_and_conditions/widgets/agreement_checkbox.dart';
import 'package:traffic/features/driving_license/presentation/screens/terms_and_conditions/widgets/custom_expansion_tile.dart';

// ── Terms data model ──────────────────────────────────────────────────────────

/// Holds the data for a single Terms & Conditions section.
class TermsSection {
  final String title;
  final String content;
  final IconData iconData;

  const TermsSection({
    required this.title,
    required this.content,
    required this.iconData,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// **Generic Terms & Conditions** screen.
///
/// Displays collapsible sections using [CustomExpansionTile]. The primary
/// action button ("التالي") is disabled until the user checks the agreement
/// checkbox.
///
/// State is kept local ([StatefulWidget]) until a Cubit is introduced.
class GenericTermsScreen extends StatefulWidget {
  final String appBarTitle;
  final String subtitle;
  final String? disclaimer; // Optional secondary lighter text
  final List<TermsSection> termsData;
  final VoidCallback onNextPressed;
  final bool isLoading;
  final String buttonLabel;

  const GenericTermsScreen({
    super.key,
    required this.appBarTitle,
    required this.subtitle,
    this.disclaimer,
    required this.termsData,
    required this.onNextPressed,
    this.isLoading = false,
    this.buttonLabel = 'التالي',
  });

  @override
  State<GenericTermsScreen> createState() => _GenericTermsScreenState();
}

class _GenericTermsScreenState extends State<GenericTermsScreen> {
  /// Whether the user has agreed to the terms.
  bool _isAgreed = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _onAgreementChanged(bool value) {
    setState(() => _isAgreed = value);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ── App bar ──────────────────────────────────────────────────────
          ServiceScreenAppBar(
            title: widget.appBarTitle,
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),

          // ── Scrollable body ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.h),

                  // ── Section header ────────────────────────────────────────
                  Text(
                    'الشروط والأحكام',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // ── Sub-title ─────────────────────────────────────────────
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 14.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (widget.disclaimer != null) ...[
                    SizedBox(height: 8.h),

                    // ── Disclaimer ────────────────────────────────────────────
                    Text(
                      widget.disclaimer!,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 12.sp,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                  ],

                  SizedBox(height: 16.h),

                  // ── Expansion tiles container ──────────────────────────────
                  Container(
                    decoration: ShapeDecoration(
                      color: AppColors.cardBg,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.w,
                          color: AppColors.greyBorder,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.r),
                      child: Column(children: _buildTileList()),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Agreement checkbox ─────────────────────────────────────
                  AgreementCheckbox(
                    isAgreed: _isAgreed,
                    onChanged: _onAgreementChanged,
                  ),

                  SizedBox(height: 16.h),

                  // ── Primary action button ──────────────────────────────────
                  NextButtonWidget(
                    onPressed: widget.onNextPressed,
                    isValid: _isAgreed,
                    height: 48.h,
                    isLoading: widget.isLoading,
                    label: widget.buttonLabel,
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Builds the list of [CustomExpansionTile] widgets separated by dividers.
  List<Widget> _buildTileList() {
    final List<Widget> tiles = [];

    for (int i = 0; i < widget.termsData.length; i++) {
      final section = widget.termsData[i];

      tiles.add(
        CustomExpansionTile(
          title: section.title,
          content: section.content,
          icon: Icon(
            section.iconData,
            color: AppColors.primary,
            size: 22.r,
          ),
        ),
      );

      // Add divider between tiles (not after the last one)
      if (i < widget.termsData.length - 1) {
        tiles.add(
          Divider(
            height: 1.h,
            thickness: 1.h,
            color: AppColors.greyBorder,
            indent: 12.w,
            endIndent: 12.w,
          ),
        );
      }
    }

    return tiles;
  }
}
