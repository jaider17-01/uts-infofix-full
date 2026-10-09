import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../utils/app_theme.dart';
import '../utils/file_image.dart';
import 'category_button.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onViewTap;

  const ReportCard({super.key, required this.report, this.onViewTap});

  @override
  Widget build(BuildContext context) {
    final color = getCategoryColor(report.type);
    final icon = getCategoryIcon(report.type);
    final label = getCategoryLabel(report.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(report.title, style: const TextStyle(color: Colors.white70, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                  if (report.imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: buildFileImage(report.imagePath!, width: 60, height: 44),
                    ),
                ],
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${report.equipment} – ${report.laboratory}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Row(children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      report.userName.isNotEmpty ? report.userName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(report.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('${report.time} · ${report.date}',
                      style: const TextStyle(color: AppColors.textGray, fontSize: 11)),
                  ])),
                  ElevatedButton(
                    onPressed: onViewTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    child: const Text('Ver reporte')),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

