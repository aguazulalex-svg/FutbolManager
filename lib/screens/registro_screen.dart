import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _cargando = false;
  bool _mostrarContrasena = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final credencial = await _authService.registrarConCorreo(
        email: _correoController.text,
        password: _contrasenaController.text,
      );

      final nombre = _nombreController.text.trim();

      // Guardar el nombre en el perfil de Firebase Authentication.
      await credencial.user?.updateDisplayName(nombre);

      if (!mounted) return;

      Navigator.of(
        context,
      ).pop(); // Cerrar el diálogo de carga si está abierto.

      // Firebase detectará la sesión y main.dart abrirá la aplicación.
    } on FirebaseAuthException catch (e) {
      String mensaje;

      switch (e.code) {
        case 'email-already-in-use':
          mensaje = 'Este correo ya tiene una cuenta registrada.';
          break;
        case 'invalid-email':
          mensaje = 'El correo electrónico no es válido.';
          break;
        case 'weak-password':
          mensaje = 'La contraseña es demasiado débil.';
          break;
        case 'network-request-failed':
          mensaje = 'Revisa tu conexión a internet.';
          break;
        default:
          mensaje = e.message ?? 'No se pudo crear la cuenta.';
      }

      if (mounted) {
        setState(() {
          _error = mensaje;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Ocurrió un error al registrarte: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  InputDecoration _decoracion(String etiqueta, IconData icono) {
    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: Icon(icono),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: const Color(0xFF146B3A),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    size: 70,
                    color: Color(0xFF146B3A),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Únete a FutbolManager',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF146B3A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea tu cuenta para administrar tu torneo.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  TextFormField(
                    controller: _nombreController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _decoracion('Nombre completo', Icons.person),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Ingresa tu nombre.';
                      }

                      if (valor.trim().length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: _decoracion('Correo electrónico', Icons.email),
                    validator: (valor) {
                      final correo = valor?.trim() ?? '';

                      if (correo.isEmpty) {
                        return 'Ingresa tu correo electrónico.';
                      }

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(correo)) {
                        return 'Ingresa un correo válido.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: !_mostrarContrasena,
                    decoration: _decoracion('Contraseña', Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _mostrarContrasena = !_mostrarContrasena;
                          });
                        },
                        icon: Icon(
                          _mostrarContrasena
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Crea una contraseña.';
                      }

                      if (valor.length < 6) {
                        return 'Usa al menos 6 caracteres.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _confirmarController,
                    obscureText: !_mostrarContrasena,
                    decoration: _decoracion(
                      'Confirmar contraseña',
                      Icons.lock_outline,
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Confirma tu contraseña.';
                      }

                      if (valor != _contrasenaController.text) {
                        return 'Las contraseñas no coinciden.';
                      }

                      return null;
                    },
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _registrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF146B3A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _cargando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Crear cuenta',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
