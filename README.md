# UTS InfoFix 🖥️🔧

App móvil Flutter para reportar fallas en laboratorios — Unidades Tecnológicas de Santander.

---

## ▶️ Configuración de Firebase (REQUERIDO)

### 1. Crear proyecto en Firebase Console
 Ve a [console.firebase.google.com](https://console.firebase.google.com) y crea un proyecto nuevo:
- Nombre: `uts-infofix`

### 2. Agregar app Android
- Nombre del paquete: `com.uts.infofix` (ver en `android/app/build.gradle → applicationId`)
- SHA-1 (opcional para debug): agregar fingerprint de debug si solicitas autenticación

### 3. Descargar configuración
- Descarga `google-services.json`
- Colócalo en: `android/app/google-services.json`

### 4. Habilitar servicios

#### Authentication:
- Proveedor: **Email/Password**
- Crea en Firebase Authentication las cuentas que necesites y asigna sus roles en Firestore.
- No guardes contraseñas ni claves de servicio en el repositorio.

#### Cloud Firestore:
- Configura reglas de seguridad que validen la identidad y los permisos de cada usuario antes de desplegar la app.

#### Cloud Messaging (para notificaciones push):
- Habilitar en Firebase Console

### 5. Verificar build.gradle

En `android/app/build.gradle` verificar:
```groovy
plugins {
    id "com.google.gms.google-services"
}
```
Al final del archivo:
```groovy
apply plugin: 'com.google.gms.google-services'
```

---

## ▶️ Importar y ejecutar

```bash
# 1. Entra a la carpeta
cd uts_infofix

# 2. Instala dependencias
flutter pub get

# 3. Ejecuta
flutter run
```

> **Android Studio:** File → Open → selecciona la carpeta `uts_infofix` → Run

---

## 👤 Cuentas de usuario

Crea las cuentas y contraseñas desde Firebase Authentication. Asigna los roles en Firestore según la configuración de tu proyecto.

---

## ✅ Funcionalidades implementadas

### Todos los botones funcionales:
- 🔔 **Campana de notificaciones** → abre pantalla de notificaciones con badges
- **Chevron `>`** en tarjeta de usuario → navega a pantalla de perfil detallado
- **Enviar Reporte** → genera notificación automática
- **Falla Grave / Leve / Faltante / Software** → navegan al formulario con tipo preseleccionado
- **Tomar Foto / Subir Galería** → acceso real a cámara y galería
- **Escanear QR** → simulación con datos reales de laboratorio
- **Tabs Pendientes / En Proceso / Solucionados / Historial** → filtros dinámicos
- **Panel Técnico** → login separado, cambio de estados, observaciones
- **Cambiar contraseña / Cerrar sesión** → funcionales con confirmación

---

## 📁 Estructura del proyecto

```
uts_infofix/
├── android/                    ← Configuración Android nativa completa
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/.../MainActivity.kt
│   │       └── res/
│   ├── build.gradle
│   ├── gradle.properties
│   └── settings.gradle
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── main_scaffold.dart
│   │   ├── home_screen.dart
│   │   ├── new_report_screen.dart
│   │   ├── my_reports_screen.dart
│   │   ├── report_detail_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── user_profile_screen.dart   ← NUEVO (chevron)
│   │   ├── notifications_screen.dart  ← NUEVO (campana)
│   │   ├── qr_scan_screen.dart
│   │   └── tech_panel_screen.dart
│   ├── widgets/
│   │   ├── app_header.dart            ← campana funcional
│   │   ├── user_card.dart             ← NUEVO (chevron funcional)
│   │   ├── bottom_nav.dart
│   │   ├── category_button.dart
│   │   └── report_card.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── reports_provider.dart
│   │   └── notifications_provider.dart ← NUEVO
│   ├── models/
│   │   ├── user_model.dart
│   │   └── report_model.dart
│   ├── services/
│   │   └── database_service.dart
│   └── utils/
│       └── app_theme.dart
├── assets/images/
├── test/widget_test.dart
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 🎨 Colores del diseño

| Color | Hex | Uso |
|---|---|---|
| Verde institucional | `#4A6B52` | Primary |
| Verde oscuro | `#3D5A44` | Hover / Dark |
| Rojo | `#DC3545` | Falla Grave |
| Naranja | `#ED8936` | Falla Leve |
| Amarillo | `#EAB308` | Faltante |
| Azul | `#3B82F6` | Problema Software |

---

Desarrollado para UTS — Unidades Tecnológicas de Santander, Bucaramanga 🇨🇴

