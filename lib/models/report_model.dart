class ReportModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String type; // grave, leve, faltante, software
  final String title;
  final String description;
  final String? imagePath;
  final String status; // Pendiente, En Proceso, Solucionado
  final String laboratory;
  final String equipment;
  final String date;
  final String time;
  final String? techObservation;

  ReportModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.type,
    required this.title,
    required this.description,
    this.imagePath,
    required this.status,
    required this.laboratory,
    required this.equipment,
    required this.date,
    required this.time,
    this.techObservation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'type': type,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'status': status,
      'laboratory': laboratory,
      'equipment': equipment,
      'date': date,
      'time': time,
      'techObservation': techObservation,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      type: map['type'] ?? 'grave',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'],
      status: map['status'] ?? 'Pendiente',
      laboratory: map['laboratory'] ?? '',
      equipment: map['equipment'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      techObservation: map['techObservation'],
    );
  }

  ReportModel copyWith({
    String? status,
    String? techObservation,
  }) {
    return ReportModel(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      type: type,
      title: title,
      description: description,
      imagePath: imagePath,
      status: status ?? this.status,
      laboratory: laboratory,
      equipment: equipment,
      date: date,
      time: time,
      techObservation: techObservation ?? this.techObservation,
    );
  }
}

