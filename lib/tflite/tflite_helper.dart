import 'dart:async';

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

import 'Result.dart';
import 'app_helper.dart';

class TFLiteHelper {
  static StreamController<List<Result>> tfLiteResultsController =
      StreamController.broadcast();
  static List<Result> _outputs;
  static var modelLoaded = false;

  static Future<String> loadModel() async {
    AppHelper.log("loadModel", "Loading model..");
    var res = await Tflite.loadModel(
      model: "assets/tflite/yolov2_tiny.tflite",
      labels: "assets/tflite/yolov2_tiny.txt",
    );
    print("Model: $res");
    return res;
  }

  static classifyImage(CameraImage image) async {
    await Tflite.runModelOnFrame(
            bytesList: image.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            numResults: 5)
        .then((value) {
      if (value.isNotEmpty) {
        AppHelper.log("classifyImage", "Results loaded. ${value.length}");

        //Clear previous results
        _outputs.clear();

        value.forEach((element) {
          _outputs.add(Result(element['confidence'], element['label']));

          AppHelper.log("classifyImage",
              "${element['confidence']} , ${element['index']}, ${element['label']}");
        });
      }

      //Sort results according to most confidence
      _outputs.sort((a, b) => a.confidence.compareTo(b.confidence));

      //Send results
      tfLiteResultsController.add(_outputs);
    });
  }

  static void disposeModel() {
    Tflite.close();
    tfLiteResultsController.close();
  }
}
