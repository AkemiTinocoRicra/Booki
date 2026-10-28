import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/estudiante_form_viewmodel.dart';

class EstudianteFormScreen extends StatefulWidget {
  const EstudianteFormScreen({super.key});

  @override
  State<EstudianteFormScreen> createState() => _EstudianteFormScreenState();
}

class _EstudianteFormScreenState extends State<EstudianteFormScreen> {
  final _dniController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _fechaNacimiento;
  int? _idGrado;
  String _estado = 'AC';
  bool _datosCargados = false;

  @override
  void dispose() {
    _dniController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _rellenar(EstudianteFormViewModel vm) {
    if (_datosCargados || vm.estudiante == null) return;
    final e = vm.estudiante!;
    _dniController.text = e.dni;
    _nombresController.text = e.nombres;
    _apellidosController.text = e.apellidos;
    _estado = e.estado;
    _idGrado = e.idGrado;
    if (e.fechaNacimiento != null && e.fechaNacimiento!.length >= 10) {
      _fechaNacimiento = DateTime.tryParse(e.fechaNacimiento!.substring(0, 10));
    }
    _datosCargados = true;
  }

  String? _validarRequerido(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Este campo es obligatorio';
    return null;
  }

  String? _validarDni(String? valor) {
    if (!EstudianteFormViewModel.dniValido(valor?.trim() ?? '')) {
      return 'El DNI debe tener 8 dígitos';
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

  Future<void> _guardar(EstudianteFormViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    if (_idGrado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona tu grado')),
      );
      return;
    }

    final exito = await vm.guardar(
      dni: _dniController.text.trim(),
      nombres: _nombresController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      fechaNacimiento:
          _fechaNacimiento == null ? null : _fechaIso(_fechaNacimiento!),
      contrasena: _contrasenaController.text.trim(),
      idGrado: _idGrado!,
      estado: vm.esEdicion ? _estado : null,
    );

    if (!mounted) return;
    if (exito) {
      Navigator.pop(context, true);
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EstudianteFormViewModel>();
    final idArg = ModalRoute.of(context)?.settings.arguments;
    if (idArg is int && vm.uiState == UiState.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) vm.cargar(idArg);
      });
    }

    if (vm.esEdicion) _rellenar(vm);

    final cargandoDatosIniciales = idArg is int &&
        vm.uiState == UiState.loading &&
        vm.estudiante == null &&
        !_datosCargados;

    return Scaffold(
      appBar: AppBar(
        title: Text(vm.esEdicion ? 'Editar estudiante' : 'Nuevo estudiante'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: cargandoDatosIniciales
                  ? const Center(child: CircularProgressIndicator())
                  : _formulario(context, vm),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context, EstudianteFormViewModel vm) {
    final cargando = vm.uiState == UiState.loading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('DNI *', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _dniController,
            enabled: !cargando && !vm.esEdicion,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: const InputDecoration(
              hintText: '8 dígitos',
              counterText: '',
            ),
            validator: _validarDni,
          ),
          const SizedBox(height: 16),
          Text('Nombres *', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nombresController,
            enabled: !cargando,
            decoration: const InputDecoration(hintText: 'Nombres'),
            validator: _validarRequerido,
          ),
          const SizedBox(height: 16),
          Text('Apellidos *', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _apellidosController,
            enabled: !cargando,
            decoration: const InputDecoration(hintText: 'Apellidos'),
            validator: _validarRequerido,
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
            validator: (valor) => valor == null ? 'Selecciona tu grado' : null,
          ),
          const SizedBox(height: 16),
          Text(
            vm.esEdicion ? 'Contraseña (vacío = no cambiar)' : 'Contraseña *',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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
            validator: (valor) {
              if (vm.esEdicion) return null;
              if (!EstudianteFormViewModel.contrasenaValida(valor?.trim() ?? '')) {
                return 'La contraseña debe tener 4 dígitos';
              }
              return null;
            },
          ),
          if (vm.esEdicion) ...[
            const SizedBox(height: 16),
            Text('Estado', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'AC', label: Text('Activo')),
                ButtonSegment(value: 'IN', label: Text('Inactivo')),
              ],
              selected: {_estado},
              onSelectionChanged: cargando
                  ? null
                  : (seleccion) => setState(() => _estado = seleccion.first),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: cargando ? null : () => _guardar(vm),
              child: cargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
