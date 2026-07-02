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
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/driving_license/data/models/driving_license_model.dart';
import 'package:traffic/features/driving_license/data/models/driving_renewal_model.dart';
import 'package:traffic/features/driving_license/presentation/cubits/driving_renewal_cubit.dart';
import 'package:traffic/features/profile/data/models/profile_model.dart';
import 'package:traffic/features/driving_license/presentation/cubits/driving_replacement_cubit.dart';
import 'package:traffic/features/driving_license/presentation/cubits/driving_replacement_state.dart';
import '../widgets/selection_option_card.dart';
import 'replacement_type_selection_screen.dart';
import 'package:traffic/injection_container.dart';
import 'package:traffic/core/api/order_payment_cache.dart';
import 'package:traffic/core/api/user_address_cache.dart';
import 'package:traffic/core/widgets/saved_addresses_selector.dart';
import 'package:traffic/core/widgets/app_drawer.dart';


// ── Enum ──────────────────────────────────────────────────────────────────────

/// Represents how the user wants to receive their replacement licence.
enum DeliveryMethod {
  /// Collect in person from the traffic unit (استلام من وحدة المرور).
  pickup,

  /// Deliver to a home address (التوصيل للعنوان).
  delivery,
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// **Licence Delivery Method Screen** — Step 4 of the
/// "Lost / Damaged Driving Licence" flow.
///
/// Behaviour summary:
/// | selectedMethod | Form visible | Button state        |
/// |----------------|--------------|---------------------|
/// | null           | No           | Disabled (grey)     |
/// | pickup         | No           | Active → proceeds   |
/// | delivery       | Yes (3 fields)| Active only if form valid |
class DeliveryMethodScreen extends StatefulWidget {
  /// The licence chosen in Step 1 (License Selection).
  /// Required for lost/damaged replacement flow. Null for renewal finalize.
  final DrivingLicenseModel? license;

  /// The replacement type chosen in Step 3 (بدل فاقد / بدل تالف).
  /// Required for lost/damaged replacement flow. Null for renewal finalize.
  final ReplacementType? replacementType;

  /// When non-null, this screen operates in **renewal finalize** mode.
  final String? renewalRequestNumber;

  /// When non-null, this screen operates in **issuance finalize** mode.
  final String? issuanceRequestNumber;

  const DeliveryMethodScreen({
    super.key,
    this.license,
    this.replacementType,
    this.renewalRequestNumber,
    this.issuanceRequestNumber,
  });

  /// Named constructor for the lost/damaged replacement flow.
  const DeliveryMethodScreen.replacement({
    super.key,
    required DrivingLicenseModel this.license,
    required ReplacementType this.replacementType,
  }) : renewalRequestNumber = null,
       issuanceRequestNumber = null;

  /// Named constructor for the renewal finalize flow.
  const DeliveryMethodScreen.renewalFinalize({
    super.key,
    required String this.renewalRequestNumber,
  }) : license = null,
       replacementType = null,
       issuanceRequestNumber = null;

  /// Named constructor for the first-time issuance finalize flow.
  const DeliveryMethodScreen.issuanceFinalize({
    super.key,
    required String this.issuanceRequestNumber,
  }) : license = null,
       replacementType = null,
       renewalRequestNumber = null;

  bool get _isRenewalFinalizeMode => renewalRequestNumber != null;

  @override
  State<DeliveryMethodScreen> createState() => _DeliveryMethodScreenState();
}

class _DeliveryMethodScreenState extends State<DeliveryMethodScreen> {
  // ── State ─────────────────────────────────────────────────────────────────

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DrivingReplacementCubit? _replacementCubit;

  /// Currently selected delivery method; `null` until the user picks one.
  DeliveryMethod? selectedMethod;

  final _formKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────────────────────

  final TextEditingController _governorateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressDetailsController =
      TextEditingController();

  UserAddress? _selectedAddress;
  bool _useSavedAddress = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (!widget._isRenewalFinalizeMode) {
      _replacementCubit = getIt<DrivingReplacementCubit>();
    }
  }

  @override
  void dispose() {
    _replacementCubit?.close();
    _governorateController.dispose();
    _cityController.dispose();
    _addressDetailsController.dispose();
    super.dispose();
  }

  // ── Derived state ─────────────────────────────────────────────────────────

