library camera_native;

import 'dart:async';

import 'camera_native_platform_interface.dart';

/// Main plugin class that provides high-level camera functionality
class CameraNative {
  static CameraNativePlatform get _platform => CameraNativePlatform.instance;

  /// Get the platform version
  static Future<String?> getPlatformVersion() {
    return _platform.getPlatformVersion();
  }

  /// Initialize the camera system
  static Future<bool> initializeCamera() {
    return _platform.initializeCamera();
  }

  /// Capture a photo and return the file path
  static Future<String?> capturePhoto() {
    return _platform.capturePhoto();
  }

  /// Start video recording
  static Future<bool> startVideoRecording() {
    return _platform.startVideoRecording();
  }

  /// Stop video recording and return the file path
  static Future<String?> stopVideoRecording() {
    return _platform.stopVideoRecording();
  }

  /// Stream of camera state changes
  static Stream<Map<String, dynamic>> get cameraStateStream {
    return _platform.cameraStateStream;
  }
}

/// Camera configuration class
class CameraConfig {
  final int width;
  final int height;
  final int quality;
  final bool enableFlash;
  final bool enableHDR;

  const CameraConfig({
    this.width = 1920,
    this.height = 1080,
    this.quality = 85,
    this.enableFlash = false,
    this.enableHDR = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
      'quality': quality,
      'enableFlash': enableFlash,
      'enableHDR': enableHDR,
    };
  }
}

/// Camera state enumeration
enum CameraState { idle, initializing, ready, capturing, recording, error }
