import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:traffic/core/features/payment/data/repositories/payment_repository.dart';
import 'package:traffic/core/features/payment/presentation/cubits/payment_state.dart';

@injectable
class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository _repository;

  PaymentCubit(this._repository) : super(const PaymentInitial());

  @override
  void emit(PaymentState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> initiatePayment({
    String? serviceRequestNumber,
    List<int>? violationIds,
    double? amount,
  }) async {
    developer.log('State Transition: PaymentLoading emitted', name: 'PaymentCubit');
    emit(const PaymentLoading());
    try {
      final response = await _repository.createPayment(
        serviceRequestNumber: serviceRequestNumber,
        violationIds: violationIds,
        amount: amount,
      );
      if (isClosed) return;
      developer.log('State Transition: PaymentInitSuccess emitted', name: 'PaymentCubit');
      emit(PaymentInitSuccess(response));
    } catch (e) {
      if (isClosed) return;
      developer.log('State Transition: PaymentFailure emitted. Error: $e', name: 'PaymentCubit');
      emit(PaymentFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> verifyPayment(String merchantOrderId) async {
    developer.log('State Transition: PaymentVerifying emitted', name: 'PaymentCubit');
    emit(const PaymentVerifying());

    int retries = 5;
    String status = 'Unknown';

    while (retries > 0) {
      if (isClosed) return;
      try {
        status = await _repository.checkPaymentStatus(merchantOrderId);
        if (isClosed) return;
        developer.log('verifyPayment: attempt ${6 - retries}, status is $status', name: 'PaymentCubit');

        final lowerStatus = status.toLowerCase();
        if (lowerStatus == 'success' || lowerStatus == 'paid' || lowerStatus == 'completed') {
          developer.log('State Transition: PaymentVerifySuccess emitted', name: 'PaymentCubit');
          emit(PaymentVerifySuccess(status));
          return;
        } else if (lowerStatus == 'failed' || lowerStatus == 'cancelled' || lowerStatus == 'declined') {
          developer.log('State Transition: PaymentVerifyFailure emitted. Status: $status', name: 'PaymentCubit');
          emit(PaymentVerifyFailure('فشلت عملية الدفع. حالة الطلب: $status'));
          return;
        }
      } catch (e) {
        developer.log('verifyPayment error: $e', name: 'PaymentCubit');
      }

      retries--;
      if (retries > 0) {
        if (isClosed) return;
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (isClosed) return;
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'success' || lowerStatus == 'paid' || lowerStatus == 'completed') {
      developer.log('State Transition: PaymentVerifySuccess emitted', name: 'PaymentCubit');
      emit(PaymentVerifySuccess(status));
    } else {
      developer.log('State Transition: PaymentVerifyFailure emitted. Status: $status', name: 'PaymentCubit');
      emit(PaymentVerifyFailure('تعذر التحقق من حالة الدفع. حالة الطلب الحالية: $status'));
    }
  }
}
