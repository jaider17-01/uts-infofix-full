import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CategoryButton extends StatelessWidget {
  final String type; // grave, leve, faltante, software
  final bool selected;
  final VoidCallback? onTap;
  final bool showDescription;

  const CategoryButton({
    super.key,
    required this.type,
    this.selected = false,
    this.onTap,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: config['color'] as Color,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: (config['color'] as Color).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(showDescription ? 14 : 12),
          child: Row(
            children: [
              Icon(
                config['icon'] as IconData,
                color: Colors.white,
                size: showDescription ? 28 : 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config['title'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: showDescription ? 15 : 14,
                      ),
                    ),
                    if (showDescription) ...[
                      const SizedBox(height: 2),
                      Text(
                        config['description'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig() {
    switch (type) {
      case 'grave':
        return {
          'color': AppColors.fallaGrave,
          'icon': Icons.warning_amber_rounded,
          'title': 'Falla Grave',
          'description': 'No funciona o tiene un daño crítico',
        };
      case 'leve':
        return {
          'color': AppColors.fallaLeve,
          'icon': Icons.build_rounded,
          'title': 'Falla Leve',
          'description': 'Funciona con problemas menores',
        };
      case 'faltante':
        return {
          'color': AppColors.faltante,
          'icon': Icons.mouse_rounded,
          'title': 'Faltante',
          'description': 'Falta mouse, cable u otro elemento',
        };
      case 'software':
        return {
          'color': AppColors.software,
          'icon': Icons.settings_rounded,
          'title': 'Problema\nde Software',
          'description': 'Errores o fallos en programas',
        };
      default:
        return {
          'color': AppColors.primary,
          'icon': Icons.report,
          'title': 'Reporte',
          'description': '',
        };
    }
  }
}

Color getCategoryColor(String type) {
  switch (type) {
    case 'grave': return AppColors.fallaGrave;
    case 'leve': return AppColors.fallaLeve;
    case 'faltante': return AppColors.faltante;
    case 'software': return AppColors.software;
    default: return AppColors.primary;
  }
}

String getCategoryLabel(String type) {
  switch (type) {
    case 'grave': return 'Falla Grave';
    case 'leve': return 'Falla Leve';
    case 'faltante': return 'Faltante';
    case 'software': return 'Problema de Software';
    default: return type;
  }
}

IconData getCategoryIcon(String type) {
  switch (type) {
    case 'grave': return Icons.warning_amber_rounded;
    case 'leve': return Icons.build_rounded;
    case 'faltante': return Icons.mouse_rounded;
    case 'software': return Icons.settings_rounded;
    default: return Icons.report;
  }
}

