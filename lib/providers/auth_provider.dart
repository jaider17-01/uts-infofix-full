import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isTechnician => _currentUser?.isTechnician ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Verifica si hay sesión activa en Firebase
  Future<void> loadSession() async {
    if (!FirebaseService.isLoggedIn) return;
    
    final user = FirebaseService.currentUser;
    if (user != null) {
      final fullUser = await FirebaseService.getUserById(user.id);
      if (fullUser != null) {
        _currentUser = fullUser;
        // Guardar ID en local para referencia rápida
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_user_id', user.id);
        notifyListeners();
      } else {
        // Usuario existe en Auth pero no en Firestore - cerrar sesión
        await FirebaseService.signOut();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('session_user_id');
        _currentUser = null;
        notifyListeners();
      }
    }
  }

  Future<bool> register({
    required String fullName,
    required String studentCode,
    required String email,
    required String program,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Verificar si ya existe
      final exists = await FirebaseService.emailOrCodeExists(email, studentCode);
      if (exists) {
        _error = 'El correo o código ya está registrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Crear usuario en Firebase
      final user = UserModel(
        id: '', // Firebase asignará el ID
        fullName: fullName,
        studentCode: studentCode,
        email: email,
        program: program,
        password: password,
      );

      await FirebaseService.createUser(user, password);
      
      // Obtener usuario creado
      _currentUser = await FirebaseService.getUserByEmailOrCode(email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al registrar: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await FirebaseService.signIn(identifier, password);
      if (user == null) {
        _error = 'Credenciales incorrectas';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      
      // Guardar sesión local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_user_id', user.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al iniciar sesión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await FirebaseService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_user_id');
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseService.updateUserPassword(_currentUser!.id, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al cambiar contraseña';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
