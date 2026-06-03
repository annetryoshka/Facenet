import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/admin_controller.dart';
import 'package:facenet_app/vistas/widgets/admin_dashboard_tab.dart';
import 'package:facenet_app/vistas/widgets/admin_employees_tab.dart';
import 'package:facenet_app/vistas/widgets/admin_history_tab.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inyectamos el controlador de administración global para este módulo
    final AdminController controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Panel de Control Admin"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () => Get.back(), // Retorna de forma segura al LoginScreen
        ),
        bottom: TabBar(
          controller: controller.tabController,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: "Estadísticas"),
            Tab(icon: Icon(Icons.people), text: "Empleados"),
            Tab(icon: Icon(Icons.history), text: "Historial"),
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