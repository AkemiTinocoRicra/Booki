import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import 'router.dart';

class BookiApp extends StatefulWidget {
  const BookiApp({super.key});

  @override
  State<BookiApp> createState() => _BookiAppState();
}

class _BookiAppState extends State<BookiApp> {
  final AuthViewModel _authViewModel = AuthViewModel();
  bool _listo = false;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    await _authViewModel.restoreSession();
    if (mounted) setState(() => _listo = true);
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_listo) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return ChangeNotifierProvider<AuthViewModel>.value(
      value: _authViewModel,
      child: MaterialApp(
        title: 'Booki',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        onGenerateRoute: generarRuta,
        initialRoute:
            _authViewModel.isAuthenticated ? '/home' : '/login',
      ),
    );
  }
}
