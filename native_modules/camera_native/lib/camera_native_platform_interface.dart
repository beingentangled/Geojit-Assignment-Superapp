import 'dart:async';

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of camera_native must implement.
abstract class CameraNativePlatform extends PlatformInterface {
  CameraNativePlatform() : super(token: _token);

  static final Object _token = Object();
  static CameraNativePlatform _instance = MethodChannelCameraNative();

  static CameraNativePlatform get instance => _instance;

  static set instance(CameraNativePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> initializeCamera() {
    throw UnimplementedError('initializeCamera() has not been implemented.');
  }

  Future<String?> capturePhoto() {
    throw UnimplementedError('capturePhoto() has not been implemented.');
  }

  Future<bool> startVideoRecording() {
    throw UnimplementedError('startVideoRecording() has not been implemented.');
  }

  Future<String?> stopVideoRecording() {
    throw UnimplementedError('stopVideoRecording() has not been implemented.');
  }

  Stream<Map<String, dynamic>> get cameraStateStream {
    throw UnimplementedError('cameraStateStream has not been implemented.');
  }
}

/// An implementation of [CameraNativePlatform] that uses method channels.
class MethodChannelCameraNative extends CameraNativePlatform {
  final methodChannel = const MethodChannel('camera_native');
  final eventChannel = const EventChannel('camera_native_events');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> initializeCamera() async {
    final result = await methodChannel.invokeMethod<bool>('initializeCamera');
    return result ?? false;
  }

  @override
  Future<String?> capturePhoto() async {
    final imagePath = await methodChannel.invokeMethod<String>('capturePhoto');
    return imagePath;
  }

  @override
  Future<bool> startVideoRecording() async {
    final result = await methodChannel.invokeMethod<bool>(
      'startVideoRecording',
    );
    return result ?? false;
  }

  @override
  Future<String?> stopVideoRecording() async {
    final videoPath = await methodChannel.invokeMethod<String>(
      'stopVideoRecording',
    );
    return videoPath;
  }

  @override
  Stream<Map<String, dynamic>> get cameraStateStream {
    return eventChannel.receiveBroadcastStream().cast<Map<String, dynamic>>();
  }
}
