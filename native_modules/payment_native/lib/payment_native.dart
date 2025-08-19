library payment_native;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of payment_native must implement.
abstract class PaymentNativePlatform extends PlatformInterface {
  PaymentNativePlatform() : super(token: _token);

  static final Object _token = Object();
  static PaymentNativePlatform _instance = MethodChannelPaymentNative();

  static PaymentNativePlatform get instance => _instance;

  static set instance(PaymentNativePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> initializePayment() {
    throw UnimplementedError('initializePayment() has not been implemented.');
  }

  Future<PaymentResult> processPayment(PaymentRequest request) {
    throw UnimplementedError('processPayment() has not been implemented.');
  }

  Future<List<PaymentMethod>> getAvailableMethods() {
    throw UnimplementedError('getAvailableMethods() has not been implemented.');
  }

  Stream<PaymentEvent> get paymentEvents {
    throw UnimplementedError('paymentEvents has not been implemented.');
  }
}

/// An implementation of [PaymentNativePlatform] that uses method channels.
class MethodChannelPaymentNative extends PaymentNativePlatform {
  final methodChannel = const MethodChannel('payment_native');
  final eventChannel = const EventChannel('payment_native_events');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> initializePayment() async {
    final result = await methodChannel.invokeMethod<bool>('initializePayment');
    return result ?? false;
  }

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
      'processPayment',
      request.toMap(),
    );
    return PaymentResult.fromMap(result ?? {});
  }

  @override
  Future<List<PaymentMethod>> getAvailableMethods() async {
    final result =
        await methodChannel.invokeMethod<List<dynamic>>('getAvailableMethods');
    return (result ?? []).map((item) => PaymentMethod.fromMap(item)).toList();
  }

  @override
  Stream<PaymentEvent> get paymentEvents {
    return eventChannel
        .receiveBroadcastStream()
        .map((event) => PaymentEvent.fromMap(event));
  }
}

/// Main plugin class that provides high-level payment functionality
class PaymentNative {
  static PaymentNativePlatform get _platform => PaymentNativePlatform.instance;

  static Future<String?> getPlatformVersion() {
    return _platform.getPlatformVersion();
  }

  static Future<bool> initializePayment() {
    return _platform.initializePayment();
  }

  static Future<PaymentResult> processPayment(PaymentRequest request) {
    return _platform.processPayment(request);
  }

  static Future<List<PaymentMethod>> getAvailableMethods() {
    return _platform.getAvailableMethods();
  }

  static Stream<PaymentEvent> get paymentEvents {
    return _platform.paymentEvents;
  }
}

/// Payment request class
class PaymentRequest {
  final double amount;
  final String currency;
  final PaymentMethodType method;
  final Map<String, dynamic>? metadata;

  const PaymentRequest({
    required this.amount,
    required this.currency,
    required this.method,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency,
      'method': method.toString(),
      'metadata': metadata,
    };
  }
}

/// Payment result class
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  const PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    this.data,
  });

  factory PaymentResult.fromMap(Map<String, dynamic> map) {
    return PaymentResult(
      success: map['success'] ?? false,
      transactionId: map['transactionId'],
      errorMessage: map['errorMessage'],
      data: map['data'],
    );
  }
}

/// Payment method class
class PaymentMethod {
  final String id;
  final String name;
  final PaymentMethodType type;
  final bool isEnabled;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.isEnabled,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: PaymentMethodType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => PaymentMethodType.creditCard,
      ),
      isEnabled: map['isEnabled'] ?? false,
    );
  }
}

/// Payment event class
class PaymentEvent {
  final PaymentEventType type;
  final Map<String, dynamic> data;

  const PaymentEvent({
    required this.type,
    required this.data,
  });

  factory PaymentEvent.fromMap(Map<String, dynamic> map) {
    return PaymentEvent(
      type: PaymentEventType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => PaymentEventType.unknown,
      ),
      data: map['data'] ?? {},
    );
  }
}

/// Payment method types
enum PaymentMethodType {
  creditCard,
  debitCard,
  paypal,
  applePay,
  googlePay,
  bankTransfer,
  cryptocurrency,
}

/// Payment event types
enum PaymentEventType {
  started,
  processing,
  completed,
  failed,
  cancelled,
  unknown,
}
