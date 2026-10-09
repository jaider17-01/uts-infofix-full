import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/lab_model.dart';
import '../../utils/app_theme.dart';

/// Pantalla de lista de Laboratorios (Admin)
class AdminLabsScreen extends StatefulWidget {
  const AdminLabsScreen({super.key});

  @override
  State<AdminLabsScreen> createState() => _AdminLabsScreenState();
}

class _AdminLabsScreenState extends State<AdminLabsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadLaboratories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Laboratorios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/admin-lab-form'),
          ),
        ],
      ),
      body: admin.labsLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : admin.laboratories.isEmpty
              ? _EmptyState(
                  onAdd: () => Navigator.pushNamed(context, '/admin-lab-form'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: admin.laboratories.length,
                  itemBuilder: (ctx, i) => _LabTile(
                    lab: admin.laboratories[i],
                    onEdit: () {
                      Navigator.pushNamed(
                        context,
                        '/admin-lab-form',
                        arguments: admin.laboratories[i],
                      );
                    },
                    onDelete: () => _confirmDelete(admin.laboratories[i]),
                  ),
                ),
    );
  }

  void _confirmDelete(Laboratory lab) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Laboratorio'),
        content: Text('¿Eliminar "${lab.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdminProvider>().deleteLaboratory(lab.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
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
          Icon(Icons.science_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('No hay laboratorios',
              style: TextStyle(color: AppColors.textGray)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Laboratorio'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _LabTile extends StatelessWidget {
  final Laboratory lab;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LabTile({
    required this.lab,
    required this.onEdit,
    required this.onDelete,
  });

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
          child: const Icon(Icons.science, color: AppColors.primary),
        ),
        title: Text(
          lab.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Código: ${lab.code}',
                style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
            Text(
                '${lab.building} · Piso ${lab.floor} · Cap: ${lab.capacity}',
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

/// Pantalla de formulario para crear/editar laboratorio
class AdminLabFormScreen extends StatefulWidget {
  const AdminLabFormScreen({super.key});

  @override
  State<AdminLabFormScreen> createState() => _AdminLabFormScreenState();
}

class _AdminLabFormScreenState extends State<AdminLabFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  
  Laboratory? _existingLab;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Recibir laboratorio existente si es edición
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Laboratory) {
        _existingLab = args;
        _nameCtrl.text = args.name;
        _codeCtrl.text = args.code;
        _capacityCtrl.text = args.capacity.toString();
        _buildingCtrl.text = args.building;
        _floorCtrl.text = args.floor.toString();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _capacityCtrl.dispose();
    _buildingCtrl.dispose();
    _floorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(_existingLab == null ? 'Nuevo Laboratorio' : 'Editar Laboratorio'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InputField(
              ctrl: _nameCtrl,
              label: 'Nombre',
              hint: 'Laboratorio de Sistemas 1',
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _InputField(
              ctrl: _codeCtrl,
              label: 'Código',
              hint: 'LAB_SIS1',
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    ctrl: _capacityCtrl,
                    label: 'Capacidad',
                    hint: '20',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputField(
                    ctrl: _floorCtrl,
                    label: 'Piso',
                    hint: '1',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InputField(
              ctrl: _buildingCtrl,
              label: 'Edificio',
              hint: 'Edificio A',
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_existingLab == null ? 'Crear Laboratorio' : 'Guardar Cambios',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final lab = Laboratory(
      id: _existingLab?.id ?? 'lab_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      code: _codeCtrl.text.trim().toUpperCase(),
      capacity: int.tryParse(_capacityCtrl.text) ?? 20,
      building: _buildingCtrl.text.trim(),
      floor: int.tryParse(_floorCtrl.text) ?? 1,
    );

    final ok = await context.read<AdminProvider>().saveLaboratory(lab);
    
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laboratorio guardado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AdminProvider>().error ?? 'Error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
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
