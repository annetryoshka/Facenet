import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/admin_controller.dart';

const _colorFondo = Color(0xFFF8F9FA);
const _colorBlanco = Color(0xFFFFFFFF);
const _colorGrisSuave = Color(0xFFE5E5E5);
const _colorGrisMedio = Color(0xFF7F7F7F);
const _colorNegroElegante = Color(0xFF1A1A1A);

class AddEmployeeDialog extends StatelessWidget {
  const AddEmployeeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    Future<void> _pickTime(BuildContext context, TextEditingController timeController) async {
      TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (picked != null) {
        timeController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      }
    }

    Widget buildTextField({
      required TextEditingController textController,
      required String label,
      TextInputType keyboardType = TextInputType.text,
      bool isTime = false,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: TextField(
          controller: textController,
          readOnly: isTime,
          onTap: isTime ? () => _pickTime(context, textController) : null,
          style: const TextStyle(color: _colorNegroElegante, fontSize: 14),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: isTime ? const Icon(Icons.access_time_rounded, size: 16) : null,
            labelStyle: const TextStyle(color: _colorGrisMedio, fontSize: 13),
            filled: true,
            fillColor: _colorFondo,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: _colorGrisSuave), borderRadius: BorderRadius.circular(6)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: _colorNegroElegante), borderRadius: BorderRadius.circular(6)),
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título con icono centrado en la misma línea
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_alt_1, color: _colorNegroElegante, size: 24),
                  const SizedBox(width: 10),
                  const Text("Nuevo Empleado", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'LibreBaskerville')),
                ],
              ),
              const SizedBox(height: 20),
              
              buildTextField(textController: controller.nameController, label: "Nombre Completo"),
              buildTextField(textController: controller.emailController, label: "Correo Electrónico", keyboardType: TextInputType.emailAddress),
              buildTextField(textController: controller.telefonoController, label: "Teléfono", keyboardType: TextInputType.phone),
              
              const SizedBox(height: 10),
              const Align(alignment: Alignment.centerLeft, child: Text("Detalles Contractuales", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: _colorGrisMedio))),
              const Divider(),
              const SizedBox(height: 10),
              
              buildTextField(textController: controller.puestoController, label: "Puesto"),
              Row(
                children: [
                  Expanded(child: buildTextField(textController: controller.entradaController, label: "Entrada", isTime: true)),
                  const SizedBox(width: 10),
                  Expanded(child: buildTextField(textController: controller.salidaController, label: "Salida", isTime: true)),
                ],
              ),

              const SizedBox(height: 15),
              const Align(alignment: Alignment.centerLeft, child: Text("Biometría", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: _colorGrisMedio))),
              const Divider(),
              const SizedBox(height: 10),

              Obx(() => _buildPhotoSection(controller)),

              const SizedBox(height: 24),
              // Botones centrados
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: () => Get.back(), child: const Text("Cancelar", style: TextStyle(color: _colorGrisMedio))),
                  const SizedBox(width: 10),
                  Obx(() {
                    // 1. Verificamos que los TextEditingControllers tengan texto
                    final bool camposTextoLlenos = controller.nameController.text.isNotEmpty &&
                                                  controller.emailController.text.isNotEmpty &&
                                                  controller.telefonoController.text.isNotEmpty &&
                                                  controller.puestoController.text.isNotEmpty &&
                                                  controller.entradaController.text.isNotEmpty &&
                                                  controller.salidaController.text.isNotEmpty;

                    // 2. Verificamos que las fotos NO sean nulas y haya al menos una frontal
                    final bool fotosCompletas = controller.registroFrontales.isNotEmpty &&
                                                controller.registroIzq.value != null &&
                                                controller.registroDer.value != null &&
                                                controller.registroExp.value != null;

                    // 3. El botón solo está activo si ambos son verdaderos
                    final bool esFormularioValido = camposTextoLlenos && fotosCompletas;

                    return ElevatedButton(
                      onPressed: (esFormularioValido && !controller.guardandoEmpleado.value) 
                          ? () => controller.registrarEmpleadoEnBackend() 
                          : null, // Si es null, el botón se deshabilita automáticamente
                      style: ElevatedButton.styleFrom(
                        backgroundColor: esFormularioValido ? _colorNegroElegante : _colorGrisSuave,
                        foregroundColor: _colorBlanco,
                      ),
                      child: const Text("Registrar"),
                    );
                  }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Frontales (${controller.registroFrontales.length}/5)", 
                 style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => controller.seleccionarFrontalesRegistro(),
              child: const Text("Tomar fotos", style: TextStyle(fontSize: 12)),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _fotoIndividual("Izq", controller.registroIzq.value, () => controller.seleccionarRegistroSingle('izq'), Icons.keyboard_arrow_left),
            _fotoIndividual("Der", controller.registroDer.value, () => controller.seleccionarRegistroSingle('der'), Icons.keyboard_arrow_right),
            _fotoIndividual("Exp", controller.registroExp.value, () => controller.seleccionarRegistroSingle('exp'), Icons.sentiment_satisfied_alt),
          ],
        ),
      ],
    );
  }

  Widget _fotoIndividual(String label, dynamic file, VoidCallback onTap, IconData icon) {
    bool tieneFoto = file != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: tieneFoto ? _colorNegroElegante : _colorGrisSuave,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(tieneFoto ? Icons.check_circle : icon, 
                        color: tieneFoto ? _colorBlanco : _colorGrisMedio, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: _colorGrisMedio)),
        ],
      ),
    );
  }
}