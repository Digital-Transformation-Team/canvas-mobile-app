import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:narxoz_face_id/features/camera/presentations/widgets/FaceCamera.dart';
import 'package:narxoz_face_id/features/students/data/change_status_request.dart';
import 'package:narxoz_face_id/features/students/domain/students_class.dart';

import '../../../core/overlays/loading_overlay.dart';
import '../data/send_image_request.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  List<CameraDescription>? cameras;
  int nextCamera = 0;
  bool isCameraGranted = false;
  bool _isDetecting = false;
  bool _isDetectingFace = false;
  Rect? _faceRect;

  @override
  void initState() {
    super.initState();
    fullCheck();
  }

  Future<void> fullCheck() async {
    await checkDataIntegrity(); // Проверяем все данные
  }

  Future<void> checkDataIntegrity() async {
    var ok = await isOK();
    if (!ok) {
      context.go('/courses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.camera_title),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white70,
      ),
      body: FaceCamera(
        cameraReverseButton: true,
        onCapture: (bytes) async {
          LoadingOverlay.show(context);
          Student? student = await sendImage(bytes);
          if (student != null) {
            showDialog<void>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.camera_right(student.name)),
                  content: Image.memory(bytes),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        await change_status(
                          student.web_id_assignment,
                          "complete",
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.yes_upper),
                    ),
                    ElevatedButton(onPressed: () {
                      Navigator.of(context).pop();
                    }, child: Text(AppLocalizations.of(context)!.no_upper)),
                  ],
                );
              },
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

          LoadingOverlay.hide();
        },
      ),
    );
  }
}
