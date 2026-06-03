import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:facenet_app/data/models/empleado.dart';
import 'package:facenet_app/data/models/app_state.dart'; 
import 'package:facenet_app/controles/admin_controller.dart';
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
      
      // Tomar foto
      final XFile foto = await cameraController!.takePicture();
      
      // Esperar a que se guarde
      await Future.delayed(Duration(milliseconds: 500));
      
      // Verificar que el archivo existe
      final file = File(foto.path);
      if (!await file.exists()) {
        error.value = "La foto no se guardó correctamente";
        isLoading.value = false;
        return;
      }
      
      // Enviar imagen
      var result = await _apiService.enviarImagen(foto.path);
      
      if (result['success']) {
        final data = result['data'];
        final accesos = data['accesos'] as List? ?? [];
        
        // --- BLOQUE INYECTADO: MANEJO DE ACCESOS EXACTO ---
        if (accesos.isNotEmpty) {
          final primerAcceso = accesos[0];
          final identificado = primerAcceso['identificado'] == true;
          
          if (identificado) {
            // CASO ÉXITO
            final nombreRostro = primerAcceso['persona'] ?? "Empleado";
            final tipoAcceso = primerAcceso['tipo_acceso'] ?? "entrada";
            
            final empleado = Empleado(
              id: "E_${DateTime.now().millisecondsSinceEpoch}",
              nombre: nombreRostro,
              departamento: tipoAcceso,
            );
            
            animController.forward();
            empleadoRegistrado.value = empleado;
            tipo.value = tipoAcceso;
            error.value = null;
            isLoading.value = false;
            
            await Future.delayed(const Duration(seconds: 3));
            Get.back();
            await Future.delayed(const Duration(seconds: 1));
            try {
              Get.find<AdminController>().cargarEmpleados();
              Get.find<AdminController>().cargarHistorial();
            } catch (e) {
              print('AdminController no inicializado: $e');
            }
          } else {
            // CASO ERROR - Persona desconocida
            error.value = "Persona desconocida. Intenta nuevamente.";
            isLoading.value = false;
            // NO hacer Get.back() - dejar que reintente
          }
        }
        // --- FIN DEL BLOQUE INYECTADO ---
      } else {
        error.value = result['error'] ?? "Error en detección";
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
      error.value = 'Error: $e';
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