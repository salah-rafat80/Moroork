part of 'order_details_cubit.dart';

abstract class OrderDetailsState {}

class OrderDetailsInitial extends OrderDetailsState {}

/// حالة التحميل العام (حجز مواعيد)
class OrderDetailsLoading extends OrderDetailsState {}

/// حالة تحميل تفاصيل الطلب من السيرفر
class OrderDetailsLoadingDetails extends OrderDetailsState {}

/// ✅ تفاصيل الطلب المحدَّثة من السيرفر — الـ UI يبني على هذه
class OrderDetailsRefreshed extends OrderDetailsState {
  final OrderModel freshOrder;
  OrderDetailsRefreshed(this.freshOrder);
}

/// فشل جلب التفاصيل من السيرفر (يُعرض fallback للـ order القديمة)
class OrderDetailsFetchFailed extends OrderDetailsState {
  final String message;
  OrderDetailsFetchFailed(this.message);
}

class OrderDetailsMedicalBookingSuccess extends OrderDetailsState {
  final String requestNumber;
  OrderDetailsMedicalBookingSuccess(this.requestNumber);
}

class OrderDetailsPracticalBookingSuccess extends OrderDetailsState {}

class OrderDetailsFailure extends OrderDetailsState {
  final String errorMessage;
  OrderDetailsFailure(this.errorMessage);
}
