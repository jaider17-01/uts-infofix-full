import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/firebase_service.dart';

class ReportsProvider extends ChangeNotifier {
  List<ReportModel> _userReports = [];
  List<ReportModel> _allReports = [];
  bool _isLoading = false;

  List<ReportModel> get userReports => _userReports;
  List<ReportModel> get allReports => _allReports;
  bool get isLoading => _isLoading;

  List<ReportModel> get pendientes =>
      _userReports.where((r) => r.status == 'Pendiente').toList();

  List<ReportModel> get enProceso =>
      _userReports.where((r) => r.status == 'En Proceso').toList();

  List<ReportModel> get solucionados =>
      _userReports.where((r) => r.status == 'Solucionado').toList();

  int get pendingCount => pendientes.length;

  Future<void> loadUserReports(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    _userReports = await FirebaseService.getReportsByUser(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllReports() async {
    _isLoading = true;
    notifyListeners();
    
    _allReports = await FirebaseService.getAllReports();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReport(ReportModel report) async {
    await FirebaseService.createReport(report);
    _userReports.insert(0, report);
    _allReports.insert(0, report);
    notifyListeners();
  }

  Future<void> updateReportStatus(
      String reportId, String status, String? observation) async {
    await FirebaseService.updateReportStatus(reportId, status, observation);
    _updateInList(_userReports, reportId, status, observation);
    _updateInList(_allReports, reportId, status, observation);
    notifyListeners();
  }

  void _updateInList(List<ReportModel> list, String id, String status,
      String? obs) {
    final index = list.indexWhere((r) => r.id == id);
    if (index != -1) {
      list[index] =
          list[index].copyWith(status: status, techObservation: obs);
    }
  }

  List<ReportModel> filterAllReports({String? lab, String? status}) {
    return _allReports.where((r) {
      final labMatch = lab == null || lab == 'Todos' || r.laboratory == lab;
      final statusMatch = status == null || status == 'Todos' || r.status == status;
      return labMatch && statusMatch;
    }).toList();
  }

  List<String> get allLaboratories {
    final labs = _allReports.map((r) => r.laboratory).toSet().toList();
    labs.sort();
    return ['Todos', ...labs];
  }
}
