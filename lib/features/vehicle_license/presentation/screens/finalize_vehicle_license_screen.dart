import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:traffic/core/features/checkout/generic_order_review_screen.dart';
import 'package:traffic/core/features/checkout/models/applicant_details.dart';
import 'package:traffic/core/features/checkout/models/fees_details.dart';
import 'package:traffic/core/features/checkout/models/order_summary.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/lost_license/presentation/widgets/custom_text_form_field.dart';
import 'package:traffic/features/lost_license/presentation/widgets/selection_option_card.dart';
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_license_cubit.dart';
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_license_state.dart';
import 'package:traffic/core/api/order_payment_cache.dart';

/// Delivery method picker for vehicle license issuance.
/// Works exactly like [FinalizeDrivingLicenseScreen] but wired to
/// [VehicleLicenseCubit] and [VehicleLicenseFinalizeSuccess].
class FinalizeVehicleLicenseScreen extends StatefulWidget {
  final String requestNumber;

  const FinalizeVehicleLicenseScreen({super.key, required this.requestNumber});

  @override
  State<FinalizeVehicleLicenseScreen> createState() =>
      _FinalizeVehicleLicenseScreenState();
}

class _FinalizeVehicleLicenseScreenState
    extends State<FinalizeVehicleLicenseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 1: TrafficUnit (pickup), 2: HomeDelivery (delivery)
  int? _deliveryMethod;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _governorateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressDetailsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<VehicleLicenseCubit>().currentRequestNumber =
        widget.requestNumber;
  }

  @override
  void dispose() {
    _governorateController.dispose();
    _cityController.dispose();
    _addressDetailsController.dispose();
    super.dispose();
  }

  void _onFinalize(BuildContext context) {
    if (_deliveryMethod == 2) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }

    context.read<VehicleLicenseCubit>().finalizeLicense(
      method: _deliveryMethod ?? 1,
      governorate: _deliveryMethod == 2
          ? _governorateController.text.trim()
          : null,
      city: _deliveryMethod == 2 ? _cityController.text.trim() : null,
      details: _deliveryMethod == 2
          ? _addressDetailsController.text.trim()
          : null,
    );
  }

  void _navigateToOrderReview(VehicleLicenseFinalizeSuccess state) async {
    final applicant = ApplicantDetails(
      name: state.profile.fullName,
      nationalId: state.profile.nationalId,
      phone: state.profile.phoneNumber,
      email: state.profile.email,
    );

    final String paymentMethodLabel = _deliveryMethod == 2
        ? 'التوصيل للعنوان'
        : 'الاستلام من وحدة المرور';

    // Prefer requestNumber from the API response (may differ from the one we sent).
    final String orderId = state.response.requestNumber.trim().isNotEmpty
        ? state.response.requestNumber
        : widget.requestNumber;

    final orderSummary = OrderSummary(
      orderType: 'إصدار رخصة مركبة',
      paymentMethod: paymentMethodLabel,
      orderId: orderId,
    );

    // Use real fees returned by the API.
    final feesPayload = state.response.fees;
    final double baseFee = feesPayload?.baseFee ?? 0;
    final double deliveryFee = feesPayload?.deliveryFee ?? 0;
    final double totalAmount = feesPayload?.totalAmount ?? 0;

    // Cache the payment details
    await OrderPaymentCache.save(
      orderId,
      OrderPaymentCachedData(
        baseFee: baseFee,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        paymentMethodLabel: paymentMethodLabel,
        orderType: 'إصدار رخصة مركبة',
      ),
    );

    final List<FeeItem> items = <FeeItem>[
      FeeItem(label: 'الرسوم الأساسية', amount: _formatCurrency(baseFee)),
    ];

    if (deliveryFee > 0) {
      items.add(
        FeeItem(label: 'رسوم التوصيل', amount: _formatCurrency(deliveryFee)),
      );
    }

    final fees = FeesDetails(items: items, total: _formatCurrency(totalAmount));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GenericOrderReviewScreen(
          appBarTitle: 'إصدار رخصة مركبة',
          applicantDetails: applicant,
          orderSummary: orderSummary,
          feesDetails: fees,
          serviceRequestNumber: orderId,
          paymentAmountOverride: totalAmount,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount == amount.truncateToDouble()) {
      return '${amount.toInt()} جنية مصري';
    }
    return '$amount جنية مصري';
  }

  String? _validateGovernorate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'برجاء إدخال اسم محافظة صحيح';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'برجاء إدخال اسم مدينة / مركز صحيح';
    }
    return null;
  }

  String? _validateAddressDetails(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'تعذر التحقق من العنوان…برجاء كتابة العنوان بشكل أوضح';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDelivery = _deliveryMethod == 2;
    final bool isButtonEnabled = _deliveryMethod != null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: BlocConsumer<VehicleLicenseCubit, VehicleLicenseState>(
        listener: (context, state) {
          if (state is VehicleLicenseFinalizeSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم حفظ طريقة الاستلام بنجاح. المرجو استكمال الدفع.',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
                ),
                backgroundColor: AppColors.primary,
              ),
            );
            _navigateToOrderReview(state);
          } else if (state is VehicleLicenseFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state is VehicleLicenseLoading;

          return Column(
            children: [
              ServiceScreenAppBar(
                title: 'استكمال الطلب',
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'طريقة استلام الرخصة',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SelectionOptionCard(
                          title: 'استلام من وحدة المرور',
                          subtitle:
                              'استلم الرخصة شخصيًا من وحدة المرور التي تم تسجيلها في بياناتك',
                          isSelected: _deliveryMethod == 1,
                          onTap: () => setState(() => _deliveryMethod = 1),
                          icon: SvgPicture.asset(
                            'assets/tabler_building-bank.svg',
                            width: 24.w,
                            height: 24.w,
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SelectionOptionCard(
                          title: 'التوصيل للعنوان',
                          subtitle:
                              'سيتم توصيل رخصتك الجديدة للعنوان الذي تحدده, يرجى التأكد من صحة العنوان لتجنب أي تأخير.',
                          isSelected: _deliveryMethod == 2,
                          onTap: () => setState(() => _deliveryMethod = 2),
                          icon: SvgPicture.asset(
                            'assets/home2.svg',
                            width: 24.w,
                            height: 24.w,
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: isDelivery
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(height: 20.h),
                                    CustomTextFormField(
                                      labelText: 'المحافظة',
                                      hintText: 'اكتب المحافظة',
                                      controller: _governorateController,
                                      validator: _validateGovernorate,
                                    ),
                                    SizedBox(height: 16.h),
                                    CustomTextFormField(
                                      labelText: 'المدينة / المركز',
                                      hintText: 'اكتب المدينة / المركز',
                                      controller: _cityController,
                                      validator: _validateCity,
                                    ),
                                    SizedBox(height: 16.h),
                                    CustomTextFormField(
                                      labelText: 'تفاصيل إضافية للعنوان',
                                      hintText: 'اكتب تفاصيل العنوان....',
                                      controller: _addressDetailsController,
                                      validator: _validateAddressDetails,
                                      minLines: 3,
                                      maxLines: 5,
                                      keyboardType: TextInputType.multiline,
                                    ),
                                    SizedBox(height: 8.h),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                child: isLoading
                    ? const Center(child: CustomLoadingIndicator())
                    : PrimaryButton(
                        label: 'إنهاء وإصدار الرخصة',
                        onPressed: isButtonEnabled
                            ? () => _onFinalize(context)
                            : null,
                        height: 48.h,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
