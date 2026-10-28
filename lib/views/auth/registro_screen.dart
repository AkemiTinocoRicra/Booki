import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _dniController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _fechaNacimiento;
  int? _idGrado;

  @override
  void dispose() {
    _dniController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  String? _validarRequerido(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Este campo es obligatorio';
    return null;
  }

  String? _validarDni(String? valor) {
    if (!AuthViewModel.dniValido(valor?.trim() ?? '')) {
      return 'El DNI debe tener 8 dígitos';
    }
    return null;
  }

  String? _validarContrasena(String? valor) {
    if (!AuthViewModel.contrasenaValida(valor?.trim() ?? '')) {
      return 'La contraseña debe tener 4 dígitos';
    }
    return null;
  }

  String? _validarConfirmacion(String? valor) {
    if (valor != _contrasenaController.text.trim()) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final seleccion = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2012),
      firstDate: DateTime(hoy.year - 20),
      lastDate: hoy,
    );
    if (seleccion != null) setState(() => _fechaNacimiento = seleccion);
  }

  String _formatearFecha(DateTime fecha) {
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    return '$d/$m/${fecha.year}';
  }

  String _fechaIso(DateTime fecha) {
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '${fecha.year}-$m-$d';
  }

  void _intentarRegistro() {
    if (!_formKey.currentState!.validate()) return;
    if (_idGrado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona tu grado')),
      );
      return;
    }
    context.read<AuthViewModel>().register(
          dni: _dniController.text.trim(),
          nombres: _nombresController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          fechaNacimiento:
              _fechaNacimiento == null ? null : _fechaIso(_fechaNacimiento!),
          contrasena: _contrasenaController.text.trim(),
          confirmarContrasena: _confirmarController.text.trim(),
          idGrado: _idGrado!,
        );
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
    final cargando = vm.uiState == UiState.loading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: cargando ? null : () => Navigator.pop(context),
        ),
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('DNI *', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dniController,
                      enabled: !cargando,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      decoration: const InputDecoration(
                        hintText: '8 dígitos',
                        counterText: '',
                      ),
                      validator: _validarDni,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nombres *',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nombresController,
                                enabled: !cargando,
                                decoration:
                                    const InputDecoration(hintText: 'Nombres'),
                                validator: _validarRequerido,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Apellidos *',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _apellidosController,
                                enabled: !cargando,
                                decoration:
                                    const InputDecoration(hintText: 'Apellidos'),
                                validator: _validarRequerido,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Fecha de nacimiento',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: cargando ? null : _seleccionarFecha,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          hintText: 'dd/mm/aaaa',
                          suffixIcon: const Icon(Icons.calendar_today),
                          enabled: !cargando,
                        ),
                        child: Text(
                          _fechaNacimiento == null
                              ? 'dd/mm/aaaa'
                              : _formatearFecha(_fechaNacimiento!),
                          style: _fechaNacimiento == null
                              ? Theme.of(context).textTheme.bodyMedium
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Grado *', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _idGrado,
                      hint: const Text('Selecciona tu grado'),
                      items: List.generate(6, (i) {
                        final grado = i + 1;
                        return DropdownMenuItem(
                          value: grado,
                          child: Text('$grado°'),
                        );
                      }),
                      onChanged: cargando
                          ? null
                          : (valor) => setState(() => _idGrado = valor),
                      validator: (valor) =>
                          valor == null ? 'Selecciona tu grado' : null,
                    ),
                    const SizedBox(height: 16),
                    Text('Contraseña *',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contrasenaController,
                      enabled: !cargando,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '••••',
                        counterText: '',
                      ),
                      validator: _validarContrasena,
                    ),
                    const SizedBox(height: 16),
                    Text('Confirmar contraseña *',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmarController,
                      enabled: !cargando,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '••••',
                        counterText: '',
                      ),
                      validator: _validarConfirmacion,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: cargando ? null : _intentarRegistro,
                        child: cargando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Crear cuenta'),
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
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: cargando
                              ? null
                              : () => Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  ),
                          child: const Text('Iniciar sesión'),
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
