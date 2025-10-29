// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user/token_dto.dart';
import '../models/user/user_login_dto.dart';
import '../models/user/user_register_dto.dart';
import '../models/producto/producto_dto.dart';
import '../models/carrito/carrito_response_dto.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // 👇 TU API en Azure (incluye /api)
  final String _baseUrl = 'https://backend-parcial.azurewebsites.net/api';

  String? _token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null && _token!.isNotEmpty) 'Authorization': 'Bearer $_token',
  };

  void _setToken(String token) => _token = token;
  void clearToken() => _token = null;

  // -------- AUTH --------

  /// POST /api/Auth/register
  Future<void> register(UserRegisterDto dto) async {
    final url = Uri.parse('$_baseUrl/Auth/register');
    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(dto.toJson()),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error al registrar usuario: ${res.body}');
    }
  }

  /// POST /api/Auth/login -> { id, nombre, rol, token }
  Future<TokenDto> login(UserLoginDto dto) async {
    final url = Uri.parse('$_baseUrl/Auth/login');
    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(dto.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception('Login inválido (${res.statusCode})');
    }
    final tokenDto = TokenDto.fromJson(jsonDecode(res.body));
    _setToken(tokenDto.token);
    return tokenDto;
  }

  // -------- PRODUCTOS (GET público) --------

  /// GET /api/productos?empresaId=...
  Future<List<ProductoDto>> getProductos({int? empresaId}) async {
    final base = Uri.parse('$_baseUrl/productos');
    final url = (empresaId == null)
        ? base
        : base.replace(queryParameters: {'empresaId': '$empresaId'});

    final res = await http.get(url, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Error al obtener productos (${res.statusCode})');
    }
    final List data = jsonDecode(res.body);
    return data
        .map((e) => ProductoDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

extension CarritoApi on ApiService {
  /// GET /api/carritos
  Future<List<CarritoResponseDto>> getCarrito() async {
    final url = Uri.parse('$_baseUrl/carritos');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode == 404) return <CarritoResponseDto>[];

    if (res.statusCode != 200) {
      throw Exception('No se pudo obtener el carrito (${res.statusCode})');
    }
    final List data = jsonDecode(res.body);
    return data
        .map((e) => CarritoResponseDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// POST /api/carritos  { productoId, cantidad }
  Future<List<CarritoResponseDto>> addToCarrito({
    required int productoId,
    int cantidad = 1,
  }) async {
    final url = Uri.parse('$_baseUrl/carritos');
    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'productoId': productoId, 'cantidad': cantidad}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('No se pudo agregar al carrito (${res.statusCode})');
    }
    final List data = jsonDecode(res.body);
    return data
        .map((e) => CarritoResponseDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// DELETE /api/carritos/{itemId}
  Future<List<CarritoResponseDto>> removeFromCarrito(int itemId) async {
    final url = Uri.parse('$_baseUrl/carritos/$itemId');
    final res = await http.delete(url, headers: _headers);

    // 204 No Content (lo más común en DELETE)
    if (res.statusCode == 204) {
      return await getCarrito();
    }

    // 2xx con o sin cuerpo
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body;

      // A veces llega vacío o con espacios -> no intentes parsear
      if (body.isEmpty || body.trim().isEmpty) {
        return await getCarrito();
      }

      // Intentar parsear; si falla, fallback a getCarrito()
      try {
        final decoded = jsonDecode(body);

        // Caso habitual: backend devuelve array de items
        if (decoded is List) {
          return decoded
              .map(
                (e) =>
                    CarritoResponseDto.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
        }

        // Soporte opcional: si viniera un objeto con 'items'
        if (decoded is Map && decoded['items'] is List) {
          final items = List.from(decoded['items']);
          return items
              .map(
                (e) =>
                    CarritoResponseDto.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
        }

        // Si no es lista ni objeto esperado, recarga estado del carrito
        return await getCarrito();
      } catch (_) {
        return await getCarrito();
      }
    }

    // Errores comunes
    if (res.statusCode == 404) {
      throw Exception('No se encontró el ítem en tu carrito (404)');
    }

    throw Exception('No se pudo eliminar del carrito (${res.statusCode})');
  }

  /// POST /api/carritos/checkout  -> { total: number, mensaje: string? }
  Future<Map<String, dynamic>> checkoutCarrito() async {
    final url = Uri.parse('$_baseUrl/carritos/checkout');
    final res = await http.post(url, headers: _headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('No se pudo completar la compra (${res.statusCode})');
    }
    return Map<String, dynamic>.from(jsonDecode(res.body));
  }
}

extension ProductosEmpresaApi on ApiService {
  /// POST /api/productos
  /// Body esperado por tu backend: { nombre, precio, stock }
  Future<ProductoDto> crearProducto({
    required String nombre,
    required num precio,
    required int stock,
  }) async {
    final url = Uri.parse('$_baseUrl/productos');
    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'nombre': nombre, 'precio': precio, 'stock': stock}),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('No se pudo crear el producto (${res.statusCode})');
    }
    final Map<String, dynamic> data = jsonDecode(res.body);
    return ProductoDto.fromJson(data);
  }

  /// PUT /api/productos/{id}
  Future<void> actualizarProducto({
    required int id,
    required String nombre,
    required num precio,
    required int stock,
  }) async {
    final url = Uri.parse('$_baseUrl/productos/$id');
    final res = await http.put(
      url,
      headers: _headers,
      body: jsonEncode({'nombre': nombre, 'precio': precio, 'stock': stock}),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      print('PUT /productos/$id -> ${res.statusCode}  ${res.body}');
      throw Exception('No se pudo actualizar (${res.statusCode}) ${res.body}');
    }
  }

  /// DELETE /api/productos/{id}
  Future<void> eliminarProducto(int id) async {
    final url = Uri.parse('$_baseUrl/productos/$id');
    final res = await http.delete(url, headers: _headers);
    if (res.statusCode != 204 && res.statusCode != 204) {
      throw Exception('No se pudo eliminar (${res.statusCode})');
    }
  }
}

class UsuarioDto {
  final int id;
  final String nombre;
  final String rol; // "Usuario" | "Empresa" | "Administrador"
  UsuarioDto({required this.id, required this.nombre, required this.rol});
  factory UsuarioDto.fromJson(Map<String, dynamic> j) => UsuarioDto(
    id: j['id'] as int,
    nombre: (j['nombre'] ?? '').toString(),
    rol: (j['rol'] ?? '').toString(),
  );
}

extension AdminApi on ApiService {
  /// GET /api/usuarios (opcional: ?rol=Empresa | Usuario | Administrador)
  Future<List<UsuarioDto>> getUsuarios({String? rol}) async {
    final base = Uri.parse('$_baseUrl/usuarios');
    final url = (rol == null || rol.isEmpty)
        ? base
        : base.replace(queryParameters: {'rol': rol});
    final res = await http.get(url, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Error al obtener usuarios (${res.statusCode})');
    }
    final List data = jsonDecode(res.body);
    return data
        .map((e) => UsuarioDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// DELETE /api/usuarios/{id}
  Future<void> eliminarUsuario(int id) async {
    final url = Uri.parse('$_baseUrl/usuarios/$id');
    final res = await http.delete(url, headers: _headers);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('No se pudo eliminar usuario (${res.statusCode})');
    }
  }
}
