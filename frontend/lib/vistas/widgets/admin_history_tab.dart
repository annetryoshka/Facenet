import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/data/models/registro.dart';
import 'package:facenet_app/controles/admin_controller.dart';

class AdminHistoryTab extends StatelessWidget {
  const AdminHistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Registros de Asistencia Recientes",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          
          Expanded(
            child: Obx(() {
              // Pantalla de carga si está consumiendo el API
              if (controller.loadingHistory.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
              }

              // Vista en caso de que no haya marcas registradas
              if (controller.historial.isEmpty) {
                return const Center(
                  child: Text("No hay registros de marcas el día de hoy.", style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                itemCount: controller.historial.length,
                itemBuilder: (context, index) {
                  // Mapeamos el JSON reactivo al objeto Registro estruturado
                  final registro = Registro.fromJson(controller.historial[index]);
                  
                  // Configuración visual según Entrada o Salida
                  final bool esEntrada = registro.tipo.toLowerCase() == "entrada";
                  final Color colorAcceso = esEntrada ? Colors.green : Colors.orange;
                  final IconData iconoAcceso = esEntrada ? Icons.login : Icons.logout;

                  return Card(
                    color: Colors.grey[850],
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorAcceso.withOpacity(0.2),
                        child: Icon(iconoAcceso, color: colorAcceso, size: 20),
                      ),
                      title: Text(
                        registro.clase, 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Modo: ${registro.tipo.toUpperCase()}", style: TextStyle(color: colorAcceso, fontSize: 11, fontWeight: FontWeight.bold)),
                          Text("Fuente: ${registro.fuente} • ${registro.fechaFormato} ${registro.horaFormato}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                      trailing: Text(
                        "${registro.confianza.toStringAsFixed(1)}% Conf.",
                        style: TextStyle(
                          color: registro.confianza > 75 ? Colors.green[300] : Colors.amber[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 13
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}