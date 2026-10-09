import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/auth_provider.dart';
import 'providers/reports_provider.dart';
import 'providers/notifications_provider.dart'; 
import 'providers/admin_provider.dart';
import 'utils/app_theme.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/new_report_screen.dart';
import 'screens/my_reports_screen.dart';
import 'screens/report_detail_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/tech_panel_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/user_profile_screen.dart';

// Admin screens
import 'screens/admin/admin_panel_screen.dart';
import 'screens/admin/admin_labs_screen.dart';  // AdminLabFormScreen included
import 'screens/admin/admin_devices_screen.dart';  // AdminDeviceFormScreen included
import 'screens/admin/admin_technicians_screen.dart';  // AdminTechFormScreen included

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  
  // Inicializar notificaciones
  final notificationsProvider = NotificationsProvider();
  await notificationsProvider.initialize();
  
  await initializeDateFormatting('es', null);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const UTSInfoFixApp());
}

class UTSInfoFixApp extends StatelessWidget {
  const UTSInfoFixApp({super.key});

  static final NotificationsProvider _notificationsProvider = NotificationsProvider();
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider.value(value: _notificationsProvider),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'UTS InfoFix',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const MainScaffold(),
          '/new-report': (_) => const NewReportScreen(),
          // standalone: true → muestra botón volver, NO BottomNav
          '/reports': (_) => const MyReportsScreen(standalone: true),
          '/report-detail': (_) => const ReportDetailScreen(),
          '/qr-scan': (_) => const QrScanScreen(),
          '/tech-panel': (_) => const TechPanelScreen(),
          '/notifications': (_) => const NotificationsScreen(),
          '/user-profile': (_) => const UserProfileScreen(),
          
          // Admin routes
          '/admin': (_) => const AdminPanelScreen(),
          '/admin-labs': (_) => const AdminLabsScreen(),
          '/admin-lab-form': (_) => const AdminLabFormScreen(),
          '/admin-devices': (_) => const AdminDevicesScreen(),
          '/admin-device-form': (_) => const AdminDeviceFormScreen(),
          '/admin-techs': (_) => const AdminTechniciansScreen(),
          '/admin-tech-form': (_) => const AdminTechFormScreen(),
        },
      ),
    );
  }
}

