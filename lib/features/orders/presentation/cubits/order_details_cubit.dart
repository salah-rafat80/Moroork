import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../driving_license/presentation/screens/document_upload/widgets/first_license_booking_helper.dart';
import '../../../orders/data/repositories/service_requests_repository.dart';
import '../../domain/entities/order_model.dart';

part 'order_details_state.dart';

@injectable
class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  final FirstLicenseBookingHelper bookingHelper;
  final ServiceRequestsRepository _serviceRequestsRepository;

  OrderDetailsCubit(this.bookingHelper, this._serviceRequestsRepository)
      : super(OrderDetailsInitial());

  /// جلب تفاصيل الطلب المحدَّثة من السيرفر
  /// يُستدعى عند فتح شاشة التفاصيل لضمان أن الحالة والخطوة الحالية حية دائماً
  Future<void> fetchOrderDetails(String requestNumber, OrderModel fallback) async {
    emit(OrderDetailsLoadingDetails());
    try {
      final result = await _serviceRequestsRepository.fetchRequestDetails(requestNumber);
      if (result.isSuccess && result.data != null) {
        // نبني OrderModel من الـ JSON المحدَّث
        final fresh = OrderModel.fromJson(result.data!);
        emit(OrderDetailsRefreshed(fresh));
      } else {
        // فشل جلب التفاصيل — نرجع للـ fallback بدل من تعطيل الشاشة
        emit(OrderDetailsFetchFailed(result.error ?? 'تعذر تحديث بيانات الطلب'));
      }
    } catch (e) {
      emit(OrderDetailsFetchFailed('حدث خطأ غير متوقع عند جلب التفاصيل.'));
    }
  }

  Future<void> submitMedicalAppointment(
      String governorateId,
      String secondaryId,
      DateTime selectedDate,
      String selectedSlot,
      String requestNumber) async {
    emit(OrderDetailsLoading());
    try {
      await bookingHelper.submitMedicalAppointment(
        governorateId,
        secondaryId,
        selectedDate,
        selectedSlot,
        requestNumber,
      );
      emit(OrderDetailsMedicalBookingSuccess(requestNumber));
    } catch (e) {
      emit(OrderDetailsFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> submitDrivingAppointment(
      String governorateId,
      String secondaryId,
      DateTime selectedDate,
      String selectedSlot,
      String requestNumber) async {
    emit(OrderDetailsLoading());
    try {
      await bookingHelper.submitDrivingAppointment(
        governorateId,
        secondaryId,
        selectedDate,
        selectedSlot,
        requestNumber,
      );
      emit(OrderDetailsPracticalBookingSuccess());
    } catch (e) {
      emit(OrderDetailsFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
