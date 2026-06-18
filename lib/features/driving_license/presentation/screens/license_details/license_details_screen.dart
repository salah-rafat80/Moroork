import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/auth/presentation/screens/signup_screen/widgets/signup_step1_form/widgets/next_button_widget.dart';
import 'package:traffic/features/driving_license/domain/enums/license_status.dart';
import 'package:traffic/features/driving_license/data/models/driving_license_model.dart';
import 'package:traffic/features/violations_inquiry/presentation/screens/violations_list_screen.dart';
import 'package:traffic/features/violations_inquiry/data/repositories/violations_repository.dart';
import 'package:traffic/features/driving_license/data/repositories/driving_license_repository.dart';
import 'license_details_confirmation_screen.dart';
import 'widgets/license_info_card.dart';
import 'widgets/warning_banner.dart';
import 'package:traffic/injection_container.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

/// **Licence Selection Screen** — shown after the user agrees to terms.
///
/// Lists all driving licences for the current user. The user selects the
/// licence they wish to renew. Selection rules:
///
/// | Status               | Selectable | "التالي" state                 |
/// |----------------------|------------|-------------------------------|
/// | valid                | ✅          | Active → proceeds to next step |
/// | expired, no violations | ✅        | Active → proceeds to next step |
/// | expired, with violations | ✅      | Disabled (pay violations first)|
/// | withdrawn            | ❌          | N/A — card is disabled        |
class LicenseDetailsScreen extends StatefulWidget {
  final Future<void> Function(DrivingLicenseModel selectedLicense)?
  onNextWithSelectedLicense;

  const LicenseDetailsScreen({super.key, this.onNextWithSelectedLicense});

  @override
  State<LicenseDetailsScreen> createState() => _LicenseDetailsScreenState();
}

class _LicenseDetailsScreenState extends State<LicenseDetailsScreen> {
  /// List of licences loaded from the repository.
  List<DrivingLicenseModel> _licenses = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  /// Index of the currently selected licence, or `null` if none selected.
  int? _selectedIndex;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  Future<void> _loadLicenses() async {
    setState(() => _isLoading = true);
    try {
      final repository = getIt<DrivingLicenseRepository>();

      // Always fetch fresh from API
      final result = await repository.getMyLicenses();

      if (result.isSuccess && result.data != null) {
        final licenses = result.data!;
        final violationsRepo = getIt<ViolationsRepository>();
        final List<DrivingLicenseModel> updatedLicenses = [];

        for (var license in licenses) {
          final violationsResult = await violationsRepo.getDrivingLicenseViolations(
            licenseNumber: license.drivingLicenseNumber,
          );
          if (violationsResult.isSuccess && violationsResult.data != null) {
            final unpaidCount = violationsResult.data!.unpaidCount;
            license = license.copyWith(hasUnpaidViolations: unpaidCount > 0);
          }
          updatedLicenses.add(license);
        }

        setState(() {
          _licenses = updatedLicenses;
          _isLoading = false;
          if (_licenses.length == 1) {
            _selectedIndex = 0;
          } else {
            _selectedIndex = null;
          }
        });
      } else {
        setState(() {
          _licenses = [];
          _isLoading = false;
          _selectedIndex = null;
        });
        // Show error if needed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.error ?? 'فشل في تحميل الرخص')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _licenses = [];
        _isLoading = false;
        _selectedIndex = null;
      });
    }
  }

  // ── Derived state ──────────────────────────────────────────────────────────

  DrivingLicenseModel? get _selectedLicense =>
      _selectedIndex != null ? _licenses[_selectedIndex!] : null;

  /// The "التالي" button is active only when a licence is selected AND it has
  /// no unpaid violations (withdrawn licences cannot be selected at all).
  bool get _canProceed {
    final lic = _selectedLicense;
    if (lic == null) return false;
    return !lic.hasUnpaidViolations;
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _onCardTap(int index) {
    final lic = _licenses[index];
    if (lic.status == LicenseStatus.withdrawn) return; // not selectable
    setState(() => _selectedIndex = index);
  }

  Future<void> _onNextPressed() async {
    final lic = _selectedLicense;
    if (lic == null) return;
    if (_isSubmitting) return;

    final Future<void> Function(DrivingLicenseModel selectedLicense)? callback =
        widget.onNextWithSelectedLicense;
    if (callback != null) {
      setState(() => _isSubmitting = true);
      try {
        await callback(lic);
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LicenseDetailsConfirmationScreen(license: lic),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              // ── App bar ──────────────────────────────────────────────────────
              ServiceScreenAppBar(
                title: 'تجديد رخصة القيادة',
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),

              // ── Scrollable licence list ───────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(child: CustomLoadingIndicator())
                    : _licenses.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد رخص قيادة مسجلة',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ── Section header ────────────────────────────────────────
                                  Text(
                                    'تفاصيل رخصة القيادة',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),

                                  SizedBox(height: 12.h),

                                  // ── Licence cards ─────────────────────────────────────────
                                  ..._licenses.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final lic = entry.value;
                                    final bool isWithdrawn =
                                        lic.status == LicenseStatus.withdrawn;
                                    final bool isSelected = _selectedIndex == index;

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 12.h),
                                      child: _SelectableLicenseCard(
                                        data: lic,
                                        isSelected: isSelected,
                                        isDisabled: isWithdrawn,
                                        onTap: () => _onCardTap(index),
                                        onViewViolationsTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ViolationsListScreen(license: lic),
                                            ),
                                          ).then((_) => _loadLicenses());
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                            child: NextButtonWidget(
                              onPressed: () => _onNextPressed(),
                              isValid: _canProceed && !_isSubmitting,
                              height: 48.h,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          if (_isSubmitting)
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.blackOverlay,
                child: const Center(child: CustomLoadingIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Selectable card widget ────────────────────────────────────────────────────

/// A tappable wrapper around [LicenseInfoCard] that shows a selected border
/// and conditionally renders the [WarningBanner].
///
/// When [isDisabled] is `true` (withdrawn licence), the card is dimmed and
/// ignores taps.
class _SelectableLicenseCard extends StatelessWidget {
  final DrivingLicenseModel data;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;
  final VoidCallback? onViewViolationsTap;

  const _SelectableLicenseCard({
    required this.data,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
    this.onViewViolationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Info card ─────────────────────────────────────────────────
            LicenseInfoCard(data: data, isSelected: isSelected),

            // ── Warning banner (shown below card when violations exist) ──
            if (isSelected && data.hasUnpaidViolations) ...[
              SizedBox(height: 12.h),
              WarningBanner(
                license: data,
                onViewViolationsTap: onViewViolationsTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
