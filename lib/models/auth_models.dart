class RegistroRequest {
  final String dni;
  final String nombres;
  final String apellidos;
  final String? fechaNacimiento;
  final String contrasena;
  final int idGrado;

  const RegistroRequest({
    required this.dni,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    required this.contrasena,
    required this.idGrado,
  });

  Map<String, dynamic> toJson() => {
        'dni': dni,
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaNacimiento,
        'contrasena': contrasena,
        'id_grado': idGrado,
      };
}

class LoginRequest {
  final String dni;
  final String contrasena;

  const LoginRequest({required this.dni, required this.contrasena});

  Map<String, dynamic> toJson() => {'dni': dni, 'contrasena': contrasena};
}

class AuthResponse {
  final String token;
  final String dni;
  final String role;

  const AuthResponse({
    required this.token,
    required this.dni,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] as String,
        dni: json['dni'] as String,
        role: json['role'] as String? ?? 'estudiante',
      );

  Map<String, dynamic> toJson() => {'token': token, 'dni': dni, 'role': role};
}
