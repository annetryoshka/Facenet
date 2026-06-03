import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/asistencia_controller.dart';

class CameraViewer extends StatelessWidget {
  const CameraViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AsistenciaController controller = Get.find<AsistenciaController>();

    return Column(
      children: [
        Text(
          "Posiciónate frente",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        Text(
          "a la cámara",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[300]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.deepPurple, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Obx(() {
              if (controller.errorCamara.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      controller.errorCamara.value,
                      style: TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              
              if (controller.camaraInicializada.value && 
                  controller.cameraController != null && 
                  controller.cameraController!.value.isInitialized) {
                return AspectRatio(
                  aspectRatio: 1.0,
                  child: CameraPreview(controller.cameraController!),
                );
              }

              return Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              );
            }),
          ),
        ),
      ],
    );
  }
}