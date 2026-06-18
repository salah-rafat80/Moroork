import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/features/payment/screens/payment_method_screen.dart';
import 'package:traffic/core/features/payment/models/payment_intent.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/empty_state_widget.dart';
import 'package:traffic/features/vehicle_license/violations_inquiry/data/models/vehicle_license_violation_model.dart';
import 'package:traffic/features/violations_inquiry/data/models/violation_model.dart';
import 'package:traffic/features/violations_inquiry/presentation/cubits/violations_cubit.dart';
import 'package:traffic/features/violations_inquiry/presentation/cubits/violations_state.dart';
import 'package:traffic/features/violations_inquiry/presentation/screens/violation_details_screen.dart';
import 'package:traffic/features/violations_inquiry/presentation/screens/violation_review_screen.dart';
import 'package:traffic/features/violations_inquiry/presentation/widgets/violation_filter_tabs.dart';
import 'package:traffic/features/violations_inquiry/presentation/widgets/violation_list_item.dart';
import 'package:traffic/features/violations_inquiry/presentation/widgets/violations_summary_card.dart';
import 'package:traffic/injection_container.dart';

/// Step 2 – Violations list screen for vehicle licenses.
/// Mirrors [ViolationsListScreen] from the driving-license violations flow but
/// uses the vehicle-license app bar title, section heading, and licenseType=Vehicle.
class VehicleViolationsListScreen extends StatelessWidget {
  final VehicleLicenseViolationModel vehicle;

  const VehicleViolationsListScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ViolationsCubit>()
        ..loadVehicleLicenseViolations(
          licenseNumber: vehicle.vehicleLicenseNumber,
        ),
      child: _VehicleViolationsListView(vehicle: vehicle),
    );
  }
}

class _VehicleViolationsListView extends StatefulWidget {
  final VehicleLicenseViolationModel vehicle;

  const _VehicleViolationsListView({required this.vehicle});

  @override
  State<_VehicleViolationsListView> createState() =>
      _VehicleViolationsListViewState();
}

class _VehicleViolationsListViewState
    extends State<_VehicleViolationsListView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showPaid = false;
  final Set<String> _selectedViolationIds = {};

  List<ViolationModel> _getFiltered(List<ViolationModel> all) =>
      all.where((v) => v.isPaid == _showPaid).toList();



  double _selectedAmount(List<ViolationModel> all) => all
      .where((v) => !v.isPaid && _selectedViolationIds.contains(v.id))
      .fold(0, (sum, v) => sum + v.amount);

  int get _selectedCount => _selectedViolationIds.length;

  void _toggleSelection(ViolationModel violation, bool selected) {
    setState(() {
      if (selected) {
        _selectedViolationIds.add(violation.id);
      } else {
        _selectedViolationIds.remove(violation.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ViolationsCubit, ViolationsState>(
      listener: (context, state) {
        if (state is ViolationsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final List<ViolationModel> allViolations = state is ViolationsLoaded
            ? state.violationsList.violations
            : [];
        final filtered = _getFiltered(allViolations);
        final totalAmt = state is ViolationsLoaded ? state.violationsList.totalPayableAmount : 0.0;
        final selAmt = _selectedAmount(allViolations);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: const AppDrawer(),
          body: Column(
            children: [
              ServiceScreenAppBar(
                title: 'استعلام عن مخالفات رخصة المركبة',
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              SizedBox(height: 5.h),

              Expanded(
                child: _buildBody(
                  context: context,
                  state: state,
                  allViolations: allViolations,
                  filtered: filtered,
                  totalAmt: totalAmt,
                ),
              ),

              // ── Bottom pay button (only for unpaid tab) ──
              if (!_showPaid && state is ViolationsLoaded)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    child: PrimaryButton(
                      label: _selectedCount > 0
                          ? 'سداد $_selectedCount مخالفات  (${selAmt.toInt()} جنية)'
                          : 'سداد المخالفات',
                      onPressed: _selectedCount > 0
                          ? () {
                              final selected = allViolations
                                  .where(
                                    (v) => _selectedViolationIds.contains(v.id),
                                  )
                                  .toList();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ViolationReviewScreen(
                                    selectedViolations: selected,
                                    onNext: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => PaymentMethodScreen(
                                            paymentIntent: PaymentIntent(
                                              orderType: 'مخالفات رخصة المركبة',
                                              amount: selAmt,
                                              currency: 'جنية مصري',
                                              violationIds: selected.map((v) => v.violationId).toList(),
                                            ),
                                          ),
                                      ),
                                    ),
                                    onEdit: () => Navigator.pop(context),
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required ViolationsState state,
    required List<ViolationModel> allViolations,
    required List<ViolationModel> filtered,
    required double totalAmt,
  }) {
    if (state is ViolationsLoading) {
      return const Center(child: CustomLoadingIndicator());
    }

    if (state is ViolationsFailure && allViolations.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
              SizedBox(height: 12.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 15.sp),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  context.read<ViolationsCubit>().loadVehicleLicenseViolations(
                    licenseNumber: widget.vehicle.vehicleLicenseNumber,
                  );
                },
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final lastUpdate = '${now.day}/${now.month}/${now.year}';

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ViolationsCubit>().loadVehicleLicenseViolations(
              licenseNumber: widget.vehicle.vehicleLicenseNumber,
            );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 16.h),
            Text(
              'مخالفات رخصة المركبة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: 16.h),
            ViolationsSummaryCard(
              totalViolations: allViolations.length,
              totalAmount: totalAmt,
              lastUpdate: lastUpdate,
            ),
            SizedBox(height: 16.h),
            ViolationFilterTabs(
              showPaid: _showPaid,
              onChanged: (val) => setState(() {
                _showPaid = val;
                _selectedViolationIds.clear();
              }),
            ),
            SizedBox(height: 16.h),
            if (filtered.isEmpty)
              const EmptyStateWidget(
                message: 'لا توجد مخالفات مسجلة حالياً',
              )
            else
              ...filtered.map(
                (violation) => ViolationListItem(
                  violation: violation,
                  isSelected: _selectedViolationIds.contains(violation.id),
                  onSelect: (selected) => _toggleSelection(violation, selected),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ViolationDetailsScreen(violation: violation),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
