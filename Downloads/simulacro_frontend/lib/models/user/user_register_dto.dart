class UserRegisterDto {
  final String nombre;
  final String password;
  final int rol; // 1 Usuario, 2 Empresa, 3 Administrador
  UserRegisterDto({
    required this.nombre,
    required this.password,
    required this.rol,
  });
  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'password': password,
    'rol': rol,
  };
}
