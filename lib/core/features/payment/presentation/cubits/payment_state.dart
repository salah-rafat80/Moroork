import 'package:flutter/foundation.dart';
import 'package:traffic/core/features/payment/models/payment_init_response.dart';

@immutable
sealed class PaymentState {
  const PaymentState();
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentInitSuccess extends PaymentState {
  final PaymentInitResponse response;

  const PaymentInitSuccess(this.response);
}

class PaymentFailure extends PaymentState {
  final String message;

  const PaymentFailure(this.message);
}

class PaymentVerifying extends PaymentState {
  const PaymentVerifying();
}

class PaymentVerifySuccess extends PaymentState {
  final String status;

  const PaymentVerifySuccess(this.status);
}

class PaymentVerifyFailure extends PaymentState {
  final String message;

  const PaymentVerifyFailure(this.message);
}
