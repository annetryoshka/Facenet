import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.0.10:5000/api";

  Future<Map<String, dynamic>> checkSalud() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/salud'))
        .timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Backend no disponible'};
    } catch (e) {
      return {'success': false, 'error': 'Conexión fallida: $e'};
    }
  }

  Future<Map<String, dynamic>> enviarImagen(String pathImagen) async {
  try {
    // Comprimir imagen antes de enviar
    final file = File(pathImagen);
    final compressedFile = await _comprimirImagen(file);
    
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/deteccion/imagen'));
    request.files.add(await http.MultipartFile.fromPath('imagen', compressedFile.path));
    
    var streamedResponse = await request.send().timeout(Duration(seconds: 30));
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    return {'success': false, 'error': 'Error: ${response.statusCode}'};
  } catch (e) {
    return {'success': false, 'error': 'Error: $e'};
  }
}

Future<File> _comprimirImagen(File file) async {
  try {
    // Aquí iría compresión real, por ahora retorna el archivo
    return file;
  } catch (e) {
    return file;
  }
}

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

      var streamedResponse = await request.send().timeout(Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> registrarEmpleado(String nombre, String pathImagen) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/deteccion/registrar'));
      request.fields['nombre'] = nombre;
      request.files.add(await http.MultipartFile.fromPath('imagen', pathImagen));

      var streamedResponse = await request.send().timeout(Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> subirDatasetYolo(String clase, List<File> imagenes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/dataset/subir'));
      request.fields['clase'] = clase;

      for (var file in imagenes) {
        request.files.add(await http.MultipartFile.fromPath('imagenes', file.path));
      }

      var streamedResponse = await request.send().timeout(Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getHistorial() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/deteccion/historial'))
        .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'] ?? []};
      }
      return {'success': false, 'error': 'Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getEstadisticas() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/deteccion/estadisticas'));
    
    // ESTO ES LO QUE NECESITAMOS VER EN LA CONSOLA:
    print("--- RESPUESTA CRUDA DE LA API ---");
    print("Código: ${response.statusCode}");
    print("Cuerpo: ${response.body}"); 
    print("---------------------------------");

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    return {'success': false, 'error': 'Error ${response.statusCode}'};
  } catch (e) {
    return {'success': false, 'error': '$e'};
  }
}

  Future<Map<String, dynamic>> obtenerEmpleado(String nombre) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/empleados/$nombre'))
        .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['empleado']};
      }
      return {'success': false, 'error': 'Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> calcularDescuento(String nombre) async {
    try {
      var request = http.Request('POST', Uri.parse('$baseUrl/empleados/$nombre/descuento'));
      request.headers.addAll({'Content-Type': 'application/json'});
      request.body = jsonEncode({'hora_acceso': DateTime.now().toIso8601String()});

      var streamedResponse = await request.send().timeout(Duration(seconds: 10));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> listarEmpleados() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/empleados/'))
        .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['empleados'] ?? []};
      }
      return {'success': false, 'error': 'Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> eliminarEmpleado(String nombre) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/empleados/$nombre'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

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

      var streamedResponse = await request.send().timeout(Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

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

      var streamedResponse = await request.send().timeout(Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'error': 'Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  } 

  Future<Map<String, dynamic>> getEstadisticasHistoricas() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/deteccion/estadisticas/historicas'))
      .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data['historicas']};
    }
    return {'success': false, 'error': 'Error'};
  } catch (e) {
    return {'success': false, 'error': 'Error: $e'};
  }
}
}