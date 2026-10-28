import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/estudiante_form_viewmodel.dart';
import '../viewmodels/estudiantes_viewmodel.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/registro_screen.dart';
import '../views/estudiantes/estudiante_form_screen.dart';
import '../views/estudiantes/estudiantes_list_screen.dart';
import '../views/home/home_screen.dart';

Route<dynamic>? generarRuta(RouteSettings settings) {
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case '/registro':
      return MaterialPageRoute(builder: (_) => const RegistroScreen());
    case '/home':
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case '/estudiantes':
      return MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => EstudiantesViewModel(),
          child: const EstudiantesListScreen(),
        ),
      );
    case '/estudiantes/form':
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => ChangeNotifierProvider(
          create: (_) => EstudianteFormViewModel(),
          child: const EstudianteFormScreen(),
        ),
      );
    default:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
  }
}
