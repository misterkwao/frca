import 'dart:io';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frca/components/general_button.dart';
import 'package:frca/model_and_service/frca_service.dart';
import 'package:frca/pages/dashboard.dart';

class NotRegistered extends StatefulWidget {
  const NotRegistered({super.key});

  @override
  State<NotRegistered> createState() => _NotRegisteredState();
}

class _NotRegisteredState extends State<NotRegistered> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  bool _isCameraInitialized = false;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    startCamera();
  }

  Future<void> startCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras[1],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await cameraController.initialize();
        cameraController.setZoomLevel(1.3);

        if (!mounted) return;

        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // print('Error initializing camera: $e');
    }
  }

  void showRecognitionModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          // Timer to automatically take picture and send to the server
          if (!isVerified && _isCameraInitialized) {
            Timer(const Duration(seconds: 1), () async {
              await cameraController.takePicture().then((XFile? file) async {
                if (mounted && file != null) {
                  final File image = File(file.path);
                  bool verifyStats = await initFacialRecog(image);
                  if (mounted && verifyStats) {
                    setState(() {
                      isVerified = true;
                    });
                    Timer(const Duration(seconds: 1), () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DashBoard()));
                    });
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text("Face enrollment failed",
                                style: TextStyle(
                                    fontFamily: 'Montserrat', fontSize: 16))
                          ],
                        ),
                        backgroundColor: Color.fromARGB(255, 255, 119, 110),
                        padding: EdgeInsets.all(25),
                      ),
                    );
                  }
                }
              });
            });
          }
          return SizedBox(
            height: 450,
            child: Center(
              child: isVerified //checking isVerified state
                  ? const Column(
                      children: [
                        SizedBox(
                          height: 120,
                        ),
                        // Verification symbol
                        Icon(
                          Icons.verified_rounded,
                          size: 150,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        // Verification text
                        Text(
                          "Facial recognition completed!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            color: Colors.blueAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 30,
                        ),
                        // Warning
                        const Text(
                          'Please standby for scanning',
                          style:
                              TextStyle(fontFamily: 'Montserrat', fontSize: 15),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        // Camera
                        Container(
                          width: 200,
                          height: 230,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              width: 4,
                              color: const Color.fromRGBO(156, 188, 255, 1),
                            ),
                          ),
                          child: _isCameraInitialized
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  child: SizedBox(
                                    height: 230,
                                    child: AspectRatio(
                                      aspectRatio:
                                          cameraController.value.aspectRatio,
                                      child: CameraPreview(cameraController),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: CircularProgressIndicator()),
                        ),
                      ],
                    ),
            ),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Illustration
                  Image.asset('lib/images/facerecog.png', height: 280),
                  const SizedBox(
                    height: 20,
                  ),
                  // Header text
                  const Text(
                    "Let's get you recognized!",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Montserrat',
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Information
                  const Text(
                    "Register your face for the first time in order to mark attendances. Click scan to register.",
                    style: TextStyle(
                      fontSize: 17.5,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 85, 85, 85),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  // General button
                  GenBtn(
                    btnText: "Scan",
                    func: () => showRecognitionModal(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
