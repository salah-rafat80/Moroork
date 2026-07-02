/// Holds the high-level order summary fields shown in [OrderSummaryCard].
class OrderSummary {
  final String orderType;
  final String paymentMethod;
  final String orderId;
  final String? shippingAddress;

  const OrderSummary({
    required this.orderType,
    required this.paymentMethod,
    required this.orderId,
    this.shippingAddress,
  });
}
