import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/admin_controller.dart';
import 'package:facenet_app/vistas/widgets/admin_dashboard_tab.dart';
import 'package:facenet_app/vistas/widgets/admin_employees_tab.dart';
import 'package:facenet_app/vistas/widgets/admin_history_tab.dart';

// Paleta corporativa unificada
const _colorFondo = Color(0xFFF8F9FA);
const _colorNegroElegante = Color(0xFF1A1A1A);
const _colorGrisMedio = Color(0xFF7F7F7F);

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: _colorFondo,
      appBar: AppBar(
        backgroundColor: _colorFondo,
        elevation: 0,
        title: const Text(
          "Panel de Administración",
          style: TextStyle(
            color: _colorNegroElegante,
            fontFamily: 'LibreBaskerville',
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: _colorNegroElegante),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: controller.tabController,
          labelColor: _colorNegroElegante,
          unselectedLabelColor: _colorGrisMedio,
          indicatorColor: _colorNegroElegante,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
          tabs: const [
            Tab(icon: Icon(Icons.insights_rounded), text: "Estadísticas"),
            Tab(icon: Icon(Icons.badge_outlined), text: "Empleados"),
            Tab(icon: Icon(Icons.history_edu_rounded), text: "Historial"),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: const [
          AdminDashboardTab(),
          AdminEmployeesTab(),
          AdminHistoryTab(),
        ],
      ),
    );
  }
}