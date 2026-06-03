import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Empleado import removed; inferred from controller list
import 'package:facenet_app/data/models/registro.dart';
import 'package:facenet_app/controles/admin_controller.dart';
import 'add_employee_dialog.dart';
import 'upload_yolo_dialog.dart';

class AdminEmployeesTab extends StatelessWidget {
  const AdminEmployeesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botones superiores: Registro y Dataset
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.dialog(AddEmployeeDialog()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 12)),
                  icon: Icon(Icons.person_add, color: Colors.white, size: 18),
                  label: Text("Nuevo Empleado", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.dialog(UploadYoloDialog()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[800], padding: const EdgeInsets.symmetric(vertical: 12)),
                  icon: Icon(Icons.model_training, color: Colors.white, size: 18),
                  label: Text("Dataset YOLO", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          Text("Monitoreo de Personal y Estados", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),

          // Busca el ListView.builder dentro de admin_employees_tab.dart y envuélvelo así:
          Expanded(
            child: Obx(() {
              if (controller.loadingHistory.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
              }

              return ListView.builder(
                itemCount: controller.empleadosReactivos.length, 
                itemBuilder: (context, index) {
                  final empleado = controller.empleadosReactivos[index];
                  
                  // El resto del algoritmo matemático de entradas/salidas se queda exactamente igual...
                  final marcasEmpleado = controller.historial
                      .map((json) => Registro.fromJson(json))
                      .where((reg) => reg.clase == empleado.nombre)
                      .toList();

                  String estadoActual = "Ausente";
                  Color colorEstado = Colors.red;

                  if (marcasEmpleado.isNotEmpty) {
                    marcasEmpleado.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                    if (marcasEmpleado.length % 2 != 0) {
                      estadoActual = "Entrada";
                      colorEstado = Colors.green;
                    } else {
                      estadoActual = "Salida";
                      colorEstado = Colors.orange;
                    }
                  }

                  return Card(
                    color: Colors.grey[850],
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(empleado.nombre.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(empleado.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text("Depto: ${empleado.departamento}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: colorEstado.withOpacity(0.15),
                          border: Border.all(color: colorEstado),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(estadoActual, style: TextStyle(color: colorEstado, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}