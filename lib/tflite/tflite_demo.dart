import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video/tflite/camera_helper.dart';
import 'package:video/tflite/tflite_helper.dart';

import 'app_helper.dart';

class TFLiteDemo extends StatefulWidget {
  @override
  _TFLiteDemoState createState() => _TFLiteDemoState();
}

class _TFLiteDemoState extends State<TFLiteDemo> with TickerProviderStateMixin {
  AnimationController _colorAnimController;
  Animation _colorTween;

  List<dynamic> outputs;

  @override
  void initState() {
    super.initState();

    TFLiteHelper.loadModel().then((value) {
      setState(() {
        TFLiteHelper.modelLoaded = true;
      });
    });

    CameraHelper.initializerCamera();

    _setupAnimation();

    TFLiteHelper.tfLiteResultsController.stream.listen(
        (event) {
          event.forEach((element) {
            _colorAnimController.animateTo(
              element.confidence,
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 500),
            );
          });

          outputs = event;

          setState(() {
            CameraHelper.isDetecting = false;
          });
        },
        onDone: () {},
        onError: (error) {
          AppHelper.log("listen", error);
        });
  }

  void _setupAnimation() {
    _colorAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _colorTween = ColorTween(begin: Colors.green, end: Colors.red)
        .animate(_colorAnimController);
  }

  @override
  void dispose() {
    TFLiteHelper.disposeModel();
    CameraHelper.cameraController.dispose();
    AppHelper.log("dispose", "Clear resources.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("TFLite Demo"),
        ),
        body: FutureBuilder<void>(
          future: CameraHelper.initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  CameraPreview(CameraHelper.cameraController),
                  _buildResultsWidget(
                      MediaQuery.of(context).size.width, outputs),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildResultsWidget(double width, List<dynamic> outputs) {
    print(outputs);
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200.0,
          width: width,
          color: Colors.white,
          child: outputs != null && outputs.isNotEmpty
              ? ListView.builder(
                  itemCount: outputs.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(20.0),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Text(
                          outputs[index].label,
                          style: TextStyle(
                            color: _colorTween.value,
                            fontSize: 20.0,
                          ),
                        ),
                        AnimatedBuilder(
                            animation: _colorAnimController,
                            builder: (context, child) => LinearPercentIndicator(
                                  width: width * 0.88,
                                  lineHeight: 14.0,
                                  percent: outputs[index].confidence,
                                  progressColor: _colorTween.value,
                                )),
                        Text(
                          "${(outputs[index].confidence * 100.0).toStringAsFixed(2)} %",
                          style: TextStyle(
                            color: _colorTween.value,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    );
                  },
                )
              : Center(
                  child: Text(
                    "Waiting for model to detect...",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
