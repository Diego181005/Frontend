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
  final int empresaId;
  final String rol;

  @override
  State<HomeEmpresaScreen> createState() => _HomeEmpresaScreenState();
}

class _HomeEmpresaScreenState extends State<HomeEmpresaScreen> {
  bool _loading = true;
  String? _error;
  List<ProductoDto> _items = [];
  final Map<int, String> _imagenes = {};
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
    final imageCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'CREAR PRODUCTO',
          style: TextStyle(
            color: Color(0xFF6C63FF),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        content: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  controller: nombreCtrl,
                  label: 'Nombre del producto',
                  icon: Icons.inventory_2_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: precioCtrl,
                  label: 'Precio',
                  icon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final n = num.tryParse(v);
                    if (n == null || n <= 0) return 'Precio inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: stockCtrl,
                  label: 'Stock disponible',
                  icon: Icons.inventory_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final n = int.tryParse(v);
                    if (n == null || n < 0) return 'Stock inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: imageCtrl,
                  label: 'URL de imagen (opcional)',
                  icon: Icons.image_rounded,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF808080),
            ),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('CREAR'),
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
        if (img.isNotEmpty) _imagenes[nuevo.id] = img;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${nuevo.nombre} creado exitosamente'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✗ Error: $e'),
          backgroundColor: const Color(0xFFFF5252),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'EDITAR PRODUCTO',
          style: TextStyle(
            color: Color(0xFFFF6B9D),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        content: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  controller: nombreCtrl,
                  label: 'Nombre del producto',
                  icon: Icons.inventory_2_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: precioCtrl,
                  label: 'Precio',
                  icon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final n = num.tryParse(v);
                    if (n == null || n <= 0) return 'Precio inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: stockCtrl,
                  label: 'Stock disponible',
                  icon: Icons.inventory_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final n = int.tryParse(v);
                    if (n == null || n < 0) return 'Stock inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: imageCtrl,
                  label: 'URL de imagen (opcional)',
                  icon: Icons.image_rounded,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF808080),
            ),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('GUARDAR'),
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

      await _init();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Producto actualizado'),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✗ Error: $e'),
          backgroundColor: const Color(0xFFFF5252),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _eliminarProducto(ProductoDto p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'ELIMINAR PRODUCTO',
          style: TextStyle(
            color: Color(0xFFFF5252),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        content: Text(
          '¿Deseas eliminar "${p.nombre}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF808080),
            ),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    
    try {
      await ApiService().eliminarProducto(p.id);
      setState(() => _items.removeWhere((e) => e.id == p.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Producto eliminado'),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✗ Error: $e'),
          backgroundColor: const Color(0xFFFF5252),
          behavior: SnackBarBehavior.floating,
        ),
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

  List<ProductoDto> get _productosFiltrados {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((p) => p.nombre.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A2E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6C63FF),
                      Color(0xFF9D50BB),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'MI INVENTARIO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.inventory_2_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_items.length} productos',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: Text(
                widget.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _init,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  tooltip: 'Actualizar',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B9D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.exit_to_app_rounded,
                    color: Color(0xFFFF6B9D),
                  ),
                  tooltip: 'Cerrar sesión',
                ),
              ),
            ],
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C63FF),
                  strokeWidth: 3,
                ),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_rounded,
                          size: 48,
                          color: Color(0xFFFF5252),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'ERROR',
                        style: TextStyle(
                          color: Color(0xFFFF5252),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFB0B0B0)),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _init,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('REINTENTAR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Barra de búsqueda
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF9D50BB)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar productos...',
                          hintStyle: const TextStyle(color: Color(0xFF606060)),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF6C63FF),
                          ),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: Color(0xFF808080),
                                  ),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Grid de productos
                  if (_productosFiltrados.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inventory_2_rounded,
                              size: 64,
                              color: const Color(0xFF6C63FF).withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Sin productos',
                            style: TextStyle(
                              color: Color(0xFF808080),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Crea tu primer producto',
                            style: TextStyle(
                              color: Color(0xFF606060),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _productosFiltrados.length,
                      itemBuilder: (_, i) {
                        final p = _productosFiltrados[i];
                        final img = _imagenes[p.id];
                        return _buildProductCard(p, img);
                      },
                    ),
                  
                  const SizedBox(height: 100),
                ]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearProducto,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'NUEVO PRODUCTO',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductoDto p, String? img) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.3),
                  const Color(0xFF9D50BB).withOpacity(0.3),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              image: (img != null && img.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(img),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (img == null || img.isEmpty)
                ? const Center(
                    child: Icon(
                      Icons.inventory_2_rounded,
                      size: 48,
                      color: Colors.white54,
                    ),
                  )
                : null,
          ),
          
          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '\$${p.precio}',
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${p.stock}',
                          style: const TextStyle(
                            color: Color(0xFF2196F3),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B9D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () => _editarProducto(p),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            color: const Color(0xFFFF6B9D),
                            tooltip: 'Editar',
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () => _eliminarProducto(p),
                            icon: const Icon(Icons.delete_rounded, size: 18),
                            color: const Color(0xFFFF5252),
                            tooltip: 'Eliminar',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF808080)),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        filled: true,
        fillColor: const Color(0xFF0F0F1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF2A2A3E),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF6C63FF),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFFF5252),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFFF5252),
            width: 2,
          ),
        ),
      ),
    );
  }
}