import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/overlays/loading_overlay.dart';
import '../../students/domain/students_class.dart';
import '../data/send_image_request.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

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
    var ok = await isOK();
    if (!ok) {
      context.go('/courses');
    }
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.camera_title),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white70,
      ),
      body: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: EdgeInsets.all(8),
            child: IconButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.white30),
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
                ? Container(
                  width: size.width,
                  height: size.height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Container(
                      width: 100, // the actual width is not important here
                      child: CameraPreview(_controller!),
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
                      child: Text(
                        AppLocalizations.of(context)!.camera_give_permission,
                      ),
                    ),
                  ],
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          LoadingOverlay.show(context);
          final image = await _controller!.takePicture();
          String? student_name = await sendImage(image);
          LoadingOverlay.hide();
          if (student_name != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.camera_hello(student_name),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.camera_student_not_found,
                ),
              ),
            );
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: Icon(Icons.camera),
      ),
    );
  }
}
