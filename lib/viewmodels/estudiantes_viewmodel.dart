import 'package:flutter/foundation.dart';

import '../core/errors.dart';
import '../models/estudiante.dart';
import '../services/estudiante_service.dart';

enum UiState { idle, loading, success, error }

class EstudiantesViewModel extends ChangeNotifier {
  final EstudianteService _service;

  EstudiantesViewModel({EstudianteService? service})
      : _service = service ?? EstudianteService();

  UiState uiState = UiState.idle;
  List<Estudiante> items = [];
  String? errorMessage;
  String? mensajeExito;

  Future<void> load() async {
    uiState = UiState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      items = await _service.fetchAll();
      uiState = UiState.success;
    } on ApiException catch (e) {
      errorMessage = e.message;
      uiState = UiState.error;
    } catch (_) {
      errorMessage = 'No se pudo cargar la lista';
      uiState = UiState.error;
    }
    notifyListeners();
  }

  Future<bool> eliminar(Estudiante estudiante) async {
    mensajeExito = null;
    try {
      await _service.delete(estudiante.idEstudiante);
      items = items.where((e) => e.idEstudiante != estudiante.idEstudiante).toList();
      mensajeExito = '${estudiante.nombreCompleto} quedó inactivo';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'No se pudo eliminar';
      notifyListeners();
      return false;
    }
  }
}
