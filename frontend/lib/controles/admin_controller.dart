import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facenet_app/data/models/empleado.dart';
import '../../services/api_service.dart';

class AdminController extends GetxController with GetSingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController tabController;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final telefonoController = TextEditingController();
  final puestoController = TextEditingController(text: "Empleado");
  final salarioController = TextEditingController(text: "2000.0");
  final entradaController = TextEditingController(text: "08:00");
  final salidaController = TextEditingController(text: "17:00");
  final descuentoController = TextEditingController(text: "5.0");

  final RxBool loadingStats = false.obs;
  final RxMap<String, dynamic> estadisticas = <String, dynamic>{}.obs;
  final RxBool loadingHistory = false.obs;
  final RxList<dynamic> historial = <dynamic>[].obs; 
  final RxString estadoBackend = "Desconectado".obs;

  final RxList<Empleado> empleadosReactivos = <Empleado>[].obs;

  final Rxn<File> imagenEmpleado = Rxn<File>();
  final RxBool guardandoEmpleado = false.obs;
  
  // Registro múltiple para mejorar precisión
  final RxList<File> registroFrontales = <File>[].obs; // Deben ser 5
  final Rxn<File> registroIzq = Rxn<File>();
  final Rxn<File> registroDer = Rxn<File>();
  final Rxn<File> registroExp = Rxn<File>();

  final RxString claseSeleccionada = "persona".obs;
  final RxList<File> imagenesYolo = <File>[].obs;
  final RxBool subiendoDataset = false.obs;

  final ImagePicker _picker = ImagePicker();
  // Administración: token tras login facial
  final RxString adminToken = ''.obs;
  final RxBool loggingIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    
    // NOTA: Asegúrate de que MockData esté importado o accesible en tu archivo original
    // empleadosReactivos.assignAll(MockData.empleados);
    
    verificarSaludBackend();
    cargarEstadisticas();
    cargarHistorial();
  }

  Future<void> verificarSaludBackend() async {
    var res = await _apiService.checkSalud();
    estadoBackend.value = res['success'] ? "Activo" : "Inalcanzable";
  }

  Future<void> cargarEstadisticas() async {
    loadingStats.value = true;
    var res = await _apiService.getEstadisticas();
    if (res['success']) estadisticas.value = res['data'];
    loadingStats.value = false;
  }

  Future<void> cargarHistorial() async {
    loadingHistory.value = true;
    var res = await _apiService.getHistorial();
    if (res['success']) {
      historial.assignAll(res['data']);
    }
    loadingHistory.value = false;
  }

  Future<void> seleccionarImagenEmpleado() async {
    final XFile? archivo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (archivo != null) imagenEmpleado.value = File(archivo.path);
  }

  Future<void> seleccionarMultiplesImagenesYolo() async {
    final List<XFile> archivos = await _picker.pickMultiImage(imageQuality: 80);
    if (archivos.isNotEmpty) {
      imagenesYolo.addAll(archivos.map((x) => File(x.path)));
    }
  }

  // Seleccionar hasta 5 fotos frontales para registro
  Future<void> seleccionarFrontalesRegistro() async {
    final List<XFile>? archivos = await _picker.pickMultiImage(imageQuality: 85);
    if (archivos != null && archivos.isNotEmpty) {
      final nuevos = archivos.map((x) => File(x.path)).toList();
      final espacio = 5 - registroFrontales.length;
      if (espacio <= 0) {
        Get.snackbar('Límite', 'Ya tienes 5 fotos frontales.');
        return;
      }
      if (nuevos.length > espacio) {
        registroFrontales.addAll(nuevos.take(espacio));
        Get.snackbar('Límite', 'Solo se aceptaron $espacio fotos adicionales (máx 5).');
      } else {
        registroFrontales.addAll(nuevos);
      }
    }
  }

  Future<void> seleccionarRegistroSingle(String tipo) async {
    final XFile? archivo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (archivo != null) {
      final file = File(archivo.path);
      if (tipo == 'izq') registroIzq.value = file;
      if (tipo == 'der') registroDer.value = file;
      if (tipo == 'exp') registroExp.value = file;
    }
  }

  // REGISTRAR NUEVO EMPLEADO (Actualizado con endpoint completo y simulación integrada)
  Future<void> registrarEmpleadoEnBackend() async {
    final nombre = nameController.text.trim();
    if (nombre.isEmpty) {
      Get.snackbar("Campos incompletos", "Nombre es obligatorio.");
      return;
    }

    // Validación estricta: requerimos 5 frontales + 1 izq + 1 der + 1 expresión
    if (registroFrontales.length < 5 || registroIzq.value == null || registroDer.value == null || registroExp.value == null) {
      Get.snackbar("Fotos insuficientes", "Por favor agrega 5 frontales, 1 perfil izq, 1 perfil der y 1 con expresión distinta.");
      return;
    }

    guardandoEmpleado.value = true;

    // Preparar lista de fotos a enviar
    final List<File> fotos = [];
    fotos.addAll(registroFrontales);
    fotos.add(registroIzq.value!);
    fotos.add(registroDer.value!);
    fotos.add(registroExp.value!);

    // Llamar al endpoint que acepta múltiples fotos
    var res = await _apiService.registrarEmpleadoMultiple(
      nombre: nombre,
      email: emailController.text.trim(),
      telefono: telefonoController.text.trim(),
      puesto: puestoController.text.trim(),
      salario: double.tryParse(salarioController.text) ?? 2000.0,
      horaEntrada: entradaController.text.trim(),
      horaSalida: salidaController.text.trim(),
      descuentoAtraso: double.tryParse(descuentoController.text) ?? 5.0,
      fotos: fotos,
    );

    if (res['success']) {
      // Intercepción para mantener la reactividad local de la UI
      final nuevoId = "E00${empleadosReactivos.length + 1}";
      
      // Intentamos recuperar el departamento/puesto que devolvió el backend de manera segura
      String deptoOpciones = "Nuevo";
      if (res['data'] != null && res['data']['empleado'] != null) {
        deptoOpciones = res['data']['empleado']['puesto'] ?? "Nuevo";
      }

      final nuevoEmpleado = Empleado(
        id: nuevoId,
        nombre: nombre,
        departamento: deptoOpciones,
      );
      empleadosReactivos.add(nuevoEmpleado);

      // Agregamos el log de registro simulado al historial local
      final nuevoLogSimulado = {
        "clase": nombre,
        "confianza": 0.99,
        "fuente": "app_registro",
        "timestamp": DateTime.now().toIso8601String(),
        "tipo": "registro"
      };
      historial.insert(0, nuevoLogSimulado); 

      // Forzar incremento reactivo de las estadísticas del Dashboard en la UI
      int totalActual = int.tryParse(estadisticas['total']?.toString() ?? '4') ?? 4;
      int presentesActual = int.tryParse(estadisticas['presentes']?.toString() ?? '2') ?? 2;
      int ausentesActual = int.tryParse(estadisticas['ausentes']?.toString() ?? '2') ?? 2;

      int nuevoTotal = totalActual + 1;
      int nuevosPresentes = presentesActual + 1; // Incrementa porque asume la presencia inicial en el registro
      double nuevoPorcentaje = (nuevosPresentes / nuevoTotal) * 100;

      estadisticas.value = {
        'total': nuevoTotal,
        'presentes': nuevosPresentes,
        'ausentes': ausentesActual,
        'porcentaje': nuevoPorcentaje.toStringAsFixed(0),
      };

      Get.back();
      Get.snackbar(
        "Éxito", 
        "Empleado registrado correctamente.", 
        backgroundColor: Colors.green, 
        colorText: Colors.white,
      );
      
      // Limpiar campos y listas de imágenes de registro
      nameController.clear();
      imagenEmpleado.value = null;
      registroFrontales.clear();
      registroIzq.value = null;
      registroDer.value = null;
      registroExp.value = null;
    } else {
      Get.snackbar("Error", res['error'] ?? "No se pudo registrar");
    }
    guardandoEmpleado.value = false;
  }

  Future<void> subirDatasetYoloBackend() async {
    if (imagenesYolo.isEmpty) {
      Get.snackbar("Sin archivos", "Selecciona al menos una imagen.");
      return;
    }

    subiendoDataset.value = true;
    var res = await _apiService.subirDatasetYolo(claseSeleccionada.value, imagenesYolo);
    if (res['success']) {
      Get.back();
      Get.snackbar("Éxito", "Lote de imágenes subido.", backgroundColor: Colors.blue, colorText: Colors.white);
      imagenesYolo.clear();
    }
    subiendoDataset.value = false;
  }

  // Login admin - soporta reconocimiento facial O contraseña
  Future<void> loginAdminFacial({File? imagen, String? usuario, String? password}) async {
    loggingIn.value = true;
    var res = await _apiService.loginAdmin(imagen: imagen, usuario: usuario, password: password);
    if (res['success'] && res['data'] != null && res['data']['token'] != null) {
      adminToken.value = res['data']['token'];
      Get.snackbar('Login exitoso', 'Bienvenido administrador', backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Error login', res['error'] ?? (res['data']?['error'] ?? 'No autenticado'));
    }
    loggingIn.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}