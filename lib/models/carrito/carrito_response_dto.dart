// lib/models/carrito/carrito_response_dto.dart
class CarritoResponseDto {
  final int id;
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final num precio;
  final num subtotal;

  CarritoResponseDto({
    required this.id,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precio,
    required this.subtotal,
  });

  factory CarritoResponseDto.fromJson(Map<String, dynamic> j) =>
      CarritoResponseDto(
        id: j['id'] as int,
        productoId: j['productoId'] as int,
        nombreProducto: (j['nombreProducto'] ?? '').toString(),
        cantidad: j['cantidad'] as int,
        precio: (j['precio'] as num),
        subtotal: (j['subtotal'] as num),
      );
}
