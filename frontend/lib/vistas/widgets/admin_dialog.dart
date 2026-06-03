import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facenet_app/controles/login_controller.dart';
import 'admin_camera_capture.dart';

class AdminDialog extends StatefulWidget {
  AdminDialog({Key? key}) : super(key: key);

  @override
  State<AdminDialog> createState() => _AdminDialogState();
}

class _AdminDialogState extends State<AdminDialog> {
  File? _imagenFacial;
  bool _usarFacial = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _abrirCamara() async {
    Get.to(
      () => AdminCameraCapture(
        onImageCapture: (File foto) {
          setState(() => _imagenFacial = foto);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        "Acceso Administrador",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle entre Contraseña y Facial
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(label: Text("Contraseña"), value: false, icon: Icon(Icons.lock, size: 18)),
                      ButtonSegment(label: Text("Facial"), value: true, icon: Icon(Icons.fingerprint, size: 18)),
                    ],
                    selected: {_usarFacial},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() => _usarFacial = newSelection.first);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Contenido dinámico
            if (!_usarFacial)
              // Modo Contraseña
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Ingresa tu contraseña",
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  SizedBox(height: 15),
                  Obx(() => TextField(
                        controller: controller.passwordController,
                        obscureText: controller.obscureText.value,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Contraseña",
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureText.value ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => controller.togglePasswordVisibility(),
                          ),
                        ),
                      )),
                ],
              )
            else
              // Modo Facial
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Selecciona tu foto facial",
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  SizedBox(height: 15),
                  _imagenFacial != null
                      ? Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(_imagenFacial!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[800],
                          ),
                          child: Icon(Icons.person, size: 60, color: Colors.grey),
                        ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _abrirCamara,
                    icon: Icon(Icons.camera_alt),
                    label: Text("Tomar foto"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        Obx(() => ElevatedButton(
              onPressed: controller.loggingInAdmin.value
                  ? null
                  : () {
                      if (!_usarFacial) {
                        // Login por contraseña
                        controller.validarAccesoAdmin();
                      } else {
                        // Login por facial
                        if (_imagenFacial != null) {
                          controller.loginAdminFacial(_imagenFacial!);
                        } else {
                          Get.snackbar("Error", "Selecciona una imagen primero");
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: controller.loggingInAdmin.value
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text("Acceder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )),
      ],
    );
  }
}