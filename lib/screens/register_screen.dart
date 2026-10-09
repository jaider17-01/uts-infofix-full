import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _selectedProgram = 'Ingeniería de Sistemas';
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  final List<String> _programs = [
    'Ingeniería de Sistemas',
    'Ingeniería Civil',
    'Ingeniería Electrónica',
    'Administración de Empresas',
    'Contaduría Pública',
    'Tecnología en Gestión Empresarial',
    'Otro',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validación de campos vacíos
    if (_nameCtrl.text.trim().isEmpty ||
        _codeCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    // Validación de nombre (mínimo 3 caracteres)
    if (_nameCtrl.text.trim().length < 3) {
      _showError('El nombre debe tener al menos 3 caracteres');
      return;
    }

    // Validación de código estudiantil (solo números, 7-10 dígitos)
    final codeRegex = RegExp(r'^\d{7,10}$');
    if (!codeRegex.hasMatch(_codeCtrl.text.trim())) {
      _showError('El código debe tener entre 7 y 10 dígitos');
      return;
    }

    // Validación de email institucional
    if (!_emailCtrl.text.contains('@uts.edu.co')) {
      _showError('Ingresa un correo institucional (@uts.edu.co)');
      return;
    }

    // Validación de contraseña (mínimo 6 caracteres)
    if (_passwordCtrl.text.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    // Validación de confirmación
    if (_passwordCtrl.text != _confirmCtrl.text) {
      _showError('Las contraseñas no coinciden');
      return;
    }

    try {
      final auth = context.read<AuthProvider>();
      final ok = await auth.register(
        fullName: _nameCtrl.text.trim(),
        studentCode: _codeCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        program: _selectedProgram,
        password: _passwordCtrl.text,
      );

      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso! Inicia sesión.'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        _showError(auth.error ?? 'Error al registrar');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error de conexión. Intenta nuevamente.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'UTS ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              TextSpan(text: 'InfoFix', style: TextStyle(color: Color(0xFFC5D4A0), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crear cuenta', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Completa tus datos para registrarte', style: TextStyle(color: AppColors.textGray, fontSize: 14)),
            const SizedBox(height: 28),

            _buildField('Nombre completo', _nameCtrl, Icons.person_outline, 'Tu nombre completo'),
            const SizedBox(height: 14),
            _buildField('Código estudiantil', _codeCtrl, Icons.badge_outlined, 'Ej: 2024010001'),
            const SizedBox(height: 14),
            _buildField('Correo institucional', _emailCtrl, Icons.email_outlined, 'correo@correo.uts.edu.co',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),

            const Text('Programa académico', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedProgram,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                  onChanged: (v) => setState(() => _selectedProgram = v!),
                  items: _programs.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 14)))).toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),

            _buildPasswordField('Contraseña', _passwordCtrl, _obscurePass, () => setState(() => _obscurePass = !_obscurePass)),
            const SizedBox(height: 14),
            _buildPasswordField('Confirmar contraseña', _confirmCtrl, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: auth.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Crear cuenta', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, String hint,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textGray, size: 20),
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController ctrl, bool obscure, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: ctrl,
            obscureText: obscure,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textGray, size: 20),
              suffixIcon: IconButton(
                onPressed: toggle,
                icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textGray),
              ),
              hintText: '••••••••',
              hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
