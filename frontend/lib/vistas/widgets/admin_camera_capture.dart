import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';

// Paleta corporativa unificada
const _colorFondo = Color(0xFFF8F9FA);
const _colorBlanco = Color(0xFFFFFFFF);
const _colorGrisMedio = Color(0xFF7F7F7F);
const _colorNegroElegante = Color(0xFF1A1A1A);

class AdminCameraCapture extends StatefulWidget {
  final Function(File) onImageCapture;

  const AdminCameraCapture({
    Key? key,
    required this.onImageCapture,
  }) : super(key: key);

  @override
  State<AdminCameraCapture> createState() => _AdminCameraCaptureState();
}

class _AdminCameraCaptureState extends State<AdminCameraCapture> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      // Buscamos la cámara frontal (front)
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras[0],
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
      );
      
      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint("Error inicializando cámara: $e");
    }
  }

  Future<void> _capturePhoto() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    try {
      setState(() => _isCapturing = true);
      final XFile photo = await _cameraController!.takePicture();
      widget.onImageCapture(File(photo.path));
      Get.back();
    } catch (e) {
      debugPrint("Error capturando foto: $e");
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorFondo,
      appBar: AppBar(
        backgroundColor: _colorFondo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: _colorNegroElegante),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Captura Facial",
          style: TextStyle(color: _colorNegroElegante, fontFamily: 'LibreBaskerville', fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _isCameraInitialized && _cameraController != null
          ? Stack(
              children: [
                // Vista previa rectangular estilo CameraScreen
                Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _colorNegroElegante, width: 2),
                  ),
                  width: Get.width * 0.85,
                  height: Get.height * 0.5,
                  // APLICAMOS ESTE CAMBIO:
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FittedBox(
                      fit: BoxFit.cover, // Esto evita que se distorsione al rellenar el espacio
                      child: SizedBox(
                        // Obtenemos la relación de aspecto del preview
                        width: _cameraController!.value.previewSize?.height,
                        height: _cameraController!.value.previewSize?.width,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  ),
                ),
              ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: _colorNegroElegante)),
    );
  }
}