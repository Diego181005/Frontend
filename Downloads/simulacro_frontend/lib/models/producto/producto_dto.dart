class ProductoDto {
  final int id;
  final String nombre;
  final num precio;
  final int stock;
  final int empresaId;
  ProductoDto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.empresaId,
  });
  factory ProductoDto.fromJson(Map<String, dynamic> j) => ProductoDto(
    id: j['id'] as int,
    nombre: j['nombre'] as String,
    precio: j['precio'] as num,
    stock: j['stock'] as int,
    empresaId: j['empresaId'] as int,
  );
}
