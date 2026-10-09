import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lab_model.dart';
import '../models/device_model.dart';
import '../models/user_model.dart';

/// Provider para administración de Laboratorios, Dispositivos y Usuarios Técnicos
class AdminProvider extends ChangeNotifier {
  // Laboratorios
  List<Laboratory> _laboratories = [];
  bool _labsLoading = false;
  
  // Dispositivos
  List<Device> _devices = [];
  bool _devicesLoading = false;
  
  // Técnicos
  List<UserModel> _technicians = [];
  bool _techsLoading = false;
  
  // Errores
  String? _error;

  // Getters
  List<Laboratory> get laboratories => _laboratories;
  List<Device> get devices => _devices;
  List<UserModel> get technicians => _technicians;
  bool get labsLoading => _labsLoading;
  bool get devicesLoading => _devicesLoading;
  bool get techsLoading => _techsLoading;
  String? get error => _error;

  // ══════════════════════════════════════════════════════════
  // LABORATORIOS
  // ══════════════════════════════════════════════════════════

  /// Carga todos los laboratorios
  Future<void> loadLaboratories() async {
    _labsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final query = await FirebaseFirestore.instance
          .collection('laboratorios')
          .orderBy('name')
          .get();
      
      _laboratories = query.docs.map((doc) {
        final data = doc.data();
        return Laboratory.fromMap({'id': doc.id, ...data});
      }).toList();

      // Si no hay laboratorios en Firestore, usar defaults
      if (_laboratories.isEmpty) {
        _laboratories = List.from(kDefaultLaboratories);
        // Guardar en Firestore
        for (final lab in _laboratories) {
          await FirebaseFirestore.instance
              .collection('laboratorios')
              .doc(lab.id)
              .set(lab.toMap());
        }
      }
    } catch (e) {
      _error = 'Error al cargar laboratorios: $e';
    }

    _labsLoading = false;
    notifyListeners();
  }

  /// Crea o actualiza laboratorio
  Future<bool> saveLaboratory(Laboratory lab) async {
    try {
      await FirebaseFirestore.instance
          .collection('laboratorios')
          .doc(lab.id)
          .set(lab.toMap());

      final index = _laboratories.indexWhere((l) => l.id == lab.id);
      if (index >= 0) {
        _laboratories[index] = lab;
      } else {
        _laboratories.add(lab);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al guardar laboratorio: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina laboratorio
  Future<bool> deleteLaboratory(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('laboratorios')
          .doc(id)
          .delete();
      
      _laboratories.removeWhere((l) => l.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar laboratorio: $e';
      notifyListeners();
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // DISPOSITIVOS
  // ═════════════════════════════════════��════════════════════

  /// Carga todos los dispositivos
  Future<void> loadDevices() async {
    _devicesLoading = true;
    _error = null;
    notifyListeners();

    try {
      final query = await FirebaseFirestore.instance
          .collection('dispositivos')
          .orderBy('name')
          .get();
      
      _devices = query.docs.map((doc) {
        final data = doc.data();
        return Device.fromMap({'id': doc.id, ...data});
      }).toList();
    } catch (e) {
      _error = 'Error al cargar dispositivos: $e';
    }

    _devicesLoading = false;
    notifyListeners();
  }

  /// Carga dispositivos por laboratorio
  Future<void> loadDevicesByLab(String labId) async {
    _devicesLoading = true;
    notifyListeners();

    try {
      final query = await FirebaseFirestore.instance
          .collection('dispositivos')
          .where('laboratoryId', isEqualTo: labId)
          .orderBy('name')
          .get();
      
      _devices = query.docs.map((doc) {
        final data = doc.data();
        return Device.fromMap({'id': doc.id, ...data});
      }).toList();
    } catch (e) {
      _error = 'Error al cargar dispositivos: $e';
    }

    _devicesLoading = false;
    notifyListeners();
  }

  /// Crea o actualiza dispositivo
  Future<bool> saveDevice(Device device) async {
    try {
      await FirebaseFirestore.instance
          .collection('dispositivos')
          .doc(device.id)
          .set(device.toMap());

      final index = _devices.indexWhere((d) => d.id == device.id);
      if (index >= 0) {
        _devices[index] = device;
      } else {
        _devices.add(device);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al guardar dispositivo: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina dispositivo
  Future<bool> deleteDevice(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('dispositivos')
          .doc(id)
          .delete();
      
      _devices.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar dispositivo: $e';
      notifyListeners();
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // TÉCNICOS
  // ══════════════════════════════════════════════════════════

  /// Carga todos los usuarios técnicos
  Future<void> loadTechnicians() async {
    _techsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final query = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('isTechnician', isEqualTo: true)
          .orderBy('fullName')
          .get();
      
      _technicians = query.docs.map((doc) {
        final data = doc.data();
        return UserModel(
          id: doc.id,
          fullName: data['fullName'] ?? '',
          studentCode: data['studentCode'] ?? '',
          email: data['email'] ?? '',
          program: data['program'] ?? '',
          password: '',
          isTechnician: data['isTechnician'] ?? false,
        );
      }).toList();
    } catch (e) {
      _error = 'Error al cargar técnicos: $e';
    }

    _techsLoading = false;
    notifyListeners();
  }

  /// Crea nuevo técnico
  Future<bool> createTechnician({
    required String fullName,
    required String email,
    required String password,
    String? assignedLabs,
  }) async {
    try {
      // Crear en Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (cred.user == null) {
        _error = 'Error al crear usuario';
        notifyListeners();
        return false;
      }

      // Guardar en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(cred.user!.uid)
          .set({
        'id': cred.user!.uid,
        'fullName': fullName,
        'email': email,
        'isTechnician': true,
        'assignedLabs': assignedLabs,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Agregar a la lista local
      _technicians.add(UserModel(
        id: cred.user!.uid,
        fullName: fullName,
        studentCode: '',
        email: email,
        program: assignedLabs ?? '',
        password: '',
        isTechnician: true,
      ));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al crear técnico: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina técnico
  Future<bool> deleteTechnician(String id) async {
    try {
      // Eliminar de Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(id)
          .delete();
      
      // Eliminar de Auth (opcional - requiere re-autenticación)
      // await FirebaseAuth.instance.currentUser?.delete();
      
      _technicians.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar técnico: $e';
      notifyListeners();
      return false;
    }
  }

  /// Restablece contraseña de técnico
  Future<bool> resetTechnicianPassword(String id, String newPassword) async {
    try {
      // Nota: Esto requiere re-autenticación del admin
      // Por simplicidad, aquí solo guardamos en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(id)
          .update({'pendingPasswordReset': newPassword});
      
      return true;
    } catch (e) {
      _error = 'Error al restablecer contraseña: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
