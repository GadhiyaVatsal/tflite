import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video/tflite/app_helper.dart';
import 'package:video/tflite/tflite_helper.dart';

class CameraHelper {
  static CameraController cameraController;

  static bool isDetecting = false;
  static CameraLensDirection _direction = CameraLensDirection.back;
  static Future<void> initializeControllerFuture;

  static Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  static void initializerCamera() async {
    AppHelper.log("_initilizeCamera", "Initializing camera...");

    cameraController = CameraController(
      await _getCamera(_direction),
      defaultTargetPlatform == TargetPlatform.iOS
          ? ResolutionPreset.low
          : ResolutionPreset.high,
      enableAudio: false,
    );

    initializeControllerFuture = cameraController.initialize().then((_) {
      AppHelper.log(
          "_initializeCamera", "Camera initialized, starting camera stream..");

      cameraController.startImageStream((CameraImage image) {
        if (!TFLiteHelper.modelLoaded) return;
        if (isDetecting) return;
        isDetecting = true;
        try {
          TFLiteHelper.classifyImage(image);
        } catch (e) {
          print(e);
        }
      });
    });
  }
}
