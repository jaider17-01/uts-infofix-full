/// Modelo para Laboratorio
class Laboratory {
  final String id;
  final String name;
  final String code; // LAB_SIS1, LAB_SIS2, etc.
  final int capacity;
  final String building;
  final int floor;
  final bool isActive;

  const Laboratory({
    required this.id,
    required this.name,
    required this.code,
    required this.capacity,
    required this.building,
    required this.floor,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'capacity': capacity,
      'building': building,
      'floor': floor,
      'isActive': isActive,
    };
  }

  factory Laboratory.fromMap(Map<String, dynamic> map) {
    return Laboratory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      capacity: map['capacity'] ?? 0,
      building: map['building'] ?? '',
      floor: map['floor'] ?? 1,
      isActive: map['isActive'] ?? true,
    );
  }

  Laboratory copyWith({
    String? id,
    String? name,
    String? code,
    int? capacity,
    String? building,
    int? floor,
    bool? isActive,
  }) {
    return Laboratory(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      capacity: capacity ?? this.capacity,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Laboratorios por defecto del sistema
const List<Laboratory> kDefaultLaboratories = [
  Laboratory(
    id: 'lab_sis1',
    name: 'Laboratorio Sistemas 1',
    code: 'LAB_SIS1',
    capacity: 20,
    building: 'Edificio A',
    floor: 1,
  ),
  Laboratory(
    id: 'lab_sis2',
    name: 'Laboratorio Sistemas 2',
    code: 'LAB_SIS2',
    capacity: 20,
    building: 'Edificio A',
    floor: 1,
  ),
  Laboratory(
    id: 'lab_redes',
    name: 'Laboratorio Redes',
    code: 'LAB_REDES',
    capacity: 15,
    building: 'Edificio A',
    floor: 2,
  ),
  Laboratory(
    id: 'lab_elec',
    name: 'Laboratorio Electrónica',
    code: 'LAB_ELEC',
    capacity: 15,
    building: 'Edificio B',
    floor: 1,
  ),
  Laboratory(
    id: 'sala_comp',
    name: 'Sala de Cómputo',
    code: 'SALA_COMP',
    capacity: 25,
    building: 'Edificio A',
    floor: 2,
  ),
];
