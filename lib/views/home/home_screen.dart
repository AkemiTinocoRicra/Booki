import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booki'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await vm.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Bienvenido a Booki',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (vm.dni != null) ...[
                const SizedBox(height: 8),
                Text('DNI: ${vm.dni}', style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: 280,
                height: 48,
                child: FilledButton.icon(
                  icon: const Icon(Icons.people),
                  label: const Text('Gestionar estudiantes'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/estudiantes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
