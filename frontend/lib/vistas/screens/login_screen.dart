import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facenet_app/controles/login_controller.dart';
import 'package:facenet_app/vistas/widgets/admin_dialog.dart';

// Paleta estética estricta y profesional
const _colorFondo = Color(0xFFF8F9FA);
const _colorBlanco = Color(0xFFFFFFFF);
const _colorGrisSuave = Color(0xFFE5E5E5);
const _colorGrisMedio = Color(0xFF7F7F7F);
const _colorNegroElegante = Color(0xFF1A1A1A);

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: _colorFondo,
      body: SafeArea(
        child: FadeTransition(
          opacity: controller.fadeAnimation,
          child: SlideTransition(
            position: controller.slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  // ==========================================
                  // 1. CONTENIDO CENTRAL (EXPANDED)
                  // ==========================================
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.face_retouching_natural_rounded,
                          size: 64,
                          color: _colorNegroElegante,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "FaceNet",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: _colorNegroElegante,
                            letterSpacing: -0.8,
                            fontFamily: 'LibreBaskerville',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Módulo Corporativo de Autenticación",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _colorGrisMedio,
                            letterSpacing: 1.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 48),
                        _ElegantButton(
                          title: "Registrar Jornada",
                          subtitle: "Identificación facial biométrica",
                          icon: Icons.camera_alt_rounded,
                          isPrimary: true,
                          onTap: () => controller.irACamara(),
                        ),
                      ],
                    ),
                  ),

                  // ==========================================
                  // 2. FOOTER (ADMIN + COPYRIGHT)
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => Get.dialog(AdminDialog()),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              "¿Eres administrador? Accede aquí",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _colorGrisMedio.withOpacity(0.6),
                                decoration: TextDecoration.underline,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                        Container(width: 40, height: 1, color: _colorGrisSuave),
                        const SizedBox(height: 16),
                        Text(
                          "© 2026 FACENET TECHNOLOGIES",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _colorGrisMedio.withOpacity(0.7),
                            letterSpacing: 1.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// COMPONENTE DE BOTÓN REFINADO
// ==========================================
class _ElegantButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ElegantButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_ElegantButton> createState() => _ElegantButtonState();
}

class _ElegantButtonState extends State<_ElegantButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fondoContenedor = widget.isPrimary ? _colorNegroElegante : _colorBlanco;
    final colorContenido = widget.isPrimary ? _colorBlanco : _colorNegroElegante;
    final colorBorde = widget.isPrimary ? Colors.transparent : _colorGrisSuave;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: _colorNegroElegante.withOpacity(widget.isPrimary ? 0.04 : 0.01),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: fondoContenedor,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorBorde, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: colorContenido.withOpacity(widget.isPrimary ? 0.9 : 0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorContenido,
                              letterSpacing: 0.2,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: widget.isPrimary
                                  ? _colorBlanco.withOpacity(0.6)
                                  : _colorGrisMedio,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: colorContenido.withOpacity(0.3),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}