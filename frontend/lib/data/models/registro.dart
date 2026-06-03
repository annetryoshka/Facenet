import 'package:intl/intl.dart';

class Registro {
  final int? id;
  final String clase; 
  final double confianza;
  final DateTime timestamp;
  final String fuente;
  final String tipo; //"entrada" o "salida"

  Registro({
    this.id,
    required this.clase,
    required this.confianza,
    required this.timestamp,
    required this.fuente,
    required this.tipo,
  });

  factory Registro.fromJson(Map<String, dynamic> json) {
    return Registro(
      id: json['id'],
      clase: json['clase'] ?? "Desconocido",
      confianza: (json['confianza'] ?? 0.0) * 100, 
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      fuente: json['fuente'] ?? "imagen",
      tipo: json['tipo'] ?? "entrada", //Si no viene, por defecto asume entrada
    );
  }

  String get horaFormato => DateFormat('HH:mm:ss').format(timestamp);
  String get fechaFormato => DateFormat('dd/MM/yyyy').format(timestamp);
}