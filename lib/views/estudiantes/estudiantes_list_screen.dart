import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/estudiante.dart';
import '../../viewmodels/estudiantes_viewmodel.dart';

class EstudiantesListScreen extends StatefulWidget {
  const EstudiantesListScreen({super.key});

  @override
  State<EstudiantesListScreen> createState() => _EstudiantesListScreenState();
}

class _EstudiantesListScreenState extends State<EstudiantesListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EstudiantesViewModel>().load();
  }

  Future<void> _confirmarYEliminar(Estudiante estudiante) async {
    final vm = context.read<EstudiantesViewModel>();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar estudiante'),
        content: Text(
          '¿Eliminar a ${estudiante.nombreCompleto}? '
          'Quedará inactivo (no podrá iniciar sesión).',
        ),
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

    if (confirmado != true || !mounted) return;
    final exito = await vm.eliminar(estudiante);
    if (!mounted) return;
    final mensaje = exito ? vm.mensajeExito : vm.errorMessage;
    if (mensaje != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  Future<void> _abrirFormulario({int? id}) async {
    await Navigator.pushNamed(
      context,
      '/estudiantes/form',
      arguments: id,
    );
    if (mounted) context.read<EstudiantesViewModel>().load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EstudiantesViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Estudiantes')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo estudiante',
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: _cuerpo(context, vm),
    );
  }

  Widget _cuerpo(BuildContext context, EstudiantesViewModel vm) {
    if (vm.uiState == UiState.loading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.uiState == UiState.error && vm.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vm.errorMessage ?? 'Error',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => vm.load(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.items.isEmpty) {
      return const Center(child: Text('No hay estudiantes registrados'));
    }

    return RefreshIndicator(
      onRefresh: vm.load,
      child: ListView.builder(
        itemCount: vm.items.length,
        itemBuilder: (context, i) {
          final e = vm.items[i];
          return ListTile(
            title: Text(e.nombreCompleto),
            subtitle: Text('DNI ${e.dni} · ${e.idGrado}°'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(e.activo ? 'Activo' : 'Inactivo'),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar',
                  onPressed: () => _confirmarYEliminar(e),
                ),
              ],
            ),
            onTap: () => _abrirFormulario(id: e.idEstudiante),
          );
        },
      ),
    );
  }
}
