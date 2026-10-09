import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';

/// Almacenamiento local en memoria (listas).
/// No usa base de datos. Los datos viven mientras la app esté abierta.
class LocalStorage {
  // ── Usuarios ──────────────────────────────────────────────
  static final List<UserModel> _users = [];

  // ── Reportes ──────────────────────────────────────────────
  static final List<ReportModel> _reports = [];

  // ══════════════════════════════════════════════════════════
  // USUARIOS
  // ══════════════════════════════════════════════════════════

  static Future<void> insertUser(UserModel user) async {
    _users.removeWhere((u) => u.id == user.id);
    _users.add(user);
  }

  static Future<UserModel?> getUserByEmailOrCode(String identifier) async {
    try {
      return _users.firstWhere(
        (u) => u.email == identifier || u.studentCode == identifier,
      );
    } catch (e) {
      debugPrint('Error al buscar usuario: $e');
      return null;
    }
  }

  static Future<bool> emailOrCodeExists(String email, String code) async {
    try {
      return _users.any((u) => u.email == email || u.studentCode == code);
    } catch (e) {
      debugPrint('Error al verificar existencia: $e');
      return false;
    }
  }

  static Future<void> updateUserPassword(
      String userId, String newPassword) async {
    try {
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        final u = _users[index];
        _users[index] = UserModel(
          id: u.id,
          fullName: u.fullName,
          studentCode: u.studentCode,
          email: u.email,
          program: u.program,
          password: newPassword,
          isTechnician: u.isTechnician,
        );
      }
    } catch (e) {
      debugPrint('Error al actualizar contraseña: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // REPORTES
  // ══════════════════════════════════════════════════════════

  static Future<void> insertReport(ReportModel report) async {
    try {
      _reports.removeWhere((r) => r.id == report.id);
      _reports.insert(0, report);
    } catch (e) {
      debugPrint('Error al insertar reporte: $e');
    }
  }

  static Future<List<ReportModel>> getReportsByUser(String userId) async {
    try {
      return _reports.where((r) => r.userId == userId).toList();
    } catch (e) {
      debugPrint('Error al obtener reportes: $e');
      return [];
    }
  }

  static Future<List<ReportModel>> getAllReports() async {
    try {
      return List.from(_reports);
    } catch (e) {
      debugPrint('Error al obtener todos los reportes: $e');
      return [];
    }
  }

  static Future<void> updateReportStatus(
      String reportId, String status, String? observation) async {
    try {
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] =
            _reports[index].copyWith(status: status, techObservation: observation);
      }
    } catch (e) {
      debugPrint('Error al actualizar estado: $e');
    }
  }

  static Future<int> countReportsByUser(String userId) async {
    try {
      return _reports.where((r) => r.userId == userId).length;
    } catch (e) {
      debugPrint('Error al contar reportes: $e');
      return 0;
    }
  }

  static Future<int> countSolvedByUser(String userId) async {
    try {
      return _reports
          .where((r) => r.userId == userId && r.status == 'Solucionado')
          .length;
    } catch (e) {
      debugPrint('Error al contar solucionados: $e');
      return 0;
    }
  }
}

