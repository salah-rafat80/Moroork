import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/service_screen_appbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/dashboard_config.dart';
import '../cubits/examiner_cubit.dart';
import '../cubits/examiner_state.dart';
import '../widgets/applicant_test_card.dart';
import '../widgets/examiner_drawer.dart';
import 'applicant_test_details_screen.dart';
import 'package:traffic/injection_container.dart';
import 'package:traffic/features/auth/data/repositories/auth_repository.dart';

class DailyTestsScreen extends StatefulWidget {
  const DailyTestsScreen({super.key});

  @override
  State<DailyTestsScreen> createState() => _DailyTestsScreenState();
}

class _DailyTestsScreenState extends State<DailyTestsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DashboardConfig _config = DashboardConfig.fromRole('EXAMINATOR');
  bool _isLoading = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final roles = await getIt<AuthRepository>().getRoles();

    String priorityRole = 'EXAMINATOR';
    if (roles.contains('DOCTOR')) {
      priorityRole = 'DOCTOR';
    } else if (roles.contains('INSPECTOR')) {
      priorityRole = 'INSPECTOR';
    } else if (roles.contains('EXAMINATOR')) {
      priorityRole = 'EXAMINATOR';
    }

    setState(() {
      _config = DashboardConfig.fromRole(priorityRole);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightGreyBg,
        body: Center(
          child: CustomLoadingIndicator(color: AppColors.primary),
        ),
      );
    }

    return BlocProvider(
      create: (context) => getIt<ExaminerCubit>()..getAppointments(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const ExaminerDrawer(),
        backgroundColor: AppColors.lightGreyBg,
        body: SafeArea(
          child: Column(
            children: [
              ServiceScreenAppBar(
                title: _config.dashboardTitle,
                showBackButton: false,
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _config.listTitle,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 17.sp,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '', // Removed hardcoded date
                              style: TextStyle(
                                color: AppColors.mediumGrey,
                                fontSize: 12.sp,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        CustomTextField(
                          controller: _searchController,
                          hintText: _config.searchHint,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.greyIcon,
                            size: 24.r,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                        SizedBox(height: 16.h),
                        Expanded(
                          child: BlocBuilder<ExaminerCubit, ExaminerState>(
                            builder: (context, state) {
                              if (state is ExaminerLoading) {
                                return const Center(
                                  child: CustomLoadingIndicator(),
                                );
                              } else if (state is ExaminerFailure) {
                                return Center(child: Text(state.message));
                              } else if (state is ExaminerAppointmentsLoaded) {
                                final filteredList =
                                    state.appointments.where((appointment) {
                                  final query =
                                      _searchQuery.trim().toLowerCase();
                                  if (query.isEmpty) return true;

                                  final requestNo = appointment
                                          .requestNumberRelated
                                          ?.toLowerCase() ??
                                      '';
                                  final nationalId = appointment
                                          .citizenNationalId
                                          ?.toLowerCase() ??
                                      '';

                                  return requestNo.contains(query) ||
                                      nationalId.contains(query);
                                }).toList();

                                if (filteredList.isEmpty) {
                                  return Center(
                                    child: Text(_searchQuery.isEmpty
                                        ? 'لا توجد مواعيد اليوم'
                                        : 'لا توجد نتائج للبحث'),
                                  );
                                }
                                return ListView.separated(
                                  itemCount: filteredList.length,
                                  padding: EdgeInsets.only(bottom: 20.h),
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 16.h),
                                  itemBuilder: (context, index) {
                                    final appointment = filteredList[index];
                                    return ApplicantTestCard(
                                      orderNo:
                                          appointment.requestNumberRelated ??
                                          '-',
                                      applicantName:
                                          appointment.citizenNationalId ?? '-',
                                      time: appointment.displayTime,
                                      buttonText: _config.cardButtonText,
                                      requestNumberLabel: _config.requestNumberLabel,
                                      onViewDetails: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ApplicantTestDetailsScreen(
                                                  config: _config,
                                                  appointment: appointment,
                                                ),
                                          ),
                                        ).then((_) {
                                          if (context.mounted) {
                                            context.read<ExaminerCubit>().getAppointments();
                                          }
                                        });
                                      },
                                    );
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
