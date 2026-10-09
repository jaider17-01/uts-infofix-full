import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../models/report_model.dart';
import '../widgets/category_button.dart';
import '../utils/app_theme.dart';

// tech_panel_screen.dart - Solo login técnico
// Admin login está en admin_login_screen.dart
// TECH LOGIN
// ─────────────────────────────────────────────
class TechLoginScreen extends StatefulWidget {
  const TechLoginScreen({super.key});
  @override
  State<TechLoginScreen> createState() => _TechLoginScreenState();
}

class _TechLoginScreenState extends State<TechLoginScreen> {
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _idCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_idCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    // Prioridad: Admin > Técnico
    if (ok && auth.isAdmin) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/admin');
    } else if (ok && auth.isTechnician) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/tech-panel');
    } else if (ok && !auth.isTechnician && !auth.isAdmin) {
      await auth.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Acceso denegado. Solo personal técnico y admin.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Credenciales incorrectas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 280, width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F4E2F), AppColors.primary],
                begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: SafeArea(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 72, height: 72,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.engineering_rounded, color: Colors.white, size: 40)),
                const SizedBox(height: 14),
                Text.rich(TextSpan(children: const [
                  TextSpan(text: 'UTS ', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  TextSpan(text: 'InfoFix', style: TextStyle(color: Color(0xFFC5D4A0), fontSize: 26, fontWeight: FontWeight.bold)),
                ])),
                const SizedBox(height: 4),
                const Text('Panel Técnico', style: TextStyle(color: Colors.white60, fontSize: 13, letterSpacing: 1)),
              ]),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Acceso Técnico',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Inicia sesión con una cuenta técnica configurada en Firebase.',
                  style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)),
                  child: TextField(controller: _idCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textGray),
                      hintText: 'Correo o código técnico',
                      hintStyle: TextStyle(color: AppColors.textGray, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16))),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)),
                  child: TextField(controller: _passCtrl, obscureText: _obscure,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textGray),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textGray)),
                      hintText: 'Contraseña',
                      hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16))),
                ),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: auth.isLoading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Ingresar al Panel',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)))),
                const SizedBox(height: 16),
                Center(child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('← Volver al login de estudiantes',
                    style: TextStyle(color: AppColors.primary)))),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TECH PANEL
// ─────────────────────────────────────────────
class TechPanelScreen extends StatefulWidget {
  const TechPanelScreen({super.key});
  @override
  State<TechPanelScreen> createState() => _TechPanelScreenState();
}

