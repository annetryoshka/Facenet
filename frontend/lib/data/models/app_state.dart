import 'empleado.dart';
import 'registro.dart';

class AppState {
  // Usamos los empleados del modelo separado que creamos antes
  static final List<Empleado> empleados = MockData.empleados;

  // Lista en memoria temporal para simular la asistencia del día si Python está apagado
  static final List<Registro> registros = [];

  /// Método de simulación para la pantalla de la cámara principal.
  /// Mapea el rostro detectado por YOLO/DeepFace y simula la entrada/salida.
  static Empleado? registrarEntradaSalidaSimulada(
    String idRostro,
    String nombreRostro,
  ) {
    // 1. Buscar si el rostro reconocido coincide con un empleado de nuestro Mock
    Empleado empleado = empleados.firstWhere(
      (e) => e.nombre.toLowerCase().contains(nombreRostro.toLowerCase()),
      orElse: () => Empleado(id: idRostro, nombre: nombreRostro, departamento: "Desconocido"),
    );

    // 2. Determinar si el último estado en memoria fue entrada o salida
    String tipoRegistro = "entrada";
    
    // Buscamos el último registro local en memoria para este empleado
    final registrosEmpleado = registros.where((r) => r.clase == empleado.nombre).toList();
    
    if (registrosEmpleado.isNotEmpty) {
      // Si el último fue entrada, ahora toca salida. Si no, entrada.
      // (Asumiendo que guardamos el tipo en alguna parte o lo deducimos por lógica local)
      // Nota: Como tu tabla 'Deteccion' de Python no tiene columna "tipo" (entrada/salida),
      // en simulación podemos alternar el estado que guardamos en el objeto Empleado:
      tipoRegistro = empleado.estado == "entrada" ? "salida" : "entrada";
    }

    // 3. Creamos el objeto Registro estructurado idéntico a tu database.py
    final nuevoRegistro = Registro(
      id: registros.length + 1,
      clase: empleado.nombre,
      confianza: 95.0, // Confianza simulada
      timestamp: DateTime.now(),
      fuente: "app_camara", tipo: '',
    );

    registros.add(nuevoRegistro);
    empleado.estado = tipoRegistro; // Actualiza el estado visual ("entrada"/"salida")
    
    return empleado;
  }

  /// Filtra los registros que han ocurrido el día de hoy para la pantalla principal
  static List<Registro> obtenerRegistrosHoy() {
    final hoy = DateTime.now();
    return registros.where((r) =>
        r.timestamp.year == hoy.year &&
        r.timestamp.month == hoy.month &&
        r.timestamp.day == hoy.day
    ).toList();
  }
}