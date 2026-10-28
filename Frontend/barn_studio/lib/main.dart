import 'package:flutter/material.dart';

void main() {
  runApp(const BarnStudioApp());
}

// Paleta de colores recomendada para Barn Studio
class AppColors {
  static const Color background = Color(0xFFF7F6F3); // Blanco cálido
  static const Color surface = Color(0xFFD1D3D4); // Gris de la cara del logo
  static const Color mediumGray = Color(
    0xFFA8A7A3,
  ); // Bordes y textos secundarios
  static const Color textPrimary = Color(0xFF1E2022); // Casi negro
  static const Color primary = Color(0xFF0A5560); // Teal de las letras
  static const Color primaryDark = Color(
    0xFF06343B,
  ); // Cabecera oscura y footer
  static const Color primaryLight = Color(
    0xFF3FA3AE,
  ); // Iconos y detalles activos
  static const Color accent = Color(0xFFC97A24); // Naranja del pico (CTA)
}

class BarnStudioApp extends StatelessWidget {
  const BarnStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barn Studio',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Cabecera / Barra de Navegación (Principal oscuro)
            Container(
              color: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              child: Row(
                children: [
                  // Logo miniatura
                  Image.asset(
                    'assets/logo.png', // Cambia por tu archivo de logo
                    height: 42,
                    width: 42,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'BARN STUDIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  // Enlaces de navegación (Color principal claro para detalles)
                  _buildNavLink('Inicio', isActive: true),
                  _buildNavLink('Proyectos'),
                  _buildNavLink('Servicios'),
                  _buildNavLink('Contacto'),
                  const SizedBox(width: 20),
                  // Botón CTA en la barra
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Comenzar'),
                  ),
                ],
              ),
            ),

            // 2. Sección Hero (Fondo principal blanco cálido)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 70),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Row(
                    children: [
                      // Texto de bienvenida
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Diseño y Desarrollo de Experiencias Digitales',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Creamos interfaces limpias, modernas y sistemas sólidos diseñados para destacar en cualquier plataforma.',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.mediumGray,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Botón de llamada a la acción principal
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Explorar Proyectos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Logo destacado
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: Container(
                            height: 240,
                            width: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Sección de Tarjetas / Superficies alternas
            Container(
              width: double.infinity,
              color: AppColors.surface.withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      const Text(
                        'Nuestros Pilares',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Elementos modulares construidos siguiendo la identidad visual.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.mediumGray,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: const [
                          _FeatureCard(
                            icon: Icons.brush_outlined,
                            title: 'Identidad Visual',
                            description: 'Diseño coherente basado en colores armónicos y legibilidad.',
                          ),
                          _FeatureCard(
                            icon: Icons.code_rounded,
                            title: 'Desarrollo Frontend',
                            description: 'Construcción modular y adaptable a múltiples resoluciones.',
                          ),
                          _FeatureCard(
                            icon: Icons.layers_outlined,
                            title: 'Arquitectura Limpia',
                            description: 'Estructuras escalables preparadas para futuras integraciones.',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Pie de página (Principal oscuro)
            Container(
              color: AppColors.primaryDark,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '© 2026 Barn Studio. Todos los derechos reservados.',
                        style: TextStyle(
                          color: AppColors.surface,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Hecho con Flutter Web',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildNavLink(String text, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? AppColors.primaryLight : Colors.white70,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
      ),
    );
  }
}

// Componente para las tarjetas de la sección de superficies
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mediumGray.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
