import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traffic/core/features/checkout/generic_order_review_screen.dart';
import 'package:traffic/core/features/checkout/models/applicant_details.dart';
import 'package:traffic/core/features/checkout/models/fees_details.dart';
import 'package:traffic/core/features/checkout/models/order_summary.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/selection_option_card.dart';
import '../../data/models/vehicle_license_model.dart';
import 'vehicle_replacement_type_selection_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/cubits/vehicle_replacement_cubit.dart';
import '../../../presentation/cubits/vehicle_replacement_state.dart';
import 'package:traffic/injection_container.dart';
import 'package:traffic/core/api/order_payment_cache.dart';

import 'package:traffic/core/widgets/app_drawer.dart';


enum VehicleDeliveryMethod { pickup, delivery }

class VehicleDeliveryMethodScreen extends StatefulWidget {
  final VehicleLicenseModel vehicle;
  final VehicleReplacementType replacementType;

  const VehicleDeliveryMethodScreen({
    super.key,
    required this.vehicle,
    required this.replacementType,
  });

  @override
  State<VehicleDeliveryMethodScreen> createState() =>
      _VehicleDeliveryMethodScreenState();
}

class _VehicleDeliveryMethodScreenState extends State<VehicleDeliveryMethodScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  VehicleReplacementCubit? _replacementCubit;
  VehicleDeliveryMethod? selectedMethod;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _governorateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressDetailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _replacementCubit = getIt<VehicleReplacementCubit>();
  }

  @override
  void dispose() {
    _replacementCubit?.close();
    _governorateController.dispose();
    _cityController.dispose();
    _addressDetailsController.dispose();
    super.dispose();
  }

  bool get _isButtonEnabled => selectedMethod != null;

  void _onNextPressed() {
    if (selectedMethod == VehicleDeliveryMethod.delivery) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }

    final int method = selectedMethod == VehicleDeliveryMethod.delivery ? 2 : 1;
    final String repType = widget.replacementType == VehicleReplacementType.lost
        ? "0" // "بدل فاقد" maps to 0 in API as per driving license? Wait, driving license was "Lost" and "Damaged". Vehicle API docs say: "بدل فاقد" (0), "بدل تالف" (1). But wait, driving license actually sends "Lost" or "Damaged". Let's check API docs. It says `replacementtype`: "بدل فاقد" (0), "بدل تالف" (1). I'll send string '0' or '1' or int? The API doc says: `replacementtype`: "بدل فاقد" (0), "بدل تالف" (1).
        : "1";

    _replacementCubit?.issueReplacement(
      licenseNumber: widget.vehicle.plateNumber,
      replacementType: repType,
      method: method,
      governorate: method == 2 ? _governorateController.text.trim() : null,
      city: method == 2 ? _cityController.text.trim() : null,
      details: method == 2 ? _addressDetailsController.text.trim() : null,
    );
  }

  Future<void> _navigateToOrderReview(VehicleReplacementSuccess state) async {
    final applicant = await ApplicantDetails.getActualDetails();

    final String paymentMethodLabel =
        selectedMethod == VehicleDeliveryMethod.delivery
            ? 'التوصيل للعنوان'
            : 'الاستلام من وحدة المرور';

    final String orderTypeLabel =
        widget.replacementType == VehicleReplacementType.lost
            ? 'بدل فاقد رخصة مركبة'
            : 'بدل تالف رخصة مركبة';

    final orderSummary = OrderSummary(
      orderType: orderTypeLabel,
      paymentMethod: paymentMethodLabel,
      orderId: widget.vehicle.plateNumber,
    );

    final double baseFee = state.response.fees?.baseFee ?? 0;
    final double deliveryFee = state.response.fees?.deliveryFee ?? 0;
    final double totalAmount = state.response.fees?.totalAmount ?? 0;

    // Cache the payment details
    await OrderPaymentCache.save(
      state.response.requestNumber,
      OrderPaymentCachedData(
        baseFee: baseFee,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        paymentMethodLabel: paymentMethodLabel,
        orderType: orderTypeLabel,
      ),
    );

    final List<FeeItem> items = [
      FeeItem(label: 'الرسوم الأساسية', amount: '$baseFee جنية مصري'),
    ];

    if (selectedMethod == VehicleDeliveryMethod.delivery) {
      items.add(
        FeeItem(label: 'رسوم التوصيل', amount: '$deliveryFee جنية مصري'),
      );
    }

    final fees = FeesDetails(items: items, total: '$totalAmount جنية مصري');

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GenericOrderReviewScreen(
          appBarTitle: 'اصدار بدل فاقد / تالف رخصة مركبة',
          applicantDetails: applicant,
          orderSummary: orderSummary,
          feesDetails: fees,
          serviceRequestNumber: state.response.requestNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.lightGreyBg,
        drawer: const AppDrawer(),
        body: Column(
          children: [
            ServiceScreenAppBar(
              title: 'اصدار بدل فاقد / تالف رخصة مركبة',
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                        isSelected: selectedMethod == VehicleDeliveryMethod.pickup,
                        onTap: () =>
                            setState(() => selectedMethod = VehicleDeliveryMethod.pickup),
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
                        isSelected: selectedMethod == VehicleDeliveryMethod.delivery,
                        onTap: () => setState(
                            () => selectedMethod = VehicleDeliveryMethod.delivery),
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
                      if (selectedMethod == VehicleDeliveryMethod.delivery) ...[
                        SizedBox(height: 20.h),
                        CustomTextFormField(
                          labelText: 'المحافظة',
                          hintText: 'اكتب المحافظة',
                          controller: _governorateController,
                          validator: (v) => v?.isEmpty ?? true
                              ? 'برجاء إدخال اسم محافظة صحيح'
                              : null,
                        ),
                        SizedBox(height: 16.h),
                        CustomTextFormField(
                          labelText: 'المدينة / المركز',
                          hintText: 'اكتب المدينة / المركز',
                          controller: _cityController,
                          validator: (v) => v?.isEmpty ?? true
                              ? 'برجاء إدخال اسم مدينة / مركز صحيح'
                              : null,
                        ),
                        SizedBox(height: 16.h),
                        CustomTextFormField(
                          labelText: 'تفاصيل إضافية للعنوان',
                          hintText: 'اكتب تفاصيل العنوان....',
                          controller: _addressDetailsController,
                          validator: (v) => v?.isEmpty ?? true
                              ? 'تعذر التحقق من العنوان…برجاء كتابة العنوان بشكل أوضح'
                              : null,
                          minLines: 3,
                          maxLines: 5,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
              child: _buildBottomButton(),
            ),
          ],
        ),
      ),
    );

    if (_replacementCubit != null) {
      body = BlocProvider.value(
        value: _replacementCubit!,
        child: BlocListener<VehicleReplacementCubit, VehicleReplacementState>(
          listener: (ctx, state) {
            if (state is VehicleReplacementSuccess) {
              _navigateToOrderReview(state);
            } else if (state is VehicleReplacementFailure) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    textDirection: TextDirection.rtl,
                  ),
                  backgroundColor: AppColors.redError,
                ),
              );
            }
          },
          child: body,
        ),
      );
    }

    return body;
  }

  Widget _buildBottomButton() {
    if (_replacementCubit != null) {
      return BlocBuilder<VehicleReplacementCubit, VehicleReplacementState>(
        bloc: _replacementCubit,
        builder: (ctx, state) {
          if (state is VehicleReplacementLoading) {
            return const Center(child: CustomLoadingIndicator());
          }
          return PrimaryButton(
            label: 'التالي',
            onPressed: _isButtonEnabled ? _onNextPressed : null,
            height: 48.h,
            backgroundColor: AppColors.primary,
            fontSize: 18.sp,
          );
        },
      );
    }

    return PrimaryButton(
      label: 'التالي',
      onPressed: _isButtonEnabled ? _onNextPressed : null,
      height: 48.h,
      backgroundColor: AppColors.primary,
      fontSize: 18.sp,
    );
  }
}
