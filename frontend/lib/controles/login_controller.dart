import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/services/api_service.dart';
import 'package:facenet_app/vistas/screens/admin_screen.dart';
import 'package:facenet_app/vistas/screens/camera_screen.dart';
import '../../controles/asistencia_controller.dart'; 
import '../../utils/app_colors.dart'; // Para usar tus estados de éxito/error globales

class LoginController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  final passwordController = TextEditingController();
  final String correctPassword = "admin123";
  final RxBool obscureText = true.obs;
  final RxBool loggingInAdmin = false.obs;

  late ApiService _apiService;

  // Paleta premium coordinada
  static const _colorNegroElegante = Color(0xFF1A1A1A);
  static const _colorBlanco = Color(0xFFFFFFFF);

  @override
  void onInit() {
    super.onInit();
    _apiService = ApiService();
    
    animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    fadeAnimation = CurvedAnimation(parent: animController, curve: Curves.easeInOut);
    slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: animController, curve: Curves.easeOut));

    animController.forward();
  }

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  void irACamara() {
    Get.to(
      () => const CameraScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AsistenciaController>(() => AsistenciaController());
      }),
    );
  }

  void validarAccesoAdmin() {
    if (passwordController.text == correctPassword) {
      passwordController.clear();
      Get.back(); 
      Get.to(() => AdminScreen()); 
    } else {
      Get.snackbar(
        "Error de Autenticación",
        "Contraseña incorrecta",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9), // Sofisticado, sin rojo semáforo
        colorText: _colorBlanco,
        margin: const EdgeInsets.all(15),
        borderRadius: 8,
      );
    }
  }

  Future<void> loginAdminFacial(File imagen) async {
    loggingInAdmin.value = true;
    try {
      var result = await _apiService.loginAdmin(imagen: imagen);
      
      if (result['success'] && result['data'] != null && result['data']['token'] != null) {
        Get.snackbar(
          "Login Exitoso",
          "Bienvenido administrador",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _colorNegroElegante, // Fondo negro bloque premium
          colorText: _colorBlanco,
          borderRadius: 8,
        );
        Get.back(); 
        Get.to(() => AdminScreen());
      } else {
        Get.snackbar(
          "Error de Autenticación",
          result['error'] ?? "No se pudo autenticar",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.9),
          colorText: _colorBlanco,
          borderRadius: 8,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Error en la comunicación con el servidor",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: _colorBlanco,
        borderRadius: 8,
      );
    } finally {
      loggingInAdmin.value = false;
    }
  }

  @override
  void onClose() {
    animController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}