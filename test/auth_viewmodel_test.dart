import 'package:flutter_application_01/core/errors.dart';
import 'package:flutter_application_01/models/auth_models.dart';
import 'package:flutter_application_01/services/auth_service.dart';
import 'package:flutter_application_01/services/session_service.dart';
import 'package:flutter_application_01/viewmodels/auth_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.respuesta, this.error});

  AuthResponse? respuesta;
  ApiException? error;
  int llamadas = 0;
  LoginRequest? ultimoLogin;

  @override
  Future<AuthResponse> login(LoginRequest request) {
    llamadas++;
    ultimoLogin = request;
    final err = error;
    if (err != null) return Future.error(err);
    return Future.value(respuesta!);
  }

  @override
  Future<AuthResponse> registrar(RegistroRequest request) {
    llamadas++;
    final err = error;
    if (err != null) return Future.error(err);
    return Future.value(respuesta!);
  }
}

class _FakeSessionService implements SessionService {
  _FakeSessionService({this.token});

  String? token;

  @override
  Future<void> saveToken(String valor) async => token = valor;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> clearToken() async => token = null;
}

const _respuestaOk = AuthResponse(
  token: 'jwt-fake',
  dni: '12345678',
  role: 'estudiante',
);

void main() {
  test('login pasa idle → loading → success con el service mockeado', () async {
    final service = _FakeAuthService(respuesta: _respuestaOk);
    final vm = AuthViewModel(
      authService: service,
      sessionService: _FakeSessionService(),
    );

    final estados = <UiState>[];
    vm.addListener(() => estados.add(vm.uiState));

    await vm.login(dni: '12345678', contrasena: '1234');

    expect(estados, [UiState.loading, UiState.success]);
    expect(vm.uiState, UiState.success);
    expect(vm.isAuthenticated, isTrue);
    expect(vm.token, 'jwt-fake');
    expect(service.llamadas, 1);
  });

  test('login con error del service → uiState=error y errorMessage', () async {
    final service = _FakeAuthService(
      error: const ApiException(401, 'DNI o contraseña incorrectos'),
    );
    final vm = AuthViewModel(
      authService: service,
      sessionService: _FakeSessionService(),
    );

    await vm.login(dni: '12345678', contrasena: '1234');

    expect(vm.uiState, UiState.error);
    expect(vm.errorMessage, 'DNI o contraseña incorrectos');
    expect(vm.isAuthenticated, isFalse);
  });

  test('contraseña != 4 dígitos no llama al service', () async {
    final service = _FakeAuthService(respuesta: _respuestaOk);
    final vm = AuthViewModel(
      authService: service,
      sessionService: _FakeSessionService(),
    );

    await vm.login(dni: '12345678', contrasena: '12a4');

    expect(vm.uiState, UiState.error);
    expect(vm.errorMessage, 'La contraseña debe tener 4 dígitos');
    expect(service.llamadas, 0);
  });

  test('DNI != 8 dígitos no llama al service', () async {
    final service = _FakeAuthService(respuesta: _respuestaOk);
    final vm = AuthViewModel(
      authService: service,
      sessionService: _FakeSessionService(),
    );

    await vm.login(dni: '1234567', contrasena: '1234');

    expect(service.llamadas, 0);
    expect(vm.errorMessage, 'El DNI debe tener 8 dígitos');
  });

  test('register valida confirmación de contraseña sin llamar al service',
      () async {
    final service = _FakeAuthService(respuesta: _respuestaOk);
    final vm = AuthViewModel(
      authService: service,
      sessionService: _FakeSessionService(),
    );

    await vm.register(
      dni: '12345678',
      nombres: 'Ana',
      apellidos: 'Perez',
      contrasena: '1234',
      confirmarContrasena: '9999',
      idGrado: 3,
    );

    expect(service.llamadas, 0);
    expect(vm.errorMessage, 'Las contraseñas no coinciden');
  });

  test('logout borra el token y desautentica', () async {
    final session = _FakeSessionService(token: 'jwt-fake');
    final vm = AuthViewModel(
      authService: _FakeAuthService(respuesta: _respuestaOk),
      sessionService: session,
    );

    await vm.login(dni: '12345678', contrasena: '1234');
    expect(vm.isAuthenticated, isTrue);

    await vm.logout();

    expect(vm.isAuthenticated, isFalse);
    expect(vm.token, isNull);
    expect(session.token, isNull);
  });

  test('restoreSession lee el token persistido', () async {
    final session = _FakeSessionService(token: 'jwt-guardado');
    final vm = AuthViewModel(
      authService: _FakeAuthService(),
      sessionService: session,
    );

    expect(vm.isAuthenticated, isFalse);
    await vm.restoreSession();

    expect(vm.isAuthenticated, isTrue);
    expect(vm.token, 'jwt-guardado');
  });
}
