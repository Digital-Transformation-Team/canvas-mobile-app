import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/consts.dart';

class FaceCamera extends StatefulWidget {
  final onCapture;
  final cameraReverseButton;
  final autoCapture;

  const FaceCamera({
    super.key,
    this.onCapture,
    this.cameraReverseButton = false,
    this.autoCapture = false,
  });

  @override
  State<FaceCamera> createState() => _FaceCameraState();
}

class _FaceCameraState extends State<FaceCamera> {
  late CameraController _controller;
  List<CameraDescription>? cameras;
  int nextCamera = 0;
  bool isCameraGranted = false;
  bool _isDetecting = false;
  bool _isCapturing = false;
  Rect? _faceRect;

  @override
  void initState() {
    super.initState();
    checkCameraPermission();
  }

  Future<void> checkCameraPermission() async {
    var status = await Permission.camera.status;
    await checkGranting(status);
  }

  Future<void> checkGranting(PermissionStatus status) async {
    if (status.isGranted) {
      await initCamera(1);
    }
    setState(() {
      isCameraGranted = status.isGranted;
    });
  }

  Future<void> initCamera(camera) async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras![camera],
      ResolutionPreset.medium,
      imageFormatGroup:
          Platform.isAndroid
              ? ImageFormatGroup
                  .nv21 // for Android
              : ImageFormatGroup.bgra8888, // for iOS,
    );
    await _controller.initialize();
    await _controller.startImageStream(_processCameraImage);
    if (mounted) setState(() {});
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    await checkGranting(status);
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        throw Exception("Invalid rotation value: $rotation");
    }
  }

  InputImage convertCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final rotation = _rotationIntToImageRotation(
      _controller.description.sensorOrientation,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format:
            Platform.isAndroid
                ? InputImageFormat
                    .nv21 // for Android
                : InputImageFormat.bgra8888,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final inputImage = convertCameraImage(image);
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        var boundingBox = faces.first.boundingBox;
        Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
        Size widgetSize = Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        );
        if (MediaQuery.of(context).orientation == Orientation.portrait &&
            imageSize.width > imageSize.height) {
          imageSize = Size(
            imageSize.height,
            imageSize.width,
          ); // swap for portrait
        }
        final offsetX = (imageSize.width - widgetSize.width) / 2;
        final scaleX = widgetSize.width / imageSize.width;
        double left = boundingBox.left - offsetX;
        double top = boundingBox.top;
        double width = boundingBox.width * scaleX;
        double height = boundingBox.height * scaleX;
        if (nextCamera == 0) {
          left = widgetSize.width - (left + width); // mirror horizontally
        }

        _faceRect = new Rect.fromLTWH(left, top, width, height);
      } else {
        _faceRect = null;
      }

      setState(() {});
    } catch (e) {
      print('Face detection error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> changeCamera() async {
    initCamera(nextCamera);
    nextCamera = nextCamera == 0 ? 1 : 0;
  }

  Future<void> capture() async {
    if (_isCapturing) return;
    _isCapturing = true;

    try {
      final XFile xfile = await _controller.takePicture();
      final bytes = await xfile.readAsBytes();

      final InputImage inputImage = InputImage.fromFilePath(xfile.path);

      final options = FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
      );
      final faceDetector = FaceDetector(options: options);
      final List<Face> faces = await faceDetector.processImage(inputImage);

      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage != null) {
        for (Face face in faces) {
          final Rect boundingBox = face.boundingBox;

          int left = boundingBox.left.toInt().clamp(0, originalImage.width);
          int top = boundingBox.top.toInt().clamp(0, originalImage.height);
          int width = boundingBox.width.toInt().clamp(
            0,
            originalImage.width - left,
          );
          int height = boundingBox.height.toInt().clamp(
            0,
            originalImage.height - top,
          );

          final cropped = img.copyCrop(
            originalImage,
            x: left,
            y: top,
            width: width,
            height: height,
          );

          final bytes = img.encodeJpg(cropped);

          widget.onCapture(bytes);
        }
      }
    } catch (e) {
      print("Make shot error: $e");
    } finally {
      _isCapturing = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return isCameraGranted
        ? SizedBox(
          width: size.width,
          height: size.height,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              child: Stack(
                children: [
                  CameraPreview(_controller),
                  if (_faceRect != null) ...[
                    Positioned(
                      left: _faceRect!.left,
                      top: _faceRect!.top,
                      width: _faceRect!.width,
                      height: _faceRect!.height,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.greenAccent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                  Positioned(
                    bottom: 10,
                    left: 100,
                    right: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child:
                              (widget.cameraReverseButton)
                                  ? IconButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        Colors.white,
                                      ),
                                    ),
                                    icon: Icon(Icons.cameraswitch),
                                    onPressed: () async {
                                      await changeCamera();
                                    },
                                  )
                                  : Padding(padding: EdgeInsets.zero),
                        ),
                        SizedBox(
                          child:
                              (!widget.cameraReverseButton)
                                  ? IconButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        Colors.white,
                                      ),
                                    ),
                                    icon: Icon(Icons.flash_off),
                                    onPressed: () async {
                                      await changeCamera();
                                    },
                                  )
                                  : Padding(padding: EdgeInsets.zero),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    bottom: 10,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        child:
                            (!widget.autoCapture)
                                ? IconButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      Colors.white,
                                    ),
                                    fixedSize: WidgetStatePropertyAll(
                                      Size(60, 60),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 40,
                                  ),
                                  onPressed: () async {
                                    await capture();
                                  },
                                )
                                : Padding(padding: EdgeInsets.zero),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.camera_not_allowed,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: requestCameraPermission,
              child: Text(AppLocalizations.of(context)!.camera_give_permission),
            ),
          ],
        );
  }
}
