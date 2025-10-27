import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user/user_register_dto.dart';

/// Pantalla de registro basada en tu backend
/// POST /api/auth/register  Body: { nombre, password, rol }
/// Respuesta esperada: { id, nombre, rol }
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
  int _rol = 1; // 1=Usuario, 2=Empresa, 3=Administrador
  bool _loading = false;
  String? _error;

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
        const SnackBar(
          content: Text('Cuenta creada con éxito. Inicia sesión.'),
        ),
      );
      Navigator.pop(context); // volver a Login
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
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Completa tus datos',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_error != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
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

                      TextFormField(
                        controller: _nombreCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de usuario',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Ingresa un nombre';
                          if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Ingresa una contraseña';
                          if (v.length < 4) return 'Mínimo 4 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _password2Ctrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Repite contraseña',
                          prefixIcon: Icon(Icons.lock_reset_rounded),
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Repite la contraseña';
                          if (v != _passwordCtrl.text)
                            return 'Las contraseñas no coinciden';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _rol,
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text('Usuario'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('Empresa'),
                              ),

                            ],
                            onChanged: (v) => setState(() => _rol = v ?? 1),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Crear cuenta'),
                        ),
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
