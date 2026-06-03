import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/admin_controller.dart';

class UploadYoloDialog extends StatelessWidget {
  const UploadYoloDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title:Text("Subir lote a Dataset YOLO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Clasificación del lote:", style: TextStyle(color: Colors.grey, fontSize: 14)),
          SizedBox(height: 5),
          
          // Selector Reactivo de Clase
          Obx(() => DropdownButton<String>(
            value: controller.claseSeleccionada.value,
            dropdownColor: Colors.grey[850],
            style: TextStyle(color: Colors.white),
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: "persona", child: Text("Persona (Caras)")),
              DropdownMenuItem(value: "no_persona", child: Text("No Persona (Fondo/Objetos)")),
            ],
            onChanged: (val) => controller.claseSeleccionada.value = val!,
          )),
          SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () => controller.seleccionarMultiplesImagenesYolo(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            icon: Icon(Icons.collections, color: Colors.white),
            label: Text("Seleccionar Imágenes", style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 15),

          // Contador Dinámico de archivos en cola
          Obx(() => Text(
            "Archivos listos para enviar: ${controller.imagenesYolo.length}",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            controller.imagenesYolo.clear();
            Get.back();
          },
          child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        Obx(() => ElevatedButton(
          onPressed: controller.subiendoDataset.value ? null : () => controller.subirDatasetYoloBackend(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: controller.subiendoDataset.value
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text("Subir a Python", style: TextStyle(color: Colors.white)),
        )),
      ],
    );
  }
}