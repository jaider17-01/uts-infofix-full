/// Modelo para Dispositivo (Admin)
class Device {
  final String id;
  final String name;
  final String type;
  final String laboratoryId;
  final String laboratoryName;
  final String serialNumber;
  final String brand;
  final String model;
  final String status; // Activo, En reparación, Dado de baja
  final String? observation;
  final DateTime? purchaseDate;
  final DateTime? lastMaintenanceDate;

  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.laboratoryId,
    required this.laboratoryName,
    required this.serialNumber,
    required this.brand,
    required this.model,
    this.status = 'Activo',
    this.observation,
    this.purchaseDate,
    this.lastMaintenanceDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'laboratoryId': laboratoryId,
      'laboratoryName': laboratoryName,
      'serialNumber': serialNumber,
      'brand': brand,
      'model': model,
      'status': status,
      'observation': observation,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      laboratoryId: map['laboratoryId'] ?? '',
      laboratoryName: map['laboratoryName'] ?? '',
      serialNumber: map['serialNumber'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      status: map['status'] ?? 'Activo',
      observation: map['observation'],
      purchaseDate: map['purchaseDate'] != null 
          ? DateTime.tryParse(map['purchaseDate']) 
          : null,
      lastMaintenanceDate: map['lastMaintenanceDate'] != null 
          ? DateTime.tryParse(map['lastMaintenanceDate']) 
          : null,
    );
  }

  Device copyWith({
    String? id,
    String? name,
    String? type,
    String? laboratoryId,
    String? laboratoryName,
    String? serialNumber,
    String? brand,
    String? model,
    String? status,
    String? observation,
    DateTime? purchaseDate,
    DateTime? lastMaintenanceDate,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      laboratoryId: laboratoryId ?? this.laboratoryId,
      laboratoryName: laboratoryName ?? this.laboratoryName,
      serialNumber: serialNumber ?? this.serialNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      status: status ?? this.status,
      observation: observation ?? this.observation,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
    );
  }
}

/// Tipos de dispositivos disponibles
const List<String> kDeviceTypes = [
  'pc',
  'monitor',
  'mouse',
  'keyboard',
  'headset',
  'webcam',
  'ups',
  'printer',
  'projector',
  'switch',
  'cable',
  'other',
];

/// Etiquetas de tipos
const Map<String, String> kDeviceTypeLabels = {
  'pc': 'Computador',
  'monitor': 'Monitor/Pantalla',
  'mouse': 'Mouse',
  'keyboard': 'Teclado',
  'headset': 'Audífonos',
  'webcam': 'Cámara web',
  'ups': 'UPS/Regulador',
  'printer': 'Impresora',
  'projector': 'Proyector',
  'switch': 'Switch de red',
  'cable': 'Cable/Adaptador',
  'other': 'Otro',
};

/// Estados posibles
const List<String> kDeviceStatuses = [
  'Activo',
  'En reparación',
  'Dado de baja',
];
