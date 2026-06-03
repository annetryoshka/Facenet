import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/admin_controller.dart';

// Paleta corporativa
const _colorFondo = Color(0xFFF8F9FA);
const _colorBlanco = Color(0xFFFFFFFF);
const _colorGrisSuave = Color(0xFFE5E5E5);
const _colorGrisMedio = Color(0xFF7F7F7F);
const _colorNegroElegante = Color(0xFF1A1A1A);

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
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.cargarEstadisticas();
      controller.cargarReporteDescuentos();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loadingStats.value) {
        return const Center(child: CircularProgressIndicator(color: _colorNegroElegante));
      }

      final stats = controller.estadisticas;
      // Debug: Si en consola ves todo en 0, revisa los nombres de las llaves en stats
      debugPrint("Estadísticas recibidas: $stats"); 
      
      final double porcentajeDecimal = (double.tryParse(stats['porcentaje']?.toString() ?? '0') ?? 0) / 100;

      return RefreshIndicator(
        onRefresh: () async {
          await controller.cargarEstadisticas();
          await controller.cargarReporteDescuentos();
        },
        color: _colorNegroElegante,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text("Reporte de Hoy", 
                style: TextStyle(color: _colorNegroElegante, fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'LibreBaskerville')
              ),
              const SizedBox(height: 40),
              
              // Gráfico Líquido
              SizedBox(
                height: 200, width: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) => ClipOval(
                        child: Container(
                          height: 200, width: 200,
                          color: _colorGrisSuave,
                          child: CustomPaint(painter: LiquidPainter(value: porcentajeDecimal, animValue: _animationController.value)),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${stats['porcentaje'] ?? '0'}%", style: const TextStyle(color: _colorNegroElegante, fontSize: 32, fontWeight: FontWeight.bold)),
                        const Text("Presentes", style: TextStyle(color: _colorGrisMedio, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Contadores KPIs (Aquí los he restaurado)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKpiCard("Total", "${stats['total'] ?? '0'}"),
                  _buildKpiCard("Activos", "${stats['presentes'] ?? '0'}"),
                  _buildKpiCard("Ausentes", "${stats['ausentes'] ?? '0'}"),
                ],
              ),
              
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Reporte de Descuentos", 
                  style: TextStyle(color: _colorNegroElegante, fontSize: 16, fontWeight: FontWeight.w700)
                ),
              ),
              const SizedBox(height: 12),

              // Lista de Descuentos
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.reporteDescuentos.length,
                itemBuilder: (context, index) {
                  final item = controller.reporteDescuentos[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: _colorGrisSuave)),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: _colorGrisMedio, size: 20),
                      title: Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text("Toca para ver desglose", style: TextStyle(fontSize: 10)),
                      trailing: Text(
                        "\$${(item['descuento'] as num).toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.w700),
                      ),
                      onTap: () {
                        final detalles = controller.obtenerDetalleDescuento(item['nombre']);
                        Get.bottomSheet(
                          Container(
                            height: Get.height * 0.6,
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                            child: Column(
                              children: [
                                Text("Desglose: ${item['nombre']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const Divider(),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: detalles.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final d = detalles[index];
                                      final bool esEntrada = d['tipo']?.toString().toLowerCase() == 'entrada';
                                      return ListTile(
                                        leading: Icon(esEntrada ? Icons.login_rounded : Icons.logout_rounded, color: esEntrada ? Colors.green : Colors.orange),
                                        title: Text(d['tipo']?.toString().toUpperCase() ?? 'EVENTO', style: const TextStyle(fontWeight: FontWeight.w600)),
                                        subtitle: Text(d['timestamp']?.toString() ?? ''),
                                        trailing: const Text("-\$5.00", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isScrollControlled: true,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildKpiCard(String title, String value) {
    return Container(
      width: 100, padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: _colorBlanco, borderRadius: BorderRadius.circular(8), border: Border.all(color: _colorGrisSuave)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: _colorNegroElegante, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: _colorGrisMedio, fontSize: 10)),
        ],
      ),
    );
  }
}

class LiquidPainter extends CustomPainter {
  final double value;
  final double animValue;
  LiquidPainter({required this.value, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    double yWaterLevel = size.height * (1.0 - value);
    Paint paint = Paint()..color = _colorNegroElegante.withOpacity(0.3);
    Path path = Path();
    path.moveTo(0, yWaterLevel);
    for (double x = 0; x <= size.width; x++) {
      double y = yWaterLevel + 8 * sin((x / size.width * 2 * pi) + (animValue * 2 * pi));
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override 
  bool shouldRepaint(covariant LiquidPainter oldDelegate) => true;
}