import '../utils/file_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';
import '../models/report_model.dart';
import '../widgets/app_header.dart';
import '../widgets/category_button.dart';
import '../utils/app_theme.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportId = ModalRoute.of(context)?.settings.arguments as String?;
    final reports = context.watch<ReportsProvider>();

    ReportModel? report;
    try {
      report = reports.userReports.firstWhere((r) => r.id == reportId);
    } catch (_) {
      try {
        report = reports.allReports.firstWhere((r) => r.id == reportId);
      } catch (_) {}
    }

    if (report == null) {
      return Scaffold(
        body: Column(
          children: [
            AppHeader(showBack: true, onBack: () => Navigator.pop(context)),
            const Expanded(child: Center(child: Text('Reporte no encontrado'))),
          ],
        ),
      );
    }

    final color = getCategoryColor(report.type);
    final icon = getCategoryIcon(report.type);
    final label = getCategoryLabel(report.type);

    Color statusColor;
    switch (report.status) {
      case 'Pendiente':
        statusColor = AppColors.fallaGrave;
        break;
      case 'En Proceso':
        statusColor = AppColors.fallaLeve;
        break;
      default:
        statusColor = AppColors.primary;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppHeader(showBack: true, onBack: () => Navigator.pop(context)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detalle del Reporte',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Status + type header card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 32),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Text(report.title,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            report.status,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info card
                  _InfoCard(children: [
                    _InfoRow(icon: Icons.computer_rounded, label: 'Equipo', value: report.equipment),
                    _InfoRow(icon: Icons.science_rounded, label: 'Laboratorio', value: report.laboratory),
                    _InfoRow(icon: Icons.calendar_today_rounded, label: 'Fecha', value: report.date),
                    _InfoRow(icon: Icons.access_time_rounded, label: 'Hora', value: report.time),
                    _InfoRow(icon: Icons.person_rounded, label: 'Reportado por', value: report.userName),
                  ]),

                  const SizedBox(height: 16),

                  // Description
                  if (report.description.isNotEmpty) ...[
                    const Text('Descripción',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                      ),
                      child: Text(report.description,
                          style: const TextStyle(color: AppColors.textDark, height: 1.5, fontSize: 14)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Image evidence
                  if (report.imagePath != null) ...[
                    const Text('Evidencia',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: buildFileImage(
                        report.imagePath!,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Technical observation
                  if (report.techObservation != null && report.techObservation!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.engineering_rounded, color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Text('Observación Técnica',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(report.techObservation!,
                              style: const TextStyle(color: AppColors.textDark, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Status indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Estado: ${report.status}',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                              fontSize: 14),
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
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        children: children
            .asMap()
            .entries
            .map((e) => Column(children: [
                  e.value,
                  if (e.key < children.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ]))
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

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
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

