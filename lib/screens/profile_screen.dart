import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../widgets/app_header.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showChangePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cambiar contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PassField(ctrl: currentCtrl, label: 'Contraseña actual'),
            const SizedBox(height: 10),
            _PassField(ctrl: newCtrl, label: 'Nueva contraseña'),
            const SizedBox(height: 10),
            _PassField(ctrl: confirmCtrl, label: 'Confirmar nueva contraseña'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Las contraseñas no coinciden')),
                );
                return;
              }
              final auth = context.read<AuthProvider>();
              final ok = await auth.changePassword(currentCtrl.text, newCtrl.text);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? '✅ Contraseña actualizada' : auth.error ?? 'Error')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.fallaGrave),
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reports = context.watch<ReportsProvider>();
    final user = auth.currentUser;

    final totalReports = reports.userReports.length;
    final solvedReports = reports.solucionados.length;
    final points = totalReports * 10 + solvedReports * 5;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppHeader(showNotification: true),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Green header with avatar
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            user?.fullName.isNotEmpty == true
                                ? user!.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user?.fullName ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.program ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Stats row
                          Row(
                            children: [
                              Expanded(child: _StatCard(label: 'Reportes\nEnviados', value: '$totalReports', icon: Icons.assignment_rounded, color: AppColors.primary)),
                              const SizedBox(width: 12),
                              Expanded(child: _StatCard(label: 'Reportes\nSolucionados', value: '$solvedReports', icon: Icons.check_circle_rounded, color: Colors.green)),
                              const SizedBox(width: 12),
                              Expanded(child: _StatCard(label: 'Puntos /\nReputación', value: '$points', icon: Icons.star_rounded, color: Colors.amber)),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // User info card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                                  child: Text('Información personal',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ),
                                const Divider(height: 1),
                                _ProfileRow(icon: Icons.person_rounded, label: 'Nombre', value: user?.fullName ?? ''),
                                const Divider(height: 1, indent: 16),
                                _ProfileRow(icon: Icons.badge_rounded, label: 'Código', value: user?.studentCode ?? ''),
                                const Divider(height: 1, indent: 16),
                                _ProfileRow(icon: Icons.email_rounded, label: 'Correo', value: user?.email ?? ''),
                                const Divider(height: 1, indent: 16),
                                _ProfileRow(icon: Icons.school_rounded, label: 'Programa', value: user?.program ?? ''),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Actions card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                            ),
                            child: Column(
                              children: [
                                _ActionRow(
                                  icon: Icons.lock_reset_rounded,
                                  label: 'Cambiar contraseña',
                                  color: AppColors.primary,
                                  onTap: () => _showChangePassword(context),
                                ),
                                const Divider(height: 1, indent: 16),
                                _ActionRow(
                                  icon: Icons.logout_rounded,
                                  label: 'Cerrar sesión',
                                  color: AppColors.fallaGrave,
                                  onTap: () => _logout(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionRow({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 15)),
            const Spacer(),
            Icon(Icons.chevron_right, color: color.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }
}

class _PassField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;

  const _PassField({required this.ctrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