  /// The "التالي" button is enabled only when a method is selected.
  /// For delivery, the form must also be valid before proceeding — that is
  /// enforced inside [_onNextPressed] via [_formKey.currentState!.validate()].
  bool get _isButtonEnabled => selectedMethod != null;

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _onMethodTap(DeliveryMethod method) {
    setState(() => selectedMethod = method);
  }

  void _onNextPressed() async {
    // Validate address fields only when delivery is selected.
    if (selectedMethod == DeliveryMethod.delivery) {
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

    if (!mounted) return;

    // ── Renewal finalize mode ─────────────────────────────────────────────
    if (widget._isRenewalFinalizeMode) {
      final int method = selectedMethod == DeliveryMethod.delivery ? 2 : 1;
      context.read<DrivingRenewalCubit>().finalizeRenewal(
        requestNumber: widget.renewalRequestNumber!,
        method: method,
        governorate: method == 2 ? _governorateController.text.trim() : null,
        city: method == 2 ? _cityController.text.trim() : null,
        details: method == 2 ? _addressDetailsController.text.trim() : null,
      );
      return;
    }

    // ── Original replacement flow ─────────────────────────────────────────
    if (widget.license == null || widget.replacementType == null) return;

    final int method = selectedMethod == DeliveryMethod.delivery ? 2 : 1;
    final String repType = widget.replacementType == ReplacementType.lost
        ? "Lost"
        : "Damaged";

    _replacementCubit?.issueReplacement(
      licenseNumber: widget.license!.licenseNumber,
      replacementType: repType,
      method: method,
      governorate: method == 2 ? _governorateController.text.trim() : null,
      city: method == 2 ? _cityController.text.trim() : null,
      details: method == 2 ? _addressDetailsController.text.trim() : null,
    );
  }

  Future<void> _navigateToOrderReview(DrivingReplacementSuccess state) async {
    final applicant = await ApplicantDetails.getActualDetails();

    final String paymentMethodLabel = selectedMethod == DeliveryMethod.delivery
        ? 'التوصيل للعنوان'
        : 'الاستلام من وحدة المرور';

    final String? shippingAddress = selectedMethod == DeliveryMethod.delivery
        ? '${_governorateController.text.trim()}، ${_cityController.text.trim()}، ${_addressDetailsController.text.trim()}'
        : null;

    final String orderTypeLabel = widget.replacementType == ReplacementType.lost
        ? 'بدل فاقد رخصة قيادة'
        : 'بدل تالف رخصة قيادة';

    final orderSummary = OrderSummary(
      orderType: orderTypeLabel,
      paymentMethod: paymentMethodLabel,
      orderId: widget.license!.licenseNumber,
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

    if (selectedMethod == DeliveryMethod.delivery) {
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
          appBarTitle: 'اصدار بدل فاقد / تالف رخصة قيادة',
          applicantDetails: applicant,
          orderSummary: orderSummary,
          feesDetails: fees,
          serviceRequestNumber: state.response.requestNumber,
        ),
      ),
    );
  }

