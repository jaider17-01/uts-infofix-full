import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../models/report_model.dart';
import '../widgets/app_header.dart';
import '../widgets/report_card.dart';
import '../utils/app_theme.dart';

class MyReportsScreen extends StatefulWidget {
  /// [standalone] = true cuando se navega desde /reports (fuera del tab)
  /// [standalone] = false cuando es el tab del BottomNav (MainScaffold)
  final bool standalone;
  const MyReportsScreen({super.key, this.standalone = false});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterEquipment = 'Todos los equipos';
  String _filterCategory = 'Todas las categorias';

  final List<String> _categoryFilters = [
    'Todas las categorias',
    'Falla Grave',
    'Falla Leve',
    'Faltante',
    'Problema de Software',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<ReportsProvider>().loadUserReports(auth.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ReportModel> _filterReports(List<ReportModel> reports) {
    return reports.where((r) {
      final equipMatch = _filterEquipment == 'Todos los equipos' ||
          r.equipment == _filterEquipment;
      final catMatch = _filterCategory == 'Todas las categorias' ||
          (_filterCategory == 'Falla Grave' && r.type == 'grave') ||
          (_filterCategory == 'Falla Leve' && r.type == 'leve') ||
          (_filterCategory == 'Faltante' && r.type == 'faltante') ||
          (_filterCategory == 'Problema de Software' && r.type == 'software');
      return equipMatch && catMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>();
    final pendientes = _filterReports(reports.pendientes);
    final enProceso = _filterReports(reports.enProceso);
    final solucionados = _filterReports(reports.solucionados);
    final historial = _filterReports(reports.userReports);
    final equipments = ['Todos los equipos',
      ...reports.userReports.map((r) => r.equipment).toSet()];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header — con botón volver solo si es standalone
          AppHeader(
            showNotification: true,
            showBack: widget.standalone,
            onBack: () => Navigator.pop(context),
          ),

          // Title row — solo en standalone
          if (widget.standalone) ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('Mis Reportes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
              ),
            ),
          ],

          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textGray,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: [
                Tab(child: Row(children: [
                  const Text('Pendientes'),
                  if (pendientes.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.fallaGrave,
                        borderRadius: BorderRadius.circular(10)),
                      child: Text('${pendientes.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.bold))),
                  ],
                ])),
                const Tab(text: 'En Proceso'),
                const Tab(text: 'Solucionados'),
                const Tab(text: 'Historial'),
              ],
            ),
          ),

          // Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(children: [
              Expanded(child: _FilterDropdown(
                value: _filterEquipment, items: equipments,
                onChanged: (v) => setState(() => _filterEquipment = v!))),
              const SizedBox(width: 10),
              Expanded(child: _FilterDropdown(
                value: _filterCategory, items: _categoryFilters,
                onChanged: (v) => setState(() => _filterCategory = v!))),
            ]),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ReportsList(reports: pendientes,
                  emptyMessage: 'No tienes reportes pendientes'),
                _ReportsList(reports: enProceso,
                  emptyMessage: 'No tienes reportes en proceso'),
                _ReportsList(reports: solucionados,
                  emptyMessage: 'No tienes reportes solucionados'),
                _ReportsList(reports: historial,
                  emptyMessage: 'No tienes reportes aún'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true, isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textGray),
          style: const TextStyle(color: AppColors.textDark, fontSize: 12),
          onChanged: onChanged,
          items: items.map((e) =>
            DropdownMenuItem(value: e,
              child: Text(e, overflow: TextOverflow.ellipsis))).toList()),
      ),
    );
  }
}

class _ReportsList extends StatelessWidget {
  final List<ReportModel> reports;
  final String emptyMessage;

  const _ReportsList({required this.reports, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(emptyMessage,
            style: const TextStyle(color: AppColors.textGray, fontSize: 14)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (ctx, i) => ReportCard(
        report: reports[i],
        onViewTap: () => Navigator.pushNamed(ctx, '/report-detail',
          arguments: reports[i].id),
      ),
    );
  }
}

