import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traffic/core/features/checkout/generic_order_review_screen.dart';
import 'package:traffic/core/features/checkout/models/applicant_details.dart';
import 'package:traffic/core/features/checkout/models/fees_details.dart';
import 'package:traffic/core/features/checkout/models/order_summary.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traffic/core/api/order_payment_cache.dart';
import 'package:traffic/core/widgets/loading_overlay.dart';
import 'package:traffic/core/api/user_address_cache.dart';
import 'package:traffic/core/widgets/saved_addresses_selector.dart';
import '../../data/models/renewal_vehicle_license_model.dart';
import '../../../presentation/cubits/vehicle_renewal_cubit.dart';
import '../../../presentation/cubits/vehicle_renewal_state.dart';
import '../../../replacement_license/presentation/widgets/selection_option_card.dart';
import 'package:traffic/injection_container.dart';

enum VehicleDeliveryMethod { pickup, delivery }

class VehicleRenewalDeliveryScreen extends StatefulWidget {
  final String requestNumber;
  final RenewalVehicleLicenseModel? vehicle;
  final String? plateNumber;

  const VehicleRenewalDeliveryScreen({
    super.key,
    required this.requestNumber,
    this.vehicle,
    this.plateNumber,
  });

  @override
  State<VehicleRenewalDeliveryScreen> createState() =>
      _VehicleRenewalDeliveryScreenState();
}

class _VehicleRenewalDeliveryScreenState
    extends State<VehicleRenewalDeliveryScreen> {
  VehicleDeliveryMethod? selectedMethod;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _governorateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressDetailsController =
      TextEditingController();

  UserAddress? _selectedAddress;
  bool _useSavedAddress = false;

  @override
  void dispose() {
    _governorateController.dispose();
    _cityController.dispose();
    _addressDetailsController.dispose();
    super.dispose();
  }

  bool get _isButtonEnabled => selectedMethod != null;

  void _onNextPressed(BuildContext context) async {
    final cubit = context.read<VehicleRenewalCubit>();
    if (selectedMethod == VehicleDeliveryMethod.delivery) {
      if (_useSavedAddress && _selectedAddress != null) {
        // Use the selected saved address
        _governorateController.text = _selectedAddress!.governorate;
        _cityController.text = _selectedAddress!.city;
        _addressDetailsController.text = _selectedAddress!.details;
      } else {
        // Validate new address input
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

    cubit.finalizeVehicleRenewal(
      requestNumber: widget.requestNumber,
      method: method,
      governorate: method == 2 ? _governorateController.text.trim() : null,
      city: method == 2 ? _cityController.text.trim() : null,
      details: method == 2 ? _addressDetailsController.text.trim() : null,
    );
  }

  Future<void> _navigateToOrderReview(
    VehicleRenewalSuccess state,
  ) async {
    final applicant = await ApplicantDetails.getActualDetails();

    final String paymentMethodLabel =
        selectedMethod == VehicleDeliveryMethod.delivery
        ? 'التوصيل للعنوان'
        : 'الاستلام من وحدة المرور';

    final String? shippingAddress = selectedMethod == VehicleDeliveryMethod.delivery
        ? '${_governorateController.text.trim()}، ${_cityController.text.trim()}، ${_addressDetailsController.text.trim()}'
        : null;

    final orderSummary = OrderSummary(
      orderType: 'تجديد رخصة مركبة',
      paymentMethod: paymentMethodLabel,
      orderId: widget.vehicle?.plateNumber ?? widget.plateNumber ?? '',
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
        orderType: 'تجديد رخصة مركبة',
      ),
    );

    final List<FeeItem> items = [
      FeeItem(label: 'رسوم تجديد الرخصة', amount: '$baseFee جنية مصري'),
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
          appBarTitle: 'تجديد رخصة مركبة',
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
    return BlocProvider(
      create: (context) => getIt<VehicleRenewalCubit>(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<VehicleRenewalCubit, VehicleRenewalState>(
            listener: (context, state) {
              if (state is VehicleRenewalSuccess) {
                _navigateToOrderReview(state);
              } else if (state is VehicleRenewalFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
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
            builder: (context, state) {
              return LoadingOverlay(
                isLoading: state is VehicleRenewalLoading,
                child: Scaffold(
                  backgroundColor: AppColors.lightGreyBg,
                  body: Column(
                    children: [
                      const ServiceScreenAppBar(title: 'تجديد رخصة مركبة'),
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
                                  isSelected:
                                      selectedMethod ==
                                      VehicleDeliveryMethod.pickup,
                                  onTap: () => setState(
                                    () => selectedMethod =
                                        VehicleDeliveryMethod.pickup,
                                  ),
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
                                  isSelected:
                                      selectedMethod ==
                                      VehicleDeliveryMethod.delivery,
                                  onTap: () => setState(
                                    () => selectedMethod =
                                        VehicleDeliveryMethod.delivery,
                                  ),
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
                                if (selectedMethod ==
                                    VehicleDeliveryMethod.delivery) ...[
                                  SizedBox(height: 20.h),
                                  SavedAddressesSelector(
                                    governorateController:
                                        _governorateController,
                                    cityController: _cityController,
                                    addressDetailsController:
                                        _addressDetailsController,
                                    onChanged: (useSaved, address) {
                                      setState(() {
                                        _useSavedAddress = useSaved;
                                        _selectedAddress = address;
                                      });
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                        child: PrimaryButton(
                          label: 'التالي',
                          onPressed: _isButtonEnabled
                              ? () => _onNextPressed(context)
                              : null,
                          height: 48.h,
                          backgroundColor: AppColors.primary,
                          fontSize: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
