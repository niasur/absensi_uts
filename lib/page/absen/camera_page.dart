import 'dart:io';

import 'package:absensi_app/page/absen/absen_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraAbsenPage extends StatefulWidget {
  const CameraAbsenPage({super.key});

  @override
  State<CameraAbsenPage> createState() => _CameraAbsenPageState();
}

class _CameraAbsenPageState extends State<CameraAbsenPage> {
  FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      enableLandmarks: true,
    ),
  );

  List<CameraDescription>? cameras;
  CameraController? controller;
  XFile? image;
  bool isBusy = false;
  String cameraError = "";

  @override
  void initState() {
    super.initState();
    loadCamera();
  }

  Future<void> loadCamera() async {
    try {
      final cameraPermission = await Permission.camera.status;
      if (!cameraPermission.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          throw Exception("Izin kamera ditolak.");
        }
      }

      cameras = await availableCameras();

      if (cameras == null || cameras!.isEmpty) {
        throw Exception("Tidak ada kamera yang tersedia.");
      }

      final frontCamera = cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first,
      );

      controller = CameraController(frontCamera, ResolutionPreset.medium);
      await controller!.initialize();

      debugPrint("✅ Kamera berhasil diinisialisasi");

      if (mounted) setState(() {
        cameraError = "";
      });
    } catch (e, stack) {
      debugPrint("❌ Gagal inisialisasi kamera: $e\n$stack");
      if (mounted) {
        setState(() {
          cameraError = "Ups, kamera bermasalah!";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Foto Selfie",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: controller == null || !controller!.value.isInitialized
                ? Center(
              child: Text(
                cameraError.isNotEmpty ? cameraError : "Sedang memuat kamera...",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : CameraPreview(controller!),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Lottie.asset("assets/raw/face_id_ring.json", fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width,
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Pastikan Anda berada di tempat terang, agar wajah terlihat jelas.",
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ClipOval(
                    child: Material(
                      color: theme.colorScheme.primary,
                      child: InkWell(
                        splashColor: theme.colorScheme.secondary,
                        onTap: () async {
                          final hasPermission = await handleLocationPermission();
                          try {
                            if (controller != null && controller!.value.isInitialized) {
                              controller!.setFlashMode(FlashMode.off);
                              image = await controller!.takePicture();

                              if (hasPermission) {
                                showLoaderDialog(context);
                                final inputImage = InputImage.fromFilePath(image!.path);
                                Platform.isAndroid
                                    ? await processImage(inputImage)
                                    : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AbsenPage(image: image),
                                  ),
                                );
                              } else {
                                showSnackBar("Nyalakan perizinan lokasi terlebih dahulu!");
                              }
                            } else {
                              showSnackBar("Kamera belum siap.");
                            }
                          } catch (e) {
                            showSnackBar("Ups, kamera bermasalah: $e");
                          }
                        },
                        child: const SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.camera_alt_outlined, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showSnackBar("Layanan lokasi belum aktif.");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showSnackBar("Izin lokasi ditolak.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showSnackBar("Izin lokasi ditolak permanen.");
      return false;
    }
    return true;
  }

  void showSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.error,
      shape: const StadiumBorder(),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void showLoaderDialog(BuildContext context) {
    final theme = Theme.of(context);
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary)),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Text("Sedang memeriksa data..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => alert,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    isBusy = false;

    if (mounted) {
      Navigator.of(context).pop(true);
      if (faces.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AbsenPage(image: image)),
        );
      } else {
        showSnackBar("Pastikan wajah Anda terlihat jelas dengan cahaya yang cukup!");
      }
    }
  }
}