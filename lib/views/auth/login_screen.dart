import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _dniController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _dniController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _intentarLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthViewModel>().login(
          dni: _dniController.text.trim(),
          contrasena: _contrasenaController.text.trim(),
        );
  }

  String? _validarDni(String? valor) {
    final dni = valor?.trim() ?? '';
    if (!AuthViewModel.dniValido(dni)) return 'El DNI debe tener 8 dígitos';
    return null;
  }

  String? _validarContrasena(String? valor) {
    final contrasena = valor?.trim() ?? '';
    if (!AuthViewModel.contrasenaValida(contrasena)) {
      return 'La contraseña debe tener 4 dígitos';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    if (vm.uiState == UiState.success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      });
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.menu_book, size: 64, color: colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(
                      'Booki',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Iniciar sesión',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 32),
                    Text('DNI', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dniController,
                      enabled: vm.uiState != UiState.loading,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      decoration: const InputDecoration(
                        hintText: '8 dígitos',
                        counterText: '',
                      ),
                      validator: _validarDni,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Contraseña',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contrasenaController,
                      enabled: vm.uiState != UiState.loading,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '••••',
                        counterText: '',
                      ),
                      validator: _validarContrasena,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: vm.uiState == UiState.loading
                            ? null
                            : _intentarLogin,
                        child: vm.uiState == UiState.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Iniciar sesión'),
                      ),
                    ),
                    if (vm.uiState == UiState.error && vm.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            vm.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: vm.uiState == UiState.loading
                              ? null
                              : () => Navigator.pushNamed(context, '/registro'),
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
    );
  }
}
