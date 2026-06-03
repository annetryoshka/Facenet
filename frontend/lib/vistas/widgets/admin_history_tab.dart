import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/data/models/registro.dart';
import 'package:facenet_app/controles/admin_controller.dart';

// Paleta corporativa unificada
const _colorFondo = Color(0xFFF8F9FA);
const _colorBlanco = Color(0xFFFFFFFF);
const _colorGrisSuave = Color(0xFFE5E5E5);
const _colorGrisMedio = Color(0xFF7F7F7F);
const _colorNegroElegante = Color(0xFF1A1A1A);

class AdminHistoryTab extends StatelessWidget {
  const AdminHistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Container(
      color: _colorFondo,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              "Historial de registros",
              style: TextStyle(
                color: _colorNegroElegante, 
                fontSize: 16, 
                fontWeight: FontWeight.w700,
                fontFamily: 'LibreBaskerville'
              ),
            ),
          ),
          
          Expanded(
            child: Obx(() {
              if (controller.loadingHistory.value) {
                return const Center(child: CircularProgressIndicator(color: _colorNegroElegante));
              }

              if (controller.historial.isEmpty) {
                return Center(
                  child: Text("Sin registros disponibles hoy.", 
                      style: TextStyle(color: _colorGrisMedio, fontFamily: 'Inter')),
                );
              }

              return ListView.builder(
                itemCount: controller.historial.length,
                itemBuilder: (context, index) {
                  final registro = Registro.fromJson(controller.historial[index]);
                  final bool esEntrada = registro.tipo.toLowerCase() == "entrada";
                  
                  // Colores sobrios para estados
                  final Color colorAcceso = esEntrada ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00);

                  return Card(
                    color: _colorBlanco,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: _colorGrisSuave),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: colorAcceso.withOpacity(0.1),
                        child: Icon(
                          esEntrada ? Icons.login_rounded : Icons.logout_rounded, 
                          color: colorAcceso, 
                          size: 20
                        ),
                      ),
                      title: Text(
                        registro.clase, 
                        style: const TextStyle(
                          color: _colorNegroElegante, 
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter'
                        )
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${registro.tipo.toUpperCase()} • ${registro.fechaFormato} ${registro.horaFormato}", 
                            style: const TextStyle(color: _colorGrisMedio, fontSize: 11)
                          ),
                        ],
                      ),
                      trailing: Text(
                        "${registro.confianza.toStringAsFixed(0)}%",
                        style: TextStyle(
                          color: _colorNegroElegante.withOpacity(0.6),
                          fontWeight: FontWeight.w700,
                          fontSize: 12
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