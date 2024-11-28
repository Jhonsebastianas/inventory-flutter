import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hola_mundo/core/themes/app_theme.dart';
import 'package:hola_mundo/routes/app_routes.dart';
import 'package:provider/provider.dart'; // Importa provider
import 'shared/providers/product_provider.dart'; // Importa tu ProductProvider
import 'shared/services/api_service.dart'; // Asegúrate de importar ApiService
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('es'), Locale('en')],
      path: 'assets/translations', // Ruta a tus archivos de traducción
      fallbackLocale: const Locale('es'),
      child: const MyApp(),
    ),
  );
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
        localizationsDelegates: context.localizationDelegates, // Usa context
        supportedLocales: context.supportedLocales,
        title: 'Flutter Demo',
        theme: AppTheme.lightTheme,
        initialRoute: '/', // Establece la ruta raíz
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
