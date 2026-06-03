import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/asistencia_controller.dart';
import 'package:facenet_app/vistas/widgets/camera_viewer.dart';
import 'package:facenet_app/vistas/widgets/success_view.dart';
import 'package:facenet_app/vistas/widgets/error_view.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AsistenciaController controller = Get.put(AsistenciaController());

    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar Asistencia"),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[900]!, Colors.black],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Obx(() {
                
                if (controller.isLoading.value) {
                  return Column(
                    children: [
                      SizedBox(height: 40),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                        strokeWidth: 5,
                      ),
                      SizedBox(height: 25),
                      Text(
                        "Analizando rostro...",
                        style: TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }

                if (controller.empleadoRegistrado.value != null) {
                  return SuccessView();
                }

                if (controller.error.value != null) {
                  return ErrorView(message: controller.error.value!);
                }

                return CameraViewer();
              }),
            ),
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        
        final bool ocultarBoton = controller.isLoading.value || 
                                  controller.empleadoRegistrado.value != null || 
                                  !controller.camaraInicializada.value;
                                  
        return ocultarBoton
            ? SizedBox.shrink()
            : FloatingActionButton(
                onPressed: () => controller.tomarFotoYRegistrar(),
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.camera_alt, size: 32, color: Colors.white),
              );
      }),
    );
  }
}