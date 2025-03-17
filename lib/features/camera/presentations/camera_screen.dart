import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/overlays/loading_overlay.dart';
import '../../students/domain/students_class.dart';
import '../data/send_image_request.dart';

class CameraScreen extends StatefulWidget {
  final String taskId;
  final String courseId;
  const CameraScreen({super.key, required this.taskId, required this.courseId});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  int nextCamera = 1;
  bool isCameraGranted = false;

  @override
  void initState() {
    super.initState();
    checkCameraPermission(); // Проверяем разрешение при запуске
  }

  Future<void> checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      await initCamera();
    }
    setState(() {
      isCameraGranted = status.isGranted;
    });
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      await initCamera();
    }
    setState(() {
      isCameraGranted = status.isGranted;
    });
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras![0], ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> changeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras![nextCamera],
      ResolutionPreset.medium,
    );
    await _controller!.initialize();
    if (mounted) setState(() {});
    nextCamera = nextCamera == 0 ? 1 : 0;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance")),
      body: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: EdgeInsets.all(8),
            child: IconButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.white70),
              ),
              icon: Icon(Icons.cameraswitch),
              onPressed: () async {
                await changeCamera();
              },
            ),
          ),
        ),
        body:
            isCameraGranted
                ? CameraPreview(_controller!)
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "🚫 Камера не разрешена",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: requestCameraPermission,
                      child: Text("Разрешить доступ"),
                    ),
                  ],
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          LoadingOverlay.show(context);
          final image = await _controller!.takePicture();
          Student? student = await sendImage(image, widget.taskId, widget.courseId);
          LoadingOverlay.hide();
          if (student != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hello ${student.name}'),
              ),
            );
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
