import 'package:flutter/material.dart';
import 'package:hola_mundo/core/screens/error_404_screen.dart';
import 'package:hola_mundo/modules/account/screens/account_settings_screen.dart';
import 'package:hola_mundo/modules/auth/screens/login_screen.dart';
import 'package:hola_mundo/modules/products/screens/product_form_screen.dart';
import 'package:hola_mundo/modules/products/screens/product_list_screen.dart';
import 'package:hola_mundo/modules/sales/screens/sale_detail_screen.dart';
import 'package:hola_mundo/modules/sales/screens/sales_list_screen.dart';
import 'package:hola_mundo/modules/sales/screens/sales_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/home/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String accountSettings = '/settings';
  static const String login = '/login';
  static const String products = '/products';
  static const String productRegister = '/products/register';
  static const String sales = '/sales';
  static const String saleDetail = '/sales/detail';
  static const String salesHistory = '/sales/history';

  // Función para validar el estado del login
  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static onTabChangeRoute(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        // Redirige en base al estado del login
        return MaterialPageRoute(
          builder: (context) {
            return FutureBuilder<bool>(
              future: checkLoginStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == true) {
                    return HomeScreen(); // Redirige a Home si está logueado
                  } else {
                    return LoginScreen(); // Redirige a Login si no está logueado
                  }
                }
                // Muestra un indicador de carga mientras se resuelve la validación
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            );
          },
        );
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case accountSettings:
        return MaterialPageRoute(builder: (_) => const AccountSettingsScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case productRegister:
        return MaterialPageRoute(builder: (_) => const ProductFormScreen());
      case products:
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
      case sales:
        return MaterialPageRoute(builder: (_) => SalesScreen());
      case salesHistory:
        return MaterialPageRoute(builder: (_) => SalesListScreen());
      case saleDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SaleDetailScreen(
            idSale: args['idSale'],
            isRecent: args['isRecent'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Error404Screen(),
        );
    }
  }
}
