class Empleado {
  final String id;
  final String nombre;
  final String departamento;
  String? estado; // "entrada", "salida", null

  Empleado({
    required this.id,
    required this.nombre,
    required this.departamento,
    this.estado,
  });
}

class MockData {
  static final List<Empleado> empleados = [
    Empleado(id: "E001", nombre: "Juan García", departamento: "Ventas"),
    Empleado(id: "E002", nombre: "María López", departamento: "Contabilidad"),
    Empleado(id: "E003", nombre: "Carlos Rodríguez", departamento: "IT"),
    Empleado(id: "E004", nombre: "Ana Martínez", departamento: "Recursos Humanos"),
  ];
}