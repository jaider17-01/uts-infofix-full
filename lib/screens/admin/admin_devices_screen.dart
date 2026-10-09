import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/device_model.dart';
import '../../utils/app_theme.dart';

/// Pantalla de lista de Dispositivos (Admin)
class AdminDevicesScreen extends StatefulWidget {
  const AdminDevicesScreen({super.key});

  @override
  State<AdminDevicesScreen> createState() => _AdminDevicesScreenState();
}

class _AdminDevicesScreenState extends State<AdminDevicesScreen> {
  String? _filterLab;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDevices();
    });
  }

  List<Device> get _filteredDevices {
    final admin = context.read<AdminProvider>();
    return admin.devices.where((d) {
      final labMatch = _filterLab == null || _filterLab == 'Todos' || d.laboratoryId == _filterLab;
      final statusMatch = _filterStatus == null || _filterStatus == 'Todos' || d.status == _filterStatus;
      return labMatch && statusMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Dispositivos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/admin-device-form'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    value: _filterLab,
                    hint: 'Laboratorio',
                    items: ['Todos', ...admin.laboratories.map((l) => l.name)],
                    onChanged: (v) => setState(() => _filterLab = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterDropdown(
                    value: _filterStatus,
                    hint: 'Estado',
                    items: const ['Todos', 'Activo', 'En reparación', 'Dado de baja'],
                    onChanged: (v) => setState(() => _filterStatus = v),
                  ),
                ),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: admin.devicesLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredDevices.isEmpty
                    ? _EmptyState(
                        onAdd: () => Navigator.pushNamed(context, '/admin-device-form'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredDevices.length,
                        itemBuilder: (ctx, i) => _DeviceTile(
                          device: _filteredDevices[i],
                          onEdit: () {
                            Navigator.pushNamed(
                              context,
                              '/admin-device-form',
                              arguments: _filteredDevices[i],
                            );
                          },
                          onDelete: () =>
                              _confirmDelete(_filteredDevices[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Device device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Dispositivo'),
        content: Text('¿Eliminar "${device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdminProvider>().deleteDevice(device.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('No hay dispositivos',
              style: TextStyle(color: AppColors.textGray)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Dispositivo'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DeviceTile({
    required this.device,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (device.status) {
      case 'Activo':
        return Colors.green;
      case 'En reparación':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  IconData get _typeIcon {
    switch (device.type) {
      case 'pc':
        return Icons.computer;
      case 'monitor':
        return Icons.monitor;
      case 'mouse':
        return Icons.mouse;
      case 'keyboard':
        return Icons.keyboard;
      case 'headset':
        return Icons.headset;
      case 'webcam':
        return Icons.videocam;
      case 'printer':
        return Icons.print;
      case 'projector':
        return Icons.videocam;
      case 'ups':
        return Icons.battery_charging_full;
      default:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_typeIcon, color: AppColors.primary),
        ),
        title: Row(
          children: [
            Text(device.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(device.status,
                  style: TextStyle(
                      color: _statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
                '${kDeviceTypeLabels[device.type] ?? device.type} · ${device.brand} ${device.model}',
                style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
            Text(device.laboratoryName,
                style: const TextStyle(fontSize: 11, color: AppColors.textGray)),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
        ),
      ),
    );
  }
}

/// Formulario de dispositivo
class AdminDeviceFormScreen extends StatefulWidget {
  const AdminDeviceFormScreen({super.key});

  @override
  State<AdminDeviceFormScreen> createState() => _AdminDeviceFormScreenState();
}

class _AdminDeviceFormScreenState extends State<AdminDeviceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  
  String _selectedType = 'pc';
  String? _selectedLabId;
  String? _selectedLabName;
  String _selectedStatus = 'Activo';
  
  Device? _existingDevice;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Device) {
        _existingDevice = args;
        _nameCtrl.text = args.name;
        _serialCtrl.text = args.serialNumber;
        _brandCtrl.text = args.brand;
        _modelCtrl.text = args.model;
        _selectedType = args.type;
        _selectedLabId = args.laboratoryId;
        _selectedLabName = args.laboratoryName;
        _selectedStatus = args.status;
        setState(() {});
      }
      // Cargar labs si no están cargados
      final admin = context.read<AdminProvider>();
      if (admin.laboratories.isEmpty) {
        admin.loadLaboratories();
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _serialCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(_existingDevice == null ? 'Nuevo Dispositivo' : 'Editar Dispositivo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo
            const Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kDeviceTypes.map((t) {
                final selected = _selectedType == t;
                return ChoiceChip(
                  label: Text(kDeviceTypeLabels[t] ?? t),
                  selected: selected,
                  onSelected: (s) => setState(() => _selectedType = t),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Nombre
            _InputField(ctrl: _nameCtrl, label: 'Nombre', hint: 'PC-01'),
            const SizedBox(height: 12),

            // Serial
            _InputField(ctrl: _serialCtrl, label: 'Número de Serie', hint: 'SN-12345'),
            const SizedBox(height: 12),

            // Marca/Modelo
            Row(
              children: [
                Expanded(child: _InputField(ctrl: _brandCtrl, label: 'Marca', hint: 'Dell')),
                const SizedBox(width: 12),
                Expanded(child: _InputField(ctrl: _modelCtrl, label: 'Modelo', hint: 'Optiplex 7080')),
              ],
            ),
            const SizedBox(height: 12),

            // Laboratorio
            const Text('Laboratorio', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLabId,
                  hint: const Text('Seleccionar laboratorio'),
                  isExpanded: true,
                  items: admin.laboratories.map((l) => DropdownMenuItem(
                    value: l.id,
                    child: Text(l.name),
                  )).toList(),
                  onChanged: (v) {
                    final lab = admin.laboratories.firstWhere((l) => l.id == v);
                    setState(() {
                      _selectedLabId = v;
                      _selectedLabName = lab.name;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Estado
            const Text('Estado', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: kDeviceStatuses.map((s) {
                final selected = _selectedStatus == s;
                Color color;
                if (s == 'Activo') {
                  color = Colors.green;
                } else if (s == 'En reparación') {
                  color = Colors.orange;
                } else {
                  color = Colors.red;
                }
                return ChoiceChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: (sel) => setState(() => _selectedStatus = s),
                  selectedColor: color.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected ? color : null,
                    fontWeight: selected ? FontWeight.bold : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_existingDevice == null ? 'Crear Dispositivo' : 'Guardar Cambios',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLabId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un laboratorio')),
      );
      return;
    }

    setState(() => _saving = true);

    final device = Device(
      id: _existingDevice?.id ?? 'dev_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      type: _selectedType,
      laboratoryId: _selectedLabId!,
      laboratoryName: _selectedLabName ?? '',
      serialNumber: _serialCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      status: _selectedStatus,
    );

    final ok = await context.read<AdminProvider>().saveDevice(device);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispositivo guardado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AdminProvider>().error ?? 'Error'), backgroundColor: Colors.red),
      );
    }
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;

  const _InputField({required this.ctrl, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
