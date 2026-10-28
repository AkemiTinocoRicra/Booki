import 'package:flutter/foundation.dart';

import '../core/errors.dart';
import '../models/estudiante.dart';
import '../services/estudiante_service.dart';

enum UiState { idle, loading, success, error }

class EstudianteFormViewModel extends ChangeNotifier {
  final EstudianteService _service;

  EstudianteFormViewModel({EstudianteService? service})
      : _service = service ?? EstudianteService();

  UiState uiState = UiState.idle;
  String? errorMessage;
  Estudiante? estudiante;
  bool get esEdicion => estudiante != null;

  Future<void> cargar(int id) async {
    uiState = UiState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      estudiante = await _service.fetchById(id);
      uiState = UiState.success;
    } on ApiException catch (e) {
      errorMessage = e.message;
      uiState = UiState.error;
    } catch (_) {
      errorMessage = 'No se pudo cargar el estudiante';
      uiState = UiState.error;
    }
    notifyListeners();
  }

  static bool dniValido(String dni) => RegExp(r'^\d{8}$').hasMatch(dni);

  static bool contrasenaValida(String contrasena) =>
      RegExp(r'^\d{4}$').hasMatch(contrasena);

  void limpiarError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> guardar({
    required String dni,
    required String nombres,
    required String apellidos,
    String? fechaNacimiento,
    required String contrasena,
    required int idGrado,
    String? estado,
  }) async {
    if (!dniValido(dni)) {
      errorMessage = 'El DNI debe tener 8 dígitos';
      notifyListeners();
      return false;
    }
    if (nombres.trim().isEmpty || apellidos.trim().isEmpty) {
      errorMessage = 'Nombres y apellidos son obligatorios';
      notifyListeners();
      return false;
    }

    uiState = UiState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      if (esEdicion) {
        estudiante = await _service.update(
          estudiante!.idEstudiante,
          nombres: nombres.trim(),
          apellidos: apellidos.trim(),
          fechaNacimiento: fechaNacimiento,
          contrasena: contrasena.isEmpty ? null : contrasena,
          idGrado: idGrado,
          estado: estado,
        );
      } else {
        if (!contrasenaValida(contrasena)) {
          errorMessage = 'La contraseña debe tener 4 dígitos';
          uiState = UiState.error;
          notifyListeners();
          return false;
        }
        estudiante = await _service.create(
          dni: dni,
          nombres: nombres.trim(),
          apellidos: apellidos.trim(),
          fechaNacimiento: fechaNacimiento,
          contrasena: contrasena,
          idGrado: idGrado,
        );
      }
      uiState = UiState.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      uiState = UiState.error;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'No se pudo guardar';
      uiState = UiState.error;
      notifyListeners();
      return false;
    }
  }
}
