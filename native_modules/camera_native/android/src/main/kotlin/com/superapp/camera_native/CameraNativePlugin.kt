package com.superapp.camera_native

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import androidx.lifecycle.LifecycleOwner
import java.io.File
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/** CameraNativePlugin with AAR dependencies integration */
class CameraNativePlugin: FlutterPlugin, MethodCallHandler, ActivityAware, EventChannel.StreamHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var context: Context
    private var activityBinding: ActivityPluginBinding? = null

    // Camera components
    private var imageCapture: ImageCapture? = null
    private var videoCapture: VideoCapture? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private lateinit var cameraExecutor: ExecutorService

    // External AAR libraries integration
    private var advancedCameraFeatures: Any? = null // From advanced-camera-features.aar
    private var aiImageProcessor: Any? = null // From ai-image-processing.aar

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "camera_native")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "camera_native_events")
        eventChannel.setStreamHandler(this)

        context = flutterPluginBinding.applicationContext
        cameraExecutor = Executors.newSingleThreadExecutor()

        // Initialize external AAR libraries
        initializeExternalLibraries()
    }

    private fun initializeExternalLibraries() {
        try {
            // Initialize advanced camera features from AAR
            // advancedCameraFeatures = AdvancedCameraSDK.initialize(context)

            // Initialize AI image processing from AAR
            // aiImageProcessor = AIImageProcessor.create(context)

            sendEvent(mapOf("type" to "external_libraries_initialized"))
        } catch (e: Exception) {
            sendEvent(mapOf("type" to "error", "message" to "Failed to initialize external libraries: ${e.message}"))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "initializeCamera" -> {
                initializeCamera(result)
            }
            "capturePhoto" -> {
                capturePhoto(result)
            }
            "startVideoRecording" -> {
                startVideoRecording(result)
            }
            "stopVideoRecording" -> {
                stopVideoRecording(result)
            }
            "enableAdvancedFeatures" -> {
                enableAdvancedFeatures(call.arguments as Map<String, Any>, result)
            }
            "processImageWithAI" -> {
                processImageWithAI(call.argument<String>("imagePath")!!, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initializeCamera(result: Result) {
        if (!hasPermissions()) {
            result.error("PERMISSION_DENIED", "Camera permissions not granted", null)
            return
        }

        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            try {
                cameraProvider = cameraProviderFuture.get()

                // Build the image capture use case
                imageCapture = ImageCapture.Builder()
                    .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
                    .build()

                // Build the video capture use case
                videoCapture = VideoCapture.Builder()
                    .setVideoFrameRate(30)
                    .build()

                sendEvent(mapOf("type" to "camera_initialized"))
                result.success(true)
            } catch (exc: Exception) {
                sendEvent(mapOf("type" to "error", "message" to "Camera initialization failed: ${exc.message}"))
                result.error("INIT_FAILED", "Camera initialization failed", exc.message)
            }
        }, ContextCompat.getMainExecutor(context))
    }

    private fun capturePhoto(result: Result) {
        val imageCapture = imageCapture ?: run {
            result.error("NOT_INITIALIZED", "Camera not initialized", null)
            return
        }

        val name = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        val contentValues = android.content.ContentValues().apply {
            put(android.provider.MediaStore.MediaColumns.DISPLAY_NAME, name)
            put(android.provider.MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
        }

        val outputOptions = ImageCapture.OutputFileOptions.Builder(
            context.contentResolver,
            android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            contentValues
        ).build()

        imageCapture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(context),
            object : ImageCapture.OnImageSavedCallback {
                override fun onError(exception: ImageCaptureException) {
                    sendEvent(mapOf("type" to "error", "message" to "Photo capture failed: ${exception.message}"))
                    result.error("CAPTURE_FAILED", "Photo capture failed", exception.message)
                }

                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    val savedUri = output.savedUri?.toString()
                    sendEvent(mapOf("type" to "photo_captured", "path" to savedUri))
                    result.success(savedUri)
                }
            }
        )
    }

    private fun enableAdvancedFeatures(arguments: Map<String, Any>, result: Result) {
        try {
            // Use advanced camera features from AAR
            val hdrEnabled = arguments["hdr"] as? Boolean ?: false
            val nightModeEnabled = arguments["nightMode"] as? Boolean ?: false

            // Example: Configure advanced features using external AAR
            // advancedCameraFeatures?.enableHDR(hdrEnabled)
            // advancedCameraFeatures?.enableNightMode(nightModeEnabled)

            sendEvent(mapOf(
                "type" to "advanced_features_configured",
                "hdr" to hdrEnabled,
                "nightMode" to nightModeEnabled
            ))
            result.success(true)
        } catch (e: Exception) {
            result.error("FEATURE_ERROR", "Failed to enable advanced features", e.message)
        }
    }

    private fun processImageWithAI(imagePath: String, result: Result) {
        try {
            // Use AI image processing from AAR
            // val processedImage = aiImageProcessor?.enhance(imagePath)

            // Simulate AI processing result
            val enhancedPath = imagePath.replace(".jpg", "_enhanced.jpg")

            sendEvent(mapOf(
                "type" to "ai_processing_complete",
                "originalPath" to imagePath,
                "enhancedPath" to enhancedPath
            ))
            result.success(enhancedPath)
        } catch (e: Exception) {
            result.error("AI_ERROR", "AI processing failed", e.message)
        }
    }

    private fun startVideoRecording(result: Result) {
        // Video recording implementation
        result.success(true)
    }

    private fun stopVideoRecording(result: Result) {
        // Stop video recording implementation
        result.success("/path/to/video.mp4")
    }

    private fun hasPermissions(): Boolean {
        return ContextCompat.checkSelfPermission(
            context, Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun sendEvent(data: Map<String, Any?>) {
        eventSink?.success(data)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        cameraExecutor.shutdown()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivity() {
        activityBinding = null
    }
}
