import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user/user_register_dto.dart';

/// Pantalla de registro con diseño dark mode premium
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _password2Ctrl = TextEditingController();
  int _rol = 1; // 1=Usuario, 2=Empresa
  bool _loading = false;
  String? _error;
  bool _obscurePass1 = true;
  bool _obscurePass2 = true;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _passwordCtrl.dispose();
    _password2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dto = UserRegisterDto(
        nombre: _nombreCtrl.text.trim(),
        password: _passwordCtrl.text,
        rol: _rol,
      );
      await ApiService().register(dto);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Cuenta creada con éxito'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF0F0F1E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con botón de retroceso
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2A2A3E),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'REGISTRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenido scrollable
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ícono principal
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B9D), Color(0xFFFF8FA3)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6B9D).withOpacity(0.4),
                                  blurRadius: 32,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          const Text(
                            'CREAR CUENTA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          const Text(
                            'Completa tus datos para registrarte',
                            style: TextStyle(
                              color: Color(0xFF808080),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Card principal
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFFF6B9D).withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Error message
                                    if (_error != null)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 24),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF5252).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFFF5252).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.error_rounded,
                                              color: Color(0xFFFF5252),
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _error!,
                                                style: const TextStyle(
                                                  color: Color(0xFFFF5252),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    
                                    // Campo Nombre
                                    _buildLabel('NOMBRE DE USUARIO'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _nombreCtrl,
                                      hint: 'Ingresa tu nombre de usuario',
                                      icon: Icons.person_rounded,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Ingresa un nombre';
                                        }
                                        if (v.trim().length < 3) {
                                          return 'Mínimo 3 caracteres';
                                        }
                                        return null;
                                      },
                                    ),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Campo Contraseña
                                    _buildLabel('CONTRASEÑA'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _passwordCtrl,
                                      hint: 'Crea una contraseña segura',
                                      icon: Icons.lock_rounded,
                                      obscureText: _obscurePass1,
                                      suffixIcon: IconButton(
                                        onPressed: () =>
                                            setState(() => _obscurePass1 = !_obscurePass1),
                                        icon: Icon(
                                          _obscurePass1
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: const Color(0xFF808080),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Ingresa una contraseña';
                                        }
                                        if (v.length < 4) {
                                          return 'Mínimo 4 caracteres';
                                        }
                                        return null;
                                      },
                                    ),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Confirmar Contraseña
                                    _buildLabel('CONFIRMAR CONTRASEÑA'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _password2Ctrl,
                                      hint: 'Repite tu contraseña',
                                      icon: Icons.lock_reset_rounded,
                                      obscureText: _obscurePass2,
                                      suffixIcon: IconButton(
                                        onPressed: () =>
                                            setState(() => _obscurePass2 = !_obscurePass2),
                                        icon: Icon(
                                          _obscurePass2
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: const Color(0xFF808080),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Repite la contraseña';
                                        }
                                        if (v != _passwordCtrl.text) {
                                          return 'Las contraseñas no coinciden';
                                        }
                                        return null;
                                      },
                                    ),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Selector de Rol
                                    _buildLabel('TIPO DE CUENTA'),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildRolOption(
                                            value: 1,
                                            label: 'Usuario',
                                            icon: Icons.person_rounded,
                                            description: 'Comprador',
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildRolOption(
                                            value: 2,
                                            label: 'Empresa',
                                            icon: Icons.business_rounded,
                                            description: 'Vendedor',
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Botón de registro
                                    SizedBox(
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _loading ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: const Color(0xFF2A2A3E),
                                          disabledForegroundColor: const Color(0xFF606060),
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            gradient: _loading
                                                ? null
                                                : const LinearGradient(
                                                    colors: [
                                                      Color(0xFFFF6B9D),
                                                      Color(0xFFFF8FA3),
                                                    ],
                                                  ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: _loading
                                                ? const SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.check_circle_rounded,
                                                        size: 24,
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        'CREAR CUENTA',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w900,
                                                          letterSpacing: 1.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Link para volver
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2A2A3E),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '¿Ya tienes cuenta?',
                                  style: TextStyle(
                                    color: Color(0xFF808080),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _loading
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: const Text(
                                    'INICIAR SESIÓN',
                                    style: TextStyle(
                                      color: Color(0xFFFF6B9D),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF808080),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF606060)),
        prefixIcon: Icon(icon, color: const Color(0xFFFF6B9D)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0F0F1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF2A2A3E),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFF6B9D),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFF5252),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFF5252),
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFFF5252),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildRolOption({
    required int value,
    required String label,
    required IconData icon,
    required String description,
  }) {
    final isSelected = _rol == value;
    
    return GestureDetector(
      onTap: () => setState(() => _rol = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF6B9D).withOpacity(0.1)
              : const Color(0xFF0F0F1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF6B9D)
                : const Color(0xFF2A2A3E),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFFF8FA3)],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF606060),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF6B9D) : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFFF6B9D).withOpacity(0.7)
                    : const Color(0xFF606060),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}