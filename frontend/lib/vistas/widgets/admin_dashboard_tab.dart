import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/admin_controller.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({Key? key}) : super(key: key);

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final AdminController controller = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    // Controlador que va de 0.0 a 1.0 continuamente para mover las olas
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); 
  }

  @override
  void dispose() {
    _animationController.dispose(); // Limpieza de memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loadingStats.value) {
        return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
      }

      final stats = controller.estadisticas;
      if (stats.isEmpty) {
        return const Center(
          child: Text("Sin estadísticas hoy", style: TextStyle(color: Colors.white))
        );
      }

      final double porcentajeDecimal = (double.tryParse(stats['porcentaje']?.toString() ?? '0') ?? 0) / 100;

      return RefreshIndicator(
        onRefresh: () => controller.cargarEstadisticas(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Asistencia de Hoy", 
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 35),
              
              //GRÁFICO LÍQUIDO CON ANIMACIÓN DE OLAS EN VIVO
              SizedBox(
                height: 220,
                width: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // AnimatedBuilder hace que el CustomPaint se redibuje con cada frame de la animación
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return ClipOval(
                          child: Container(
                            height: 200,
                            width: 200,
                            color: Colors.grey[900],
                            child: CustomPaint(
                              painter: LiquidPainter(
                                value: porcentajeDecimal,
                                animValue: _animationController.value, // Pasamos el valor que cambia en tiempo real
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Anillo exterior de decoración
                    Container(
                      height: 206,
                      width: 206,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.deepPurple.withOpacity(0.5), width: 4),
                      ),
                    ),
                    // Textos centrales
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${stats['porcentaje'] ?? '0'}%", 
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 34, 
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(0, 2))]
                          )
                        ),
                        Text(
                          "Presentes", 
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 45),
              
              // Tarjetas KPI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKpiCard("Total Personal", "${stats['total'] ?? '0'}", Colors.blue),
                  _buildKpiCard("Presentes", "${stats['presentes'] ?? '0'}", Colors.green),
                  _buildKpiCard("Ausentes", "${stats['ausentes'] ?? '0'}", Colors.red),
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildKpiCard(String title, String value, Color color) {
    return Container(
      width: 105,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[850], 
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text(title, style: TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}


class LiquidPainter extends CustomPainter {
  final double value;     // Nivel de llenado (0.0 a 1.0)
  final double animValue; 
  
  LiquidPainter({required this.value, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    double yWaterLevel = size.height * (1.0 - value);

    // 1. Capa trasera del agua (Morado translúcido)
    Paint paintDeep = Paint()..color = Colors.deepPurple.withOpacity(0.45);
    Path pathDeep = Path();

    pathDeep.moveTo(0, yWaterLevel);
    for (double x = 0; x <= size.width; x++) {
      double y = yWaterLevel + 7 * sin((x / size.width * 2 * pi) + (animValue * 2 * pi));
      pathDeep.lineTo(x, y);
    }
    pathDeep.lineTo(size.width, size.height);
    pathDeep.lineTo(0, size.height);
    pathDeep.close();
    canvas.drawPath(pathDeep, paintDeep);

    // 2. Capa frontal del agua (Azul translúcido con movimiento inverso)
    Paint paintLight = Paint()..color = Colors.blue.withOpacity(0.3);
    Path pathLight = Path();

    pathLight.moveTo(0, yWaterLevel);
    for (double x = 0; x <= size.width; x++) {
      
      double y = yWaterLevel + 5 * sin((x / size.width * 2 * pi) - (animValue * 2 * pi) + pi);
      pathLight.lineTo(x, y);
    }
    pathLight.lineTo(size.width, size.height);
    pathLight.lineTo(0, size.height);
    pathLight.close();
    canvas.drawPath(pathLight, paintLight);
  }

  @override 
  bool shouldRepaint(covariant LiquidPainter oldDelegate) {
    
    return oldDelegate.animValue != animValue || oldDelegate.value != value;
  }
}