// lib/screens/home_usuario_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/producto/producto_dto.dart';
import '../models/carrito/carrito_response_dto.dart';
import 'login_screen.dart';

class HomeUsuarioScreen extends StatefulWidget {
  const HomeUsuarioScreen({super.key, required this.nombre});
  final String nombre;

  @override
  State<HomeUsuarioScreen> createState() => _HomeUsuarioScreenState();
}

class _HomeUsuarioScreenState extends State<HomeUsuarioScreen> {
  final _searchCtrl = TextEditingController();
  List<ProductoDto> _all = [];
  List<ProductoDto> _filtered = [];
  List<CarritoResponseDto> _carrito = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final productos = await ApiService().getProductos();
      final carrito = await ApiService().getCarrito();
      _all = productos;
      _filtered = productos;
      _carrito = carrito;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String q) {
    q = q.trim().toLowerCase();
    setState(() {
      _filtered = _all.where((p) {
        final n = p.nombre.toLowerCase();
        return q.isEmpty || n.contains(q);
      }).toList();
    });
  }

  int _cantidadEnCarritoDe(int productoId) {
    return _carrito
        .where((i) => i.productoId == productoId)
        .fold<int>(0, (sum, i) => sum + i.cantidad);
  }

  num get _total => _carrito.fold<num>(0, (sum, i) => sum + i.subtotal);

  Future<void> _addConCantidad(ProductoDto p) async {
    final enCarrito = _cantidadEnCarritoDe(p.id);
    final disponible = (p.stock - enCarrito).clamp(0, p.stock);

    if (disponible <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay stock disponible para ${p.nombre}')),
      );
      return;
    }

    int cantidad = 1;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16 + 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.nombre,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text('Disp: $disponible'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setModal(() {
                        if (cantidad > 1) cantidad--;
                      }),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$cantidad',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      onPressed: () => setModal(() {
                        if (cantidad < disponible) cantidad++;
                      }),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Agregar al carrito'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Al cerrar el bottom sheet, si la cantidad es válida, intentamos agregar
    if (cantidad > 0) {
      if (cantidad > disponible) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No hay suficientes unidades. Disponible: $disponible',
            ),
          ),
        );
        return;
      }

      try {
        final updated = await ApiService().addToCarrito(
          productoId: p.id,
          cantidad: cantidad,
        );
        setState(() => _carrito = updated);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agregado(s): $cantidad × ${p.nombre}')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al agregar: $e')));
      }
    }
  }

  Future<void> _remove(int itemId) async {
    try {
      final updated = await ApiService().removeFromCarrito(itemId);
      setState(() => _carrito = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  Future<void> _checkout() async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tu carrito está vacío')));
      return;
    }
    try {
      final resp = await ApiService().checkoutCarrito();
      final total = resp['total'] ?? _total;

      // Refrescamos datos para reflejar stock actualizado desde el backend
      await _init();

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Compra exitosa!'),
          content: Text('Total pagado: $total'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo completar la compra: $e')),
      );
    }
  }

  void _logout() {
    ApiService().clearToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${widget.nombre}'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 42),
                    const SizedBox(height: 8),
                    Text('Error: $_error'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _init,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Cabecera estilizada con buscador
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Encuentra tus productos',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Buscar productos...',
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text('No hay productos para mostrar'),
                        )
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final p = _filtered[i];
                            final enCarrito = _cantidadEnCarritoDe(p.id);
                            final disponible = (p.stock - enCarrito).clamp(
                              0,
                              p.stock,
                            );
                            return ListTile(
                              title: Text(p.nombre),
                              subtitle: Text(
                                'Precio: ${p.precio}  |  Stock: ${p.stock}  •  Disponible: $disponible',
                              ),
                              trailing: FilledButton.icon(
                                onPressed: disponible <= 0
                                    ? null
                                    : () => _addConCantidad(p),
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Agregar'),
                              ),
                            );
                          },
                        ),
                ),

                // Panel inferior de carrito
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8 + 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total: $_total',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          FilledButton(
                            onPressed: _checkout,
                            child: const Text('Comprar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Carrito expandible
                      ExpansionTile(
                        shape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        title: Text('Mi carrito (${_carrito.length} ítems)'),
                        children: _carrito.isEmpty
                            ? [
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Tu carrito está vacío'),
                                ),
                              ]
                            : _carrito
                                  .map(
                                    (i) => ListTile(
                                      dense: true,
                                      title: Text(i.nombreProducto),
                                      subtitle: Text(
                                        'x${i.cantidad}  •  ${i.precio}  •  Subtotal: ${i.subtotal}',
                                      ),
                                      trailing: IconButton(
                                        onPressed: () => _remove(i.id),
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: 'Quitar',
                                      ),
                                    ),
                                  )
                                  .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
