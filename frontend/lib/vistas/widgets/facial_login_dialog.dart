import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facenet_app/controles/admin_controller.dart';

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
    return AlertDialog(
      title: const Text('Login Admin (Facial)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _imagen != null
                ? Image.file(_imagen!, width: 160, height: 160, fit: BoxFit.cover)
                : Container(width: 160, height: 160, color: Colors.grey[200], child: const Icon(Icons.person, size: 80, color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo), label: const Text('Seleccionar imagen')),
            const SizedBox(height: 12),
            TextField(controller: usuarioController, decoration: const InputDecoration(labelText: 'Usuario (opcional)')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña (fallback)'), obscureText: true),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        Obx(() => ElevatedButton(
              onPressed: controller.loggingIn.value
                  ? null
                  : () async {
                      await controller.loginAdminFacial(
                        imagen: _imagen,
                        usuario: usuarioController.text.trim().isEmpty ? null : usuarioController.text.trim(),
                        password: passwordController.text.trim().isEmpty ? null : passwordController.text.trim(),
                      );
                      if (controller.adminToken.value.isNotEmpty) Get.back();
                    },
              child: controller.loggingIn.value ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Iniciar sesión'),
            ))
      ],
    );
  }
}
