import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.0.2.2:5000/api";

  Future<Map<String, dynamic>> checkSalud() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/salud'));
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Error de servidor: ${response.statusCode}'};
    } catch (e) {
      return {'success': true, 'data': {'estado': 'Backend no disponible - Modo simulado'}};
    }
  }

  // POST /api/empleados/registrar (Registrar empleado con múltiples fotos)
  Future<Map<String, dynamic>> registrarEmpleadoMultiple({
    required String nombre,
    required String email,
    required String telefono,
    required String puesto,
    required double salario,
    required String horaEntrada,
    required String horaSalida,
    required double descuentoAtraso,
    required List<File> fotos,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/empleados/registrar'),
      );

      request.fields['nombre'] = nombre;
      request.fields['email'] = email;
      request.fields['telefono'] = telefono;
      request.fields['puesto'] = puesto;
      request.fields['salario'] = salario.toString();
      request.fields['hora_entrada'] = horaEntrada;
      request.fields['hora_salida'] = horaSalida;
      request.fields['descuento_atraso'] = descuentoAtraso.toString();

      for (var file in fotos) {
        request.files.add(await http.MultipartFile.fromPath('foto', file.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Error al registrar empleado'};
    } catch (e) {
      return {
        'success': true,
        'data': {
          'empleado': {
            'nombre': nombre,
            'email': email,
            'telefono': telefono,
            'puesto': puesto,
            'salario': salario,
            'hora_entrada': horaEntrada,
            'hora_salida': horaSalida,
            'descuento_atraso': descuentoAtraso,
          },
          'caras': fotos.length,
          'mensaje': 'Simulación: Empleado registrado con múltiples fotos (modo offline)'
        }
      };
    }
  }

  // POST /api/auth/login (Login admin - acepta imagen (facial) O contraseña)
  Future<Map<String, dynamic>> loginAdmin({
    File? imagen,
    String? usuario,
    String? password,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/login'));
      if (usuario != null) request.fields['usuario'] = usuario;
      if (password != null) request.fields['password'] = password;
      if (imagen != null) request.files.add(await http.MultipartFile.fromPath('imagen', imagen.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      // Try to parse response body for more info
      try {
        final body = jsonDecode(response.body);
        return {'success': false, 'error': body['error'] ?? 'Error de autenticación', 'body': body};
      } catch (_) {
        return {'success': false, 'error': 'Error de autenticación'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  //Pantalla de la Cámara - Registro 
  Future<Map<String, dynamic>> enviarImagen(String pathImagen) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/deteccion/imagen'));
      request.files.add(await http.MultipartFile.fromPath('imagen', pathImagen));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'No se reconoció el rostro o error de servidor.'};
    } catch (e) {
      // Simulación local en caso de error
      final empleadosSimulados = [
        {"nombre": "Juan García", "id": "E001", "confianza": 98.0},
        {"nombre": "María López", "id": "E002", "confianza": 95.0},
        {"nombre": "Carlos Rodríguez", "id": "E003", "confianza": 97.0},
      ];
      final random = (DateTime.now().millisecondsSinceEpoch % 3);
      return {
        'success': true,
        'data': {
          'nombre': empleadosSimulados[random]['nombre'],
          'success': true
        }
      };
    }
  }

  // POST /api/deteccion/registrar-empleado-completo
Future<Map<String, dynamic>> registrarEmpleadoCompleto({
  required String nombre,
  required String email,
  required String telefono,
  required String puesto,
  required double salario,
  required String horaEntrada,
  required String horaSalida,
  required double descuentoAtraso,
  required String pathFoto,
}) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/deteccion/registrar-empleado-completo'),
    );

    request.fields['nombre'] = nombre;
    request.fields['email'] = email;
    request.fields['telefono'] = telefono;
    request.fields['puesto'] = puesto;
    request.fields['salario'] = salario.toString();
    request.fields['hora_entrada'] = horaEntrada;
    request.fields['hora_salida'] = horaSalida;
    request.fields['descuento_atraso'] = descuentoAtraso.toString();
    request.files.add(await http.MultipartFile.fromPath('foto', pathFoto));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    return {'success': false, 'error': 'Error al registrar empleado'};
  } catch (e) {
    return {
      'success': true,
      'data': {
        'empleado': {
          'nombre': nombre,
          'email': email,
          'telefono': telefono,
          'puesto': puesto,
          'salario': salario,
          'hora_entrada': horaEntrada,
          'hora_salida': horaSalida,
          'descuento_atraso': descuentoAtraso,
        },
        'mensaje': 'Simulación: Empleado registrado (modo offline)'
      }
    };
  }
}

  //POST /api/deteccion/registrar (Admin - Registrar Empleado Único en DeepFace)
  Future<Map<String, dynamic>> registrarEmpleado(String nombre, String pathImagen) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/deteccion/registrar'));
      request.fields['nombre'] = nombre;
      request.files.add(await http.MultipartFile.fromPath('imagen', pathImagen));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Fallo en el registro del servidor.'};
    } catch (e) {
      return {'success': true, 'mensaje': 'Simulación: Empleado guardado en mock'};
    }
  }

  //POST /api/dataset/subir (Admin - Subir lote múltiple a YOLO)
  Future<Map<String, dynamic>> subirDatasetYolo(String clase, List<File> imagenes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/dataset/subir'));
      request.fields['clase'] = clase;

      for (var file in imagenes) {
        request.files.add(await http.MultipartFile.fromPath('imagenes', file.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Error al subir dataset masivo.'};
    } catch (e) {
      return {'success': true, 'guardados': imagenes.length};
    }
  }

  //GET /api/deteccion/historial
  Future<Map<String, dynamic>> getHistorial() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/deteccion/historial'));
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['data']};
      }
      return {'success': false, 'error': 'Error de historial'};
    } catch (e) {
      // Retorna una lista simulada
      return {
        'success': true,
        // Modifica la lista mock dentro del catch(e) de getHistorial() en tu api_service.dart:
        "data": [
          {"clase": "Juan García", "confianza": 0.98, "fuente": "app_camara", "timestamp": "2026-06-02T08:02:15", "tipo": "entrada"},
          {"clase": "María López", "confianza": 0.96, "fuente": "app_camara", "timestamp": "2026-06-02T08:15:30", "tipo": "entrada"},
          {"clase": "Carlos Rodríguez", "confianza": 0.91, "fuente": "app_camara", "timestamp": "2026-06-02T08:30:00", "tipo": "entrada"},
          {"clase": "Juan García", "confianza": 0.95, "fuente": "app_camara", "timestamp": "2026-06-02T12:00:45", "tipo": "salida"},
        ]
      };
    }
  }

  //GET /api/deteccion/estadisticas
  // En api_service.dart
  // En api_service.dart
  Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/deteccion/estadisticas'));
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['estadisticas']};
      }
      return {'success': false, 'error': 'Error de servidor'};
    } catch (e) {
      // SIMULACIÓN INTERACTIVA DE ESTADÍSTICAS:
      int presentes = 2; // María y Carlos
      int ausentes = 2;  // Ana y Juan
      int total = presentes + ausentes;
      
      double calculoPorcentaje = (presentes / total) * 100;

      return {
        'success': true,
        'data': {
          'total': total,                                           
          'presentes': presentes,                                   
          'ausentes': ausentes,                                      
            'porcentaje': calculoPorcentaje.toStringAsFixed(0),        
          }
        };
      }
    }

  

  // GET /api/empleados/<nombre> (Obtener info del empleado)
  Future<Map<String, dynamic>> obtenerEmpleado(String nombre) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/empleados/$nombre'));
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['empleado']};
      }
      return {'success': false, 'error': 'Empleado no encontrado'};
    } catch (e) {
      return {'success': true, 'data': {
        'nombre': nombre,
        'puesto': 'Desarrollador',
        'salario': 5000.0,
        'hora_entrada': '08:00',
        'hora_salida': '17:00',
      }};
    }
  }

  // POST /api/empleados/<nombre>/descuento (Calcular descuento)
  Future<Map<String, dynamic>> calcularDescuento(String nombre) async {
    try {
      var request = http.Request('POST', Uri.parse('$baseUrl/empleados/$nombre/descuento'));
      request.headers.addAll({'Content-Type': 'application/json'});
      request.body = jsonEncode({'hora_acceso': DateTime.now().toIso8601String()});

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Error al calcular descuento'};
    } catch (e) {
      return {'success': true, 'data': {
        'empleado': nombre,
        'salario': 5000.0,
        'descuento_pct': 0.0,
        'monto_descuento': 0.0,
        'salario_final': 5000.0,
        'razon': 'Sin descuento',
      }};
    }
  }

  // GET /api/empleados/ (Listar todos los empleados)
  Future<Map<String, dynamic>> listarEmpleados() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/empleados/'));
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['empleados']};
      }
      return {'success': false, 'error': 'Error al listar'};
    } catch (e) {
      return {'success': true, 'data': []};
    }
  }
}
