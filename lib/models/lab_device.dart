/// Representa un dispositivo/implemento de laboratorio
class LabDevice {
  final String id;
  final String name;
  final String type; // pc, monitor, mouse, keyboard, headset, webcam, ups, printer, projector, chair, desk, cable, other
  final String laboratory;
  final String code; // código QR embebido

  const LabDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.laboratory,
    required this.code,
  });

  /// Icono según el tipo de dispositivo
  String get typeLabel {
    switch (type) {
      case 'pc':
        return 'Computador';
      case 'monitor':
        return 'Monitor/Pantalla';
      case 'mouse':
        return 'Mouse';
      case 'keyboard':
        return 'Teclado';
      case 'headset':
        return 'Audífonos';
      case 'webcam':
        return 'Cámara web';
      case 'ups':
        return 'UPS / Regulador';
      case 'printer':
        return 'Impresora';
      case 'projector':
        return 'Proyector';
      case 'chair':
        return 'Silla';
      case 'desk':
        return 'Mesa/Escritorio';
      case 'cable':
        return 'Cable / Adaptador';
      case 'switch':
        return 'Switch de red';
      default:
        return 'Otro implemento';
    }
  }

  /// Parsea un string QR con formato: UTS|LAB|DEVICE_CODE
  /// Ej: "UTS|LAB_SIS1|PC-01"
  static LabDevice? fromQrCode(String raw) {
    try {
      final parts = raw.split('|');
      if (parts.length < 3 || parts[0] != 'UTS') return null;
      final lab = _parseLab(parts[1]);
      final code = parts[2];
      return _catalog.firstWhere(
        (d) => d.code == code && d.laboratory == lab,
        orElse: () => LabDevice(
          id: 'unknown',
          name: code,
          type: 'other',
          laboratory: lab,
          code: code,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static String _parseLab(String key) {
    const map = {
      'LAB_SIS1': 'Laboratorio Sistemas 1',
      'LAB_SIS2': 'Laboratorio Sistemas 2',
      'LAB_REDES': 'Laboratorio Redes',
      'LAB_ELEC': 'Laboratorio Electrónica',
      'SALA_COMP': 'Sala de Cómputo',
    };
    return map[key] ?? key;
  }
}

// ──────────────────────────────────────────────────────────
// BASE CATÁLOGO DE DISPOSITIVOS (compilados)
// ──────────────────────────────────────────────────────────
const List<LabDevice> _catalog = [
  // ── Laboratorio Sistemas 1 ────────────────────────────
  LabDevice(id: 'ls1_pc01', name: 'PC-01', type: 'pc', laboratory: 'Laboratorio Sistemas 1', code: 'PC-01'),
  LabDevice(id: 'ls1_pc02', name: 'PC-02', type: 'pc', laboratory: 'Laboratorio Sistemas 1', code: 'PC-02'),
  LabDevice(id: 'ls1_pc03', name: 'PC-03', type: 'pc', laboratory: 'Laboratorio Sistemas 1', code: 'PC-03'),
  LabDevice(id: 'ls1_pc04', name: 'PC-04', type: 'pc', laboratory: 'Laboratorio Sistemas 1', code: 'PC-04'),
  LabDevice(id: 'ls1_pc05', name: 'PC-05', type: 'pc', laboratory: 'Laboratorio Sistemas 1', code: 'PC-05'),
  LabDevice(id: 'ls1_pc06', name: 'PC-06', type: 'pc', laboratory: 'Laboratorio Sistemas 1', code: 'PC-06'),
  LabDevice(id: 'ls1_pc07', name: 'PC-07', type: 'pc', laboratory: 'Laboratorio Sistemas 1', code: 'PC-07'),
  LabDevice(id: 'ls1_pc08', name: 'PC-08', type: 'pc', laboratory: 'Laboratorio Sistemas 1', code: 'PC-08'),
  LabDevice(id: 'ls1_pc09', name: 'PC-09', type: 'pc', laboratory: 'Laboratorio Sistemas 1', code: 'PC-09'),
  LabDevice(id: 'ls1_pc10', name: 'PC-10', type: 'pc', laboratory: 'Laboratorio Sistemas 1', code: 'PC-10'),
  LabDevice(id: 'ls1_mon01', name: 'Monitor-01', type: 'monitor', laboratory: 'Laboratorio Sistemas 1', code: 'MON-01'),
  LabDevice(id: 'ls1_mon02', name: 'Monitor-02', type: 'monitor', laboratory: 'Laboratorio Sistemas 1', code: 'MON-02'),
  LabDevice(id: 'ls1_mon03', name: 'Monitor-03', type: 'monitor', laboratory: 'Laboratorio Sistemas 1', code: 'MON-03'),
  LabDevice(id: 'ls1_mou01', name: 'Mouse-01', type: 'mouse', laboratory: 'Laboratorio Sistemas 1', code: 'MOU-01'),
  LabDevice(id: 'ls1_mou02', name: 'Mouse-02', type: 'mouse', laboratory: 'Laboratorio Sistemas 1', code: 'MOU-02'),
  LabDevice(id: 'ls1_mou03', name: 'Mouse-03', type: 'mouse', laboratory: 'Laboratorio Sistemas 1', code: 'MOU-03'),
  LabDevice(id: 'ls1_key01', name: 'Teclado-01', type: 'keyboard', laboratory: 'Laboratorio Sistemas 1', code: 'KEY-01'),
  LabDevice(id: 'ls1_key02', name: 'Teclado-02', type: 'keyboard', laboratory: 'Laboratorio Sistemas 1', code: 'KEY-02'),
  LabDevice(id: 'ls1_key03', name: 'Teclado-03', type: 'keyboard', laboratory: 'Laboratorio Sistemas 1', code: 'KEY-03'),
  LabDevice(id: 'ls1_ups01', name: 'UPS-01', type: 'ups', laboratory: 'Laboratorio Sistemas 1', code: 'UPS-01'),
  LabDevice(id: 'ls1_proj01', name: 'Proyector-01', type: 'projector', laboratory: 'Laboratorio Sistemas 1', code: 'PROJ-01'),
  LabDevice(id: 'ls1_sw01', name: 'Switch-01', type: 'switch', laboratory: 'Laboratorio Sistemas 1', code: 'SW-01'),

  // ── Laboratorio Sistemas 2 ────────────────────────────
  LabDevice(id: 'ls2_pc01', name: 'PC-01', type: 'pc', laboratory: 'Laboratorio Sistemas 2', code: 'PC-01'),
  LabDevice(id: 'ls2_pc02', name: 'PC-02', type: 'pc', laboratory: 'Laboratorio Sistemas 2', code: 'PC-02'),
  LabDevice(id: 'ls2_pc03', name: 'PC-03', type: 'pc', laboratory: 'Laboratorio Sistemas 2', code: 'PC-03'),
  LabDevice(id: 'ls2_pc04', name: 'PC-04', type: 'pc', laboratory: 'Laboratorio Sistemas 2', code: 'PC-04'),
  LabDevice(id: 'ls2_pc05', name: 'PC-05', type: 'pc', laboratory: 'Laboratorio Sistemas 2', code: 'PC-05'),
  LabDevice(id: 'ls2_mon01', name: 'Monitor-01', type: 'monitor', laboratory: 'Laboratorio Sistemas 2', code: 'MON-01'),
  LabDevice(id: 'ls2_mon02', name: 'Monitor-02', type: 'monitor', laboratory: 'Laboratorio Sistemas 2', code: 'MON-02'),
  LabDevice(id: 'ls2_mou01', name: 'Mouse-01', type: 'mouse', laboratory: 'Laboratorio Sistemas 2', code: 'MOU-01'),
  LabDevice(id: 'ls2_mou02', name: 'Mouse-02', type: 'mouse', laboratory: 'Laboratorio Sistemas 2', code: 'MOU-02'),
  LabDevice(id: 'ls2_key01', name: 'Teclado-01', type: 'keyboard', laboratory: 'Laboratorio Sistemas 2', code: 'KEY-01'),
  LabDevice(id: 'ls2_key02', name: 'Teclado-02', type: 'keyboard', laboratory: 'Laboratorio Sistemas 2', code: 'KEY-02'),
  LabDevice(id: 'ls2_head01', name: 'Audífonos-01', type: 'headset', laboratory: 'Laboratorio Sistemas 2', code: 'HEAD-01'),
  LabDevice(id: 'ls2_ups01', name: 'UPS-01', type: 'ups', laboratory: 'Laboratorio Sistemas 2', code: 'UPS-01'),
  LabDevice(id: 'ls2_proj01', name: 'Proyector-01', type: 'projector', laboratory: 'Laboratorio Sistemas 2', code: 'PROJ-01'),

  // ── Laboratorio Redes ─────────────────────────────────
  LabDevice(id: 'lr_pc01', name: 'PC-01', type: 'pc', laboratory: 'Laboratorio Redes', code: 'PC-01'),
  LabDevice(id: 'lr_pc02', name: 'PC-02', type: 'pc', laboratory: 'Laboratorio Redes', code: 'PC-02'),
  LabDevice(id: 'lr_pc03', name: 'PC-03', type: 'pc', laboratory: 'Laboratorio Redes', code: 'PC-03'),
  LabDevice(id: 'lr_pc04', name: 'PC-04', type: 'pc', laboratory: 'Laboratorio Redes', code: 'PC-04'),
  LabDevice(id: 'lr_mon01', name: 'Monitor-01', type: 'monitor', laboratory: 'Laboratorio Redes', code: 'MON-01'),
  LabDevice(id: 'lr_mou01', name: 'Mouse-01', type: 'mouse', laboratory: 'Laboratorio Redes', code: 'MOU-01'),
  LabDevice(id: 'lr_key01', name: 'Teclado-01', type: 'keyboard', laboratory: 'Laboratorio Redes', code: 'KEY-01'),
  LabDevice(id: 'lr_sw01', name: 'Switch-Red-01', type: 'switch', laboratory: 'Laboratorio Redes', code: 'SW-01'),
  LabDevice(id: 'lr_sw02', name: 'Switch-Red-02', type: 'switch', laboratory: 'Laboratorio Redes', code: 'SW-02'),
  LabDevice(id: 'lr_ups01', name: 'UPS-01', type: 'ups', laboratory: 'Laboratorio Redes', code: 'UPS-01'),
  LabDevice(id: 'lr_proj01', name: 'Proyector-01', type: 'projector', laboratory: 'Laboratorio Redes', code: 'PROJ-01'),
  LabDevice(id: 'lr_cab01', name: 'Cable-Patch-01', type: 'cable', laboratory: 'Laboratorio Redes', code: 'CAB-01'),

  // ── Laboratorio Electrónica ───────────────────────────
  LabDevice(id: 'le_pc01', name: 'PC-01', type: 'pc', laboratory: 'Laboratorio Electrónica', code: 'PC-01'),
  LabDevice(id: 'le_pc02', name: 'PC-02', type: 'pc', laboratory: 'Laboratorio Electrónica', code: 'PC-02'),
  LabDevice(id: 'le_mon01', name: 'Monitor-01', type: 'monitor', laboratory: 'Laboratorio Electrónica', code: 'MON-01'),
  LabDevice(id: 'le_mou01', name: 'Mouse-01', type: 'mouse', laboratory: 'Laboratorio Electrónica', code: 'MOU-01'),
  LabDevice(id: 'le_key01', name: 'Teclado-01', type: 'keyboard', laboratory: 'Laboratorio Electrónica', code: 'KEY-01'),
  LabDevice(id: 'le_ups01', name: 'UPS-01', type: 'ups', laboratory: 'Laboratorio Electrónica', code: 'UPS-01'),
  LabDevice(id: 'le_proj01', name: 'Proyector-01', type: 'projector', laboratory: 'Laboratorio Electrónica', code: 'PROJ-01'),

  // ── Sala de Cómputo ───────────────────────────────────
  LabDevice(id: 'sc_pc01', name: 'PC-01', type: 'pc', laboratory: 'Sala de Cómputo', code: 'PC-01'),
  LabDevice(id: 'sc_pc02', name: 'PC-02', type: 'pc', laboratory: 'Sala de Cómputo', code: 'PC-02'),
  LabDevice(id: 'sc_pc03', name: 'PC-03', type: 'pc', laboratory: 'Sala de Cómputo', code: 'PC-03'),
  LabDevice(id: 'sc_pc04', name: 'PC-04', type: 'pc', laboratory: 'Sala de Cómputo', code: 'PC-04'),
  LabDevice(id: 'sc_pc05', name: 'PC-05', type: 'pc', laboratory: 'Sala de Cómputo', code: 'PC-05'),
  LabDevice(id: 'sc_pc06', name: 'PC-06', type: 'pc', laboratory: 'Sala de Cómputo', code: 'PC-06'),
  LabDevice(id: 'sc_mon01', name: 'Monitor-01', type: 'monitor', laboratory: 'Sala de Cómputo', code: 'MON-01'),
  LabDevice(id: 'sc_mon02', name: 'Monitor-02', type: 'monitor', laboratory: 'Sala de Cómputo', code: 'MON-02'),
  LabDevice(id: 'sc_mou01', name: 'Mouse-01', type: 'mouse', laboratory: 'Sala de Cómputo', code: 'MOU-01'),
  LabDevice(id: 'sc_mou02', name: 'Mouse-02', type: 'mouse', laboratory: 'Sala de Cómputo', code: 'MOU-02'),
  LabDevice(id: 'sc_key01', name: 'Teclado-01', type: 'keyboard', laboratory: 'Sala de Cómputo', code: 'KEY-01'),
  LabDevice(id: 'sc_key02', name: 'Teclado-02', type: 'keyboard', laboratory: 'Sala de Cómputo', code: 'KEY-02'),
  LabDevice(id: 'sc_head01', name: 'Audífonos-01', type: 'headset', laboratory: 'Sala de Cómputo', code: 'HEAD-01'),
  LabDevice(id: 'sc_head02', name: 'Audífonos-02', type: 'headset', laboratory: 'Sala de Cómputo', code: 'HEAD-02'),
  LabDevice(id: 'sc_web01', name: 'Webcam-01', type: 'webcam', laboratory: 'Sala de Cómputo', code: 'WEB-01'),
  LabDevice(id: 'sc_print01', name: 'Impresora-01', type: 'printer', laboratory: 'Sala de Cómputo', code: 'PRINT-01'),
  LabDevice(id: 'sc_ups01', name: 'UPS-01', type: 'ups', laboratory: 'Sala de Cómputo', code: 'UPS-01'),
  LabDevice(id: 'sc_proj01', name: 'Proyector-01', type: 'projector', laboratory: 'Sala de Cómputo', code: 'PROJ-01'),
];

// ──────────────────────────────────────────────────────────
// DISPOSITIVOS DINÁMICOS (agregados en tiempo de ejecución)
// ──────────────────────────────────────────────────────────
final List<LabDevice> _dynamicCatalog = [];

/// Agrega un dispositivo desconocido al catálogo dinámico.
/// Si ya existe un dispositivo con el mismo código en el laboratorio, retorna el existente.
/// Genera un nombre único: "Equipo desconocido-001", "Equipo desconocido-002", etc.
LabDevice addUnknownDevice(String laboratory, String scannedCode) {
  // Si ya existe en el catálogo base, retornarlo
  try {
    final existing = _catalog.firstWhere(
      (d) => d.code == scannedCode && d.laboratory == laboratory,
    );
    return existing;
  } catch (_) {}

  // Si ya fue agregado dinámicamente, retornarlo
  try {
    final dynamicExisting = _dynamicCatalog.firstWhere(
      (d) => d.code == scannedCode && d.laboratory == laboratory,
    );
    return dynamicExisting;
  } catch (_) {}

  // Contar cuántos "Equipo desconocido" ya existen en este laboratorio
  final unknownCount = _dynamicCatalog
      .where((d) => d.laboratory == laboratory && d.name.startsWith('Equipo desconocido'))
      .length;

  // Generar nombre con sufijo
  final suffix = (unknownCount + 1).toString().padLeft(3, '0');
  final newName = 'Equipo desconocido-$suffix';

  // Crear nuevo dispositivo
  final newDevice = LabDevice(
    id: 'dynamic_${DateTime.now().millisecondsSinceEpoch}',
    name: newName,
    type: 'other',
    laboratory: laboratory,
    code: scannedCode,
  );

  _dynamicCatalog.add(newDevice);
  return newDevice;
}

/// Retorna todos los dispositivos (base + dinámicos) de un laboratorio
List<LabDevice> getDevicesByLab(String laboratory) {
  final base = _catalog.where((d) => d.laboratory == laboratory).toList();
  final dynamic = _dynamicCatalog.where((d) => d.laboratory == laboratory).toList();
  return [...base, ...dynamic];
}

/// Lista de laboratorios disponibles
const List<String> kLaboratories = [
  'Laboratorio Sistemas 1',
  'Laboratorio Sistemas 2',
  'Laboratorio Redes',
  'Laboratorio Electrónica',
  'Sala de Cómputo',
];

