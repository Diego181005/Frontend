import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user/user_login_dto.dart';
import 'register_screen.dart';
import 'home_usuario_screen.dart';
import 'home_empresa_screen.dart';
import 'home_administrador_screen.dart';

/// Pantalla de Login bonita y lista para conectar con tu ApiService.
///
/// - Llama a ApiService().login(UserLoginDto(...))
/// - Muestra loaders y errores
/// - Tiene mostrar/ocultar contraseña
/// - Si [onLoginSuccess] no es null, se llama con el token/rol; de lo contrario muestra un SnackBar.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess});

  final void Function({
    required String nombre,
    required String rol,
    required String token,
  })?
  onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dto = UserLoginDto(
        nombre: _nombreCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      final tokenDto = await ApiService().login(dto);

      if (!mounted) return;

      // ✅ Navegar según el rol del usuario
      if (tokenDto.rol.toLowerCase() == '1') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeUsuarioScreen(nombre: tokenDto.nombre),
          ),
        );
      } else {
        if (tokenDto.rol.toLowerCase() == '2') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeEmpresaScreen(
                nombre: tokenDto.nombre,
                empresaId: tokenDto.id, // viene del tokenDto
                rol: tokenDto.rol,
              ),
            ),
          );
        } else if (tokenDto.rol.toLowerCase() == '3') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeAdminScreen(nombre: tokenDto.nombre),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        color: theme
            .colorScheme
            .surface, // Estética más empresarial (fondo limpio)
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Encabezado más sobrio/empresarial
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.shield_rounded,
                              size: 28,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Portal de Acceso',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Autenticación segura',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      if (_error != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Formulario
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nombreCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                hintText: 'Ej: juan',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Ingresa tu usuario';
                                if (v.trim().length < 3)
                                  return 'Mínimo 3 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                filled: true,
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Ingresa tu contraseña';
                                if (v.length < 4) return 'Mínimo 4 caracteres';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Botón de acceso
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Ingresar'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta?',
                            style: theme.textTheme.bodySmall,
                          ),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () {
                                    // Navega a RegisterScreen (que crearás)
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                            child: const Text('Crear cuenta'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Import al final para evitar problemas de orden durante la edición
