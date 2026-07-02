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
import '../widgets/selection_option_card.dart';
import 'package:traffic/features/vehicle_license/data/models/vehicle_license_model.dart';
import 'vehicle_replacement_type_selection_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/cubits/vehicle_replacement_cubit.dart';
import '../../../presentation/cubits/vehicle_replacement_state.dart';
import 'package:traffic/injection_container.dart';
import 'package:traffic/core/api/order_payment_cache.dart';
import 'package:traffic/core/api/user_address_cache.dart';
import 'package:traffic/core/widgets/saved_addresses_selector.dart';
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

  UserAddress? _selectedAddress;
  bool _useSavedAddress = false;

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

  bool get isDelivery => selectedMethod == VehicleDeliveryMethod.delivery;

  bool get _isButtonEnabled => selectedMethod != null;

  void _onMethodTap(VehicleDeliveryMethod method) {
    if (selectedMethod == method) return;
    setState(() {
      selectedMethod = method;
      _useSavedAddress = false;
      _selectedAddress = null;
      _governorateController.clear();
      _cityController.clear();
      _addressDetailsController.clear();
    });
  }

  void _onNextPressed() async {
    if (selectedMethod == VehicleDeliveryMethod.delivery) {
      if (_useSavedAddress && _selectedAddress != null) {
        _governorateController.text = _selectedAddress!.governorate;
        _cityController.text = _selectedAddress!.city;
        _addressDetailsController.text = _selectedAddress!.details;
      } else {
        if (!(_formKey.currentState?.validate() ?? false)) return;
        final newAddr = UserAddress(
          governorate: _governorateController.text.trim(),
          city: _cityController.text.trim(),
          details: _addressDetailsController.text.trim(),
        );
        await UserAddressCache.saveAddress(newAddr);
      }
    }

    final int method = selectedMethod == VehicleDeliveryMethod.delivery ? 2 : 1;
    final String repType = widget.replacementType == VehicleReplacementType.lost
        ? "بدل فاقد"
        : "بدل تالف";

    if (!mounted) return;
    _replacementCubit?.issueReplacement(
      licenseNumber: widget.vehicle.licenseNumber,
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

    final String? shippingAddress = selectedMethod == VehicleDeliveryMethod.delivery
        ? '${_governorateController.text.trim()}، ${_cityController.text.trim()}، ${_addressDetailsController.text.trim()}'
        : null;

    final String orderTypeLabel =
        widget.replacementType == VehicleReplacementType.lost
            ? 'بدل فاقد رخصة مركبة'
            : 'بدل تالف رخصة مركبة';

    final orderSummary = OrderSummary(
      orderType: orderTypeLabel,
      paymentMethod: paymentMethodLabel,
      orderId: widget.vehicle.licenseNumber,
      shippingAddress: shippingAddress,
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
    Widget body = Scaffold(
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
                      onTap: () => _onMethodTap(VehicleDeliveryMethod.pickup),
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
                      onTap: () => _onMethodTap(VehicleDeliveryMethod.delivery),
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 20.h),
                                SavedAddressesSelector(
                                  governorateController: _governorateController,
                                  cityController: _cityController,
                                  addressDetailsController: _addressDetailsController,
                                  onChanged: (useSaved, address) {
                                    setState(() {
                                      _useSavedAddress = useSaved;
                                      _selectedAddress = address;
                                    });
                                  },
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
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
          );
        },
      );
    }

    return PrimaryButton(
      label: 'التالي',
      onPressed: _isButtonEnabled ? _onNextPressed : null,
      height: 48.h,
    );
  }
}
