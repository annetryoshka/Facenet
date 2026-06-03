import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/login_controller.dart';
import 'admin_camera_capture.dart';

// Paleta corporativa
const _colorFondo = Color(0xFFF8F9FA);
const _colorBlanco = Color(0xFFFFFFFF);
const _colorGrisSuave = Color(0xFFE5E5E5);
const _colorGrisMedio = Color(0xFF7F7F7F);
const _colorNegroElegante = Color(0xFF1A1A1A);

class AdminDialog extends StatefulWidget {
  AdminDialog({Key? key}) : super(key: key);

  @override
  State<AdminDialog> createState() => _AdminDialogState();
}

class _AdminDialogState extends State<AdminDialog> {
  File? _imagenFacial;
  bool _usarFacial = false;

  Future<void> _abrirCamara() async {
    // Al abrir la cámara, mantendremos la navegación fluida similar a tu CameraScreen
    Get.to(() => AdminCameraCapture(
          onImageCapture: (File foto) {
            setState(() => _imagenFacial = foto);
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();

    return Dialog(
      backgroundColor: _colorFondo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Acceso Administrador",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _colorNegroElegante,
                fontFamily: 'LibreBaskerville',
              ),
            ),
            const SizedBox(height: 24),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(label: Text("Contraseña"), value: false),
                ButtonSegment(label: Text("Facial"), value: true),
              ],
              selected: {_usarFacial},
              onSelectionChanged: (set) => setState(() => _usarFacial = set.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: _colorNegroElegante.withOpacity(0.1),
                selectedForegroundColor: _colorNegroElegante,
                foregroundColor: _colorGrisMedio,
              ),
            ),
            const SizedBox(height: 24),
            if (!_usarFacial)
              Obx(() => TextField(
                    controller: controller.passwordController,
                    obscureText: controller.obscureText.value,
                    decoration: InputDecoration(
                      hintText: "Contraseña",
                      filled: true,
                      fillColor: _colorBlanco,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _colorGrisSuave),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(controller.obscureText.value ? Icons.visibility_off : Icons.visibility),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ))
            else
              GestureDetector(
                onTap: _abrirCamara,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _colorGrisSuave,
                    borderRadius: BorderRadius.circular(8),
                    image: _imagenFacial != null
                        ? DecorationImage(image: FileImage(_imagenFacial!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imagenFacial == null
                      ? const Icon(Icons.camera_alt, color: _colorGrisMedio)
                      : null,
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancelar", style: TextStyle(color: _colorGrisMedio)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: controller.loggingInAdmin.value
                      ? null
                      : () {
                          if (!_usarFacial) controller.validarAccesoAdmin();
                          else if (_imagenFacial != null) controller.loginAdminFacial(_imagenFacial!);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorNegroElegante,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Acceder", style: TextStyle(color: _colorBlanco)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}