class _TechPanelScreenState extends State<TechPanelScreen> {
  String _filterLab = 'Todos';
  String _filterStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().loadAllReports();
    });
  }

  // ── Dialog completamente independiente con StatefulWidget ──
  void _showUpdateDialog(ReportModel report) {
    final reportsProvider = context.read<ReportsProvider>();
    showDialog(
      context: context,
      builder: (ctx) => _UpdateDialog(
        report: report,
        onSave: (newStatus, observation) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          await reportsProvider
              .updateReportStatus(report.id, newStatus, observation);
          if (!mounted) return;
          Navigator.pop(ctx);
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('✅ Reporte marcado como $newStatus'),
              backgroundColor: newStatus == 'Solucionado'
                  ? Colors.green
                  : AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>();
    final allReports = reports.filterAllReports(
        lab: _filterLab, status: _filterStatus);
    final labs = reports.allLaboratories;
    final pending = reports.allReports.where((r) => r.status == 'Pendiente').length;
    final inProcess = reports.allReports.where((r) => r.status == 'En Proceso').length;
    final solved = reports.allReports.where((r) => r.status == 'Solucionado').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: RichText(text: const TextSpan(children: [
          TextSpan(text: 'UTS ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          TextSpan(text: 'InfoFix', style: TextStyle(color: Color(0xFFC5D4A0), fontSize: 18, fontWeight: FontWeight.bold)),
        ])),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
            label: const Text('Salir', style: TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
      body: Column(
        children: [
          // Stats
          Container(
            color: AppColors.primaryDark,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(children: [
              _StatChip(label: 'Pendientes', count: pending, color: AppColors.fallaGrave),
              const SizedBox(width: 8),
              _StatChip(label: 'En Proceso', count: inProcess, color: AppColors.fallaLeve),
              const SizedBox(width: 8),
              _StatChip(label: 'Solucionados', count: solved, color: Colors.green),
            ]),
          ),

          // Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Expanded(child: _TechFilter(
                value: _filterLab, items: labs,
                onChanged: (v) => setState(() => _filterLab = v!),
                hint: 'Laboratorio')),
              const SizedBox(width: 10),
              Expanded(child: _TechFilter(
                value: _filterStatus,
                items: const ['Todos', 'Pendiente', 'En Proceso', 'Solucionado'],
                onChanged: (v) => setState(() => _filterStatus = v!),
                hint: 'Estado')),
            ]),
          ),

          // List
          Expanded(
            child: reports.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : allReports.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    const Text('No hay reportes', style: TextStyle(color: AppColors.textGray)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allReports.length,
                    itemBuilder: (ctx, i) => _ReportTile(
                      report: allReports[i],
                      onUpdate: () => _showUpdateDialog(allReports[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UPDATE DIALOG — propio StatefulWidget para
// que los RadioButton funcionen correctamente
// ─────────────────────────────────────────────
class _UpdateDialog extends StatefulWidget {
  final ReportModel report;
  final Future<void> Function(String status, String observation) onSave;

  const _UpdateDialog({required this.report, required this.onSave});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  late String _status;
  late TextEditingController _obsCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.report.status;
    _obsCtrl = TextEditingController(text: widget.report.techObservation ?? '');
  }

  @override
  void dispose() { _obsCtrl.dispose(); super.dispose(); }

  Color get _statusColor {
    switch (_status) {
      case 'Solucionado': return Colors.green;
      case 'En Proceso': return AppColors.fallaLeve;
      default: return AppColors.fallaGrave;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Actualizar reporte',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.report.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text('${widget.report.equipment} · ${widget.report.laboratory}',
                  style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 16),

            const Text('Cambiar estado:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),

            // Status options — each as a styled tile
            ...['Pendiente', 'En Proceso', 'Solucionado'].map((s) {
              final isSelected = _status == s;
              Color color;
              IconData icon;
              switch (s) {
                case 'Solucionado': color = Colors.green; icon = Icons.check_circle_rounded; break;
                case 'En Proceso': color = AppColors.fallaLeve; icon = Icons.build_circle_rounded; break;
                default: color = AppColors.fallaGrave; icon = Icons.pending_rounded;
              }
              return GestureDetector(
                onTap: () => setState(() => _status = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.12) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade200,
                      width: isSelected ? 2 : 1)),
                  child: Row(children: [
                    Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    Text(s, style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? color : AppColors.textDark,
                      fontSize: 14)),
                    const Spacer(),
                    if (isSelected)
                      Icon(Icons.radio_button_checked, color: color, size: 18)
                    else
                      Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400, size: 18),
                  ]),
                ),
              );
            }),

            const SizedBox(height: 12),
            const Text('Observación técnica:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _obsCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe la intervención realizada...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textGray),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(12))),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.textGray))),
        ElevatedButton.icon(
          onPressed: _saving ? null : () async {
            setState(() => _saving = true);
            await widget.onSave(_status, _obsCtrl.text.trim());
          },
          icon: _saving
            ? const SizedBox(width: 14, height: 14,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Icon(
                _status == 'Solucionado' ? Icons.check_circle_rounded : Icons.save_rounded,
                size: 18),
          label: Text(_status == 'Solucionado' ? 'Marcar Resuelto' : 'Guardar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _statusColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// REPORT TILE in tech panel
// ─────────────────────────────────────────────
class _ReportTile extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onUpdate;

  const _ReportTile({required this.report, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final color = getCategoryColor(report.type);
    Color statusColor;
    IconData statusIcon;
    switch (report.status) {
      case 'Solucionado': statusColor = Colors.green; statusIcon = Icons.check_circle_rounded; break;
      case 'En Proceso': statusColor = AppColors.fallaLeve; statusIcon = Icons.build_rounded; break;
      default: statusColor = AppColors.fallaGrave; statusIcon = Icons.pending_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Icon(getCategoryIcon(report.type), color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(getCategoryLabel(report.type),
                  style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                Text(report.title,
                  style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                  overflow: TextOverflow.ellipsis),
              ])),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(statusIcon, color: statusColor, size: 14),
                  const SizedBox(width: 4),
                  Text(report.status,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ])),
            ]),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.person_rounded, size: 13, color: AppColors.textGray),
                  const SizedBox(width: 4),
                  Flexible(child: Text(report.userName,
                    style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                    overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.computer_rounded, size: 13, color: AppColors.textGray),
                  const SizedBox(width: 4),
                  Flexible(child: Text('${report.equipment} · ${report.laboratory}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                    overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textGray),
                  const SizedBox(width: 4),
                  Text('${report.time} · ${report.date}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textGray)),
                ]),
              ])),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                child: const Text('Actualizar', style: TextStyle(color: Colors.white))),
            ]),
          ),

          // Technical observation preview
          if (report.techObservation != null && report.techObservation!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.2))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.engineering_rounded, color: Colors.green, size: 14),
                  const SizedBox(width: 6),
                  Expanded(child: Text(report.techObservation!,
                    style: const TextStyle(fontSize: 11, color: AppColors.textDark, height: 1.4),
                    maxLines: 2, overflow: TextOverflow.ellipsis)),
                ])),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label; final int count; final Color color;
  const _StatChip({required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(children: [
          Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10),
            textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _TechFilter extends StatelessWidget {
  final String value; final List<String> items;
  final ValueChanged<String?> onChanged; final String hint;
  const _TechFilter({required this.value, required this.items,
    required this.onChanged, required this.hint});
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
          style: const TextStyle(color: AppColors.textDark, fontSize: 13),
          onChanged: onChanged,
          items: items.map((e) =>
            DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList()),
      ),
    );
  }
}

