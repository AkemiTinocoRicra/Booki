import 'package:flutter/foundation.dart';

import '../core/errors.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

enum UiState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final SessionService _sessionService;

  AuthViewModel({
    AuthService? authService,
    SessionService? sessionService,
  })  : _authService = authService ?? AuthService(),
        _sessionService = sessionService ?? SessionService();

  UiState uiState = UiState.idle;
  String? errorMessage;
  bool isAuthenticated = false;
  String? token;
  String? dni;

  static bool dniValido(String dni) => RegExp(r'^\d{8}$').hasMatch(dni);

  static bool contrasenaValida(String contrasena) =>
      RegExp(r'^\d{4}$').hasMatch(contrasena);

  void _establecer(String? token, String? dni) {
    this.token = token;
    this.dni = dni;
    isAuthenticated = token != null;
  }

  Future<void> register({
    required String dni,
    required String nombres,
    required String apellidos,
    String? fechaNacimiento,
    required String contrasena,
    required String confirmarContrasena,
    required int idGrado,
  }) async {
    if (!dniValido(dni)) {
      _fallar('El DNI debe tener 8 dígitos');
      return;
    }
    if (nombres.trim().isEmpty || apellidos.trim().isEmpty) {
      _fallar('Nombres y apellidos son obligatorios');
      return;
    }
    if (!contrasenaValida(contrasena)) {
      _fallar('La contraseña debe tener 4 dígitos');
      return;
    }
    if (contrasena != confirmarContrasena) {
      _fallar('Las contraseñas no coinciden');
      return;
    }

    uiState = UiState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final respuesta = await _authService.registrar(
        RegistroRequest(
          dni: dni,
          nombres: nombres.trim(),
          apellidos: apellidos.trim(),
          fechaNacimiento: fechaNacimiento,
          contrasena: contrasena,
          idGrado: idGrado,
        ),
      );
      await _sessionService.saveToken(respuesta.token);
      _establecer(respuesta.token, respuesta.dni);
      uiState = UiState.success;
    } on ApiException catch (e) {
      _establecer(null, null);
      errorMessage = e.message;
      uiState = UiState.error;
    } catch (_) {
      _establecer(null, null);
      errorMessage = 'Error inesperado';
      uiState = UiState.error;
    }
    notifyListeners();
  }

  Future<void> login({
    required String dni,
    required String contrasena,
  }) async {
    if (!dniValido(dni)) {
      _fallar('El DNI debe tener 8 dígitos');
      return;
    }
    if (!contrasenaValida(contrasena)) {
      _fallar('La contraseña debe tener 4 dígitos');
      return;
    }

    uiState = UiState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final respuesta = await _authService.login(
        LoginRequest(dni: dni, contrasena: contrasena),
      );
      await _sessionService.saveToken(respuesta.token);
      _establecer(respuesta.token, respuesta.dni);
      uiState = UiState.success;
    } on ApiException catch (e) {
      _establecer(null, null);
      errorMessage = e.message;
      uiState = UiState.error;
    } catch (_) {
      _establecer(null, null);
      errorMessage = 'Error inesperado';
      uiState = UiState.error;
    }
    notifyListeners();
  }

  Future<void> restoreSession() async {
    final guardado = await _sessionService.readToken();
    if (guardado != null && guardado.isNotEmpty) {
      _establecer(guardado, null);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _sessionService.clearToken();
    _establecer(null, null);
    uiState = UiState.idle;
    errorMessage = null;
    notifyListeners();
  }

  void _fallar(String mensaje) {
    errorMessage = mensaje;
    uiState = UiState.error;
    notifyListeners();
  }
}
