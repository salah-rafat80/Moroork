import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPaymentCachedData {
  final double baseFee;
  final double deliveryFee;
  final double totalAmount;
  final String paymentMethodLabel;
  final String orderType;

  OrderPaymentCachedData({
    required this.baseFee,
    required this.deliveryFee,
    required this.totalAmount,
    required this.paymentMethodLabel,
    required this.orderType,
  });

  Map<String, dynamic> toJson() => {
        'baseFee': baseFee,
        'deliveryFee': deliveryFee,
        'totalAmount': totalAmount,
        'paymentMethodLabel': paymentMethodLabel,
        'orderType': orderType,
      };

  factory OrderPaymentCachedData.fromJson(Map<String, dynamic> json) =>
      OrderPaymentCachedData(
        baseFee: (json['baseFee'] as num? ?? 0).toDouble(),
        deliveryFee: (json['deliveryFee'] as num? ?? 0).toDouble(),
        totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
        paymentMethodLabel: json['paymentMethodLabel']?.toString() ?? '',
        orderType: json['orderType']?.toString() ?? '',
      );
}

class OrderPaymentCache {
  static const String _prefix = 'order_payment_cache_';

  static Future<void> save(String requestNumber, OrderPaymentCachedData data) async {
    if (requestNumber.trim().isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(data.toJson());
      await prefs.setString('$_prefix$requestNumber', jsonStr);
    } catch (_) {}
  }

  static Future<OrderPaymentCachedData?> get(String requestNumber) async {
    if (requestNumber.trim().isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_prefix$requestNumber');
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return OrderPaymentCachedData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
