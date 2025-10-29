class UserLoginDto {
  final String nombre;
  final String password;
  UserLoginDto({required this.nombre, required this.password});
  Map<String, dynamic> toJson() => {'nombre': nombre, 'password': password};
}
