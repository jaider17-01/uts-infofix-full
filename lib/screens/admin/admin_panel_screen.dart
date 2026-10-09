import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

/// Panel principal de Administración
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: RichText(text: const TextSpan(children: [
          TextSpan(text: 'UTS ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          TextSpan(text: 'InfoFix', style: TextStyle(color: Color(0xFFC5D4A0), fontSize: 18, fontWeight: FontWeight.bold)),
          TextSpan(text: ' · Admin', style: TextStyle(color: Colors.white70, fontSize: 18)),
        ])),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats overview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F4E2F), AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bienvenido, ${auth.currentUser?.fullName ?? "Admin"}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Panel de administración',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Gestión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Opciones grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: const [
                _AdminOption(
                  icon: Icons.science,
                  label: 'Laboratorios',
                  route: '/admin-labs',
                  color: AppColors.primary,
                ),
                _AdminOption(
                  icon: Icons.devices_other,
                  label: 'Dispositivos',
                  route: '/admin-devices',
                  color: Colors.blue,
                ),
                _AdminOption(
                  icon: Icons.engineering,
                  label: 'Técnicos',
                  route: '/admin-techs',
                  color: Colors.orange,
                ),
                _AdminOption(
                  icon: Icons.analytics,
                  label: 'Reportes',
                  route: '/tech-panel',
                  color: Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const Text('Acceso rápido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            _QuickAccess(
              icon: Icons.build,
              label: 'Panel Técnico',
              onTap: () => Navigator.pushNamed(context, '/tech-panel'),
            ),
            const SizedBox(height: 8),
            _QuickAccess(
              icon: Icons.person,
              label: 'Mi Perfil',
              onTap: () => Navigator.pushNamed(context, '/user-profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  const _AdminOption({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccess({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right, color: AppColors.textGray),
          ],
        ),
      ),
    );
  }
}
