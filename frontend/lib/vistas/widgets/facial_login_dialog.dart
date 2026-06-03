import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facenet_app/controles/admin_controller.dart';

// Paleta de tu LoginScreen
const _colorFondo = Color(0xFFF8F9FA);
const _colorBlanco = Color(0xFFFFFFFF);
const _colorGrisSuave = Color(0xFFE5E5E5);
const _colorGrisMedio = Color(0xFF7F7F7F);
const _colorNegroElegante = Color(0xFF1A1A1A);

class FacialLoginDialog extends StatefulWidget {
  const FacialLoginDialog({Key? key}) : super(key: key);

  @override
  State<FacialLoginDialog> createState() => _FacialLoginDialogState();
}

class _FacialLoginDialogState extends State<FacialLoginDialog> {
  File? _imagen;
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? archivo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (archivo != null) setState(() => _imagen = File(archivo.path));
  }

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Dialog(
      backgroundColor: _colorFondo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(28.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Acceso Administrador',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _colorNegroElegante,
                  fontFamily: 'LibreBaskerville',
                ),
              ),
              const SizedBox(height: 24),
              
              // Contenedor de Imagen Estilo Minimalista
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _colorGrisSuave,
                    borderRadius: BorderRadius.circular(8),
                    image: _imagen != null 
                        ? DecorationImage(image: FileImage(_imagen!), fit: BoxFit.cover) 
                        : null,
                  ),
                  child: _imagen == null 
                      ? const Icon(Icons.person, size: 48, color: _colorGrisMedio) 
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              
              // TextFields Estilo Corporativo
              TextField(
                controller: usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  labelStyle: TextStyle(color: _colorGrisMedio),
                  filled: true,
                  fillColor: _colorBlanco,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: _colorGrisMedio),
                  filled: true,
                  fillColor: _colorBlanco,
                ),
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancelar', style: TextStyle(color: _colorGrisMedio)),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => ElevatedButton(
                    onPressed: controller.loggingIn.value ? null : () async {
                      await controller.loginAdminFacial(
                        imagen: _imagen,
                        usuario: usuarioController.text.trim().isEmpty ? null : usuarioController.text.trim(),
                        password: passwordController.text.trim().isEmpty ? null : passwordController.text.trim(),
                      );
                      if (controller.adminToken.value.isNotEmpty) Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorNegroElegante,
                      foregroundColor: _colorBlanco,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: controller.loggingIn.value 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _colorBlanco)) 
                        : const Text('Iniciar sesión'),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}