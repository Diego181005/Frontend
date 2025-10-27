// lib/screens/home_admin_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/producto/producto_dto.dart';
import 'login_screen.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key, required this.nombre});
  final String nombre;

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  bool _loading = true;
  String? _error;

  // Datos
  List<UsuarioDto> _usuarios = [];
  List<UsuarioDto> _empresas = [];

  // Filtros
  final _searchUsuarios = TextEditingController();
  final _searchEmpresas = TextEditingController();

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
      // Carga usuarios y empresas (empresas = usuarios con rol Empresa)
      final allUsers = await ApiService().getUsuarios();
      final empresas = allUsers
          .where((u) => u.rol.toLowerCase() == '2')
          .toList();
      final usuarios = allUsers
          .where((u) => u.rol.toLowerCase() == '1')
          .toList();

      setState(() {
        _usuarios = usuarios;
        _empresas = empresas;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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

  Future<void> _eliminarUsuario(UsuarioDto u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Eliminar a "${u.nombre}"?'),
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
    if (ok != true) return;

    try {
      await ApiService().eliminarUsuario(u.id);
      await _init();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Usuario eliminado: ${u.nombre}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }

  Future<void> _verProductosEmpresa(UsuarioDto empresa) async {
    // Abre un modal que lista productos de la empresa con opción de eliminar
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ProductosEmpresaSheet(empresa: empresa),
    );
    // Tras cerrar, refresca por si hubo eliminaciones
    await _init();
  }

  List<UsuarioDto> get _usuariosFiltrados {
    final q = _searchUsuarios.text.trim().toLowerCase();
    if (q.isEmpty) return _usuarios;
    return _usuarios.where((u) => u.nombre.toLowerCase().contains(q)).toList();
  }

  List<UsuarioDto> get _empresasFiltradas {
    final q = _searchEmpresas.text.trim().toLowerCase();
    if (q.isEmpty) return _empresas;
    return _empresas.where((e) => e.nombre.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido Administrador, ${widget.nombre}'),
        actions: [
          IconButton(onPressed: _init, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
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
          : ListView(
              children: [
                // Bloque: Usuarios
                Container(
                  color: theme.colorScheme.primaryContainer,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuarios',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchUsuarios,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Buscar usuarios...',
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                ),
                ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    'Lista de usuarios (${_usuariosFiltrados.length})',
                  ),
                  children: _usuariosFiltrados.isEmpty
                      ? [const ListTile(title: Text('Sin usuarios'))]
                      : _usuariosFiltrados
                            .map(
                              (u) => ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary
                                      .withOpacity(.1),
                                  child: const Icon(Icons.person_outline),
                                ),
                                title: Text(u.nombre),
                                subtitle: const Text('Rol: Usuario'),
                                trailing: IconButton(
                                  tooltip: 'Eliminar',
                                  onPressed: () => _eliminarUsuario(u),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ),
                            )
                            .toList(),
                ),

                const SizedBox(height: 8),

                // Bloque: Empresas
                Container(
                  color: theme.colorScheme.secondaryContainer,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Empresas',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchEmpresas,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Buscar empresas...',
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                ),
                ExpansionTile(
                  title: Text(
                    'Lista de empresas (${_empresasFiltradas.length})',
                  ),
                  children: _empresasFiltradas.isEmpty
                      ? [const ListTile(title: Text('Sin empresas'))]
                      : _empresasFiltradas
                            .map(
                              (e) => ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.secondary
                                      .withOpacity(.1),
                                  child: const Icon(Icons.apartment_outlined),
                                ),
                                title: Text(e.nombre),
                                subtitle: const Text('Rol: Empresa'),
                                onTap: () => _verProductosEmpresa(e),
                                trailing: IconButton(
                                  tooltip: 'Eliminar',
                                  onPressed: () => _eliminarUsuario(e),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ),
                            )
                            .toList(),
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

// ---------- BottomSheet: productos de una empresa ----------
class _ProductosEmpresaSheet extends StatefulWidget {
  const _ProductosEmpresaSheet({required this.empresa});
  final UsuarioDto empresa;

  @override
  State<_ProductosEmpresaSheet> createState() => _ProductosEmpresaSheetState();
}

class _ProductosEmpresaSheetState extends State<_ProductosEmpresaSheet> {
  bool _loading = true;
  String? _error;
  List<ProductoDto> _items = [];
  final _searchCtrl = TextEditingController();

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
      final data = await ApiService().getProductos(
        empresaId: widget.empresa.id,
      );
      setState(() => _items = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ProductoDto> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((p) => p.nombre.toLowerCase().contains(q)).toList();
  }

  Future<void> _eliminarProducto(ProductoDto p) async {
    final ok = await showDialog<bool>(
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
    if (ok != true) return;
    try {
      await ApiService().eliminarProducto(p.id);
      await _init();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safe = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: safe),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, controller) {
          return Material(
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Productos de ${widget.empresa.nombre}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _filtered.isEmpty
                      ? const Center(child: Text('Sin productos'))
                      : ListView.builder(
                          controller: controller,
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final p = _filtered[i];
                            return ListTile(
                              title: Text(p.nombre),
                              subtitle: Text(
                                'Precio: ${p.precio} • Stock: ${p.stock}',
                              ),
                              trailing: IconButton(
                                tooltip: 'Eliminar',
                                onPressed: () => _eliminarProducto(p),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
