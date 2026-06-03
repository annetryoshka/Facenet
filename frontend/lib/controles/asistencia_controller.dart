import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:facenet_app/data/models/empleado.dart';
import 'package:facenet_app/data/models/app_state.dart'; 
import 'package:facenet_app/services/api_service.dart';

class AsistenciaController extends GetxController with GetSingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  CameraController? cameraController;
  final RxBool camaraInicializada = false.obs;
  final RxString errorCamara = "".obs;

  late AnimationController animController;
  late Animation<double> scaleAnimation;

  final RxBool isLoading = false.obs;
  final Rxn<Empleado> empleadoRegistrado = Rxn<Empleado>();
  final RxnString error = RxnString();
  final RxnString tipo = RxnString();

  @override
  void onInit() {
    super.onInit();
    _inicializarAnimacion();
    inicializarCamara(); 
  }

  void _inicializarAnimacion() {
    animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.elasticOut),
    );
  }

  Future<void> inicializarCamara() async {
    try {
      camaraInicializada.value = false;
      errorCamara.value = "";

      final camaras = await availableCameras();
      if (camaras.isEmpty) {
        errorCamara.value = "No se detectaron cámaras en el emulador.";
        return;
      }

      final camaraFrontal = camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => camaras.first,
      );

      cameraController = CameraController(
        camaraFrontal,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      camaraInicializada.value = true;
    } catch (e) {
      errorCamara.value = "Error al conectar con la Webcam: $e";
      camaraInicializada.value = false;
    }
  }

  Future<void> tomarFotoYRegistrar() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      error.value = "La cámara aún no se ha inicializado por completo.";
      return;
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;
      empleadoRegistrado.value = null;
      error.value = null;
      tipo.value = null;

      final XFile foto = await cameraController!.takePicture();
      final bytes = await foto.readAsBytes();
      String base64Image = base64Encode(bytes);
      
      var result = await _apiService.enviarImagen(base64Image);

      if (result['success']) {
        final data = result['data'];
        final nombreRostro = data['nombre'] ?? "Empleado";

        final empleado = AppState.registrarEntradaSalidaSimulada(
          "rostro_${DateTime.now().millisecondsSinceEpoch}",
          nombreRostro,
        );

        animController.forward();

        isLoading.value = false;
        empleadoRegistrado.value = empleado;
        tipo.value = empleado?.estado;
        error.value = null;

        await Future.delayed(const Duration(seconds: 4));
        _limpiarFormulario();
        Get.back(); 
      } else {
        isLoading.value = false;
        error.value = result['error'] ?? "No se reconoció el rostro.";
        empleadoRegistrado.value = null;
      }
    } catch (e) {
      isLoading.value = false;
      error.value = 'Error en el escaneo: $e';
    }
  }

  void _limpiarFormulario() {
    empleadoRegistrado.value = null;
    tipo.value = null;
    error.value = null;
    animController.reset();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    animController.dispose();
    super.onClose();
  }
}