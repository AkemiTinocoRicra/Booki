class Estudiante {
  final int idEstudiante;
  final String dni;
  final String nombres;
  final String apellidos;
  final String? fechaNacimiento;
  final int idGrado;
  final String estado;
  final int cantidadCopas;

  const Estudiante({
    required this.idEstudiante,
    required this.dni,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    required this.idGrado,
    required this.estado,
    required this.cantidadCopas,
  });

  bool get activo => estado == 'AC';

  String get nombreCompleto => '$nombres $apellidos';

  factory Estudiante.fromJson(Map<String, dynamic> json) => Estudiante(
        idEstudiante: json['id_estudiante'] as int,
        dni: json['dni'] as String,
        nombres: json['nombres'] as String,
        apellidos: json['apellidos'] as String,
        fechaNacimiento: json['fecha_nacimiento'] as String?,
        idGrado: json['id_grado'] as int,
        estado: json['estado'] as String,
        cantidadCopas: json['cantidad_copas'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id_estudiante': idEstudiante,
        'dni': dni,
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaNacimiento,
        'id_grado': idGrado,
        'estado': estado,
        'cantidad_copas': cantidadCopas,
      };
}
