import '../core/api_client.dart';
import '../models/auth_models.dart';

class AuthService {
  final ApiClient _client;

  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<AuthResponse> registrar(RegistroRequest request) async {
    final data = await _client.post(
      '/api/auth/registro',
      body: request.toJson(),
    );
    return AuthResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final data = await _client.post(
      '/api/auth/login',
      body: request.toJson(),
    );
    return AuthResponse.fromJson(data as Map<String, dynamic>);
  }
}
