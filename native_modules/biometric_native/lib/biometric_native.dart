library biometric_native;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of biometric_native must implement.
abstract class BiometricNativePlatform extends PlatformInterface {
  BiometricNativePlatform() : super(token: _token);

  static final Object _token = Object();
  static BiometricNativePlatform _instance = MethodChannelBiometricNative();

  static BiometricNativePlatform get instance => _instance;

  static set instance(BiometricNativePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isAvailable() {
    throw UnimplementedError('isAvailable() has not been implemented.');
  }

  Future<List<BiometricType>> getAvailableBiometrics() {
    throw UnimplementedError(
      'getAvailableBiometrics() has not been implemented.',
    );
  }

  Future<BiometricAuthResult> authenticate({
    required String reason,
    List<BiometricType>? allowedTypes,
    bool fallbackToPIN = false,
  }) {
    throw UnimplementedError('authenticate() has not been implemented.');
  }

  Stream<BiometricEvent> get biometricEvents {
    throw UnimplementedError('biometricEvents has not been implemented.');
  }
}

/// An implementation of [BiometricNativePlatform] that uses method channels.
class MethodChannelBiometricNative extends BiometricNativePlatform {
  final methodChannel = const MethodChannel('biometric_native');
  final eventChannel = const EventChannel('biometric_native_events');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> isAvailable() async {
    final result = await methodChannel.invokeMethod<bool>('isAvailable');
    return result ?? false;
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>(
      'getAvailableBiometrics',
    );
    return (result ?? [])
        .map(
          (item) => BiometricType.values.firstWhere(
            (e) => e.toString() == item,
            orElse: () => BiometricType.fingerprint,
          ),
        )
        .toList();
  }

  @override
  Future<BiometricAuthResult> authenticate({
    required String reason,
    List<BiometricType>? allowedTypes,
    bool fallbackToPIN = false,
  }) async {
    final result = await methodChannel
        .invokeMethod<Map<String, dynamic>>('authenticate', {
          'reason': reason,
          'allowedTypes': allowedTypes?.map((e) => e.toString()).toList(),
          'fallbackToPIN': fallbackToPIN,
        });
    return BiometricAuthResult.fromMap(result ?? {});
  }

  @override
  Stream<BiometricEvent> get biometricEvents {
    return eventChannel.receiveBroadcastStream().map(
      (event) => BiometricEvent.fromMap(event),
    );
  }
}

/// Main plugin class that provides high-level biometric functionality
class BiometricNative {
  static BiometricNativePlatform get _platform =>
      BiometricNativePlatform.instance;

  static Future<String?> getPlatformVersion() {
    return _platform.getPlatformVersion();
  }

  static Future<bool> isAvailable() {
    return _platform.isAvailable();
  }

  static Future<List<BiometricType>> getAvailableBiometrics() {
    return _platform.getAvailableBiometrics();
  }

  static Future<BiometricAuthResult> authenticate({
    required String reason,
    List<BiometricType>? allowedTypes,
    bool fallbackToPIN = false,
  }) {
    return _platform.authenticate(
      reason: reason,
      allowedTypes: allowedTypes,
      fallbackToPIN: fallbackToPIN,
    );
  }

  static Stream<BiometricEvent> get biometricEvents {
    return _platform.biometricEvents;
  }
}

/// Biometric authentication result
class BiometricAuthResult {
  final bool success;
  final BiometricAuthStatus status;
  final String? errorMessage;
  final BiometricType? usedBiometric;

  const BiometricAuthResult({
    required this.success,
    required this.status,
    this.errorMessage,
    this.usedBiometric,
  });

  factory BiometricAuthResult.fromMap(Map<String, dynamic> map) {
    return BiometricAuthResult(
      success: map['success'] ?? false,
      status: BiometricAuthStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => BiometricAuthStatus.unknown,
      ),
      errorMessage: map['errorMessage'],
      usedBiometric: map['usedBiometric'] != null
          ? BiometricType.values.firstWhere(
              (e) => e.toString() == map['usedBiometric'],
              orElse: () => BiometricType.fingerprint,
            )
          : null,
    );
  }
}

/// Biometric event class
class BiometricEvent {
  final BiometricEventType type;
  final Map<String, dynamic> data;

  const BiometricEvent({required this.type, required this.data});

  factory BiometricEvent.fromMap(Map<String, dynamic> map) {
    return BiometricEvent(
      type: BiometricEventType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => BiometricEventType.unknown,
      ),
      data: map['data'] ?? {},
    );
  }
}

/// Available biometric types
enum BiometricType { fingerprint, face, voice, iris, palm }

/// Biometric authentication status
enum BiometricAuthStatus {
  success,
  failed,
  cancelled,
  timeout,
  notAvailable,
  notEnrolled,
  unknown,
}

/// Biometric event types
enum BiometricEventType {
  started,
  progress,
  completed,
  error,
  cancelled,
  unknown,
}
