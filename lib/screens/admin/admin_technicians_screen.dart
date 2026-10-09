import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

/// Pantalla de lista de Usuarios Técnicos (Admin)
class AdminTechniciansScreen extends StatefulWidget {
  const AdminTechniciansScreen({super.key});

  @override
  State<AdminTechniciansScreen> createState() => _AdminTechniciansScreenState();
}

class _AdminTechniciansScreenState extends State<AdminTechniciansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadTechnicians();
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
        title: const Text('Técnicos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.pushNamed(context, '/admin-tech-form'),
          ),
        ],
      ),
      body: admin.techsLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : admin.technicians.isEmpty
              ? _EmptyState(
                  onAdd: () => Navigator.pushNamed(context, '/admin-tech-form'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: admin.technicians.length,
                  itemBuilder: (ctx, i) => _TechTile(
                    tech: admin.technicians[i],
                    onDelete: () => _confirmDelete(admin.technicians[i]),
                    onReset: () => _showResetDialog(admin.technicians[i]),
                  ),
                ),
    );
  }

  void _confirmDelete(UserModel tech) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Técnico'),
        content: Text('¿Eliminar a "${tech.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdminProvider>().deleteTechnician(tech.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(UserModel tech) {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer Contraseña'),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Nueva contraseña',
            hintText: 'Ingresa la nueva contraseña',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passCtrl.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mínimo 6 caracteres')),
                );
                return;
              }
              Navigator.pop(ctx);
              await context.read<AdminProvider>().resetTechnicianPassword(
                  tech.id, passCtrl.text);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contraseña marcada para restablecer')),
              );
            },
            child: const Text('Guardar'),
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
          Icon(Icons.engineering, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('No hay técnicos', style: TextStyle(color: AppColors.textGray)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add),
            label: const Text('Agregar Técnico'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _TechTile extends StatelessWidget {
  final UserModel tech;
  final VoidCallback onDelete;
  final VoidCallback onReset;

  const _TechTile({
    required this.tech,
    required this.onDelete,
    required this.onReset,
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
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.engineering, color: AppColors.primary),
        ),
        title: Text(tech.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(tech.email,
                style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
            if (tech.program.isNotEmpty)
              Text('Lab: ${tech.program}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textGray)),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'reset', child: Text('Restablecer contraseña')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
          onSelected: (value) {
            if (value == 'reset') onReset();
            if (value == 'delete') onDelete();
          },
        ),
      ),
    );
  }
}

/// Formulario para crear técnico
class AdminTechFormScreen extends StatefulWidget {
  const AdminTechFormScreen({super.key});

  @override
  State<AdminTechFormScreen> createState() => _AdminTechFormScreenState();
}

class _AdminTechFormScreenState extends State<AdminTechFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _labsCtrl = TextEditingController();
  
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _labsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Nuevo Técnico'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDecoration('Nombre completo', 'Juan Pérez'),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Email', 'tecnico@uts.edu.co'),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: _inputDecoration('Contraseña temporal', 'Mínimo 6 caracteres'),
              validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _labsCtrl,
              decoration: _inputDecoration('Laboratorios asignados (opcional)', 'LAB_SIS1, LAB_REDES'),
            ),
            const SizedBox(height: 24),
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
                    : const Text('Crear Técnico',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
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
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final ok = await context.read<AdminProvider>().createTechnician(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      assignedLabs: _labsCtrl.text.trim().isEmpty ? null : _labsCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Técnico creado')),
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
