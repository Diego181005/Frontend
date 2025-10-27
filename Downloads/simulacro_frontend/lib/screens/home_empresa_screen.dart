// lib/screens/home_empresa_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/producto/producto_dto.dart';
import 'login_screen.dart';

class HomeEmpresaScreen extends StatefulWidget {
  const HomeEmpresaScreen({
    super.key,
    required this.nombre,
    required this.empresaId,
    required this.rol,
  });
  final String nombre;
  final int empresaId; // id del usuario-empresa (viene del tokenDto.id)
  final String rol; // para validar acceso

  @override
  State<HomeEmpresaScreen> createState() => _HomeEmpresaScreenState();
}

class _HomeEmpresaScreenState extends State<HomeEmpresaScreen> {
  bool _loading = true;
  String? _error;
  List<ProductoDto> _items = [];
  final Map<int, String> _imagenes = {}; // Opcional: URL por producto (solo UI)

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
      // Carga solo productos de esta empresa
      final data = await ApiService().getProductos(empresaId: widget.empresaId);
      setState(() => _items = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _crearProducto() async {
    final form = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final imageCtrl = TextEditingController(); // opcional, solo UI por ahora

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo producto'),
        content: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: precioCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final n = num.tryParse(v);
                    if (n == null || n <= 0) return 'Precio inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final n = int.tryParse(v);
                    if (n == null || n < 0) return 'Stock inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Imagen (URL, opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      final nuevo = await ApiService().crearProducto(
        nombre: nombreCtrl.text.trim(),
        precio: num.parse(precioCtrl.text),
        stock: int.parse(stockCtrl.text),
      );

      setState(() {
        _items = [..._items, nuevo];
        final img = imageCtrl.text.trim();
        if (img.isNotEmpty) _imagenes[nuevo.id] = img; // sólo UI por ahora
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto creado: ${nuevo.nombre}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo crear: $e')));
    }
  }

  Future<void> _editarProducto(ProductoDto p) async {
    final form = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController(text: p.nombre);
    final precioCtrl = TextEditingController(text: p.precio.toString());
    final stockCtrl = TextEditingController(text: p.stock.toString());
    final imageCtrl = TextEditingController(text: _imagenes[p.id] ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar producto'),
        content: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: precioCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final n = num.tryParse(v);
                    if (n == null || n <= 0) return 'Precio inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final n = int.tryParse(v);
                    if (n == null || n < 0) return 'Stock inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Imagen (URL, opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await ApiService().actualizarProducto(
        id: p.id,
        nombre: nombreCtrl.text.trim(),
        precio: num.parse(precioCtrl.text),
        stock: int.parse(stockCtrl.text),
      );

      // ✅ Recarga desde backend para reflejar el estado real
      await _init();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto actualizado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo actualizar: $e')));
    }
  }

  Future<void> _eliminarProducto(ProductoDto p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${p.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService().eliminarProducto(p.id);
      setState(() => _items.removeWhere((e) => e.id == p.id));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }

  void _logout() {
    ApiService().clearToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false, // elimina todas las pantallas previas
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${widget.nombre}'),
        actions: [
          IconButton(onPressed: _init, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearProducto,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
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
          : _items.isEmpty
          ? const Center(child: Text('Sin productos aún'))
          : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = _items[i];
                final img = _imagenes[p.id];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(.1),
                    backgroundImage: (img != null && img.isNotEmpty)
                        ? NetworkImage(img)
                        : null,
                    child: (img == null || img.isEmpty)
                        ? Icon(
                            Icons.inventory_2_outlined,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),
                  title: Text(p.nombre),
                  subtitle: Text('Precio: ${p.precio}  |  Stock: ${p.stock}'),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        onPressed: () => _editarProducto(p),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        onPressed: () => _eliminarProducto(p),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
