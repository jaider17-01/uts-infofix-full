import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

/// Notificación local
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final String? reportId;
  final String type; // 'report_sent', 'status_changed', 'system'

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.reportId,
    this.type = 'system',
  });
}

/// Provider de Notificaciones (Local + Push)
class NotificationsProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  bool _isInitialized = false;
  String? _fcmToken;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  List<NotificationItem> get unread => _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unread.length;
  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  // ══════════════════════════════════════════════════════════
  // INICIALIZACIÓN
  // ══════════════════════════════════════════════════════════

  /// Inicializa FCM y configura handlers
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission en iOS
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get token
      _fcmToken = await FirebaseMessaging.instance.getToken();
      
      // Guardar token en Firestore (si hay usuario logueado)
      await _saveTokenToFirestore();

      // Configurar handler para mensajes en foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Configurar handler para abrir desde background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Guarda el token FCM en Firestore
  Future<void> _saveTokenToFirestore() async {
    if (_fcmToken == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('fcm_tokens')
          .doc(_fcmToken)
          .set({
        'token': _fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': 'android',
      });
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Suscribe a tópico (por laboratorio)
  Future<void> subscribeToLabTopic(String labCode) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('lab_$labCode');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Desuscribe de tópico
  Future<void> unsubscribeFromLabTopic(String labCode) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('lab_$labCode');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // HANDLERS DE MENSAJES
  // ═════════════════════════���════════════════════════════════

  void _handleForegroundMessage(RemoteMessage message) {
    _processRemoteMessage(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _processRemoteMessage(message);
    // Navegar al reporte si tiene reportId
    final reportId = message.data['reportId'];
    if (reportId != null) {
      // Esto se maneja en la UI
    }
  }

  void _processRemoteMessage(RemoteMessage message) {
    final item = NotificationItem(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? message.data['title'] ?? 'Notificación',
      body: message.notification?.body ?? message.data['body'] ?? '',
      timestamp: DateTime.now(),
      reportId: message.data['reportId'],
      type: message.data['type'] ?? 'system',
    );
    _notifications.insert(0, item);
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════
  // NOTIFICACIONES LOCALES
  // ══════════════════════════════════════════════════════════

  void addReportNotification(ReportModel report) {
    final item = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '✅ Reporte enviado',
      body: '${report.equipment} – ${report.laboratory}: "${report.title}"',
      timestamp: DateTime.now(),
      reportId: report.id,
      type: 'report_sent',
    );
    _notifications.insert(0, item);
    notifyListeners();
  }

  void addStatusNotification(ReportModel report) {
    String emoji;
    switch (report.status) {
      case 'En Proceso':
        emoji = '🔧';
        break;
      case 'Solucionado':
        emoji = '✅';
        break;
      default:
        emoji = '📋';
    }
    final item = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '$emoji Reporte actualizado',
      body: 'Tu reporte "${report.title}" ahora está: ${report.status}',
      timestamp: DateTime.now(),
      reportId: report.id,
      type: 'status_changed',
    );
    _notifications.insert(0, item);
    notifyListeners();
  }

  /// Notifica al técnico de nuevo reporte (envía a FCM)
  Future<void> notifyTechnician(ReportModel report) async {
    try {
      // Enviar a tópico de laboratorio
      final labCode = report.laboratory.replaceAll(' ', '_').toLowerCase();
      
      await FirebaseMessaging.instance
          .subscribeToTopic('lab_$labCode');
      
      // Enviar mensaje a través de FCM (esto requiere Cloud Functions en producción)
      // Por ahora, guardamos en Firestore para que el técnico vea
      await FirebaseFirestore.instance
          .collection('notificaciones')
          .add({
        'title': '📢 Nuevo reporte',
        'body': '${report.type}: ${report.title}',
        'reportId': report.id,
        'laboratory': report.laboratory,
        'type': 'new_report',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error notifying technician: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // GESTIÓN DE NOTIFICACIONES
  // ══════════════════════════════════════════════════════════

  void markAllRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Carga notificaciones desde Firestore
  Future<void> loadFromFirestore() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('notificaciones')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        final item = NotificationItem(
          id: doc.id,
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          timestamp: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          reportId: data['reportId'],
          type: data['type'] ?? 'system',
        );
        _notifications.add(item);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
  }
}
