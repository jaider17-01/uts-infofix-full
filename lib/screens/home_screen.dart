import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../models/lab_device.dart';
import '../widgets/app_header.dart';
import '../widgets/user_card.dart';
import '../widgets/category_button.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedLab = kLaboratories.first;
  LabDevice? _selectedDevice;

  List<LabDevice> get _devices => getDevicesByLab(_selectedLab);

  @override
  void initState() {
    super.initState();
    _selectedDevice = _devices.isNotEmpty ? _devices.first : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<ReportsProvider>().loadUserReports(auth.currentUser!.id);
      }
    });
  }

  void _onLabChanged(String lab) {
    setState(() {
      _selectedLab = lab;
      final devs = getDevicesByLab(lab);
      _selectedDevice = devs.isNotEmpty ? devs.first : null;
    });
  }

  void _navigateToReport(String type) {
    Navigator.pushNamed(context, '/new-report', arguments: {
      'type': type,
      'lab': _selectedLab,
      'equipment': _selectedDevice?.name ?? 'PC-01',
      'deviceType': _selectedDevice?.type ?? 'pc',
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'pc': return Icons.computer_rounded;
      case 'monitor': return Icons.monitor_rounded;
      case 'mouse': return Icons.mouse_rounded;
      case 'keyboard': return Icons.keyboard_rounded;
      case 'headset': return Icons.headset_rounded;
      case 'webcam': return Icons.videocam_rounded;
      case 'ups': return Icons.battery_charging_full_rounded;
      case 'printer': return Icons.print_rounded;
      case 'projector': return Icons.slideshow_rounded;
      case 'switch': return Icons.device_hub_rounded;
      case 'cable': return Icons.cable_rounded;
      default: return Icons.devices_other_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reports = context.watch<ReportsProvider>();
    final user = auth.currentUser;
    final dateStr = DateFormat('hh:mm a - d MMMM yyyy', 'es').format(DateTime.now());
    final devices = _devices;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(showNotification: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Hola ${user?.fullName ?? 'Estudiante'}!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  const Text('Reporta fallos o faltantes en los equipos\ninformáticos que vas a utilizar en el laboratorio.',
                    style: TextStyle(color: AppColors.textGray, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 16),

                  // User card
                  UserCard(
                    showEquipment: true,
                    equipment: _selectedDevice?.name ?? '—',
                    dateTime: dateStr,
                  ),
                  const SizedBox(height: 12),

                  // Lab + Device selectors
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Seleccionar equipo a reportar',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        // Lab dropdown
                        const Text('Laboratorio', style: TextStyle(fontSize: 12, color: AppColors.textGray)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(10)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLab, isExpanded: true, isDense: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
                              style: const TextStyle(color: AppColors.textDark, fontSize: 13),
                              onChanged: (v) => _onLabChanged(v!),
                              items: kLaboratories.map((l) =>
                                DropdownMenuItem(value: l, child: Text(l))).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Device dropdown
                        const Text('Dispositivo', style: TextStyle(fontSize: 12, color: AppColors.textGray)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(10)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDevice?.id,
                              isExpanded: true, isDense: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
                              style: const TextStyle(color: AppColors.textDark, fontSize: 13),
                              onChanged: (id) {
                                setState(() {
                                  _selectedDevice = devices.firstWhere((d) => d.id == id);
                                });
                              },
                              items: devices.map((d) => DropdownMenuItem(
                                value: d.id,
                                child: Row(children: [
                                  Icon(_iconForType(d.type), size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text('${d.name} — ${d.typeLabel}', overflow: TextOverflow.ellipsis),
                                ]),
                              )).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text('Tipo de reporte',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
                    children: [
                      CategoryButton(type: 'grave', onTap: () => _navigateToReport('grave')),
                      CategoryButton(type: 'leve', onTap: () => _navigateToReport('leve')),
                      CategoryButton(type: 'faltante', onTap: () => _navigateToReport('faltante')),
                      CategoryButton(type: 'software', onTap: () => _navigateToReport('software')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Mis Reportes
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/reports'),
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(children: [
                        const Icon(Icons.assignment_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 14),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Mis Reportes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Ver reportes pendientes o históricos', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ])),
                        if (reports.pendingCount > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text('${reports.pendingCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Escanear QR
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/qr-scan'),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(children: [
                        const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 28),
                        const SizedBox(width: 14),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Escanear QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Identifica el equipo escaneando su código QR', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                        ])),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 22)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

