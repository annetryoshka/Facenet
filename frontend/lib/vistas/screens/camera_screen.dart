import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../controles/asistencia_controller.dart';
import '../../utils/app_colors.dart';

// Paleta estética local
const _colorFondo = Color(0xFFF8F9FA);
const _colorBlanco = Color(0xFFFFFFFF);
const _colorGrisSuave = Color(0xFFE5E5E5);
const _colorGrisMedio = Color(0xFF7F7F7F);
const _colorNegroElegante = Color(0xFF1A1A1A);

class CameraScreen extends GetView<AsistenciaController> {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorFondo,
      appBar: AppBar(
        backgroundColor: _colorFondo,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: _colorNegroElegante),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "CONTROL DE ACCESO",
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 2.0,
            color: _colorGrisMedio,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Encabezado con Iconos lado a lado
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.security_rounded, size: 32, color: _colorNegroElegante),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Verificación Facial",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LibreBaskerville',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: _colorNegroElegante,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Posicione su rostro frente a la cámara para registrar su jornada laboral.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: _colorGrisMedio,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Contenedor de la cámara
              Expanded(
                child: Obx(() {
                  if (!controller.camaraInicializada.value) {
                    return _buildStatusContainer(
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(_colorNegroElegante),
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (controller.errorCamara.isNotEmpty) {
                    return _buildStatusContainer(
                      child: Text(
                        controller.errorCamara.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'Inter', color: _colorNegroElegante, fontSize: 14),
                      ),
                    );
                  }

                  final cameraController = controller.cameraController!;
                  return Container(
                    decoration: BoxDecoration(
                      color: _colorBlanco,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _colorGrisSuave, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: cameraController.value.previewSize?.height ?? 1080,
                                height: cameraController.value.previewSize?.width ?? 1920,
                                child: CameraPreview(cameraController),
                              ),
                            ),
                          ),
                          const _FaceOvalMask(),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Sección de feedback/botón
              Obx(() => _buildBottomActionArea()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _colorBlanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorGrisSuave, width: 1),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildBottomActionArea() {
    if (controller.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_colorNegroElegante))),
      );
    }
    if (controller.error.value != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(controller.error.value!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
      );
    }
    if (controller.empleadoRegistrado.value != null) {
      final emp = controller.empleadoRegistrado.value!;
      return ScaleTransition(
        scale: controller.scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: _colorBlanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: _colorGrisSuave)),
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 36),
              const SizedBox(height: 12),
              Text(emp.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
            ],
          ),
        ),
      );
    }
    return ElevatedButton(
      onPressed: () => controller.tomarFotoYRegistrar(),
      style: ElevatedButton.styleFrom(
        backgroundColor: _colorNegroElegante,
        foregroundColor: _colorBlanco,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text("Identificar Rostro"),
    );
  }
}

class _FaceOvalMask extends StatelessWidget {
  const _FaceOvalMask({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(_colorNegroElegante.withOpacity(0.4), BlendMode.srcOut),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: _colorNegroElegante),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.elliptical(200, 250)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}