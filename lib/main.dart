import 'package:flutter/material.dart';
import 'package:hola_mundo/core/themes/app_theme.dart';
import 'package:hola_mundo/routes/app_routes.dart';
import 'package:provider/provider.dart'; // Importa provider
import 'shared/providers/product_provider.dart'; // Importa tu ProductProvider
import 'shared/services/api_service.dart'; // Asegúrate de importar ApiService

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider(ApiService())),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.lightTheme,
        initialRoute: '/', // Establece la ruta raíz
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
