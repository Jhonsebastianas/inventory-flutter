import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Importa provider
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/product_provider.dart'; // Importa tu ProductProvider
import 'services/api_service.dart'; // Asegúrate de importar ApiService

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Esta función verifica si el usuario está logueado.
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Crear instancia de ApiService
    final ApiService apiService = ApiService();

    return MultiProvider(
      providers: [
        // Pasar la instancia de ApiService al ProductProvider
        ChangeNotifierProvider(create: (_) => ProductProvider(apiService)),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: FutureBuilder<bool>(
          future: _checkLoginStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data == true) {
              // Si el usuario está logueado, lo redirigimos a la pantalla principal
              return HomeScreen();
            } else {
              // Si no está logueado, lo redirigimos a la pantalla de login
              return LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
