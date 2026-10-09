import '../utils/file_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../providers/notifications_provider.dart';
import '../models/report_model.dart';
import '../models/lab_device.dart';
import '../widgets/app_header.dart';
import '../widgets/user_card.dart';
import '../widgets/category_button.dart';
import '../utils/app_theme.dart';

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});
  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  String _selectedType = 'grave';
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<String> _imagePaths = [];
  final _picker = ImagePicker();
  bool _sending = false;

  String _lab = kLaboratories.first;
  String _equipmentName = 'PC-01';
  String _deviceType = 'pc';

  // Device list for current lab
  List<LabDevice> get _devices => getDevicesByLab(_lab);
  LabDevice? _selectedDevice;

  String? _getValidDeviceId(List<LabDevice> devices) {
    if (devices.isEmpty) return null;
    if (_selectedDevice != null && devices.any((d) => d.id == _selectedDevice!.id)) {
      return _selectedDevice!.id;
    }
    return devices.first.id;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _selectedType = args['type'] ?? 'selectedType';
      _lab = args['lab'] ?? _lab;
      _equipmentName = args['equipment'] ?? _equipmentName;
      _deviceType = args['deviceType'] ?? _deviceType;
    }
    _updateSelectedDevice();
  }

  void _updateSelectedDevice() {
    // If equipment is provided (from QR scan), search in CURRENT lab first
    if (_equipmentName.isNotEmpty) {
      final currentLabDevices = getDevicesByLab(_lab);
      // First try exact code match (from QR), then name match in current lab
      try {
        final found = currentLabDevices.firstWhere(
          (d) => d.code == _equipmentName || d.name == _equipmentName,
        );
        _selectedDevice = found;
        return;
      } catch (_) {
        // Not found in current lab → create new unknown device
        _selectedDevice = addUnknownDevice(_lab, _equipmentName);
        return;
      }
    }
    // Default: search in current lab by equipment name
    final devs = getDevicesByLab(_lab);
    try {
      _selectedDevice = devs.firstWhere((d) => d.name == _equipmentName);
    } catch (_) {
      _selectedDevice = devs.isNotEmpty ? devs.first : null;
    }
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(source: source, imageQuality: 80);
      if (xfile != null) setState(() => _imagePaths.add(xfile.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo acceder a la cámara o galería')));
    }
  }

  Future<void> _sendReport() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un título para el reporte')));
      return;
    }
    setState(() => _sending = true);
    final auth = context.read<AuthProvider>();
    final reports = context.read<ReportsProvider>();
    final notifs = context.read<NotificationsProvider>();
    final user = auth.currentUser!;
    final now = DateTime.now();
    final deviceLabel = _selectedDevice != null
        ? '${_selectedDevice!.name} (${_selectedDevice!.typeLabel})'
        : _equipmentName;

    final report = ReportModel(
      id: const Uuid().v4(), userId: user.id, userName: user.fullName,
      userEmail: user.email, type: _selectedType, title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imagePath: _imagePaths.isNotEmpty ? _imagePaths.first : null,
      status: 'Pendiente', laboratory: _lab, equipment: deviceLabel,
      date: DateFormat('d MMMM yyyy', 'es').format(now),
      time: DateFormat('hh:mm a').format(now),
    );
    await reports.addReport(report);
    notifs.addReportNotification(report);
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Reporte enviado correctamente'),
        backgroundColor: AppColors.primary));
    Navigator.pushReplacementNamed(context, '/reports');
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
    final devices = _devices;
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
                  const Text('Nuevo Reporte',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  const UserCard(),
                  const SizedBox(height: 16),

                  // Type selector
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.4,
                    children: ['grave','leve','faltante','software'].map((type) => CategoryButton(
                      type: type, selected: _selectedType == type, showDescription: false,
                      onTap: () => setState(() => _selectedType = type),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Lab selector
                  const Text('Laboratorio',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white,
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _lab, isExpanded: true, isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
                        style: const TextStyle(color: AppColors.textDark, fontSize: 13),
                        onChanged: (v) {
                          setState(() {
                            _lab = v!;
                            // Reset equipment selection when lab changes
                            final devices = getDevicesByLab(_lab);
                            _selectedDevice = devices.isNotEmpty ? devices.first : null;
                          });
                        },
                        items: kLaboratories.map((l) =>
                          DropdownMenuItem(value: l, child: Text(l))).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Device selector
                  const Text('Dispositivo a reportar',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white,
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(12)),
                    child: devices.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('No hay dispositivos en este laboratorio',
                            style: TextStyle(color: AppColors.textGray, fontSize: 13)),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _getValidDeviceId(devices) ?? devices.first.id,
                            isExpanded: true, isDense: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
                            style: const TextStyle(color: AppColors.textDark, fontSize: 13),
                            onChanged: (id) => setState(() {
                              _selectedDevice = devices.firstWhere((d) => d.id == id);
                            }),
                            items: devices.map((d) => DropdownMenuItem(
                          value: d.id,
                          child: Row(children: [
                            Icon(_iconForType(d.type), size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(child: Text('${d.name} — ${d.typeLabel}',
                              overflow: TextOverflow.ellipsis)),
                          ]),
                        )).toList(),
                      ),
                    ),
                  ),

                  // Confirmed device chip
                  if (_selectedDevice != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Icon(_iconForType(_selectedDevice!.type), color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text('${_selectedDevice!.name} · ${_selectedDevice!.typeLabel}',
                            style: const TextStyle(color: AppColors.primary,
                              fontWeight: FontWeight.w600, fontSize: 13)),
                        ]),
                        const SizedBox(height: 4),
                        Text(_selectedDevice!.laboratory,
                          style: TextStyle(color: AppColors.textGray, fontSize: 11)),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Title
                  const Text('Título del reporte',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor)),
                    child: TextField(controller: _titleCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Describa brevemente el problema',
                        hintStyle: TextStyle(color: AppColors.textGray, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Detalles adicionales',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor)),
                    child: TextField(controller: _descCtrl, maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Proporcione más información sobre la falla',
                        hintStyle: TextStyle(color: AppColors.textGray, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
                  ),
                  const SizedBox(height: 16),

                  // Evidence
                  const Text('Evidencia Multimedia',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded, size: 18),
                      label: const Text('Tomar Foto', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.textDark,
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10)))),
                    const SizedBox(width: 10),
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Galería', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.textDark,
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10)))),
                  ]),
                  const SizedBox(height: 12),
                  if (_imagePaths.isNotEmpty)
                    SizedBox(height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal, itemCount: _imagePaths.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => Stack(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(10),
                            child: buildFileImage(_imagePaths[i], width: 80, height: 80)),
                          Positioned(top: 2, right: 2,
                            child: GestureDetector(onTap: () => setState(() => _imagePaths.removeAt(i)),
                              child: Container(decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 16)))),
                        ]),
                      ))
                  else
                    Container(height: 80,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor)),
                      child: Center(child: Icon(Icons.add_photo_alternate_rounded,
                        color: Colors.grey.shade300, size: 40))),

                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sending ? null : _sendReport,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: _sending
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Enviar Reporte',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)))),
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

