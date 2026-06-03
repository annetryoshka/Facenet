import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/data/models/registro.dart';
import 'package:facenet_app/controles/admin_controller.dart';
import 'add_employee_dialog.dart';
import 'upload_yolo_dialog.dart';

// Paleta corporativa unificada
const _colorFondo = Color(0xFFF8F9FA);
const _colorBlanco = Color(0xFFFFFFFF);
const _colorGrisSuave = Color(0xFFE5E5E5);
const _colorGrisMedio = Color(0xFF7F7F7F);
const _colorNegroElegante = Color(0xFF1A1A1A);

class AdminEmployeesTab extends StatelessWidget {
  const AdminEmployeesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Container(
      color: _colorFondo,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botones superiores minimalistas
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.dialog(const AddEmployeeDialog()),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _colorNegroElegante),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: _colorNegroElegante, size: 18),
                  label: const Text("Empleado", style: TextStyle(color: _colorNegroElegante, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.dialog(const UploadYoloDialog()),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _colorNegroElegante),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.delete, color: _colorNegroElegante, size: 18),
                  label: const Text("Eliminar Empleado", style: TextStyle(color: _colorNegroElegante, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Monitoreo de Personal",
            style: TextStyle(color: _colorNegroElegante, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'LibreBaskerville'),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: Obx(() {
              if (controller.loadingHistory.value) {
                return const Center(child: CircularProgressIndicator(color: _colorNegroElegante));
              }

              return ListView.builder(
                itemCount: controller.empleadosReactivos.length,
                itemBuilder: (context, index) {
                  final empleado = controller.empleadosReactivos[index];
                  final marcasEmpleado = controller.historial
                      .map((json) => Registro.fromJson(json))
                      .where((reg) => reg.clase == empleado.nombre)
                      .toList();

                  String estadoActual = "Ausente";
                  Color colorEstado = _colorGrisMedio;

                  if (marcasEmpleado.isNotEmpty) {
                    marcasEmpleado.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                    if (marcasEmpleado.length % 2 != 0) {
                      estadoActual = "Entrada";
                      colorEstado = const Color(0xFF2E7D32); // Verde elegante
                    } else {
                      estadoActual = "Salida";
                      colorEstado = const Color(0xFFEF6C00); // Naranja elegante
                    }
                  }

                  return Card(
                    color: _colorBlanco,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: _colorGrisSuave)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: _colorGrisSuave,
                        child: Text(empleado.nombre.substring(0, 1), style: const TextStyle(color: _colorNegroElegante, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(empleado.nombre, style: const TextStyle(color: _colorNegroElegante, fontWeight: FontWeight.w600)),
                      subtitle: Text("Depto: ${empleado.departamento}", style: const TextStyle(color: _colorGrisMedio, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorEstado.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: colorEstado.withOpacity(0.5)),
                            ),
                            child: Text(estadoActual, style: TextStyle(color: colorEstado, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: _colorNegroElegante, size: 20),
                            onPressed: () {
                              Get.defaultDialog(
                                title: "Eliminar Empleado",
                                middleText: "¿Estás seguro de eliminar a ${empleado.nombre}?",
                                textConfirm: "Eliminar",
                                textCancel: "Cancelar",
                                confirmTextColor: Colors.white,
                                onConfirm: () {
                                  controller.eliminarEmpleado(empleado.nombre);
                                  Get.back();
                                },
                              );
                            },
                          ),
                        ],
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