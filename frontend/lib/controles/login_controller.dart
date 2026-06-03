import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/services/api_service.dart';
import 'package:facenet_app/vistas/screens/admin_screen.dart';
import 'package:facenet_app/vistas/screens/camera_screen.dart';

class LoginController extends GetxController with GetSingleTickerProviderStateMixin {
  // Controladores de UI animada
  late AnimationController animController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Controladores del diálogo de administración
  final passwordController = TextEditingController();
  final String correctPassword = "admin123";
  final RxBool obscureText = true.obs;
  final RxBool loggingInAdmin = false.obs;

  // API Service
  late ApiService _apiService;

  @override
  void onInit() {
    super.onInit();
    _apiService = ApiService();
    
    // Inicialización de la animación original
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
    Get.to(() => CameraScreen());
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
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(15),
      );
    }
  }

  // Login admin por reconocimiento facial
  Future<void> loginAdminFacial(File imagen) async {
    loggingInAdmin.value = true;
    try {
      var result = await _apiService.loginAdmin(imagen: imagen);
      
      if (result['success'] && result['data'] != null && result['data']['token'] != null) {
        Get.snackbar(
          "Login Exitoso",
          "Bienvenido administrador",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back(); // Cierra el dialog
        Get.to(() => AdminScreen());
      } else {
        Get.snackbar(
          "Error de Autenticación",
          result['error'] ?? "No se pudo autenticar",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Error en la comunicación con el servidor: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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