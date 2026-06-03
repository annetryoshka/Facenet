import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/admin_controller.dart';

class AddEmployeeDialog extends StatelessWidget {
  const AddEmployeeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    // Helper para construir los inputs y ahorrar código repetitivo
    Widget buildTextField({
      required TextEditingController textController,
      required String label,
      TextInputType keyboardType = TextInputType.text,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple)
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purpleAccent)
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text(
        "Registrar Empleado Completo", 
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        // Limitamos la altura máxima para que no desborde en pantallas chicas
        height: MediaQuery.of(context).size.height * 0.65, 
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Información Personal", 
                style: TextStyle(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.bold)
              ),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),

              buildTextField(textController: controller.nameController, label: "Nombre Completo"),
              buildTextField(textController: controller.emailController, label: "Correo Electrónico", keyboardType: TextInputType.emailAddress),
              buildTextField(textController: controller.telefonoController, label: "Teléfono / Celular", keyboardType: TextInputType.phone),
              
              const SizedBox(height: 15),
              const Text(
                "Detalles del Contrato", 
                style: TextStyle(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.bold)
              ),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),

              buildTextField(textController: controller.puestoController, label: "Puesto / Cargo"),
              buildTextField(textController: controller.salarioController, label: "Salario (Bs)", keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              
              Row(
                children: [
                  Expanded(child: buildTextField(textController: controller.entradaController, label: "Hora Entrada (HH:MM)")),
                  const SizedBox(width: 15),
                  Expanded(child: buildTextField(textController: controller.salidaController, label: "Hora Salida (HH:MM)")),
                ],
              ),
              buildTextField(textController: controller.descuentoController, label: "Descuento por Atraso (Bs)", keyboardType: const TextInputType.numberWithOptions(decimal: true)),

              const SizedBox(height: 15),
              const Text(
                "Biometría", 
                style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold)
              ),
              const Divider(color: Colors.grey),
              const SizedBox(height: 15),

              // Contenedor de selección categorizada de fotos (5 frontales, izq, der, expresión)
              Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Fotos requeridas:", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),

                    // Frontales (lista horizontal)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                ...controller.registroFrontales.map((f) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: kIsWeb ? Image.network(f.path, width: 90, height: 90, fit: BoxFit.cover) : Image.file(f, width: 90, height: 90, fit: BoxFit.cover),
                                  ),
                                )),
                                // placeholder para mostrar cuantos faltan
                                if (controller.registroFrontales.length < 5)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[850],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[700]!)
                                      ),
                                      child: Center(child: Text('${controller.registroFrontales.length}/5', style: const TextStyle(color: Colors.grey))),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => controller.seleccionarFrontalesRegistro(),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
                          child: const Text('Agregar Frontales'),
                        )
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Perfiles y expresión
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Izq
                        Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                border: Border.all(color: Colors.grey[700]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: controller.registroIzq.value != null
                                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: kIsWeb ? Image.network(controller.registroIzq.value!.path, fit: BoxFit.cover) : Image.file(controller.registroIzq.value!, fit: BoxFit.cover))
                                  : const Center(child: Icon(Icons.person, color: Colors.grey)),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(onPressed: () => controller.seleccionarRegistroSingle('izq'), child: const Text('Perfil Izq'))
                          ],
                        ),

                        // Der
                        Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                border: Border.all(color: Colors.grey[700]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: controller.registroDer.value != null
                                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: kIsWeb ? Image.network(controller.registroDer.value!.path, fit: BoxFit.cover) : Image.file(controller.registroDer.value!, fit: BoxFit.cover))
                                  : const Center(child: Icon(Icons.person, color: Colors.grey)),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(onPressed: () => controller.seleccionarRegistroSingle('der'), child: const Text('Perfil Der'))
                          ],
                        ),

                        // Expresión
                        Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                border: Border.all(color: Colors.grey[700]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: controller.registroExp.value != null
                                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: kIsWeb ? Image.network(controller.registroExp.value!.path, fit: BoxFit.cover) : Image.file(controller.registroExp.value!, fit: BoxFit.cover))
                                  : const Center(child: Icon(Icons.mood, color: Colors.grey)),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(onPressed: () => controller.seleccionarRegistroSingle('exp'), child: const Text('Expresión'))
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
              controller.nameController.clear();
              controller.emailController.clear();
              controller.telefonoController.clear();
              controller.puestoController.text = "Empleado";
              controller.salarioController.text = "2000.0";
              controller.entradaController.text = "08:00";
              controller.salidaController.text = "17:00";
              controller.descuentoController.text = "5.0";
              controller.imagenEmpleado.value = null;
              controller.registroFrontales.clear();
              controller.registroIzq.value = null;
              controller.registroDer.value = null;
              controller.registroExp.value = null;
              Get.back();
          },
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        Obx(() => ElevatedButton(
          onPressed: controller.guardandoEmpleado.value 
              ? null 
              : () => controller.registrarEmpleadoEnBackend(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            disabledBackgroundColor: Colors.green.withOpacity(0.3),
          ),
          child: controller.guardandoEmpleado.value 
            ? const SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : const Text("Registrar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )),
      ],
    );
  }
}