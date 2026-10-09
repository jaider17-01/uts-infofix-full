import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';
import '../models/lab_device.dart';

/// Servicio de Firebase Firestore para persistencia de datos.
/// Reemplaza LocalStorage para datos que deben persistir en la nube.
class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ══════════════════════════════════════════════════════════
  // INICIALIZACIÓN
  // ══════════════════════════════════════════════════════════

  /// Inicializa Firebase (llamar en main.dart antes de runApp)
  static Future<void> initialize() async {
    try {
      await _db.collection('_health').doc('_check').get();
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════
  // AUTENTICACIÓN
  // ══════════════════════════════════════════════════════════

  /// Inicia sesión con email y contraseña
  static Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return await getUserById(credential.user!.uid);
      }
      return null;
    } on FirebaseAuthException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Cierra sesión
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Obtiene el usuario actual
  static UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      fullName: user.displayName ?? '',
      studentCode: '',
      email: user.email ?? '',
      program: '',
      password: '',
      isTechnician: false,
    );
  }

  /// Verifica si hay sesión activa
  static bool get isLoggedIn => _auth.currentUser != null;

  // ══════════════════════════════════════════════════════════
  // USUARIOS
  // ══════════════════════════════════════════════════════════

  static CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('usuarios');

  /// Crea un nuevo usuario
  static Future<void> createUser(UserModel user, String password) async {
    try {
      // Crear en Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
      
      // Guardar en Firestore (NO guardar password - Firebase Auth ya la maneja)
      await _usersRef.doc(cred.user!.uid).set({
        'id': cred.user!.uid,
        'fullName': user.fullName,
        'studentCode': user.studentCode,
        'email': user.email,
        'program': user.program,
        'isTechnician': user.isTechnician,
        'isAdmin': user.isAdmin,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene usuario por ID
  static Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _usersRef.doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return UserModel(
        id: doc.id,
        fullName: data['fullName'] ?? '',
        studentCode: data['studentCode'] ?? '',
        email: data['email'] ?? '',
        program: data['program'] ?? '',
        password: '',
        // Verificar que existen los campos, si no existen usar false
        isTechnician: data.containsKey('isTechnician') ? (data['isTechnician'] ?? false) : false,
        isAdmin: data.containsKey('isAdmin') ? (data['isAdmin'] ?? false) : false,
      );
    } catch (_) {
      return null;
    }
  }

  /// Busca usuario por email o código
  static Future<UserModel?> getUserByEmailOrCode(String identifier) async {
    try {
      final query = await _usersRef
          .where('email', isEqualTo: identifier)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        return UserModel(
          id: doc.id,
          fullName: data['fullName'] ?? '',
          studentCode: data['studentCode'] ?? '',
          email: data['email'] ?? '',
          program: data['program'] ?? '',
          password: '',
          isTechnician: data.containsKey('isTechnician') ? (data['isTechnician'] ?? false) : false,
          isAdmin: data.containsKey('isAdmin') ? (data['isAdmin'] ?? false) : false,
        );
      }
      // Buscar por código
      final query2 = await _usersRef
          .where('studentCode', isEqualTo: identifier)
          .limit(1)
          .get();
      if (query2.docs.isNotEmpty) {
        final doc = query2.docs.first;
        final data = doc.data();
        return UserModel(
          id: doc.id,
          fullName: data['fullName'] ?? '',
          studentCode: data['studentCode'] ?? '',
          email: data['email'] ?? '',
          program: data['program'] ?? '',
          password: '',
          isTechnician: data.containsKey('isTechnician') ? (data['isTechnician'] ?? false) : false,
          isAdmin: data.containsKey('isAdmin') ? (data['isAdmin'] ?? false) : false,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si email o código ya existe
  static Future<bool> emailOrCodeExists(String email, String code) async {
    final emailExists = await _usersRef.where('email', isEqualTo: email).limit(1).get();
    if (emailExists.docs.isNotEmpty) return true;
    
    final codeExists = await _usersRef.where('studentCode', isEqualTo: code).limit(1).get();
    return codeExists.docs.isNotEmpty;
  }

  /// Actualiza datos del usuario
  static Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _usersRef.doc(userId).update(data);
  }

  /// Actualiza contraseña
  static Future<void> updateUserPassword(String userId, String newPassword) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      await user.updatePassword(newPassword);
    }
  }

  // ══════════════════════════════════════════════════════════
  // REPORTES
  // ══════════════════════════════════════════════════════════

  static CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _db.collection('reportes');

  /// Crea un nuevo reporte
  static Future<void> createReport(ReportModel report) async {
    await _reportsRef.doc(report.id).set({
      'id': report.id,
      'userId': report.userId,
      'userName': report.userName,
      'userEmail': report.userEmail,
      'type': report.type,
      'title': report.title,
      'description': report.description,
      'imageUrl': report.imagePath,
      'status': report.status,
      'laboratory': report.laboratory,
      'equipment': report.equipment,
      'date': report.date,
      'time': report.time,
      'techObservation': report.techObservation,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Obtiene reportes de un usuario
  static Future<List<ReportModel>> getReportsByUser(String userId) async {
    final query = await _reportsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map(_reportFromDoc).toList();
  }

  /// Obtiene todos los reportes (para técnicos)
  static Future<List<ReportModel>> getAllReports() async {
    final query = await _reportsRef
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map(_reportFromDoc).toList();
  }

  /// Actualiza estado del reporte (técnico)
  static Future<void> updateReportStatus(
      String reportId, String status, String? observation) async {
    await _reportsRef.doc(reportId).update({
      'status': status,
      'techObservation': observation,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Filtra reportes por laboratorio y estado
  static Future<List<ReportModel>> filterReports({
    String? laboratory,
    String? status,
  }) async {
    Query<Map<String, dynamic>> query = _reportsRef;
    
    if (laboratory != null && laboratory != 'Todos') {
      query = query.where('laboratory', isEqualTo: laboratory);
    }
    if (status != null && status != 'Todos') {
      query = query.where('status', isEqualTo: status);
    }
    
    final result = await query.orderBy('createdAt', descending: true).get();
    return result.docs.map(_reportFromDoc).toList();
  }

  static ReportModel _reportFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ReportModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      type: data['type'] ?? 'grave',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imageUrl'],
      status: data['status'] ?? 'Pendiente',
      laboratory: data['laboratory'] ?? '',
      equipment: data['equipment'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      techObservation: data['techObservation'],
    );
  }

  // ══════════════════════════════════════════════════════════
  // DISPOSITIVOS (Catálogo)
  // ══════════════════════════════════════════════════════════

  static CollectionReference<Map<String, dynamic>> get _devicesRef =>
      _db.collection('dispositivos');

  /// Obtiene todos los dispositivos
  static Future<List<LabDevice>> getAllDevices() async {
    final query = await _devicesRef.orderBy('laboratory').orderBy('name').get();
    return query.docs.map(_deviceFromDoc).toList();
  }

  /// Obtiene dispositivos por laboratorio
  static Future<List<LabDevice>> getDevicesByLab(String laboratory) async {
    final query = await _devicesRef
        .where('laboratory', isEqualTo: laboratory)
        .orderBy('name')
        .get();
    return query.docs.map(_deviceFromDoc).toList();
  }

  /// Crea o actualiza dispositivo
  static Future<void> saveDevice(LabDevice device) async {
    await _devicesRef.doc(device.id).set({
      'id': device.id,
      'name': device.name,
      'type': device.type,
      'laboratory': device.laboratory,
      'code': device.code,
    });
  }

  static LabDevice _deviceFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return LabDevice(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? 'other',
      laboratory: data['laboratory'] ?? '',
      code: data['code'] ?? '',
    );
  }

  // ══════════════════════════════════════════════════════════
  // ESTADÍSTICAS
  // ══════════════════════════════════════════════════════════

  /// Cuenta reportes por estado
  static Future<Map<String, int>> getReportStats() async {
    final all = await getAllReports();
    return {
      'Pendiente': all.where((r) => r.status == 'Pendiente').length,
      'En Proceso': all.where((r) => r.status == 'En Proceso').length,
      'Solucionado': all.where((r) => r.status == 'Solucionado').length,
      'Total': all.length,
    };
  }
}
