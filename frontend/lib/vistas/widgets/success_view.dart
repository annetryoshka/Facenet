import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/asistencia_controller.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AsistenciaController controller = Get.find<AsistenciaController>();
    final empleado = controller.empleadoRegistrado.value;
    final isEntrada = controller.tipo.value == "entrada";

    if (empleado == null) return const SizedBox.shrink();

    return ScaleTransition(
      scale: controller.scaleAnimation,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEntrada ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
              border: Border.all(color: isEntrada ? Colors.green : Colors.orange, width: 4),
            ),
            child: Icon(
              isEntrada ? Icons.login : Icons.logout,
              size: 60,
              color: isEntrada ? Colors.green : Colors.orange,
            ),
          ),
          SizedBox(height: 30),
          Text(
            isEntrada ? "¡Bienvenido!" : "¡Hasta luego!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 15),
          Text(
            empleado.nombre,
            style: TextStyle(fontSize: 20, color: Colors.blue[300], fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 25),
          Container(
            padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isEntrada ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isEntrada ? Colors.green : Colors.orange, width: 2),
            ),
            child: Text(
              isEntrada ? "✓ ENTRADA" : "✗ SALIDA",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: isEntrada ? Colors.green[300] : Colors.orange[300]
              ),
            ),
          ),
        ],
      ),
    );
  }
}