  void _navigateToRenewalOrderReview(
    FinalizeRenewalResponseModel response,
    ProfileModel profile,
  ) async {
    final applicant = ApplicantDetails(
      name: profile.fullName,
      nationalId: profile.nationalId,
      phone: profile.phoneNumber,
      email: profile.email,
    );

    final String paymentMethodLabel = selectedMethod == DeliveryMethod.delivery
        ? 'التوصيل للعنوان'
        : 'الاستلام من وحدة المرور';

    final String? shippingAddress = selectedMethod == DeliveryMethod.delivery
        ? '${_governorateController.text.trim()}، ${_cityController.text.trim()}، ${_addressDetailsController.text.trim()}'
        : null;

    final String orderId = response.requestNumber.trim().isNotEmpty
        ? response.requestNumber
        : widget.renewalRequestNumber ?? '';

    final orderSummary = OrderSummary(
      orderType: 'تجديد رخصة قيادة',
      paymentMethod: paymentMethodLabel,
      orderId: orderId,
      shippingAddress: shippingAddress,
    );

    final FinalizeRenewalFeesModel feesPayload =
        response.fees ??
        const FinalizeRenewalFeesModel(
          baseFee: 0,
          deliveryFee: 0,
          totalAmount: 0,
        );

    // Cache the payment details
    await OrderPaymentCache.save(
      orderId,
      OrderPaymentCachedData(
        baseFee: feesPayload.baseFee,
        deliveryFee: feesPayload.deliveryFee,
        totalAmount: feesPayload.totalAmount,
        paymentMethodLabel: paymentMethodLabel,
        orderType: 'تجديد رخصة قيادة',
      ),
    );

    final List<FeeItem> items = <FeeItem>[
      FeeItem(
        label: 'الرسوم الأساسية',
        amount: _formatCurrency(feesPayload.baseFee),
      ),
    ];

    if (feesPayload.deliveryFee > 0) {
      items.add(
        FeeItem(
          label: 'رسوم التوصيل',
          amount: _formatCurrency(feesPayload.deliveryFee),
        ),
      );
    }

    final fees = FeesDetails(
      items: items,
      total: _formatCurrency(feesPayload.totalAmount),
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GenericOrderReviewScreen(
          appBarTitle: 'تجديد رخصة قيادة',
          applicantDetails: applicant,
          orderSummary: orderSummary,
          feesDetails: fees,
          serviceRequestNumber: orderId,
          paymentAmountOverride: feesPayload.totalAmount,
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isDelivery = selectedMethod == DeliveryMethod.delivery;

    Widget body = Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ── App bar ────────────────────────────────────────────────────
          ServiceScreenAppBar(
            title: widget._isRenewalFinalizeMode
                ? 'استكمال تجديد رخصة القيادة'
                : 'اصدار بدل فاقد / تالف رخصة قيادة',
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),

          // ── Scrollable body ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Section header ──────────────────────────────────
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

                    // ── Option 1: استلام من وحدة المرور (pickup) ─────────
                    SelectionOptionCard(
                      title: 'استلام من وحدة المرور',
                      subtitle:
                          'استلم الرخصة شخصيًا من وحدة المرور التي تم تسجيلها في بياناتك',
                      isSelected: selectedMethod == DeliveryMethod.pickup,
                      onTap: () => _onMethodTap(DeliveryMethod.pickup),
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

                    // ── Option 2: التوصيل للعنوان (delivery) ─────────────
                    SelectionOptionCard(
                      title: 'التوصيل للعنوان',
                      subtitle:
                          'سيتم توصيل رخصتك الجديدة للعنوان الذي تحدده, يرجى التأكد من صحة العنوان لتجنب أي تأخير.',
                      isSelected: selectedMethod == DeliveryMethod.delivery,
                      onTap: () => _onMethodTap(DeliveryMethod.delivery),
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

                    // ── Delivery address form (animated in/out) ──────────
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
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Sticky bottom button ───────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: _buildBottomButton(),
          ),
        ],
      ),
    );

    // Wrap with BlocListener based on mode
    if (widget._isRenewalFinalizeMode) {
      body = BlocListener<DrivingRenewalCubit, DrivingRenewalState>(
        listener: (BuildContext ctx, DrivingRenewalState state) {
          if (state is DrivingRenewalFinalizeSuccess) {
            _navigateToRenewalOrderReview(state.response, state.profile);
          } else if (state is DrivingRenewalFailure) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message, textDirection: TextDirection.rtl),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: body,
      );
    } else if (_replacementCubit != null) {
      body = BlocProvider.value(
        value: _replacementCubit!,
        child: BlocListener<DrivingReplacementCubit, DrivingReplacementState>(
          listener: (ctx, state) {
            if (state is DrivingReplacementSuccess) {
              _navigateToOrderReview(state);
            } else if (state is DrivingReplacementFailure) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage,
                    textDirection: TextDirection.rtl,
                  ),
                  backgroundColor: AppColors.error,
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
    if (widget._isRenewalFinalizeMode) {
      return BlocBuilder<DrivingRenewalCubit, DrivingRenewalState>(
        builder: (BuildContext ctx, DrivingRenewalState state) {
          if (state is DrivingRenewalFinalizeLoading) {
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
    } else if (_replacementCubit != null) {
      return BlocBuilder<DrivingReplacementCubit, DrivingReplacementState>(
        bloc: _replacementCubit,
        builder: (ctx, state) {
          if (state is DrivingReplacementLoading) {
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

