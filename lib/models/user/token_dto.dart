class TokenDto {
  final int id;
  final String nombre;
  final String rol;
  final String token;
  TokenDto({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.token,
  });
  factory TokenDto.fromJson(Map<String, dynamic> j) => TokenDto(
    id: j['id'] as int,
    nombre: j['nombre'] as String,
    rol: j['rol'].toString(),
    token: (j['token'] ?? '').toString(),
  );
}
